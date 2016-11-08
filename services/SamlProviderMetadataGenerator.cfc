/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @samlAttributesService.inject samlAttributesService
	 * @x509CertPath.inject          coldbox:setting:saml2.keystore.x509Path
	 *
	 */
	public any function init( required any samlAttributesService, required string x509CertPath ) {
		_setSamlAttributesService( arguments.samlAttributesService );
		_setX509CertPath( arguments.x509CertPath );

		return this;
	}

// PUBLIC API METHODS
	public string function generateMetadata() {
		var template         = FileRead( "resources/metadata.template.xml" );
		var providerSettings = $getPresideCategorySettings( "saml2Provider" );

		template = template.replace( "${x509}"          , _getX509Cert()                                                                 , "all" );
		template = template.replace( "${attribs}"       , _getSupportedAttributesXml()                                                   , "all" );
		template = template.replace( "${ssolocation}"   , ( providerSettings.sso_endpoint_root       ?: "" ) & "/saml2/sso/"             , "all" );
		template = template.replace( "${orgshortname}"  , ( providerSettings.organisation_short_name ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgfullname}"   , ( providerSettings.organisation_full_name  ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${orgurl}"        , ( providerSettings.organisation_url        ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportcontact}", ( providerSettings.support_person          ?: "----ERROR: NOT CONFIGURED----" ), "all" );
		template = template.replace( "${supportemail}"  , ( providerSettings.support_email           ?: "----ERROR: NOT CONFIGURED----" ), "all" );

		return template;
	}

// PRIVATE HELPERS
	private string function _getX509Cert() {
		try {
			return Trim( FileRead( _getX509CertPath() ) );
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

	private string function _getX509CertPath() {
		return _x509CertPath;
	}
	private void function _setX509CertPath( required string x509CertPath ) {
		_x509CertPath = arguments.x509CertPath;
	}


}