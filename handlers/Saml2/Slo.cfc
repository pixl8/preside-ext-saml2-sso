component {

	property name="samlRequestParser"   inject="samlRequestParser";
	property name="samlResponseParser"  inject="samlResponseParser";
	property name="samlResponseBuilder" inject="samlResponseBuilder";
	property name="samlRequestBuilder"  inject="samlRequestBuilder";
	property name="samlEntityPool"      inject="samlEntityPool";
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

		var isResponse = StructKeyExists( rc, "samlResponse" );

		if ( isResponse ) {
			_processSloResponse( argumentCollection=arguments );
		} else {
			_respondToSloRequest( argumentCollection=arguments );
		}
	}

	/**
	 * /saml2/slo/sprequest/
	 *
	 * Initiates an SLO request to a Service Provider from this IdP.
	 * In our current implementation, this will be triggered from an embedded iframe
	 * in the logout page
	 */
	public any function sprequest( event, rc, prc ) {
		var samlSessionId = rc.sid ?: "";
		var sessionDetail = samlSessionService.getSessionDetail( samlSessionId );
		var sessionIndex  = sessionDetail.sessionIndex ?: "";

		if ( !Len( sessionIndex ) ) {
			event.notFound();
		}

		var ssoReqs          = sessionDetail.issuerMetadata.getServiceProviderSSORequirements();
		var redirectLocation = ssoReqs.logoutService.location ?: "";
		var binding          = ssoReqs.logoutService.binding ?: "";
		if ( isEmptyString( ssoReqs.logoutService.location ?: "" ) ) {
			event.notFound();
		}

		var samlSpLogoutRequest = samlRequestBuilder.buildLogoutRequest(
			  issuer       = getSystemSetting( "saml2Provider", "sso_endpoint_root", event.getSiteUrl() )
			, sloEndpoint  = redirectLocation
			, nameIdValue  = sessionDetail.nameId
			, sessionIndex = sessionDetail.sessionIndex
			, requestId    = samlSessionId
		);

		if ( binding contains "POST" ) {
			event.setXFrameOptionsHeader( "sameorigin" );
			// POST BINDING, javascript form to post request to redirect location
			return renderView( view="/saml2/ssoRequestForm", args={
				  samlRequest      = samlSpLogoutRequest
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

	/**
	 * /saml2/slo/idpresponse/
	 *
	 * Initiates a response to an SP logout request
	 * In our current implementation, this will be triggered from an embedded iframe
	 * in the logout page
	 */
	public any function spresponse( event, rc, prc ) {
		var issuerId       = rc.issuer ?: "";
		var inResponseTo   = rc.inResponseTo ?: ""
		var spIssuer       = samlEntityPool.getEntityById( issuerId );
		var logoutEndpoint = spIssuer.serviceProviderSsoRequirements.logoutService.location ?: "";
		var logoutBinding  = spIssuer.serviceProviderSsoRequirements.logoutService.binding ?: "";

		if ( isEmptyString( logoutEndpoint ) || isEmptyString( inResponseTo ) ) {
			event.notFound();
		}

		var logoutResponse = buildLogoutResponse(
			  issuer       = getSystemSetting( "saml2Provider", "sso_endpoint_root", event.getSiteUrl() )
			, inResponseTo = inResponseTo
			, destination  = logoutEndpoint
		);

		if ( logoutBinding contains "POST" ) {
			// POST BINDING, javascript form to post request to redirect location
			event.setXFrameOptionsHeader( "sameorigin" );

			return renderView( view="/saml2/ssoRequestForm", args={
				  samlResponse     = logoutResponse
				, redirectLocation = logoutEndpoint
				, serviceName	   = ( spIssuer.consumerRecord.name ?: "" )
				, noRelayState     = true
			} );
		} else {
			// REDIRECT BINDING, zip up xml to send in URL
			var qs    = "samlRequest=" & deflateEncoder.encode( logoutResponse );
			var delim = Find( logoutEndpoint, "?" ) ? "&" : "?";

			setNextEvent( url=( logoutEndpoint & delim & qs ) );
		}
	}

// PAGE TYPE VIEWLET
	private string function logoutPage( event, rc, prc, args={} ) {
		var nameId       = rc.nameId       ?: "";
		var spIssuerId   = rc.spIssuerId   ?: "";
		var sessionIndex = rc.sessionIndex ?: "";
		var requestId    = rc.requestId    ?: "";
		var userId       = rc.userId       ?: samlSessionService.getUserIdFromNameId( nameId, spIssuerId );

		if ( !isEmptyString( userId ) && !isEmptyString( sessionIndex ) ) {
			var sessionsToLogout = samlSessionService.getSessions( userId, sessionIndex );

			// URL for a logout response to original
			// SP requester
			if ( Len( Trim( requestId ) ) ) {
				args.spResponseUrl = event.buildLink(
					  linkto      = "saml2.slo.spresponse"
					, queryString = "issuer=#spIssuerId#&inResponseTo=#requestId#"
				);
			}

			// URLs for additional SPs to request logout from
			args.spRequestUrls = [];
			for( var s in sessionsToLogout ) {
				ArrayAppend( args.spRequestUrls, event.buildLink(
					  linkto      = "saml2.slo.sprequest"
					, queryString = "sid=#s#"
				) );
			}

			samlSessionService.invalidateSession();
		}

		return renderView(
			  view          = "/page-types/saml_slo_page/index"
			, presideObject = "saml_slo_page"
			, id            = event.getCurrentPageId()
			, args          = args
		);
	}

// HELPERS
	private void function _respondToSloRequest( event, rc, prc ) {
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

		// 4. Clear SPs recorded session
		var sessionIndex = samlRequest.samlRequest.sessionIndex ?: "";
		if ( isEmptyString( sessionIndex ) ) {
			sessionIndex = samlSessionService.getSessionId();
		}
		samlSessionService.removeSessionByIssuerAndIndex( samlRequest.issuerEntity.id, sessionIndex )

		// 5. Redirect to logged out page (with variables to help output iframes to do followout logout requests with SPs)
		setNextEvent( url=event.buildLink( page="saml_slo_page" ), persistStruct={
			  nameId       = samlRequest.samlRequest.nameId ?: ""
			, requestId    = samlRequest.samlRequest.id ?: ""
			, spIssuerId   = samlRequest.issuerEntity.id
			, sessionIndex = sessionIndex
		} );
	}

	private void function _processSloResponse() {
		// 1. Parse the response, check it is generally valid
		try {
			var samlResponse      = samlResponseParser.parse();
			var totallyBadRequest = !IsStruct( samlResponse ) || samlResponse.keyExists( "error" ) ||  !( samlResponse.samlResponse.type ?: "" ).len() || !samlResponse.keyExists( "issuerentity" ) || samlResponse.issuerEntity.isEmpty();
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

		// 2. Remove the session that this logout request is a response to
		samlSessionService.removeSessionById(
			sessionId = ( samlResponse.samlResponse.inResponseTo ?: "" )
		);

		// 3. For now, we're just going to redirect to logged out page.
		// nothing more for us to do here (although we could fire off a number
		// of hooks, etc. and do a load of helpful things... another time)
		setNextEvent( url=event.buildLink( page="saml_slo_page" ) );
	}
}