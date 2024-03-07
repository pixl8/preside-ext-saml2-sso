component {

	property name="samlRequestParser"            inject="samlRequestParser";
	property name="samlResponseParser"           inject="samlResponseParser";
	property name="samlAttributesService"        inject="samlAttributesService";
	property name="samlResponseBuilder"          inject="samlResponseBuilder";
	property name="samlRequestBuilder"           inject="samlRequestBuilder";
	property name="samlSsoWorkflowService"       inject="samlSsoWorkflowService";
	property name="samlEntityPool"               inject="samlEntityPool";
	property name="samlIdentityProviderService"  inject="samlIdentityProviderService";
	property name="authCheckHandler"             inject="coldbox:setting:saml2.authCheckHandler";
	property name="samlSessionService"           inject="samlSessionService";
	property name="samlMetadataGenerator"        inject="samlProviderMetadataGenerator";
	property name="rulesEngineWebRequestService" inject="rulesEngineWebRequestService";
	property name="debugger"                     inject="saml2DebuggingService";

	public string function sso( event, rc, prc ) {
		var debugInfo         = { success=true, requesttype="authnrequest" };
		var totallyBadRequest = false;
		try {
			var samlRequest        = samlRequestParser.parse();
			var xmlPresent         = Len( samlRequest.samlXml ?: "" ) > 0;
			var entityFound        = StructKeyExists( samlRequest, "issuerentity" ) && !IsEmpty( samlRequest.issuerEntity );
			var requestTypePresent = Len( samlRequest.samlRequest.type ?: "" ) > 0;
			var hasError           = Len( samlRequest.error ?: "" ) > 0;

			totallyBadRequest  = !xmlPresent || !entityFound || !requestTypePresent || hasError;

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

			announceInterception( "postRenderSiteTreePage" );

			debugger.log( argumentCollection=debugInfo );

			return;
		}

		var redirectLocation   = samlRequest.issuerEntity.assertion_consumer_location ?: "";
		var isWrongRequestType = samlRequest.samlRequest.type != "AuthnRequest";
		var samlResponse       = "";
		var issuer             = samlMetadataGenerator.getIdpEntityId();

		if ( isWrongRequestType ) {
			debugInfo.success = false;
			debugInfo.failureReason = "wrongreqtype";

			samlResponse = samlResponseBuilder.buildErrorResponse(
				  statusCode          = "urn:oasis:names:tc:SAML:2.0:status:Responder"
				, subStatusCode       = "urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported"
				, statusMessage       = "Operation unsupported"
				, issuer              = issuer
				, inResponseTo        = samlRequest.samlRequest.id
				, recipientUrl        = redirectLocation
			);

		} else {
			var userId = runEvent(
					event          = authCheckHandler // default, saml2.authenticationCheck (below)
				  , eventArguments = { samlRequest = samlRequest }
				  , private        = true
				  , prePostExempt  = true
			);

			if ( isFeatureEnabled( "rulesengine" ) ) {
				var rulesEngineCondition = samlRequest.issuerEntity.access_condition ?: "";

				if ( Len( Trim( rulesEngineCondition ) ) && !rulesEngineWebRequestService.evaluateCondition( rulesEngineCondition ) ) {
					event.accessDenied(
						  reason              = "INSUFFICIENT_PRIVILEGES"
						, accessDeniedMessage = ( samlRequest.issuerEntity.access_denied_message ?: "" )
					);
				}
			}

			var attributeConfig = _getAttributeConfig( samlRequest.issuerEntity );
			var sessionIndex    = samlSessionService.getSessionId();

			if ( isFeatureEnabled( "samlSsoProviderSlo" ) ) {
				samlSessionService.recordLoginSession(
					  sessionIndex = sessionIndex
					, userId       = userId
					, issuerId     = samlRequest.issuerEntity.id
				);
			}

			announceInterception( "preSamlSsoLoginResponse", {
				  userId          = userId
				, samlRequest     = samlRequest
				, attributeConfig = attributeConfig
				, sessionIndex    = sessionIndex
			} );

			debugger.log( argumentCollection=debugInfo );

			samlResponse = samlResponseBuilder.buildAuthenticationAssertion(
				  issuer            = issuer
				, inResponseTo      = samlRequest.samlRequest.id
				, recipientUrl      = redirectLocation
				, nameIdFormat      = attributeConfig.idFormat
				, nameIdValue       = attributeConfig.idValue
				, audience          = samlRequest.issuerEntity.entity_id
				, sessionTimeout    = 40
				, sessionIndex      = sessionIndex
				, attributes        = attributeConfig.attributes
				, privateKey        = samlRequest.issuerEntity.private_key
				, publicCertificate = samlRequest.issuerEntity.public_cert
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

	public any function idpSso( event, rc, prc ) {
		var slug              = rc.providerSlug ?: "";
		var totallyBadRequest = !slug.len() > 0;
		var debugInfo         = { success=true, requesttype="idpsso" };

		if ( slug.len() ) {
			try {
				var entity = samlEntityPool.getEntityBySlug( slug );
				var entityFound = !IsEmpty( entity );
				var correctSsoType = ( entity.consumerRecord.sso_type ?: "" ) == "idp";

				totallyBadRequest = !entityFound || !correctSsoType;

				if ( !entityFound ) {
					debugInfo.failureReason = "entitynotfound";
				} else if ( !correctSsoType ) {
					debugInfo.failureReason = "wrongspssotype";
				}
			} catch( any e ) {
				logError( e );
				totallyBadRequest = true;
				debugInfo.error         = "Message: #( e.message ?: '' )#. Detail: #( e.detail ?: '' )#";
				debugInfo.failureReason = "error";
			}
		}

		debugInfo.sp = entity.consumerRecord.id ?: "";

		if ( totallyBadRequest ) {
			debugInfo.success = false;

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

			announceInterception( "postRenderSiteTreePage" );

			debugger.log( argumentCollection=debugInfo );
			return;
		}

		var redirectLocation = entity.consumerRecord.assertion_consumer_location ?: "";

		runEvent(
				event          = authCheckHandler // default, saml2.authenticationCheck (below)
			  , eventArguments = { samlRequest = { issuerEntity=entity } }
			  , private        = true
			  , prePostExempt  = true
		);

		var attributeConfig = _getAttributeConfig( entity.consumerRecord );
		var issuer = samlMetadataGenerator.getIdpEntityId();

		samlResponse = samlResponseBuilder.buildAuthenticationAssertion(
			  issuer            = issuer
			, inResponseTo      = ""
			, recipientUrl      = redirectLocation
			, nameIdFormat      = attributeConfig.idFormat
			, nameIdValue       = attributeConfig.idValue
			, audience          = entity.consumerRecord.entity_id
			, sessionTimeout    = 40
			, sessionIndex      = samlSessionService.getSessionId()
			, attributes        = attributeConfig.attributes
			, privateKey        = entity.consumerRecord.private_key
			, publicCertificate = entity.consumerRecord.public_cert
		);

		debugger.log( argumentCollection=debugInfo );

		return renderView( view="/saml2/ssoResponseForm", args={
			  samlResponse     = samlResponse
			, redirectLocation = redirectLocation
			, serviceName	   = ( entity.consumerRecord.name ?: "" )
			, noRelayState     = true
		} );
	}

	private string function authenticationCheck( event, rc, prc, samlRequest={} ) {
		if ( !isLoggedIn() ) {
			setNextEvent( url=event.buildLink( page="login" ), persistStruct={
				  samlRequest     = samlRequest
				, ssoLoginMessage = ( samlRequest.issuerEntity.login_message ?: "" )
				, postLoginUrl    = event.getBaseUrl() & event.getCurrentUrl()
			} );
		}

		return getLoggedInUserId();
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

	public string function spSso( event, rc, prc ) {
		event.cachePage( false );

		var debugInfo    = { success=true, requesttype="spsso" };
		var providerSlug = rc.providerSlug ?: "";
		var idp          = samlIdentityProviderService.getProvider( providerSlug );

		if ( StructIsEmpty( idp ) ) {
			debugInfo.success = false;
			debugInfo.failureReason = "entitynotfound";
			debugger.log( argumentCollection=debugInfo );
			event.notFound();
		}



		var metaSettings = samlMetadataGenerator.getIdpSpMetadataSettings( providerSlug );
		var samlRequest = samlRequestBuilder.buildAuthenticationRequest(
			  responseHandlerUrl  = metaSettings.assertionConsumerLocation
			, spIssuer            = metaSettings.entityId
			, spName              = metaSettings.orgShortName
			, ssoLocation         = idp.sso_location
			, nameIdFormat        = idp.name_id_format
			, privateSigningKey   = idp.private_key
			, publicSigningCert   = idp.public_cert
		);

		debugInfo.samlXml = samlRequest;
		debugInfo.idp     = idp.id;
		debugger.log( argumentCollection=debugInfo );

		return renderView( view="/saml2/ssoRequestForm", args={
			  samlRequest      = samlRequest
			, samlRelayState   = rc.relayState ?: ""
			, redirectLocation = idp.sso_location
			, serviceName	   = idp.title
		} );
	}

	public void function response( event, rc, prc ) {
		var debugInfo         = { success=true, requesttype="authnresponse" };
		var totallyBadRequest = false;

		try {
			var samlResponse       = samlResponseParser.parse();
			var xmlPresent         = Len( samlResponse.samlXml ?: "" ) > 0;
			var entityFound        = StructKeyExists( samlResponse, "issuerentity" ) && !IsEmpty( samlResponse.issuerEntity );
			var requestTypePresent = Len( samlResponse.samlResponse.type ?: "" ) > 0;
			var hasError           = Len( samlResponse.error ?: "" ) > 0;

			totallyBadRequest  = !xmlPresent || !entityFound || !requestTypePresent || hasError;

			if ( !xmlPresent ) {
				debugInfo.failureReason = "noxml";
			} else if ( !entityFound ) {
				debugInfo.failureReason = "entitynotfound";
			} else if ( !requestTypePresent ) {
				debugInfo.failureReason = "noresponsetype";
			} else if ( hasError ) {
				debugInfo.failureReason = samlResponse.error;
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

		debugInfo.idp        = samlResponse.issuerEntity.idpRecord.id ?: "";
		debugInfo.samlXml    = samlResponse.samlXml                   ?: "";
		debugInfo.relayState = samlResponse.relayState                ?: "";

		if ( totallyBadRequest ) {
			debugInfo.success = false;
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

			announceInterception( "postRenderSiteTreePage" );

			debugger.log( argumentCollection=debugInfo );
			return;
		}

		if ( !samlResponse.issuerEntity.idpRecord.postAuthHandler.len() ) {
			throw( type="saml2.method.not.supported", message="Currently, the SAML2 extension does not support auto login as a result of a SAML assertion response. Instead, you are required to provide a custom postAuthHandler for each IDP to process their response" );
		}

		debugger.log( argumentCollection=debugInfo );

		runEvent(
			  event          = samlResponse.issuerEntity.idpRecord.postAuthHandler
			, eventArguments = samlResponse
			, private        = true
			, prePostExempt  = true
		);

	}

	public void function idpmeta( event, rc, prc ) {
		if ( !Len( rc.sp ?: "" ) && !getPresideObject( "saml2_sp" ).dataExists( id=rc.sp ) ) {
			event.notFound();
		}
		var meta = samlMetadataGenerator.generateIdpMetadata( rc.sp );

		event.renderData( data=meta, contentType="application/xml" );
	}

	public void function spmeta( event, rc, prc ) {
		var idp  = Len( rc.idp ?: "" ) ? getPresideObject( "saml2_idp" ).selectData( id=rc.idp, selectFields=[ "slug" ] ) : QueryNew('');

		if ( !idp.recordCount ) {
			event.notFound();
		}

		var meta = samlMetadataGenerator.generateSpMetadata( idp.slug );

		event.renderData( data=meta, contentType="application/xml" );
	}

// Custom attributes for NameID:
// Methods for getting the userId based on custom attribute field (and in reverse)
	private string function getUserIdFromEmail( event, rc, prc, args={} ) {
		var emailAddress = args.value ?: "";

		return getPresideObject( "website_user" ).selectData( selectFields=[ "id" ], filter={
			  email_address = emailAddress
			, active        = true
		} ).id;
	}
	private string function getEmailForUser( event, rc, prc, args={} ) {
		var userId = args.userId ?: "";

		return getPresideObject( "website_user" ).selectData(
			  id           = userId
			, selectFields = [ "email_address" ]
		).email_address;
	}

// HELPERS
	private struct function _getAttributeConfig( required struct consumerRecord ) {
		var attributes = samlAttributesService.getAttributeValues();
		var idFormat   = samlAttributesService.getNameIdFormat( consumerRecord = consumerRecord );
		var idValue    = attributes[ consumerRecord.id_attribute ?: "" ] ?: getLoggedInUserId();
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