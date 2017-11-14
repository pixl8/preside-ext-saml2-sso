component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public struct function parse() {
		_checkUrlParams();

		var samlXml = _decode( url.samlResponse );

		return {
			  samlResponse = new SamlResponse( samlXml )
			, relayState  = url.relayState ?: ""
			, samlXml     = samlXml
		};
	}

// PRIVATE HELPERS
	private void function _checkUrlParams() {
		if ( !_isGetRequest() ) {
			throw( type="saml.httpRedirectResponse.invalidMethod", message="SAML Redirect Response must be a GET Response." );
		}

		if ( !url.keyExists( "SAMLResponse" ) ) {
			throw( type="saml.httpRedirectResponse.missingParams", message="The required SAML Response parameter, [SAMLResponse], was not found" );
		}
	}

	private boolean function _isGetRequest() {
		var req = getHTTPRequestData();

		return ( req.method ?: "" ) == "GET";
	}

	private string function _decode( required string encoded ) {
		try {
			var decoded = ToString( ToBinary( arguments.encoded ) );
			if ( IsXml( decoded ) ) {
				return decoded;
			}
		} catch( any e ) {}

		var Decoder        = CreateObject( "Java", "sun.misc.BASE64Decoder" ).init();
		var SamlByte       = Decoder.decodeBuffer( arguments.encoded );
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

// GETTERS AND SETTERS

}