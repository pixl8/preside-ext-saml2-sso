component extends="testbox.system.BaseSpec" {

	variables.rsaSha256 = "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256";
	variables.rsaSha1   = "http://www.w3.org/2000/09/xmldsig##rsa-sha1";
	variables.dsaSha1   = "http://www.w3.org/2000/09/xmldsig##dsa-sha1";

	function run() {
		describe( "validateRedirectBindingSignature()", function(){
			it( "should return true when the signature was produced over the signed content with the private key of the given cert (RSA-SHA256)", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&RelayState=LkHyk-gOkW1y4x8kceWexz4T&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeTrue();
			} );

			it( "should return true for RSA-SHA1 signatures", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA1withRSA", content )
					, sigAlg        = rsaSha1
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeTrue();
			} );

			it( "should return true for DSA-SHA1 signatures", function(){
				var utils    = _getUtils();
				var keyStore = _getDsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23dsa-sha1";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA1withDSA", content )
					, sigAlg        = dsaSha1
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeTrue();
			} );

			it( "should accept certificates that are wrapped in PEM header and footer", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = keyStore.getFormattedX509Certificate( multiline=true )
				);

				expect( result ).toBeTrue();
			} );

			it( "should tolerate a base64 signature whose '+' characters were decoded to spaces by the web server", function(){
				var utils     = _getUtils();
				var keyStore  = _getRsaKeyStore();
				var content   = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";
				var signature = "";

				while ( !Find( "+", signature ) ) {
					content  &= "a";
					signature = _javaSign( keyStore, "SHA256withRSA", content );
				}

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = Replace( signature, "+", " ", "all" )
					, sigAlg        = rsaSha256
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeTrue();
			} );

			it( "should return false when the signed content has been tampered with", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&RelayState=original&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = Replace( content, "original", "tampered" )
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the signature was produced by a different key", function(){
				var utils       = _getUtils();
				var signingKs   = _getRsaKeyStore();
				var verifyingKs = _getDsaKeyStore();
				var content     = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( signingKs, "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getCertAsBase64( verifyingKs )
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the SigAlg does not match the algorithm used to sign", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = rsaSha1
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the SigAlg is unrecognised", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = "http://example.com/not-a-real-algorithm"
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false, and not error, when the signature is not valid base64", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();

				var result = utils.validateRedirectBindingSignature(
					  signedContent = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x"
					, signature     = "!!! not base64 !!!"
					, sigAlg        = rsaSha256
					, signingCert   = _getCertAsBase64( keyStore )
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false, and not error, when the signing cert is garbage", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( keyStore, "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = "not a certificate"
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when any of signedContent, signature or sigAlg are empty", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";
				var sig      = _javaSign( keyStore, "SHA256withRSA", content );
				var cert     = _getCertAsBase64( keyStore );

				expect( utils.validateRedirectBindingSignature( signedContent="", signature=sig, sigAlg=rsaSha256, signingCert=cert ) ).toBeFalse();
				expect( utils.validateRedirectBindingSignature( signedContent=content, signature="", sigAlg=rsaSha256, signingCert=cert ) ).toBeFalse();
				expect( utils.validateRedirectBindingSignature( signedContent=content, signature=sig, sigAlg="", signingCert=cert ) ).toBeFalse();
			} );
		} );

		describe( "signRedirectBindingContent()", function(){
			it( "should produce a base64 signature that verifies with the certificate's public key using the given algorithm", function(){
				var utils    = _getUtils();
				var keyStore = _getRsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256";

				var signature = utils.signRedirectBindingContent(
					  content    = content
					, credential = _getCredential( utils, keyStore )
					, sigAlg     = rsaSha256
				);

				expect( _javaVerify( keyStore, "SHA256withRSA", content, signature ) ).toBeTrue();
				expect( _javaVerify( keyStore, "SHA256withRSA", content & "tampered", signature ) ).toBeFalse();
			} );

			it( "should work with DSA keys", function(){
				var utils    = _getUtils();
				var keyStore = _getDsaKeyStore();
				var content  = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var signature = utils.signRedirectBindingContent(
					  content    = content
					, credential = _getCredential( utils, keyStore )
					, sigAlg     = dsaSha1
				);

				expect( _javaVerify( keyStore, "SHA1withDSA", content, signature ) ).toBeTrue();
			} );
		} );

		describe( "getRedirectBindingSigAlg()", function(){
			it( "should return RSA-SHA256 for RSA keys", function(){
				var utils = _getUtils();

				expect( utils.getRedirectBindingSigAlg( _getCredential( utils, _getRsaKeyStore() ) ) ).toBe( rsaSha256 );
			} );

			it( "should return DSA-SHA1 for DSA keys", function(){
				var utils = _getUtils();

				expect( utils.getRedirectBindingSigAlg( _getCredential( utils, _getDsaKeyStore() ) ) ).toBe( dsaSha1 );
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getUtils() {
		return new samlIdProvider.OpenSamlUtils();
	}

	private any function _getRsaKeyStore() {
		return new samlIdProvider.SamlKeyStore( ExpandPath( "/tests/resources/keystore/teststore_rsa" ), "teststorepass", "testkey", "testkeypass" );
	}

	private any function _getDsaKeyStore() {
		return new samlIdProvider.SamlKeyStore( ExpandPath( "/tests/resources/keystore/teststore" ), "teststorepass", "testkey", "testkeypass" );
	}

	private any function _getCredential( required any utils, required any keyStore ) {
		return arguments.utils.getOpenSamlCredential(
			  privateKey  = arguments.keyStore.getPrivateKey()
			, certificate = arguments.keyStore.getCert()
		);
	}

	private string function _getCertAsBase64( required any keyStore ) {
		return ToBase64( arguments.keyStore.getCert().getEncoded() );
	}

	private string function _javaSign( required any keyStore, required string algorithm, required string content ) {
		var signer = CreateObject( "java", "java.security.Signature" ).getInstance( arguments.algorithm );

		signer.initSign( arguments.keyStore.getPrivateKey() );
		signer.update( arguments.content.getBytes( "UTF-8" ) );

		return BinaryEncode( signer.sign(), "base64" );
	}

	private boolean function _javaVerify( required any keyStore, required string algorithm, required string content, required string signature ) {
		var verifier = CreateObject( "java", "java.security.Signature" ).getInstance( arguments.algorithm );

		verifier.initVerify( arguments.keyStore.getCert().getPublicKey() );
		verifier.update( arguments.content.getBytes( "UTF-8" ) );

		return verifier.verify( BinaryDecode( arguments.signature, "base64" ) );
	}
}
