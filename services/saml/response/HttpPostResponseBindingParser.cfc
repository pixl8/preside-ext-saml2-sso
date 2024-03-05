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
		var samlXml    = ToString( ToBinary( postParams.SAMLResponse ?: "" ) );

		return {
			  samlResponse = new SamlResponse( samlXml )
			, relayState   = postParams.relayState ?: ""
			, samlXml      = samlXml
		};
	}

// PRIVATE HELPERS
	private void function _checkPostParams() {
		if ( !_isPostRequest() ) {
			throw( type="saml.httpPostRequest.invalidMethod", message="SAML Response must be a POST Response." );
		}

		if ( !StructKeyExists( _getPostParams(), "SAMLResponse" ) ) {
			throw( type="saml.httpPostResponse.missingParams", message="The required SAML POST Response parameter, [SAMLResponse], was not found" );
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