/**
 * @singleton true
 */
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
			  samlRequest = new SamlRequest( samlXml )
			, relayState  = postParams.relayState ?: ""
			, samlXml     = samlXml
		};
	}

// PRIVATE HELPERS
	private void function _checkPostParams() {
		if ( !_isPostRequest() ) {
			throw( type="saml.httpPostRequest.invalidMethod", message="SAML Request must be a POST request." );
		}

		if ( !StructKeyExists( _getPostParams(), "SAMLRequest" ) ) {
			throw( type="saml.httpPostRequest.missingParams", message="The required SAML POST Request parameter, [SAMLRequest], was not found" );
		}
	}

	private struct function _getPostParams() {
		return StructCopy( form );
	}

	private boolean function _isPostRequest() {
		var req = GetHTTPRequestData( false );

		return ( req.method ?: "GET" ) == "POST";
	}

}