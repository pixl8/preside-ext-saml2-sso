component {

	property name="samlRequestParser"     inject="samlRequestParser";
	property name="samlResponseParser"    inject="samlResponseParser";
	property name="samlResponseBuilder"   inject="samlResponseBuilder";
	property name="samlRequestBuilder"    inject="samlRequestBuilder";
	property name="samlEntityPool"        inject="samlEntityPool";
	property name="deflateEncoder"        inject="httpRedirectRequestDeflateEncoder";
	property name="websiteLoginService"   inject="websiteLoginService";
	property name="samlSessionService"    inject="samlSessionService";
	property name="samlMetadataGenerator" inject="samlProviderMetadataGenerator";
	property name="debugger"              inject="saml2DebuggingService";

	/**
	 *
	 * /saml2/slo/
	 *
	 * Initial request for Single Logout where we are the IdP
	 * for frontend website. This handler is to process both
	 * SP initiated logout _requests_ and also logout _responses_
	 */
	public void function index( event, rc, prc ) {
		event.cachePage( false );
		event.preventPageCache();
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
	 * Initiates a SLO request to a Service Provider from this IdP.
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

		var redirectLocation = sessionDetail.issuer.single_logout_location;
		var binding          = sessionDetail.issuer.single_logout_binding;
		if ( isEmptyString( redirectLocation ) ) {
			event.notFound();
		}
		var samlSpLogoutRequest = samlRequestBuilder.buildLogoutRequest(
			  issuer            = samlMetadataGenerator.getIdpEntityId()
			, sloEndpoint       = redirectLocation
			, nameIdValue       = sessionDetail.nameId
			, sessionIndex      = sessionDetail.sessionIndex
			, requestId         = samlSessionId
			, privateSigningKey = sessionDetail.issuer.private_key
			, publicSigningCert = sessionDetail.issuer.public_cert
		);

		debugger.log(
			  success     = true
			, requesttype = "initiateslorequest"
			, sp          = sessionDetail.issuer.id ?: ""
			, samlXml     = samlSpLogoutRequest
		);

		if ( binding contains "POST" ) {
			event.setXFrameOptionsHeader( "sameorigin" );
			// POST BINDING, javascript form to post request to redirect location
			return renderView( view="/saml2/ssoRequestForm", args={
				  samlRequest      = samlSpLogoutRequest
				, redirectLocation = redirectLocation
				, serviceName	   = ( sessionDetail.issuer.name ?: "" )
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
	 * Crafts a response to a SP logout request
	 * In our current implementation, this will be triggered from an embedded iframe
	 * in the logout page
	 */
	public any function spresponse( event, rc, prc ) {
		var issuerId       = rc.issuer ?: "";
		var inResponseTo   = rc.inResponseTo ?: ""
		var spIssuer       = samlEntityPool.getEntityById( issuerId );
		var logoutEndpoint = spIssuer.consumerRecord.single_logout_location ?: "";
		var logoutBinding  = spIssuer.consumerRecord.single_logout_binding  ?: "";
		var debugInfo      = { success=true, requesttype="sloresponse" };

		debugInfo.sp = spIssuer.consumerRecord.id ?: "";

		if ( isEmptyString( logoutEndpoint ) || isEmptyString( inResponseTo ) ) {
			debugInfo.success = false;
			debugInfo.failureReason = "entitynotfound";
			debugger.log( argumentCollection=debugInfo );
			event.notFound();
		}

		var logoutResponse = samlResponseBuilder.buildLogoutResponse(
			  issuer            = samlMetadataGenerator.getIdpEntityId()
			, inResponseTo      = inResponseTo
			, destination       = logoutEndpoint
			, privateKey        = spIssuer.consumerRecord.private_key
			, publicCertificate = spIssuer.consumerRecord.public_cert
		);

		debugInfo.xml = logoutResponse;
		debugger.log( argumentCollection=debugInfo );

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
		var debugInfo = { success=true, requesttype="slorequest" };

		try {
			var samlRequest        = samlRequestParser.parse();
			var xmlPresent         = Len( samlRequest.samlXml ?: "" ) > 0;
			var entityFound        = StructKeyExists( samlRequest, "issuerentity" ) && !IsEmpty( samlRequest.issuerEntity );
			var requestTypePresent = Len( samlRequest.samlRequest.type ?: "" ) > 0;
			var hasError           = Len( samlRequest.error ?: "" ) > 0;
			var totallyBadRequest  = !xmlPresent || !entityFound || !requestTypePresent || hasError;

			if ( !xmlPresent ) {
				debugInfo.failureReason = "noxml";
			} else if ( !entityFound ) {
				debugInfo.failureReason = "entitynotfound";
			} else if ( !requestTypePresent ) {
				debugInfo.failureReason = "norequesttype";
			} else if ( hasError ) {
				debugInfo.failureReason = samlRequest.error;
			}
		} catch( any e ) {
			logError( e );
			totallyBadRequest = true;
			debugInfo.error         = "Message: #( e.message ?: '' )#. Detail: #( e.detail ?: '' )#";
			debugInfo.failureReason = "error";
		}

		debugInfo.sp         = samlRequest.issuerEntity.id ?: "";
		debugInfo.samlXml    = samlRequest.samlXml         ?: "";
		debugInfo.relayState = samlRequest.relayState      ?: "";

		if ( totallyBadRequest ) {
			debugInfo.success = false;
			debugger.log( argumentCollection=debugInfo );

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
			debugInfo.success = false;
			debugInfo.failureReason = "wrongreqtype";
			debugger.log( argumentCollection=debugInfo );

			var redirectLocation   = samlRequest.issuerEntity.single_logout_location ?: "";
			if ( !Len( redirectLocation ) ) {
				redirectLocation = samlRequest.issuerEntity.assertion_consumer_location ?: "";
			}
			samlResponse = samlResponseBuilder.buildErrorResponse(
				  statusCode          = "urn:oasis:names:tc:SAML:2.0:status:Responder"
				, subStatusCode       = "urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported"
				, statusMessage       = "Operation unsupported"
				, issuer              = samlMetadataGenerator.getIdpEntityId()
				, inResponseTo        = samlRequest.samlRequest.id
				, recipientUrl        = redirectLocation
			);

			return renderView( view="/saml2/ssoResponseForm", args={
				  samlResponse     = samlResponse
				, samlRelayState   = samlRequest.relayState ?: ""
				, redirectLocation = redirectLocation
				, serviceName	   = ( samlRequest.issuerEntity.name ?: "" )
			} );
		}

		debugger.log( argumentCollection=debugInfo );

		// 3. Log current user out
		if ( isLoggedIn() ) {
			websiteLoginService.logout();
		}

		// 4. Clear SPs recorded session
		var sessionIndex = samlRequest.samlRequest.sessionIndex ?: "";
		if ( isEmptyString( sessionIndex ) ) {
			sessionIndex = samlSessionService.getSessionId();
		}
		samlSessionService.removeSessionByIssuerAndIndex( samlRequest.issuerEntity.id, sessionIndex );

		// 5. Redirect to logged out page (with variables to help output iframes to do followout logout requests with SPs)
		setNextEvent( url=event.buildLink( page="saml_slo_page" ), persistStruct={
			  nameId       = samlRequest.samlRequest.nameId ?: ""
			, requestId    = samlRequest.samlRequest.id ?: ""
			, spIssuerId   = samlRequest.issuerEntity.id ?: ""
			, sessionIndex = sessionIndex
		} );
	}

	private void function _processSloResponse() {
		try {
			var samlResponse       = samlResponseParser.parse( issuerType="sp" );
			var xmlPresent         = Len( samlResponse.samlXml ?: "" ) > 0;
			var entityFound        = StructKeyExists( samlResponse, "issuerentity" ) && !IsEmpty( samlResponse.issuerEntity );
			var requestTypePresent = Len( samlResponse.samlResponse.type ?: "" ) > 0;
			var totallyBadRequest  = !xmlPresent || !entityFound || !requestTypePresent;

			if ( !xmlPresent ) {
				debugInfo.failureReason = "noxml";
			} else if ( !entityFound ) {
				debugInfo.failureReason = "entitynotfound";
			} else if ( !requestTypePresent ) {
				debugInfo.failureReason = "noresponsetype";
			}
		} catch( any e ) {
			logError( e );
			totallyBadRequest = true;
			if ( ( e.type ?: "" ) == "saml2responseparser.invalid.signature" ) {
				debugInfo.failureReason = "invalidsignature";
			} else if ( ( e.type ?: "" ) == "saml2responseparser.assertion.timed.out" ) {
				debugInfo.failureReason = "timeout";
			} else {
				debugInfo.error         = "Message: #( e.message ?: '' )#. Detail: #( e.detail ?: '' )#";
				debugInfo.failureReason = "error";
			}
		}

		debugInfo.sp         = samlResponse.issuerEntity.consumerRecord.id ?: "";
		debugInfo.samlXml    = samlResponse.samlXml ?: "";
		debugInfo.relayState = samlResponse.relayState ?: "";
		debugInfo.success    = !totallyBadRequest;

		debugger.log( argumentCollection=debugInfo );

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

// BG THREAD RUNNERS
	private boolean function clearSessionInBgThread( event, rc, prc, args={} ) {
		var sessionIndex = args.sessionIndex ?: "";

		if ( Len( Trim( sessionIndex ) ) ) {
			samlSessionService.removeSessionsByIndex( sessionIndex );
		}

		return true;
	}
}