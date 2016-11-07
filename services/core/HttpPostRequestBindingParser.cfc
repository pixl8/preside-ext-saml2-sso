component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public struct function parse() {
		_checkPostParams();

		var postParams = _getPostParams();
		var samlXml    = ToString( ToBinary( postParams.SAMLRequest ?: "" ) )

		return {
			  samlRequest = new samlIdProvider.core.SamlRequest( samlXml )
			, relayState  = postParams.relayState ?: ""
			, samlXml     = samlXml
		};
	}

// PRIVATE HELPERS
	private void function _checkPostParams() {
		if ( !_isPostRequest() ) {
			throw( type="saml.httpPostRequest.invalidMethod", message="SAML Request must be a POST request." );
		}

		if ( !_getPostParams().keyExists( "SAMLRequest" ) ) {
			throw( type="saml.httpPostRequest.missingParams", message="The required SAML POST Request parameter, [SAMLRequest], was not found" );
		}
	}

	private struct function _getPostParams() {
		return Duplicate( form );
	}

	private boolean function _isPostRequest() {
		var req = getHTTPRequestData();

		return ( req.method ?: "GET" ) == "POST";
	}

// GETTERS AND SETTERS

}