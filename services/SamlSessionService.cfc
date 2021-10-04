/**
 * @singleton      true
 * @presideService true
 */
component {

	property name="cookieService"         inject="cookieService";
	property name="samlSessionCookieName" inject="coldbox:setting:saml2.sessionCookieName";

	public any function init() {
		return this;
	}

// PUBLIC API
	public string function getSessionId() {
		var sessionId = cookieService.getVar( samlSessionCookieName, "" );

		if ( !Len( sessionId ) ) {
			sessionId = LCase( Hash( CreateUUId() ) );
			cookieService.setVar(
				  name  = samlSessionCookieName
				, value = sessionId
			);
		}

		return sessionId;
	}

	public void function recordLoginSession(
		  required string sessionIndex
		, required string userId
		, required string issuerId
	) {
		if ( $isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			$getPresideObject( "saml2_login_session" ).insertData({
				  owner         = arguments.ownerId
				, session_index = arguments.sessionIndex
				, issuer        = arguments.issuerId
			});
		}
	}

	public array function getSessions( required string userId, required string sessionIndex ) {
		var sessions = [];
		var records  = $getPresideObject( "saml2_login_session" ).selectData( selectFields=[ "id" ], filter = {
			  owner         = arguments.userId
			, session_index = arguments.sessionIndex
		} );

		return ValueArray( records.id );
	}

	public void function getUserIdFromNameId( required string nameId, required string issuerId ) {
		var nameIdField = getNameIdFieldForSp( arguments.issuerId );
		var customEvent = "saml2.getUserIdFrom#nameIdField#";

		if ( $getColdbox().handlerExists( customEvent ) ) {
			var userId = $runEvent(
				  event          = customEvent
				, private        = true
				, prepostexempt  = true
				, eventArguments = { args={ value=arguments.nameId } }
			);

			return local.userId ?: arguments.nameId;
		}

		// no way of knowing to convert to something else
		// just assume the nameId is the userId
		return arguments.nameId;
	}

	public string function getNameIdFromUserId( required string userId, required string issuerId ) {
		var nameIdField = getNameIdFieldForSp( arguments.issuerId );
		var customEvent = "saml2.get#nameIdField#ForUser";

		if ( $getColdbox().handlerExists( customEvent ) ) {
			var nameId = $runEvent(
				  event          = customEvent
				, private        = true
				, prepostexempt  = true
				, eventArguments = { args={ userId=arguments.userId } }
			);

			return local.nameId ?: arguments.userId;
		}

		// no way of knowing to convert to something else
		// just assume the userId is the nameId
		return arguments.userId;
	}

	public string function getNameIdFieldForSp( required string serviceProviderId ) {
		var record = $getPresideObject( "saml2_consumer" ).selectData(
			  id           = arguments.serviceProviderId
			, selectFields = [ "id_attribute" ]
		);

		return Len( record.id_attribute ) ? record.id_attribute : "id";
	}

	public struct function getSessionDetail( required string sessionId ) {
		var record = $getPresideObject( "saml2_login_session" ).selectData( id=arguments.sessionId );

		if ( !record.recordCount ) {
			return {};
		}

		var spIssuer = $getPresideObject( "saml2_consumer" ).selectData( id=record.issuer );
		if ( !spIssuer.recordCount ) {
			return {};
		}

		var issuerMeta = new SamlMetadata( spIssuer.metadata );

		return {
			  sessionIndex   = record.session_index
			, issuer         = spIssuer
			, nameId         = getNameIdFromUserId( record.owner, record.issuer )
			, issuerMetadata = new SamlMetadata( spIssuer.metadata )
		};
	}
}