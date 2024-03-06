/**
 * @singleton      true
 * @presideService true
 */
component {

	property name="idpConfigurationDefaults" inject="coldbox:setting:saml2.idpConfigurationDefaults";

// CONSTRUCTOR
	/**
	 * @samlAttributesService.inject  samlAttributesService
	 * @samlIdpService.inject         samlIdentityProviderService
	 *
	 */
	public any function init(
		  required any    samlAttributesService
		, required any    samlIdpService
	) {
		_setSamlAttributesService( arguments.samlAttributesService );
		_setSamlIdpService( arguments.samlIdpService );

		return this;
	}

// PUBLIC API METHODS
	public string function generateIdpMetadata( required string serviceProviderId ) {
		var settings = getSpIdpMetadataSettings( arguments.serviceProviderId );
		var template = FileRead( "resources/idp.metadata.template.xml" );

		if ( StructIsEmpty( settings ) ) {
			return "";
		}

		template = template.replace( "${x509}"          , settings.x509Certificate    , "all" );
		template = template.replace( "${attribs}"       , settings.supportedAttribs   , "all" );
		template = template.replace( "${nameidformat}"  , settings.nameIdFormat       , "all" );
		template = template.replace( "${ssolocation}"   , settings.singleLoginLocation, "all" );
		template = template.replace( "${entityid}"      , settings.entityId           , "all" );
		template = template.replace( "${orgshortname}"  , settings.orgShortName       , "all" );
		template = template.replace( "${orgfullname}"   , settings.orgFullName        , "all" );
		template = template.replace( "${orgurl}"        , settings.orgUrl             , "all" );
		template = template.replace( "${supportcontact}", settings.supportPerson      , "all" );
		template = template.replace( "${supportemail}"  , settings.supportEmail       , "all" );

		if ( $isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			template = template.replace( "${slo}", '<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="#settings.singleLogoutLocation#"/>', "all" );
		} else {
			template = template.replace( "${slo}", "", "all" );
		}

		return template;
	}


	public string function generateSpMetadata( required string idpId ) {
		var template = FileRead( "resources/sp.metadata.template.xml" );
		var settings = getIdpSpMetadataSettings( arguments.idpId );

		if ( StructIsEmpty( settings ) ) {
			return ""
		}

		template = Replace( template, "${x509}"              , settings.x509Certificate          , "all" );
		template = Replace( template, "${ssolocation}"       , settings.assertionConsumerLocation, "all" );
		template = Replace( template, "${entityid}"          , settings.entityId                 , "all" );
		template = Replace( template, "${orgshortname}"      , settings.orgShortName             , "all" );
		template = Replace( template, "${orgfullname}"       , settings.orgFullName              , "all" );
		template = Replace( template, "${orgurl}"            , settings.orgUrl                   , "all" );
		template = Replace( template, "${supportcontact}"    , settings.supportPerson            , "all" );
		template = Replace( template, "${supportemail}"      , settings.supportEmail             , "all" );

		return template;
	}

	public struct function getMetadataSettings() {
		var rawSettings = $getPresideCategorySettings( "saml2Provider" );
		var settings = {
			  sso_endpoint_root       = rawSettings.sso_endpoint_root       ?: ""
			, organisation_short_name = rawSettings.organisation_short_name ?: ""
			, organisation_full_name  = rawSettings.organisation_full_name  ?: ""
			, organisation_url        = rawSettings.organisation_url        ?: ""
			, support_person          = rawSettings.support_person          ?: ""
			, support_email           = rawSettings.support_email           ?: ""
		};

		if ( !Len( Trim( settings.sso_endpoint_root ) ) ) {
			if ( $isFeatureEnabled( "sites" ) ) {
				var defaultSite = $getPresideObject( "site" ).selectData( filter={ deleted=false }, selectFields=[ "domain", "path", "protocol" ], orderBy="datecreated", maxRows=1 );
				if ( defaultSite.recordCount ) {
					settings.sso_endpoint_root = "#defaultSite.protocol#://#defaultSite.domain##defaultSite.path#";
				}
			} else {
				$getRequestContext().buildLink( linkto="" );
			}
		}
		settings.sso_endpoint_root = ReReplace( settings.sso_endpoint_root, "/$", "" );

		if ( !Len( settings.organisation_short_name ) ) {
			settings.organisation_short_name = idpConfigurationDefaults.organisationShortName ?: "Not configured"
		}
		if ( !Len( settings.organisation_full_name ) ) {
			settings.organisation_full_name = idpConfigurationDefaults.organisationFullName ?: "Not configured"
		}
		if ( !Len( settings.organisation_url ) ) {
			settings.organisation_url = idpConfigurationDefaults.organisationWebsite ?: "Not configured"
		}
		if ( !Len( settings.support_person ) ) {
			settings.support_person = idpConfigurationDefaults.supportContactName ?: "Not configured"
		}
		if ( !Len( settings.support_email ) ) {
			settings.support_email = idpConfigurationDefaults.supportContactEmail ?: "Not configured"
		}

		return settings;
	}

	public struct function getIdpSpMetadataSettings( required string idpId ) {
		var settings = getMetadataSettings();
		var idp      = _getSamlIdpService().getProvider( arguments.idpId );

		if ( !StructCount( idp ) ) {
			return "";
		}

		var entityId = settings.sso_endpoint_root;
		if ( Len( Trim( idp.entityIdSuffix ?: "" ) ) ) {
			entityId &= idp.entityIdSuffix;
		}

		return {
			  x509Certificate           = idp.public_cert
			, assertionConsumerLocation = settings.sso_endpoint_root & "/saml2/response/?idp=#idpId#"
			, entityId                  = entityId
			, orgShortName              = settings.organisation_short_name
			, orgFullName               = settings.organisation_full_name
			, orgUrl                    = settings.organisation_url
			, supportPerson             = settings.support_person
			, supportEmail              = settings.support_email
		};
	}

	public struct function getSpIdpMetadataSettings( required string serviceProviderId ) {
		var settings = getMetadataSettings();
		var sp       = $getPresideObject( "saml2_sp" ).selectData( id=arguments.serviceProviderId );
		var entityId = settings.sso_endpoint_root;

		if ( !sp.recordcount ) {
			return {};
		}

		if ( $isFeatureEnabled( "saml2SSOUrlAsIssuer" ) ) {
			entityId &= "/saml2/sso/"; // backward compat fix for previous bug - should be disabled by default
		}

		return {
			  x509Certificate           = sp.public_cert
			, singleLoginLocation       = settings.sso_endpoint_root & "/saml2/sso/"
			, singleLogoutLocation      = settings.sso_endpoint_root & "/saml2/slo/"
			, entityId                  = entityId
			, supportedAttribs          = _getSupportedAttributesXml( sp.use_attributes )
			, nameIdFormat              = _getSamlAttributesService().getNameIdFormat( $helpers.queryRowToStruct( sp ) )
			, orgShortName              = settings.organisation_short_name
			, orgFullName               = settings.organisation_full_name
			, orgUrl                    = settings.organisation_url
			, supportPerson             = settings.support_person
			, supportEmail              = settings.support_email
		};
	}

	public string function getIdpEntityId() {
		var settings = getMetadataSettings();
		var entityId = settings.sso_endpoint_root;

		if ( $isFeatureEnabled( "saml2SSOUrlAsIssuer" ) ) {
			entityId &= "/saml2/sso/"; // backward compat fix for previous bug - should be disabled by default
		}

		return entityId;
	}

	public string function getFormattedX509Cert() {
		return _getX509Cert( multiline=true );
	}

// PRIVATE HELPERS
	private string function _getSupportedAttributesXml( configuredAttribs  ) {
		var attribsXml  = "";
		var indentation = RepeatString( " ", 8 );
		var newline     = Chr( 13 ) & Chr( 10 );
		var attribs     = _getSamlAttributesService().getSupportedAttributes();

		for( var attribName in attribs ) {
			if ( Len( arguments.configuredAttribs ) && !ListFindNoCase( arguments.configuredAttribs, attribName ) ) {
				continue;
			}

			var attrib = attribs[ attribName ];

			attribsXml &= indentation;
			attribsXml &= '<saml:Attribute FriendlyName="#XmlFormat( attrib.friendlyName ?: attribName )#" Name="#XmlFormat( attrib.samlUrn ?: attribName )#" NameFormat="#XmlFormat( attrib.samlNameFormat ?: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri' )#"></saml:Attribute>';
			attribsXml &= newline;
		}

		return attribsXml;
	}


// GETTERS AND SETTERS
	private struct function _getSamlAttributesService() {
		return _samlAttributesService;
	}
	private void function _setSamlAttributesService( required struct samlAttributesService ) {
		_samlAttributesService = arguments.samlAttributesService;
	}

	private any function _getSamlIdpService() {
	    return _samlIdpService;
	}
	private void function _setSamlIdpService( required any samlIdpService ) {
	    _samlIdpService = arguments.samlIdpService;
	}

}