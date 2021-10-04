component {

	property name="samlRequestParser"   inject="samlRequestParser";
	property name="samlResponseBuilder" inject="samlResponseBuilder";
	property name="samlRequestBuilder"  inject="samlRequestBuilder";
	property name="deflateEncoder"      inject="httpRedirectRequestDeflateEncoder";
	property name="websiteLoginService" inject="websiteLoginService";
	property name="samlSessionService"  inject="samlSessionService";

	/**
	 *
	 * /saml2/slo/
	 *
	 * Initial request for Single Logout where we are the IdP
	 * for frontend website. This handler is to process both
	 * SP initiated logout _requests_ and also logout _responses_
	 */
	public void function index( event, rc, prc ) {
		if ( !isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			event.notFound();
		}

		// 1. Parse the request, check it is generally valid
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

		// 2. Finer detail validation
		var isWrongRequestType = samlRequest.samlRequest.type != "LogoutRequest";
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

			return renderView( view="/saml2/ssoResponseForm", args={
				  samlResponse     = samlResponse
				, samlRelayState   = samlRequest.relayState ?: ""
				, redirectLocation = redirectLocation
				, serviceName	   = ( samlRequest.issuerEntity.consumerRecord.name ?: "" )
			} );
		}

		// 3. Log current user out
		if ( isLoggedIn() ) {
			websiteLoginService.logout();
		}

		// 4. Get external sessions to logout
		var nameId       = samlRequest.samlRequest.nameId ?: "";
		var userId       = samlSessionService.getUserIdFromNameId( nameId, samleRequest.issuerEntity.id );
		var sessionIndex = samlRequest.samlRequest.sessionIndex ?: "";
		if ( isEmptyString( sessionIndex ) ) {
			sessionIndex = samlSessionService.getSessionId();
		}

		var sessionsToLogout = samlSessionService.getSessions( userId, sessionIndex );

		// TODO: all the things...
		WriteDump( sessionsToLogout ); abort;
	}

	/**
	 * /saml2/slo/sprequest/
	 *
	 * Initiates an SLO request to a Service Provider from this IdP.
	 * In our current implementation, this will be triggered from an embedded iframe
	 * in the logout page
	 */
	public void function sprequest( event, rc, prc ) {
		var samlSessionId = rc.sid ?: "";
		var sessionDetail = samlSessionService.getSessionDetail( samlSessionId );
		var sessionIndex  = sessionDetail.sessionIndex ?: "";

		if ( sessionIndex != samlSessionService.getSessionId() ) {
			event.notFound();
		}

		var ssoReqs          = sessionDetail.issuerMetadata.getServiceProviderSSORequirements();
		var redirectLocation = ssoReqs.logoutService.location ?: "";
		var binding          = ssoReqs.logoutService.binding ?: "";
		if ( isEmptyString( ssoReqs.logoutService.location ?: "" ) ) {
			event.notFound();
		}

		var samlSpLogoutRequest = samlRequestBuilder.buildSloRequest(
			  issuer       = getSystemSetting( "saml2Provider", "sso_endpoint_root", event.getSiteUrl() )
			, sloEndpoint  = redirectLocation
			, nameIdValue  = sessionDetail.nameId
			, sessionIndex = sessionDetail.sessionIndex
		);

		if ( binding contains "POST" ) {
			// POST BINDING, javascript form to post request to redirect location
			return renderView( view="/saml2/ssoRequestForm", args={
				  samlResponse     = samlSpLogoutRequest
				, redirectLocation = redirectLocation
				, serviceName	   = ( samlRequest.issuerEntity.consumerRecord.name ?: "" )
				, noRelayState     = true
			} );
		} else {
			// REDIRECT BINDING, zip up xml to send in URL
			var qs    = "samlRequest=" & deflateEncoder.encode( samlSpLogoutRequest );
			var delim = Find( redirectLocation, "?" ) ? "&" : "?";

			setNextEvent( url=( redirectLocation & delim & qs ) );
		}
	}
}