component {

	public void function configure( required struct config ) {
		var settings = arguments.config.settings ?: {};

		settings.saml2 = {};

		_configureExtensionSettings( settings );
		_configureFeatures( settings );
		_configureEnums( settings )
		_configureAdmin( settings );
		_configureValidationProviders( settings );
		_configureUriPatterns( settings );
		_configureInterceptors( arguments.config );
		_configureLegacyKeyStore( settings );

		_workaroundEsapiDefaultClassIssue();
	}

	private void function _configureExtensionSettings( settings ) {
		settings.saml2.sessionCookieName = "_samlid";
		settings.saml2.authCheckHandler = "saml2.authenticationCheck";
		settings.saml2.attributes = {};
		settings.saml2.attributes.retrievalHandler = "saml2.retrieveAttributes";
		settings.saml2.attributes.supported = {
			  id          = { friendlyName="UserID"                                                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="persistent" }
			, email       = { friendlyName="Email"      , samlUrn="urn:oid:0.9.2342.19200300.100.1.3", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="email" }
			, displayName = { friendlyName="DisplayName", samlUrn="urn:oid:2.16.840.1.113730.3.1.241", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
			, firstName   = { friendlyName="FirstName"  , samlUrn="urn:oid:2.5.4.42"                 , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
			, lastName    = { friendlyName="LastName"   , samlUrn="urn:oid:2.5.4.4"                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
		};

		settings.saml2.identityProviders = settings.saml2.identityProviders ?: {};
		settings.saml2.idpConfigurationDefaults = {
			  organisationShortName = settings.env.SAML2_ORGANISATION_SHORT   ?: "Preside"
			, organisationFullName  = settings.env.SAML2_ORGANISATION_FULL    ?: "Preside Platform"
			, organisationWebsite   = settings.env.SAML2_ORGANISATION_WEBSITE ?: "https://www.preside.org/"
			, supportContactName    = settings.env.SAML2_SUPPORT_CONTACT      ?: "Unknown"
			, supportContactEmail   = settings.env.SAML2_SUPPORT_EMAIL        ?: "unknown@example.com"
		};
	}

	private void function _configureFeatures( settings ) {
		settings.features.samlSsoProvider     = { enabled=true, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoProviderSlo  = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
		settings.features.samlSsoConsumer     = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
		settings.features.saml2SSOUrlAsIssuer = { enabled=false, siteTemplates=[ "*" ], widgets=[] };
	}

	private void function _configureEnums( settings ) {
		settings.enum.samlSsoType = [ "sp", "idp" ];
		settings.enum.samlIdpType = [ "admin", "web" ];
		settings.enum.samlNameIdFormat = [ "auto", "persistent", "email", "unspecified", "transient", "none" ];
		settings.enum.saml2certifateuploadmethods = [ "auto", "manual" ];
		settings.enum.saml2SpConfigurationMethod = [ "metadata", "manual" ];
		settings.enum.saml2BindingMethods = [ "HTTP-POST", "HTTP-REDIRECT" ];
		settings.enum.saml2CertEditMethod = [ "auto", "manual" ];
		settings.enum.saml2DebugOptions = [ "off", "erroronly", "all" ];
		settings.enum.saml2RequestType = [ "authnrequest", "authnresponse", "spsso", "initiateslorequest", "sloresponse", "slorequest" ];
		settings.enum.saml2FailureReason = [ "noxml", "entitynotfound", "norequesttype", "error", "wrongreqtype", "wrongspssotype", "noresponsetype", "invalidsignature", "timeout" ];
	}

	private void function _configureAdmin( settings ) {
		settings.adminPermissions.saml2 = {
			  general   = [ "navigate", "manage" ]
			, provider  = [ "navigate", "read", "edit" ]
			, consumer  = [ "navigate", "read", "add", "edit", "batchedit", "delete", "batchdelete" ]
			, debuglogs = [ "navigate", "read", "delete", "batchdelete" ]
		};

		ArrayAppend( settings.adminRoles.sysadmin, "saml2.*" );
		settings.adminRoles.samlManager = [ "saml2.*" ];

		settings.adminConfigurationMenuItems.insertAt( settings.adminConfigurationMenuItems.findNoCase( "usermanager" )+1, "saml2" );
	}

	private void function _configureLegacyKeyStore( settings ) {
		// used only for data migration
		settings.saml2.keystore = {
			  filepath     = ( settings.injectedConfig.samlKeyStoreFile     ?: ExpandPath( "/uploads/saml2/keystore" ) )
			, password     = ( settings.injectedConfig.samlKeyStorePassword ?: "" )
			, certAlias    = ( settings.injectedConfig.samlCertAlias        ?: "" )
			, certPassword = ( settings.injectedConfig.samlCertPassword     ?: "" )
		};
	}

	private void function _configureValidationProviders( settings ) {
		ArrayAppend( settings.validationProviders, "samlMetaDataValidator" );
	}

	private void function _configureUriPatterns( settings ) {
		settings.multilingual.ignoredUrlPatterns = settings.multilingual.ignoredUrlPatterns ?: [];
		settings.multilingual.ignoredUrlPatterns.append( "^/saml2/" );
	}

	private void function _configureInterceptors( config ) {
		ArrayAppend( config.interceptorSettings.customInterceptionPoints, "preSamlSsoLoginResponse" );
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