/**
 * Builds signed query strings for the SAML HTTP-Redirect binding
 * (SAML Bindings 2.0, 3.4.4.1). The signature is calculated over
 * the URL-encoded SAMLRequest/SAMLResponse, RelayState and SigAlg
 * parameters and appended as a separate Signature parameter.
 *
 * @singleton
 */
component {

// CONSTRUCTOR
	/**
	 * @deflateEncoder.inject httpRedirectRequestDeflateEncoder
	 * @keyStore.inject       samlKeyStore
	 */
	public any function init( required any deflateEncoder, required any keyStore ) {
		_setDeflateEncoder( arguments.deflateEncoder );
		_setKeyStore( arguments.keyStore );
		_setOpenSamlUtils( new OpenSamlUtils() );

		return this;
	}

// PUBLIC API METHODS
	public string function buildSignedQueryString(
		  required string samlXml
		,          string paramName  = "SAMLRequest"
		,          string relayState = ""
	) {
		var osUtils    = _getOpenSamlUtils();
		var credential = _getSigningCredential();
		var sigAlg     = osUtils.getRedirectBindingSigAlg( credential );
		var content    = arguments.paramName & "=" & _getDeflateEncoder().encode( arguments.samlXml );

		if ( Len( arguments.relayState ) ) {
			content &= "&RelayState=" & _urlEncode( arguments.relayState );
		}
		content &= "&SigAlg=" & _urlEncode( sigAlg );

		var signature = osUtils.signRedirectBindingContent(
			  content    = content
			, credential = credential
			, sigAlg     = sigAlg
		);

		return content & "&Signature=" & _urlEncode( signature );
	}

// PRIVATE HELPERS
	private any function _getSigningCredential() {
		var keyStore = _getKeyStore();

		return _getOpenSamlUtils().getOpenSamlCredential(
			  privateKey  = keyStore.getPrivateKey()
			, certificate = keyStore.getCert()
		);
	}

	private string function _urlEncode( required string value ) {
		return CreateObject( "java", "java.net.URLEncoder" ).encode( arguments.value, "UTF-8" );
	}

// GETTERS AND SETTERS
	private any function _getDeflateEncoder() {
		return _deflateEncoder;
	}
	private void function _setDeflateEncoder( required any deflateEncoder ) {
		_deflateEncoder = arguments.deflateEncoder;
	}

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
