component {

// CONSTRUCTOR
	public any function init() {
		_setLib( DirectoryList( ExpandPath( "/app/extensions/preside-ext-saml2-sso/services/lib" ), false, "path", "*.jar" ) );

		_bootstrapOpenSamlConfiguration();

		return this;
	}

// PUBLIC API METHODS
	public any function openSamlObjectToXml( required any openSaml, boolean toString=true ) {
		var mf         = _create( "org.opensaml.Configuration" ).getMarshallerFactory();
		var marshaller = mf.getMarshaller( arguments.openSaml );
		var marshalled = marshaller.marshall( arguments.openSaml );

		if ( toString ) {
			return _create( "org.opensaml.xml.util.XMLHelper" ).nodeToString( marshalled );
		}
	}

	public any function xmlToOpenSamlObject( required string xml ) {
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

	public any function getOpenSamlCredential( required any privateKey, required any certificate ) {
		var credential = _create( "org.opensaml.xml.security.x509.BasicX509Credential" );

		credential.setPrivateKey( arguments.privateKey );
		credential.setEntityCertificate( arguments.certificate );

		return credential;
	}

	public any function createAndPrepareOpenSamlSignature( required any credential ) {
		var bf        = _create( "org.opensaml.Configuration" ).getBuilderFactory();
		var signature = bf.getBuilder( _create( "org.opensaml.xml.signature.Signature" ).DEFAULT_ELEMENT_NAME ).buildObject();

		signature.setSigningCredential( credential );

		_create( "org.opensaml.xml.security.SecurityHelper" ).prepareSignatureParams( signature, credential, NullValue(), NullValue() );

		return signature;
	}

	public void function signSamlObject( required any signature ) {
		_create( "org.opensaml.xml.signature.Signer" ).signObject( arguments.signature );
	}

// PRIVATE HELPERS
	private any function _create( required string classPath ) {
		return CreateObject( "java", arguments.classPath, _getLib() );
	}

	private void function _bootstrapOpenSamlConfiguration() {
		try {
      		_create( "org.opensaml.DefaultBootstrap" ).bootstrap();
      	} catch ( any e ){}
	}

// GETTERS AND SETTERS
	private any function _getKeyStore() {
		return _keyStore;
	}
	private void function _setKeyStore( required any keyStore ) {
		_keyStore = arguments.keyStore;
	}

	private array function _getLib() {
		return _lib;
	}
	private void function _setLib( required array lib ) {
		_lib = arguments.lib;
	}
}