component {

	property name="samlRequestParser"            inject="samlRequestParser";
	property name="samlAttributesService"        inject="samlAttributesService";
	property name="samlResponseBuilder"          inject="samlResponseBuilder";
	property name="samlSsoWorkflowService"       inject="samlSsoWorkflowService";
	property name="samlEntityPool"               inject="samlEntityPool";
	property name="rulesEngineWebRequestService" inject="rulesEngineWebRequestService";
	property name="authCheckHandler"             inject="coldbox:setting:saml2.authCheckHandler";


	public string function sso( event, rc, prc ) {
		try {
			var samlRequest       = samlRequestParser.parse();
			var totallyBadRequest = !IsStruct( samlRequest ) || samlRequest.keyExists( "error" ) ||  !( samlRequest.samlRequest.type ?: "" ).len() || !samlRequest.keyExists( "issuerentity" ) || samlRequest.issuerEntity.isEmpty();
		} catch( any e ) {
			logError( e );
			totallyBadRequest = true;
		}

		if ( totallyBadRequest ) {
			event.setHTTPHeader( statusCode="400" );
			event.setHTTPHeader( name="X-Robots-Tag", value="noindex" );
			event.initializePresideSiteteePage( systemPage="samlSsoBadRequest" );

			rc.body = renderView(
				  view          = "/page-types/samlSsoBadRequest/index"
				, presideobject = "samlSsoBadRequest"
				, id            = event.getCurrentPageId()
				, args          = {}
			);

			event.setView( "/core/simpleBodyRenderer" );
			return;
		}

		var redirectLocation   = samlRequest.issuerEntity.serviceProviderSsoRequirements.defaultAssertionConsumer.location ?: "";
		var isWrongRequestType = samlRequest.samlRequest.type != "AuthnRequest";
		var samlResponse       = "";

		if ( isWrongRequestType ) {
			samlResponse = samlResponseBuilder.buildErrorResponse(
				  statusCode          = "urn:oasis:names:tc:SAML:2.0:status:Responder"
				, subStatusCode       = "urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported"
				, statusMessage       = "Operation unsupported"
				, issuer              = samlRequest.samlRequest.issuer
				, inResponseTo        = samlRequest.samlRequest.id
				, recipientUrl        = redirectLocation
			);
		} else {
			runEvent(
					event          = authCheckHandler // default, saml2.authenticationCheck (below)
				  , eventArguments = { samlRequest = samlRequest }
				  , private        = true
				  , prePostExempt  = true
			);

			var attributeConfig = _getAttributeConfig( samlRequest.issuerEntity.consumerRecord );

			samlResponse = samlResponseBuilder.buildAuthenticationAssertion(
				  issuer          = getSystemSetting( "saml2Provider", "sso_endpoint_root", event.getSiteUrl() ) & "/saml2/sso/"
				, inResponseTo    = samlRequest.samlRequest.id
				, recipientUrl    = redirectLocation
				, nameIdFormat    = "urn:oasis:names:tc:SAML:2.0:nameid-format:#attributeConfig.idFormat#"
				, nameIdValue     = attributeConfig.idValue
				, audience        = samlRequest.issuerEntity.id
				, sessionTimeout  = 40
				, sessionIndex    = session.sessionid
				, attributes      = attributeConfig.attributes
			);
		}

		samlSsoWorkflowService.completeWorkflow();

		return renderView( view="/saml2/ssoResponseForm", args={
			  samlResponse     = samlResponse
			, samlRelayState   = samlRequest.relayState ?: ""
			, redirectLocation = redirectLocation
			, serviceName	   = ( samlRequest.issuerEntity.consumerRecord.name ?: "" )
		} );
	}

	public any function idpsso( event, rc, prc ) {
		var slug              = rc.providerSlug ?: "";
		var totallyBadRequest = !slug.len() > 0;

		if ( slug.len() ) {
			try {
				var entity = samlEntityPool.getEntityBySlug( slug );
				var totallyBadRequest = entity.isEmpty() || ( entity.consumerRecord.sso_type ?: "" ) != "idp";
			} catch( any e ) {
				logError( e );
				totallyBadRequest = true;
			}
		}

		if ( totallyBadRequest ) {
			event.setHTTPHeader( statusCode="400" );
			event.setHTTPHeader( name="X-Robots-Tag", value="noindex" );
			event.initializePresideSiteteePage( systemPage="samlSsoBadRequest" );

			rc.body = renderView(
				  view          = "/page-types/samlSsoBadRequest/index"
				, presideobject = "samlSsoBadRequest"
				, id            = event.getCurrentPageId()
				, args          = {}
			);

			event.setView( "/core/simpleBodyRenderer" );
			return;
		}

		var redirectLocation = entity.serviceProviderSsoRequirements.defaultAssertionConsumer.location ?: "";

		runEvent(
				event          = authCheckHandler // default, saml2.authenticationCheck (below)
			  , eventArguments = { samlRequest = { issuerEntity=entity } }
			  , private        = true
			  , prePostExempt  = true
		);

		var attributeConfig = _getAttributeConfig( entity.consumerRecord );

		samlResponse = samlResponseBuilder.buildAuthenticationAssertion(
			  issuer          = event.getSiteUrl( includePath=false, includeLanguageSlug=false ).reReplace( "/$", "" ) & "/saml2/idpsso/#slug#/"
			, inResponseTo    = ""
			, recipientUrl    = redirectLocation
			, nameIdFormat    = "urn:oasis:names:tc:SAML:2.0:nameid-format:#attributeConfig.idFormat#"
			, nameIdValue     = attributeConfig.idValue
			, audience        = entity.id
			, sessionTimeout  = 40
			, sessionIndex    = session.sessionid
			, attributes      = attributeConfig.attributes
		);

		return renderView( view="/saml2/ssoResponseForm", args={
			  samlResponse     = samlResponse
			, redirectLocation = redirectLocation
			, serviceName	   = ( entity.consumerRecord.name ?: "" )
			, noRelayState     = true
		} );
	}

	private void function authenticationCheck( event, rc, prc, samlRequest={} ) {
		if ( !isLoggedIn() ) {
			setNextEvent( url=event.buildLink( page="login" ), persistStruct={
				  samlRequest     = samlRequest
				, ssoLoginMessage = ( samlRequest.issuerEntity.consumerRecord.login_message ?: "" )
				, postLoginUrl    = event.getBaseUrl() & event.getCurrentUrl()
			} );
		}

		if ( isFeatureEnabled( "rulesengine" ) ) {
			var rulesEngineCondition = samlRequest.issuerEntity.consumerRecord.access_condition ?: "";

			if ( Len( Trim( rulesEngineCondition ) ) && !rulesEngineWebRequestService.evaluateCondition( rulesEngineCondition ) ) {
				event.accessDenied(
					  reason              = "INSUFFICIENT_PRIVILEGES"
					, accessDeniedMessage = ( samlRequest.issuerEntity.consumerRecord.access_denied_message ?: "" )
				);
			}
		}

		return;
	}

	private struct function retrieveAttributes( event, rc, prc, supportedAttributes={} ) {
		var userDetails = getLoggedInUserDetails();
		var attribs = {};

		return {
			  email       = ( userDetails.email_address ?: "" )
			, displayName = ( userDetails.display_name ?: "" )
			, firstName   = ListFirst( userDetails.display_name ?: "", " " )
			, lastName    = ListRest( userDetails.display_name ?: "", " " )
			, id          = userDetails.id ?: getLoggedInUserId()
		};
	}

// HELPERS
	private struct function _getSamlRequest( event, rc, prc ) {

	}

	private struct function _getAttributeConfig( required struct consumerRecord ) {
		var attributes = samlAttributesService.getAttributeValues();
		var idValue    = attributes[ consumerRecord.id_attribute ?: "" ] ?: getLoggedInUserId();
		var idFormat   = IsTrue( consumerRecord.id_attribute_is_transient ?: "" ) ? "transient" : "persistent";
		var restricted = ( consumerRecord.use_attributes ?: "" ).listToArray();

		if ( restricted.len() ) {
			for( var attributeId in attributes ) {
				if ( !restricted.findNoCase( attributeId ) ) {
					attributes.delete( attributeId );
				}
			}
		}

		return {
			  attributes = attributes
			, idValue    = idValue
			, idFormat   = idFormat
		};
	}
}