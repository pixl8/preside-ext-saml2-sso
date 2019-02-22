/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @samlAttributesService.inject samlAttributesService
	 * @samlKeyStore.inject          samlKeyStore
	 *
	 */
	public any function init(
		  required any    samlAttributesService
		, required any    samlKeyStore
	) {
		_setSamlAttributesService( arguments.samlAttributesService );
		_setSamlKeyStore( arguments.samlKeyStore );

		return this;
	}

// PUBLIC API METHODS
	public string function generateIdpMetadata() {
		var template = FileRead( "resources/idp.metadata.template.xml" );
		var settings = $getPresideCategorySettings( "saml2Provider" );

		template = template.replace( "${x509}"          , _getX509Cert()                                                         , "all" );
		template = template.replace( "${attribs}"       , _getSupportedAttributesXml()                                           , "all" );
		template = template.replace( "${ssolocation}"   , ( settings.sso_endpoint_root       ?: "" ) & "/saml2/sso/"             , "all" );
		template = template.replace( "${orgshortname}"  , ( settings.organisation_short_name ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgfullname}"   , ( settings.organisation_full_name  ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgurl}"        , ( settings.organisation_url        ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportcontact}", ( settings.support_person          ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportemail}"  , ( settings.support_email           ?: "----ERROR: NOT CONFIGURED----" ), "all" );

		return template;
	}

	public string function generateSpMetadata() {
		var template = FileRead( "resources/sp.metadata.template.xml" );
		var settings = $getPresideCategorySettings( "saml2Provider" );

		template = template.replace( "${x509}"              , _getX509Cert()                                                         , "all" );
		template = template.replace( "${ssolocation}"       , ( settings.sso_endpoint_root       ?: "" ) & "/saml2/response/"        , "all" );
		template = template.replace( "${orgshortname}"      , ( settings.organisation_short_name ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgfullname}"       , ( settings.organisation_full_name  ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgurl}"            , ( settings.organisation_url        ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportcontact}"    , ( settings.support_person          ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportemail}"      , ( settings.support_email           ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${servicename}"       , ( settings.service_name            ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${servicedescription}", ( settings.service_description     ?: "----ERROR: NOT CONFIGURED----" ), "all" );

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

}