/**
 * Overriding core preside here as there is no postlogout
 * interception point.
 *
 */
component extends="preside.system.handlers.Login" {

	property name="samlSessionService" inject="samlSessionService";

	public void function logout( event, rc, prc ) {
		if ( !isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			return super.logout( argumentCollection=arguments );
		}

		var userId = getLoggedInUserId();
		var sessionId = samlSessionService.getSessionId();

		websiteLoginService.logout();

		setNextEvent( url=event.buildLink( page="saml_slo_page" ), persistStruct={
			  sessionIndex = sessionId
			, userId       = userId
		} );
	}

}