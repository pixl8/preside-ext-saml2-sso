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
		_checkUrlParams();

		var samlXml = _decode( url.samlRequest );

		return {
			  samlRequest   = new SamlRequest( samlXml )
			, relayState    = url.relayState ?: ""
			, samlXml       = samlXml
			, sigAlg        = url.sigAlg    ?: ""
			, signature     = url.signature ?: ""
			, signedContent = _getSignedContent()
		};
	}

// PRIVATE HELPERS
	/**
	 * Reconstructs the string that an HTTP-Redirect binding signature
	 * covers: SAMLRequest=value&RelayState=value&SigAlg=value (RelayState
	 * only when present), using the URL-encoded values exactly as the
	 * sender transmitted them.
	 */
	private string function _getSignedContent() {
		var rawParams = _parseRawQueryString( _getRawQueryString() );
		var parts     = [];

		for( var paramName in [ "SAMLRequest", "RelayState", "SigAlg" ] ) {
			if ( StructKeyExists( rawParams, paramName ) ) {
				ArrayAppend( parts, rawParams[ paramName ].name & "=" & rawParams[ paramName ].value );
			} else if ( Len( url[ paramName ] ?: "" ) ) {
				ArrayAppend( parts, paramName & "=" & _urlEncode( url[ paramName ] ) );
			}
		}

		return ArrayToList( parts, "&" );
	}

	private struct function _parseRawQueryString( required string queryString ) {
		var params = {};

		for( var pair in ListToArray( arguments.queryString, "&" ) ) {
			var name  = ListFirst( pair, "=" );
			var value = Find( "=", pair ) ? Mid( pair, Find( "=", pair ) + 1, Len( pair ) ) : "";

			params[ name ] = { name=name, value=value };
		}

		return params;
	}

	private string function _getRawQueryString() {
		return cgi.query_string ?: "";
	}

	private string function _urlEncode( required string value ) {
		return CreateObject( "java", "java.net.URLEncoder" ).encode( arguments.value, "UTF-8" );
	}

	private void function _checkUrlParams() {
		if ( !_isGetRequest() ) {
			Throw( type="saml.httpRedirectRequest.invalidMethod", message="SAML Redirect Request must be a GET request." );
		}

		if ( !StructKeyExists( url, "SAMLRequest" ) ) {
			Throw( type="saml.httpRedirectRequest.missingParams", message="The required SAML Request parameter, [SAMLRequest], was not found" );
		}
	}

	private boolean function _isGetRequest() {
		var req = GetHTTPRequestData( false );

		return ( req.method ?: "" ) == "GET";
	}

	private string function _decode( required string encoded ) {
		try {
			var decoded = ToString( ToBinary( arguments.encoded ) );
			if ( IsXml( decoded ) ) {
				return decoded;
			}
		} catch( any e ) {}

		var Decoder        = CreateObject( "java", "java.util.Base64" ).getMimeDecoder();
		var SamlByte       = Decoder.decode( arguments.encoded.getBytes( "utf-8" ) );
		var ByteClass      = CreateObject( "Java", "java.lang.Byte" ).TYPE;
		var ByteArray      = CreateObject( "Java", "java.lang.reflect.Array" ).NewInstance( ByteClass, 1024 );
		var ByteIn         = CreateObject( "Java", "java.io.ByteArrayInputStream" ).init( SamlByte );
		var ByteOut        = CreateObject( "Java", "java.io.ByteArrayOutputStream" ).init();
		var Inflater       = CreateObject( "Java", "java.util.zip.Inflater" ).init( true );
		var InflaterStream = CreateObject( "Java", "java.util.zip.InflaterInputStream" ).init( ByteIn, Inflater );
		var Count          = InflaterStream.read( ByteArray );

		while ( Count != -1 ) {
		    ByteOut.write( ByteArray, 0, Count );
		    Count = InflaterStream.read( ByteArray );
		}
		Inflater.end();
		InflaterStream.close();

		return CreateObject( "Java", "java.lang.String" ).init( ByteOut.toByteArray() );
	}

}