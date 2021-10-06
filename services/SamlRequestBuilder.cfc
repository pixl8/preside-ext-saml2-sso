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

	public string function buildLogoutRequest(
		  required string sloEndpoint
		, required string issuer
		, required string nameIdValue
		, required string sessionIndex
		, required string requestId
	) {
		var nowish = getInstant();

		var xml  = _getXmlHeader();
			xml &= '<saml2p:LogoutRequest xmlns:saml2p="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0"'
			xml &= 'ID="#requestId#" ';
			xml &= 'IssueInstant="#_dateTimeFormat( nowish )#" ';
			xml &= 'Destination="#arguments.sloEndpoint#" '
			xml &= 'NotOnOrAfter="#_dateTimeFormat( DateAdd( 'n', 10, nowish ) )#" ';
			xml &= 'Reason="urn:oasis:names:tc:SAML:2.0:logout:user">';

				xml &= '<saml2:Issuer>#arguments.issuer#</saml2:Issuer>'
				xml &= '<saml2:NameID>#arguments.nameIdValue#</saml2:NameID>'
				xml &= '<samlp:SessionIndex>#arguments.sessionIndex#</samlp:SessionIndex>'

			xml &= '</saml2p:LogoutRequest>';

		xml = _getXmlSigner().sign( xml );

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