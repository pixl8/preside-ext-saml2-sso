/**
 * @singleton
 *
 */
component {

// CONSTRUCTOR
	/**
	 * @xmlSigner.inject samlXmlSigner
	 */
	public any function init( required any xmlSigner ) {
		_setXmlSigner( arguments.xmlSigner );

		return this;
	}

// PUBLIC API METHODS
	public string function buildAuthenticationRequest(
		  required string idpMetaData
		, required string responseHandlerUrl
		, required string spIssuer
		, required string spName
		, required string signWithCertificate
	) {
		var idpMeta = new SamlMetadata( arguments.idpMetaData );
		var nowish  = getInstant();
		var id      = LCase( _createSamlId() );

		var xml  = _getXmlHeader();
		    xml &= '<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" ';
		    xml &= 'ID="#id#" ';
		    xml &= 'ProviderName="#XmlFormat( arguments.spName )#" ';
		    xml &= 'IssueInstant="#_dateTimeFormat( nowish )#" ';
		    xml &= 'Destination="#XmlFormat( idpMeta.getIdpSsoLocation() )#" ';
		    xml &= 'AssertionConsumerServiceURL="#XmlFormat( arguments.responseHandlerUrl )#">';
		    	xml &= '<saml:Issuer>#arguments.spIssuer#</saml:Issuer>';
		    	xml &= '<samlp:NameIDPolicy Format="#idpMeta.getIdpNameIdFormat()#" AllowCreate="true"/>';
				xml &= '<samlp:RequestedAuthnContext Comparison="exact">';
					xml &= '<saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>';
				xml &= '</samlp:RequestedAuthnContext>';
			xml &= '</samlp:AuthnRequest>';

		xml = _getXmlSigner().sign( xml, signWithCertificate );

		return xml;
	}

	public date function getInstant() {
		return Now();
	}

// PRIVATE HELPERS
	private string function _getXmlHeader() {
		return '<?xml version="1.0" encoding="UTF-8"?>';
	}

	private string function _dateTimeFormat( required string datetime ) {
		var utc = DateConvert( "local2Utc", arguments.dateTime );
		return DateFormat( utc, "yyyy-mm-dd" ) & "T" & TimeFormat( utc, "HH:mm:ss" ) & "Z";
	}

	private string function _createSamlId() {
		return 'a' & LCase( CreateUUId() ).reReplace( "[^a-z0-9]", "", "all" ); // IDs must start with a letter
	}

// GETTERS AND SETTERS
	private any function _getXmlSigner() {
		return _xmlSigner;
	}
	private void function _setXmlSigner( required any xmlSigner ) {
		_xmlSigner = arguments.xmlSigner;
	}
}