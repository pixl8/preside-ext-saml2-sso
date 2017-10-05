component {

// CONSTRUCTOR
	/**
	 * @keyStore.inject samlKeyStore
	 *
	 */
	public any function init( required any keyStore ) {
		_setKeyStore( arguments.keyStore );
		_setOpenSamlUtils( new OpenSamlUtils() );

		return this;
	}

// PUBLIC API METHODS
	public string function sign( required string xmlToSign ) {
		var osUtils    = _getOpenSamlUtils();
		var assertion  = osUtils.xmlToOpenSamlObject( arguments.xmlToSign );
		var credential = _getOpenSamlCredentialFromKeyStore();
		var signature  = osUtils.createAndPrepareOpenSamlSignature( credential );
		var signedXml  = "";

		assertion.setSignature( signature );

		osUtils.openSamlObjectToXml( assertion, false ); // odd looking but necessary. the process of doing this sets the signature into the object's internal XML definition
		osUtils.signSamlObject( signature );

		signedXml = osUtils.openSamlObjectToXml( assertion );
		signedXml = _stripWhitespaceFromX509Cert( signedXml );

		return signedXml;
	}

// PRIVATE HELPERS
	private any function _create( required string classPath ) {
		return CreateObject( "java", arguments.classPath, _getLib() );
	}

	private any function _getOpenSamlCredentialFromKeyStore() {
		var keystore   = _getKeyStore();

		return _getOpenSamlUtils().getOpenSamlCredential(
			  privateKey  = keystore.getPrivateKey()
			, certificate = keystore.getCert()
		);
	}

	public any function _xmlToOpenSamlObject( required string xml ) {
		var parserPool  = _create( "org.opensaml.xml.parse.BasicParserPool" ).init();
			parserPool.setNamespaceAware( true );

		var inputStream = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( arguments.xml.getBytes() );
		var DOM         = parserPool.parse( inputStream ).getDocumentElement();

		var unmarshallerFactory = _create( "org.opensaml.Configuration" ).getUnmarshallerFactory();
		var unmarshaller        = unmarshallerFactory.getUnmarshaller( DOM );

		if ( IsNull( unmarshaller ) ){
			throw( type="saml.invalid.saml", message="The XML passed was not valid saml", detail=arguments.xml );
		}

		var obj = unmarshaller.unmarshall( DOM );

		obj.validate( true );

		return obj;
	}

	private string function _stripWhitespaceFromX509Cert( required string samlXml ) {
		var cert = arguments.samlXml.reReplace( ".*?<ds:X509Certificate>(.*?)<\/ds:X509Certificate>.*", "\1" );

		cert = cert.reReplace( "\s", "", "all" );

		return arguments.samlXml.reReplace( "<ds:X509Certificate>(.*?)<\/ds:X509Certificate>", "<ds:X509Certificate>#cert#</ds:X509Certificate>" );
	}

// GETTERS AND SETTERS
	private any function _getKeyStore() {
		return _keyStore;
	}
	private void function _setKeyStore( required any keyStore ) {
		_keyStore = arguments.keyStore;
	}

	private any function _getOpenSamlUtils() {
		return _openSamlUtils;
	}
	private void function _setOpenSamlUtils( required any openSamlUtils ) {
		_openSamlUtils = arguments.openSamlUtils;
	}
}