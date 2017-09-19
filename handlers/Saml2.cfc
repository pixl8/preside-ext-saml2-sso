component {

	property name="samlRequestParser"            inject="samlRequestParser";
	property name="samlAttributesService"        inject="samlAttributesService";
	property name="samlResponseBuilder"          inject="samlResponseBuilder";
	property name="samlSsoWorkflowService"       inject="samlSsoWorkflowService";
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

			samlResponse = samlResponseBuilder.buildAuthenticationAssertion(
				  issuer          = getSystemSetting( "saml2Provider", "sso_endpoint_root", event.getSiteUrl() ) & "/saml2/sso/"
				, inResponseTo    = samlRequest.samlRequest.id
				, recipientUrl    = redirectLocation
				, nameIdFormat    = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
				, nameIdValue     = getLoggedInUserId()
				, audience        = samlRequest.issuerEntity.id
				, sessionTimeout  = 40
				, sessionIndex    = session.sessionid
				, attributes      = samlAttributesService.getAttributeValues()
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

	public void function idpsso( event, rc, prc ) {
		WriteDump( rc.providerSlug ?: "" ); abort;
	}

	private void function authenticationCheck( event, rc, prc, samlRequest={} ) {
		if ( !isLoggedIn() ) {
			setNextEvent( url=event.buildLink( page="login" ), persistStruct={
				  samlRequest     = samlRequest
				, ssoLoginMessage = ( samlRequest.issuerEntity.consumerRecord.login_message ?: "" )
				, postLoginUrl    = event.buildLink( linkTo="saml2.sso" )
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
		};
	}

// HELPERS
	private struct function _getSamlRequest( event, rc, prc ) {

	}
}