component extends="testbox.system.BaseSpec" {

	variables.logoutRequestXml = '<?xml version="1.0" encoding="UTF-8"?><samlp:LogoutRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0" ID="a123" IssueInstant="2026-09-17T13:01:40Z" Destination="https://sp.example.com/slo"><saml:Issuer>https://idp.example.com/</saml:Issuer><saml:NameID>289937</saml:NameID><samlp:SessionIndex>68fef764d731c594ffbd3cc8900ff9ea</samlp:SessionIndex></samlp:LogoutRequest>';

	function run() {
		describe( "buildSignedQueryString()", function(){
			it( "should return a query string with the encoded SAML message, SigAlg and Signature parameters in that order", function(){
				var keyStore = _getKeyStore();
				var signer   = _getSigner( keyStore );

				var qs     = signer.buildSignedQueryString( samlXml=logoutRequestXml );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLRequest", "SigAlg", "Signature" ] );
				expect( UrlDecode( params.values.SigAlg ) ).toBe( "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256" );
				expect( Len( params.values.Signature ) ).toBeGT( 0 );
			} );

			it( "should include RelayState between the SAML message and SigAlg when supplied", function(){
				var keyStore = _getKeyStore();
				var signer   = _getSigner( keyStore );

				var qs     = signer.buildSignedQueryString( samlXml=logoutRequestXml, relayState="some relay/state" );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLRequest", "RelayState", "SigAlg", "Signature" ] );
				expect( UrlDecode( params.values.RelayState ) ).toBe( "some relay/state" );
			} );

			it( "should use the supplied parameter name for the SAML message", function(){
				var keyStore = _getKeyStore();
				var signer   = _getSigner( keyStore );

				var qs     = signer.buildSignedQueryString( samlXml=logoutRequestXml, paramName="SAMLResponse" );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLResponse", "SigAlg", "Signature" ] );
			} );

			it( "should deflate and base64 encode the SAML message so that it decodes back to the original XML", function(){
				var keyStore = _getKeyStore();
				var signer   = _getSigner( keyStore );

				var qs     = signer.buildSignedQueryString( samlXml=logoutRequestXml );
				var params = _parseQueryString( qs );

				expect( _inflate( UrlDecode( params.values.SAMLRequest ) ) ).toBe( logoutRequestXml );
			} );

			it( "should produce a signature over the raw query string (minus the Signature param) that validates against the keystore certificate", function(){
				var keyStore = _getKeyStore();
				var signer   = _getSigner( keyStore );
				var utils    = new samlIdProvider.OpenSamlUtils();

				var qs            = signer.buildSignedQueryString( samlXml=logoutRequestXml, relayState=CreateUUId() );
				var params        = _parseQueryString( qs );
				var signedContent = ListDeleteAt( qs, ListLen( qs, "&" ), "&" );

				expect( utils.validateRedirectBindingSignature(
					  signedContent = signedContent
					, signature     = UrlDecode( params.values.Signature )
					, sigAlg        = UrlDecode( params.values.SigAlg )
					, signingCert   = ToBase64( keyStore.getCert().getEncoded() )
				) ).toBeTrue();

				expect( utils.validateRedirectBindingSignature(
					  signedContent = signedContent & "x"
					, signature     = UrlDecode( params.values.Signature )
					, sigAlg        = UrlDecode( params.values.SigAlg )
					, signingCert   = ToBase64( keyStore.getCert().getEncoded() )
				) ).toBeFalse();
			} );

			it( "should choose a SigAlg appropriate to the keystore's key type", function(){
				var keyStore = new samlIdProvider.SamlKeyStore( ExpandPath( "/tests/resources/keystore/teststore" ), "teststorepass", "testkey", "testkeypass" );
				var signer   = _getSigner( keyStore );

				var qs     = signer.buildSignedQueryString( samlXml=logoutRequestXml );
				var params = _parseQueryString( qs );

				expect( UrlDecode( params.values.SigAlg ) ).toBe( "http://www.w3.org/2000/09/xmldsig##dsa-sha1" );
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getKeyStore() {
		return new samlIdProvider.SamlKeyStore( ExpandPath( "/tests/resources/keystore/teststore_rsa" ), "teststorepass", "testkey", "testkeypass" );
	}

	private any function _getSigner( required any keyStore ) {
		return new samlIdProvider.HttpRedirectBindingSigner(
			  deflateEncoder = new samlIdProvider.HttpRedirectRequestDeflateEncoder()
			, keyStore       = arguments.keyStore
		);
	}

	private struct function _parseQueryString( required string qs ) {
		var parsed = { names=[], values={} };

		for( var pair in ListToArray( arguments.qs, "&" ) ) {
			var name = ListFirst( pair, "=" );

			ArrayAppend( parsed.names, name );
			parsed.values[ name ] = ListRest( pair, "=" );
		}

		return parsed;
	}

	private string function _inflate( required string encoded ) {
		var decoder        = CreateObject( "java", "java.util.Base64" ).getMimeDecoder();
		var samlBytes      = decoder.decode( arguments.encoded.getBytes( "utf-8" ) );
		var byteClass      = CreateObject( "java", "java.lang.Byte" ).TYPE;
		var byteArray      = CreateObject( "java", "java.lang.reflect.Array" ).NewInstance( byteClass, 1024 );
		var byteIn         = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( samlBytes );
		var byteOut        = CreateObject( "java", "java.io.ByteArrayOutputStream" ).init();
		var inflater       = CreateObject( "java", "java.util.zip.Inflater" ).init( true );
		var inflaterStream = CreateObject( "java", "java.util.zip.InflaterInputStream" ).init( byteIn, inflater );
		var count          = inflaterStream.read( byteArray );

		while ( count != -1 ) {
			byteOut.write( byteArray, 0, count );
			count = inflaterStream.read( byteArray );
		}
		inflater.end();
		inflaterStream.close();

		return CreateObject( "java", "java.lang.String" ).init( byteOut.toByteArray(), "UTF-8" );
	}
}
