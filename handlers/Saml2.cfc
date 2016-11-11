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
			// TODO: something more attractive
			event.renderData( type="plain", data="400: Bad request", statusCode=400 );
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

	private void function authenticationCheck( event, rc, prc, samlRequest={} ) {
		if ( !isLoggedIn() ) {
			setNextEvent( url=event.buildLink( page="login" ), persistStruct={
				  samlRequest     = samlRequest
				, ssoLoginMessage = ( samlRequest.issuerEntity.consumerRecord.login_message ?: "" )
				, postLoginUrl    = event.buildLink( linkTo="saml2.sso" )
			} );
		}

		var rulesEngineCondition = samlRequest.issueEntity.consumerRecord.access_condition ?: "";

		if ( Len( Trim( rulesEngineCondition ) ) && !rulesEngineWebRequestService.evaluateCondition( rulesEngineCondition ) ) {
			WriteDump( 'TODO: access denied message' ); abort;
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