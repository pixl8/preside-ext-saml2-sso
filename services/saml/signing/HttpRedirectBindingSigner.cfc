/**
 * Builds signed query strings for the SAML HTTP-Redirect binding
 * (SAML Bindings 2.0, 3.4.4.1). The signature is calculated over
 * the URL-encoded SAMLRequest/SAMLResponse, RelayState and SigAlg
 * parameters and appended as a separate Signature parameter.
 *
 * @singleton true
 */
component {

// CONSTRUCTOR
	/**
	 * @deflateEncoder.inject         httpRedirectRequestDeflateEncoder
	 * @samlCertificateService.inject samlCertificateService
	 * @openSamlUtils.inject          openSamlUtils
	 */
	public any function init(
		  required any deflateEncoder
		, required any samlCertificateService
		, required any openSamlUtils
	) {
		_setDeflateEncoder( arguments.deflateEncoder );
		_setSamlCertificateService( arguments.samlCertificateService );
		_setOpenSamlUtils( arguments.openSamlUtils );

		return this;
	}

// PUBLIC API METHODS
	public string function buildSignedQueryString(
		  required string samlXml
		, required string privateKey
		, required string publicCertificate
		,          string paramName  = "SAMLRequest"
		,          string relayState = ""
	) {
		var osUtils    = _getOpenSamlUtils();
		var credential = _getSigningCredential( arguments.privateKey, arguments.publicCertificate );
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
	private any function _getSigningCredential( required string privateKey, required string publicCertificate ) {
		var keyPair = _getSamlCertificateService().getKeyPairForSigningCredential(
			  privateKey = arguments.privateKey
			, publicCert = arguments.publicCertificate
		);

		return _getOpenSamlUtils().getOpenSamlCredential(
			  privateKey  = keyPair.privateKey
			, certificate = keyPair.publicCertificate
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

	private any function _getSamlCertificateService() {
		return _samlCertificateService;
	}
	private void function _setSamlCertificateService( required any samlCertificateService ) {
		_samlCertificateService = arguments.samlCertificateService;
	}

	private any function _getOpenSamlUtils() {
		return _openSamlUtils;
	}
	private void function _setOpenSamlUtils( required any openSamlUtils ) {
		_openSamlUtils = arguments.openSamlUtils;
	}
}
