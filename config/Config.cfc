component {

	public void function configure( required struct config ) {
		var settings = arguments.config.settings ?: {};

		settings.saml2 = {};
		settings.saml2.keystore = {
			  filepath     = ( settings.injectedConfig.samlKeyStoreFile     ?: ExpandPath( "/uploads/saml2/keystore" ) )
			, password     = ( settings.injectedConfig.samlKeyStorePassword ?: "" )
			, certAlias    = ( settings.injectedConfig.samlCertAlias        ?: "" )
			, certPassword = ( settings.injectedConfig.samlCertPassword     ?: "" )
		};
		settings.saml2.authCheckHandler = "saml2.authenticationCheck";
		settings.saml2.attributes = {};
		settings.saml2.attributes.retrievalHandler = "saml2.retrieveAttributes";
		settings.saml2.attributes.supported = {
			  email       = { friendlyName="Email"      , samlUrn="urn:oid:0.9.2342.19200300.100.1.3", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, displayName = { friendlyName="DisplayName", samlUrn="urn:oid:2.16.840.1.113730.3.1.241", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, firstName   = { friendlyName="FirstName"  , samlUrn="urn:oid:2.5.4.42"                 , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, lastName    = { friendlyName="LastName"   , samlUrn="urn:oid:2.5.4.4"                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		};


		settings.features.samlSsoProvider = { enabled=true, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoConsumer = { enabled=false, siteTemplates=[ "*" ], widgets=[] };

		settings.adminPermissions.saml2 = {
			  provider = [ "navigate", "manage", "deleteConsumer" ]
			, consumer = [ "navigate", "manage" ]
		};
		settings.adminRoles.sysadmin.append( "saml2.*" );
		settings.adminRoles.sysadmin.append( "!saml2.provider.deleteConsumer" );

		settings.adminSideBarItems.insertAt( settings.adminSideBarItems.findNoCase( "websiteUserManager" )+1, "saml2" );

		settings.validationProviders.append( "samlMetaDataValidator" );

		settings.enum.samlSsoType = [ "sp", "idp" ];
	}
}