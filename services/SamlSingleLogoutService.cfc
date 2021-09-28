/**
 * @singleton      true
 * @presideService true
 */
component {

	public any function init() {
		return this;
	}

// PUBLIC API
	public void function recordLoginSession(
		  required string sessionIndex
		, required string userId
		, required string issuerId
	) {
		if ( $isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			$getPresideObject( "saml2_login_session" ).deleteData( filter={
				  owner  = arguments.userId
				, issuer = arguments.issuerId
			});

			$getPresideObject( "saml2_login_session" ).insertData({
				  owner         = arguments.ownerId
				, session_index = arguments.sessionIndex
				, issuer        = arguments.issuerId
			});
		}
	}

	public void function getUserIdFromNameID( required string nameId, required string issuerId ) {
		var nameIdField = getNameIdFieldForSp( arguments.issuerId );
		var customEvent = "saml2.getUserIdFrom#nameIdField#";

		if ( $getColdbox().handlerExists( "saml2.getUserIdFrom#nameIdField#" ) ) {
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

	public string function getNameIdFieldForSp( required string serviceProviderId ) {
		var record = $getPresideObject( "saml2_consumer" ).selectData(
			  id           = arguments.serviceProviderId
			, selectFields = [ "id_attribute" ]
		);

		return Len( record.id_attribute ) ? record.id_attribute : "id";
	}

}