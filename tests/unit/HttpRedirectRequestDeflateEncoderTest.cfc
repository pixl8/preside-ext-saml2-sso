component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "encode()", function(){
			it( "should take a SAML xml string and encode it useing deflate and base64 encoding the result", function(){
				var input   = '<?xml version="1.0"?><samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0" ID="_092906B8-C0EC-4944-8957-E4D63789611A" IssueInstant="2014-11-30T21:57:40.753Z" Destination="http://lfhe-ph002.staging2.pixl8-hosting.co.uk/SSO/"><saml:Issuer>https://app.staging.goodpractice.net</saml:Issuer><samlp:NameIDPolicy AllowCreate="true"/></samlp:AuthnRequest>';
				var encoder = new samlIdProvider.saml.request.HttpRedirectRequestDeflateEncoder();

				var encoded = encoder.encode( input );
				var decoded = _decode( UrlDecode( encoded ) );

				expect( decoded ).toBe( input );
			} );
		} );
	}

	private string function _decode( required string encoded ) {
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