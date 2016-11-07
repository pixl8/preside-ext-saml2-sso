component {

	public void function configure( required struct config ) {
		var settings = arguments.config.settings ?: {};

		settings.features.samlSsoProvider = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoConsumer = { enabled=false, siteTemplates=[ "*" ], widgets=[] };

		settings.adminPermissions.saml2 = {
			  provider = [ "navigate", "manage", "deleteConsumer" ]
			, consumer = [ "navigate", "manage" ]
		};
		settings.adminRoles.sysadmin.append( "saml2.*" );
		settings.adminRoles.sysadmin.append( "!saml2.provider.deleteConsumer" );

		settings.adminSideBarItems.insertAt( settings.adminSideBarItems.findNoCase( "websiteUserManager" )+1, "saml2" );

		settings.validationProviders.append( "samlMetaDataValidator" );
	}
}