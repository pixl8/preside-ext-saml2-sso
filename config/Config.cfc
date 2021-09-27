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
			  id          = { friendlyName="UserID"                                                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, email       = { friendlyName="Email"      , samlUrn="urn:oid:0.9.2342.19200300.100.1.3", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, displayName = { friendlyName="DisplayName", samlUrn="urn:oid:2.16.840.1.113730.3.1.241", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, firstName   = { friendlyName="FirstName"  , samlUrn="urn:oid:2.5.4.42"                 , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
			, lastName    = { friendlyName="LastName"   , samlUrn="urn:oid:2.5.4.4"                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		};

		settings.saml2.identityProviders = settings.saml2.identityProviders ?: {};


		settings.features.samlSsoProvider     = { enabled=true, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoProviderSlo  = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoConsumer     = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
		settings.features.saml2SSOUrlAsIssuer = { enabled=false, siteTemplates=[ "*" ], widgets=[] };

		settings.adminPermissions.saml2 = [ "navigate", "manage", "deleteConsumer" ];

		settings.adminPermissions.saml2 = {
			  general  = [ "navigate" ]
			, provider = [ "navigate", "manage", "deleteConsumer" ]
			, consumer = [ "navigate", "manage" ]
		};
		settings.adminRoles.sysadmin.append( "saml2.general.navigate" );
		settings.adminRoles.sysadmin.append( "saml2.provider.navigate" );
		settings.adminRoles.sysadmin.append( "saml2.provider.manage" );

		settings.adminConfigurationMenuItems.insertAt( settings.adminConfigurationMenuItems.findNoCase( "usermanager" )+1, "saml2" );

		settings.validationProviders.append( "samlMetaDataValidator" );

		settings.enum.samlSsoType = [ "sp", "idp" ];
		settings.enum.samlIdpType = [ "admin", "web" ];

		settings.multilingual.ignoredUrlPatterns = settings.multilingual.ignoredUrlPatterns ?: [];
		settings.multilingual.ignoredUrlPatterns.append( "^/saml2/" );

		_workaroundEsapiDefaultClassIssue();
	}

	private void function _workaroundEsapiDefaultClassIssue() {
		var esapiSysPropKey = "org.owasp.esapi.SecurityConfiguration";
		var sys             = CreateObject( "java", "java.lang.System" );
		var defaultVal      = CreateObject( "java", "org.owasp.esapi.reference.DefaultSecurityConfiguration" ).getClass().getName();
		var configuredVal   = sys.getProperty( esapiSysPropKey );

		if ( IsNull( configuredVal ) ) {
			sys.setProperty( esapiSysPropKey, defaultVal );
		}
	}
}