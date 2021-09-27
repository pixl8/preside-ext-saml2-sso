/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @samlAttributesService.inject samlAttributesService
	 * @samlKeyStore.inject          samlKeyStore
	 * @samlIdpService.inject        samlIdentityProviderService
	 *
	 */
	public any function init(
		  required any    samlAttributesService
		, required any    samlKeyStore
		, required any    samlIdpService
	) {
		_setSamlAttributesService( arguments.samlAttributesService );
		_setSamlKeyStore( arguments.samlKeyStore );
		_setSamlIdpService( arguments.samlIdpService );

		return this;
	}

// PUBLIC API METHODS
	public string function generateIdpMetadata() {
		var template = FileRead( "resources/idp.metadata.template.xml" );
		var settings = $getPresideCategorySettings( "saml2Provider" );

		template = template.replace( "${x509}"          , _getX509Cert()                                                         , "all" );
		template = template.replace( "${attribs}"       , _getSupportedAttributesXml()                                           , "all" );
		template = template.replace( "${ssolocation}"   , ( settings.sso_endpoint_root       ?: "" ) & "/saml2/sso/"             , "all" );
		template = template.replace( "${entityid}"      , ( settings.sso_endpoint_root       ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgshortname}"  , ( settings.organisation_short_name ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgfullname}"   , ( settings.organisation_full_name  ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgurl}"        , ( settings.organisation_url        ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportcontact}", ( settings.support_person          ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportemail}"  , ( settings.support_email           ?: "----ERROR: NOT CONFIGURED----" ), "all" );

		if ( $isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			template = template.replace( "${slo}", '<md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="#( settings.sso_endpoint_root ?: "" )#/saml2/slo/"/>', "all" );
		} else {
			template = template.replace( "${slo}", "", "all" );
		}

		return template;
	}

	public string function generateSpMetadata( required string idpId ) {
		var template = FileRead( "resources/sp.metadata.template.xml" );
		var settings = $getPresideCategorySettings( "saml2Provider" );
		var idpSettings = _getSamlIdpService().getProvider( arguments.idpId );

		if ( !idpSettings.count() ) {
			return "";
		}

		var ssoLocation        = ( settings.sso_endpoint_root ?: "" ) & "/saml2/response/?idp=#idpId#";
		var entityId           = ( settings.sso_endpoint_root       ?: "----ERROR: NOT CONFIGURED----" )
		var orgShortName       = ( settings.organisation_short_name ?: "----ERROR: NOT CONFIGURED----" )
		var orgFullName        = ( settings.organisation_full_name  ?: "----ERROR: NOT CONFIGURED----" )
		var orgUrl             = ( settings.organisation_url        ?: "----ERROR: NOT CONFIGURED----" )
		var supportPerson      = ( settings.support_person          ?: "----ERROR: NOT CONFIGURED----" )
		var supportEmail       = ( settings.support_email           ?: "----ERROR: NOT CONFIGURED----" )
		var serviceName        = ( settings.service_name            ?: "----ERROR: NOT CONFIGURED----" )
		var serviceDescription = ( settings.service_description     ?: "----ERROR: NOT CONFIGURED----" )

		if ( Len( Trim( idpSettings.entityIdSuffix ?: "" ) ) ) {
			entityId &= idpSettings.entityIdSuffix;
		}

		template = template.replace( "${x509}"              , _getX509Cert()    , "all" );
		template = template.replace( "${ssolocation}"       , ssoLocation       , "all" );
		template = template.replace( "${entityid}"          , entityId          , "all" );
		template = template.replace( "${orgshortname}"      , orgShortName      , "all" );
		template = template.replace( "${orgfullname}"       , orgFullName       , "all" );
		template = template.replace( "${orgurl}"            , orgUrl            , "all" );
		template = template.replace( "${supportcontact}"    , supportPerson     , "all" );
		template = template.replace( "${supportemail}"      , supportEmail      , "all" );
		template = template.replace( "${servicename}"       , serviceName       , "all" );
		template = template.replace( "${servicedescription}", serviceDescription, "all" );

		return template;
	}

	public string function getFormattedX509Cert() {
		return _getX509Cert( multiline=true );
	}

// PRIVATE HELPERS
	private string function _getX509Cert( boolean multiline=false ) {
		try {
			return _getSamlKeyStore().getFormattedX509Certificate( multiline=arguments.multiline );
		} catch( any e ) {
			return "=====ERROR READING X509 CERT. SEE SAML2 EXTENSION DOCUMENTATION FOR SETUP HELP=====";
		}
	}

	private string function _getSupportedAttributesXml() {
		var attribsXml  = "";
		var indentation = RepeatString( " ", 8 );
		var newline     = Chr( 13 ) & Chr( 10 );
		var attribs     = _getSamlAttributesService().getSupportedAttributes();

		for( var attribName in attribs ) {
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

	private any function _getSamlKeyStore() {
		return _samlKeyStore;
	}
	private void function _setSamlKeyStore( required any samlKeyStore ) {
		_samlKeyStore = arguments.samlKeyStore;
	}

	private any function _getSamlIdpService() {
	    return _samlIdpService;
	}
	private void function _setSamlIdpService( required any samlIdpService ) {
	    _samlIdpService = arguments.samlIdpService;
	}

}