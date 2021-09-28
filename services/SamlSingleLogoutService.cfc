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

}