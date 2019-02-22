component {

// CONSTRUCTOR
	/**
	 * @keystoreFile.inject     coldbox:setting:saml2.keystore.filepath
	 * @keystorePassword.inject coldbox:setting:saml2.keystore.password
	 * @certAlias.inject        coldbox:setting:saml2.keystore.certAlias
	 * @certPassword.inject     coldbox:setting:saml2.keystore.certPassword
	 */
	public any function init(
		  required string keystoreFile
		, required string keystorePassword
		, required string certAlias
		, required string certPassword
	) {
		_setKeystoreFile( arguments.keystoreFile );
		_setKeystorePassword( arguments.keystorePassword );
		_setCertAlias( arguments.certAlias );
		_setCertPassword( arguments.certPassword );

		return this;
	}

// PUBLIC API METHODS
	public any function getKeyStore() {
		var ksfile      = CreateObject( "java", "java.io.File").init( _getKeystoreFile() );
		var inputStream = CreateObject( "java", "java.io.FileInputStream").init( ksfile );
		var keystore    = CreateObject( "java", "java.security.KeyStore" ).getInstance( "JKS" ); // JKS is the keystore type - may be variable

		keystore.load( inputStream, _getKeyStorePassword() );

		return keystore;
	}

	public any function getPrivateKey() {
		return getKeyStore().getKey( _getCertAlias(), _getCertPassword().toCharArray() );
	}

	public any function getCert() {
		return getKeyStore().getCertificate( _getCertAlias() );
	}

	public string function getFormattedX509Certificate( boolean multiline=false ) {
		var raw = ToBase64( getCert( _getCertAlias() ).getEncoded() );

		if ( !arguments.multiline ) {
			return raw;
		}

		var x509cert = "-----BEGIN CERTIFICATE-----" & Chr( 10 );

		for( var i=1; i <= raw.len(); i++ ) {
			x509cert &= raw[i];
			if ( !i mod 64 && i < raw.len() ) {
				x509cert &= Chr( 10 );
			}
		}
		x509cert &= Chr(10) & "-----END CERTIFICATE-----";

		return x509cert;
	}

// GETTERS AND SETTERS
	private string function _getKeystoreFile() {
		return _keystoreFile;
	}
	private void function _setKeystoreFile( required string keystoreFile ) {
		_keystoreFile = arguments.keystoreFile;
	}

	private string function _getKeyStorePassword() {
		return _keyStorePassword;
	}
	private void function _setKeyStorePassword( required string keyStorePassword ) {
		_keyStorePassword = arguments.keyStorePassword.toCharArray();
	}

	private any function _getCertAlias() {
		return _certAlias;
	}
	private void function _setCertAlias( required any certAlias ) {
		_certAlias = arguments.certAlias;
	}

	private string function _getCertPassword() {
		return _certPassword;
	}
	private void function _setCertPassword( required string certPassword ) {
		_certPassword = arguments.certPassword;
	}
}