<cfscript>
	addRouteHandler( getModel( dsl="delayedInjector:saml2IdpInitiatedSsoRouteHandler" ) );
	addRouteHandler( getModel( dsl="delayedInjector:saml2AdminIdpRouteHandler" ) );
</cfscript>