/**
 * @singleton
 *
 */
component {

	variables._standardAttributes = {
		  email                  = { friendlyName="Email"                 , name="urn:oid:0.9.2342.19200300.100.1.3", NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		, displayName            = { friendlyName="DisplayName"           , name="urn:oid:2.16.840.1.113730.3.1.241", NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		, firstName              = { friendlyName="FirstName"             , name="urn:oid:2.5.4.42"                 , NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		, lastName               = { friendlyName="LastName"              , name="urn:oid:2.5.4.4"                  , NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		, eduPersonPrincipalName = { friendlyName="eduPersonPrincipalName", name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6" , NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
		, eduPersonTargetedID    = { friendlyName="eduPersonTargetedID"   , name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10", NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" }
	};

// CONSTRUCTOR
	/**
	 * @xmlSigner.inject samlXmlSigner
	 */
	public any function init( required any xmlSigner ) {
		_setXmlSigner( arguments.xmlSigner );

		return this;
	}

// PUBLIC API METHODS
	public string function buildAuthenticationAssertion(
		  required string  issuer
		, required string  nameIdFormat
		, required string  nameIdValue
		, required string  inResponseTo
		, required string  recipientUrl
		, required string  audience
		, required numeric sessionTimeout
		, required string  sessionIndex
		, required struct  attributes
	) {
		var nowish = getInstant();
		var xml    = "";
		var id     = LCase( _createSamlId() );

		xml  = _getAssertionHeader( instant=nowish, issuer=arguments.issuer, id=id );
		xml &= _getSubject(
			  instant      = nowish
			, nameIdFormat = arguments.nameIdFormat
			, nameIdValue  = arguments.nameIdValue
			, inResponseTo = arguments.inResponseTo
			, recipientUrl = arguments.recipientUrl
		);
		xml &= _getConditions( instant=nowish, audience=arguments.audience );
		xml &= _getAuthenticationStatement( instant=nowish, sessionIndex=arguments.sessionIndex, sessionTimeout=arguments.sessionTimeout );
		xml &= _getAttributesStatement( arguments.attributes );
		xml &= _getAssertionFooter();

		xml = _getXmlSigner().sign( xml );
		xml = Replace( xml, '<?xml version="1.0" encoding="UTF-8"?>', '' );

		return _wrapAssertionInResponse( argumentCollection=arguments, assertion=xml, instant=nowish );
	}

	public string function buildErrorResponse(
		  required string statusCode
		, required string statusMessage
		, required string subStatusCode
		, required string issuer
		, required string inResponseTo
		, required string recipientUrl
	) {
		var nowish = getInstant();
		var xml    = "";
		var id     = LCase( _createSamlId() );

		xml  = _getXmlHeader() & _getResponseHeader(
			  instant       = nowish
			, issuer        = arguments.issuer
			, id            = id
			, inResponseTo  = arguments.inResponseTo
			, recipientUrl  = arguments.recipientUrl
			, statusCode    = arguments.statusCode
			, statusMessage = arguments.statusMessage
			, subStatusCode = arguments.subStatusCode
		);

		xml &= _getResponseFooter();

		return xml;
	}

	public string function buildLogoutResponse(
		  required string destination
		, required string inResponseTo
		, required string issuer
	) {
		var nowish = getInstant();
		var xml    = "";
		var id     = LCase( _createSamlId() );

		xml  = _getXmlHeader() & '<samlp:LogoutResponse xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0"';
		xml &= ' ID="#CreateUUId()#"';
		xml &= ' IssueInstant="#_dateTimeFormat( Now() )#"';
		xml &= ' Destination="#arguments.destination#"';

		if ( Len( Trim( arguments.inResponseTo ) ) ) {
			xml &= ' InResponseTo="#arguments.inResponseTo#"';
		}
		xml &= '>';

		xml &= '<saml:Issuer>#arguments.issuer#</saml:Issuer>';
		xml &= '<samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></samlp:Status>';
		xml &= '</samlp:LogoutResponse>';

		return xml;
	}

	public date function getInstant() {
		return Now();
	}

// PRIVATE HELPERS
	private string function _getXmlHeader() {
		return '<?xml version="1.0" encoding="UTF-8"?>';
	}

	private string function _getResponseHeader( required date instant, required string issuer, required string id, required string inResponseTo, required string recipientUrl, string statusCode="urn:oasis:names:tc:SAML:2.0:status:Success", string statusMessage="", string subStatusCode="" ) {
		var xml  = '<saml:Response IssueInstant="#_dateTimeFormat( arguments.instant )#" Version="2.0" ID="#arguments.id#" Destination="#arguments.recipientUrl#"#( arguments.inResponseTo.len() ? ' InResponseTo="#arguments.inResponseTo#"' : '' )# xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" >';
			xml &= '<samlp:Status>';
			xml &= '<samlp:StatusCode Value="#arguments.statusCode#">';
			if ( Len( Trim( arguments.subStatusCode ) ) ) {
				xml &= '<samlp:StatusCode Value="#arguments.subStatusCode#"/>';
			}
			xml &= '</samlp:StatusCode>';

			if ( Len( Trim( arguments.statusMessage ) ) ) {
				xml &= '<samlp:StatusMessage>#XmlFormat( arguments.statusMessage )#</samlp:StatusMessage>';
			}
			xml &= '</samlp:Status>';
			xml &= '<saml:Issuer>#XmlFormat( arguments.issuer )#</saml:Issuer>';

		return xml;
	}

	private string function _getAssertionHeader( required date instant, required string issuer, required string id ) {
		var xml  = '<saml:Assertion IssueInstant="#_dateTimeFormat( arguments.instant )#" Version="2.0" ID="#arguments.id#" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol">';
			xml &= '<saml:Issuer>#XmlFormat( arguments.issuer )#</saml:Issuer>';

		return xml;
	}

	private string function _getAssertionFooter() {
		return '</saml:Assertion>';
	}

	private string function _wrapAssertionInResponse( required string instant, required string inResponseTo, required string recipientUrl, required string issuer, required string assertion ) {
		var formattedInstant = _dateTimeFormat( arguments.instant );
		var xml  = _getXmlHeader();
		    xml &= '<samlp:Response ID="#_createSamlId()#"#( arguments.inResponseTo.len() ? ' InResponseTo="#arguments.inResponseTo#"' : '' )# Version="2.0" IssueInstant="#formattedInstant#" Destination="#arguments.recipientUrl#" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol">';
		    xml &= '<saml:Issuer xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">#arguments.issuer#</saml:Issuer>';
			xml &= '<samlp:Status xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol">';
			xml &= '<samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" />';
			xml &= '</samlp:Status>';
			xml &= arguments.assertion;
			xml &= '</samlp:Response>';

		return xml;
	}

	private string function _getResponseFooter() {
		return '</saml:Response>';
	}

	private string function _getSubject( required date instant, required string nameIdFormat, required string nameIdValue, required string inResponseTo, required string recipientUrl ) {
		var xml  = '<saml:Subject>';
		    xml &= '<saml:NameID Format="#arguments.nameIdFormat#">#nameIdValue#</saml:NameID>';

		if ( arguments.inResponseTo.len() ) {
		    xml &= '<saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">';
		    xml &= '<saml:SubjectConfirmationData InResponseTo="#arguments.inResponseTo#" Recipient="#arguments.recipientUrl#" NotOnOrAfter="#_dateTimeFormat( DateAdd( 'n', 2, instant ) )#" />';
		    xml &= '</saml:SubjectConfirmation>';
		}
		    xml &= '</saml:Subject>';

		return xml;
	}

	private string function _getConditions( required date instant, required string audience ) {
		var notBefore = _dateTimeFormat( DateAdd( 'n', -2, arguments.instant ) );
		var notAfter  = _dateTimeFormat( DateAdd( 'n',  2, arguments.instant ) );
		var xml       = '<saml:Conditions NotBefore="#notBefore#" NotOnOrAfter="#notAfter#">'
		    xml      &= '<saml:AudienceRestriction>';
		    xml      &= '<saml:Audience>#XmlFormat( arguments.audience )#</saml:Audience>';
		    xml      &= '</saml:AudienceRestriction>';
		    xml      &= '</saml:Conditions>';

		return xml;
	}

	private string function _getAuthenticationStatement( required date instant, required string sessionIndex, required numeric sessionTimeout ) {
		var inst   = _dateTimeFormat( arguments.instant );
		var expiry = _dateTimeFormat( DateAdd( 'n', arguments.sessionTimeout, arguments.instant ) );
		var xml    = '<saml:AuthnStatement AuthnInstant="#inst#" SessionIndex="#arguments.sessionIndex#" SessionNotOnOrAfter="#expiry#">';
		    xml   &= '<saml:AuthnContext>';
		    xml   &= '<saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</saml:AuthnContextClassRef>';
		    xml   &= '</saml:AuthnContext>';
		    xml   &= '</saml:AuthnStatement>';

		return xml;
	}

	private string function _getAttributesStatement( required struct attributes ) {
		var xml = '<saml:AttributeStatement>';

		for( var key in arguments.attributes ) {
			if ( _standardAttributes.keyExists( key ) ) {
				var attr = _standardAttributes[ key ];
				xml &= '<saml:Attribute FriendlyName="#attr.friendlyName#" Name="#attr.name#" NameFormat="#attr.nameFormat#">';
			} else {
				xml &= '<saml:Attribute Name="#key#">';
			}

			xml &= '<saml:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">#XmlFormat( arguments.attributes[ key ] )#</saml:AttributeValue>';
			xml &= '</saml:Attribute>';
		}

		xml &= '</saml:AttributeStatement>';

		return xml;
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

	private string function _getCertAlias() {
		return _certAlias;
	}
	private void function _setCertAlias( required string certAlias ) {
		_certAlias = arguments.certAlias;
	}

	private string function _getCertPass() {
		return _certPass;
	}
	private void function _setCertPass( required string certPass ) {
		_certPass = arguments.certPass;
	}
}