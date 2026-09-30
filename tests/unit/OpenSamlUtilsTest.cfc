component extends="testbox.system.BaseSpec" {

	variables.rsaSha256 = "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256";
	variables.rsaSha1   = "http://www.w3.org/2000/09/xmldsig##rsa-sha1";

	function run() {
		describe( "validateRedirectBindingSignature()", function(){
			it( "should return true when the signature was produced over the signed content with the private key of the given cert (RSA-SHA256)", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&RelayState=LkHyk-gOkW1y4x8kceWexz4T&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeTrue();
			} );

			it( "should return true for RSA-SHA1 signatures", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA1withRSA", content )
					, sigAlg        = rsaSha1
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeTrue();
			} );

			it( "should accept certificates that are wrapped in PEM header and footer", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertPem()
				);

				expect( result ).toBeTrue();
			} );

			it( "should tolerate a base64 signature whose '+' characters were decoded to spaces by the web server", function(){
				var utils     = _getUtils();
				var content   = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";
				var signature = "";

				while ( !Find( "+", signature ) ) {
					content  &= "a";
					signature = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content );
				}

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = Replace( signature, "+", " ", "all" )
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeTrue();
			} );

			it( "should return false when the signed content has been tampered with", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&RelayState=original&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = Replace( content, "original", "tampered" )
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the signature was produced by a different key", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _generateOtherPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the SigAlg does not match the algorithm used to sign", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha1
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when the SigAlg is unrecognised", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = "http://example.com/not-a-real-algorithm"
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false, and not error, when the signature is not valid base64", function(){
				var utils = _getUtils();

				var result = utils.validateRedirectBindingSignature(
					  signedContent = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x"
					, signature     = "!!! not base64 !!!"
					, sigAlg        = rsaSha256
					, signingCert   = _getTestCertBase64()
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false, and not error, when the signing cert is garbage", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var result = utils.validateRedirectBindingSignature(
					  signedContent = content
					, signature     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content )
					, sigAlg        = rsaSha256
					, signingCert   = "not a certificate"
				);

				expect( result ).toBeFalse();
			} );

			it( "should return false when any of signedContent, signature or sigAlg are empty", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";
				var sig     = _javaSign( _getTestPrivateKey(), "SHA256withRSA", content );
				var cert    = _getTestCertBase64();

				expect( utils.validateRedirectBindingSignature( signedContent="", signature=sig, sigAlg=rsaSha256, signingCert=cert ) ).toBeFalse();
				expect( utils.validateRedirectBindingSignature( signedContent=content, signature="", sigAlg=rsaSha256, signingCert=cert ) ).toBeFalse();
				expect( utils.validateRedirectBindingSignature( signedContent=content, signature=sig, sigAlg="", signingCert=cert ) ).toBeFalse();
			} );
		} );

		describe( "signRedirectBindingContent()", function(){
			it( "should produce a base64 signature that verifies with the certificate's public key using the given algorithm", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256";

				var signature = utils.signRedirectBindingContent(
					  content    = content
					, credential = _getTestCredential( utils )
					, sigAlg     = rsaSha256
				);

				expect( _javaVerify( "SHA256withRSA", content, signature ) ).toBeTrue();
				expect( _javaVerify( "SHA256withRSA", content & "tampered", signature ) ).toBeFalse();
			} );

			it( "should honour the requested algorithm", function(){
				var utils   = _getUtils();
				var content = "SAMLRequest=fJLNasMwEIRfJfLd&SigAlg=x";

				var signature = utils.signRedirectBindingContent(
					  content    = content
					, credential = _getTestCredential( utils )
					, sigAlg     = rsaSha1
				);

				expect( _javaVerify( "SHA1withRSA", content, signature ) ).toBeTrue();
				expect( _javaVerify( "SHA256withRSA", content, signature ) ).toBeFalse();
			} );
		} );

		describe( "getRedirectBindingSigAlg()", function(){
			it( "should return RSA-SHA256 for a certificate signed with SHA256withRSA", function(){
				var utils = _getUtils();

				expect( utils.getRedirectBindingSigAlg( _getTestCredential( utils ) ) ).toBe( rsaSha256 );
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getUtils() {
		return new samlIdProvider.saml.signing.OpenSamlUtils();
	}

	private any function _getTestPrivateKey() {
		return new samlIdProvider.saml.signing.RsaKeyReader().read( _getTestPrivateKeyPem() );
	}

	private any function _getTestCert() {
		return new samlIdProvider.saml.signing.X509CertReader().read( _getTestCertPem() );
	}

	private any function _getTestCredential( required any utils ) {
		return arguments.utils.getOpenSamlCredential(
			  privateKey  = _getTestPrivateKey()
			, certificate = _getTestCert()
		);
	}

	private string function _getTestCertBase64() {
		return ToBase64( _getTestCert().getEncoded() );
	}

	private any function _generateOtherPrivateKey() {
		var generator = CreateObject( "java", "java.security.KeyPairGenerator" ).getInstance( "RSA" );

		generator.initialize( 2048 );

		return generator.generateKeyPair().getPrivate();
	}

	private string function _javaSign( required any privateKey, required string algorithm, required string content ) {
		var signer = CreateObject( "java", "java.security.Signature" ).getInstance( arguments.algorithm );

		signer.initSign( arguments.privateKey );
		signer.update( arguments.content.getBytes( "UTF-8" ) );

		return BinaryEncode( signer.sign(), "base64" );
	}

	private boolean function _javaVerify( required string algorithm, required string content, required string signature ) {
		var verifier = CreateObject( "java", "java.security.Signature" ).getInstance( arguments.algorithm );

		verifier.initVerify( _getTestCert().getPublicKey() );
		verifier.update( arguments.content.getBytes( "UTF-8" ) );

		try {
			return verifier.verify( BinaryDecode( arguments.signature, "base64" ) );
		} catch ( any e ) {
			// A signature produced under a different digest does not decode as
			// this algorithm's DigestInfo. Some JDKs report that as an exception
			// rather than a failed verification.
			return false;
		}
	}

	private string function _getTestPrivateKeyPem() {
		return '-----BEGIN PRIVATE KEY----- MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDU3iBuHInoK8z6 4DEpz6euMPpzNZKc02QtO/AAjB8Q8nlrWdZ4HM6UlLYstcmukEP0Pkp5pcn9dYgd zemwfIQDt3QGgGkpxfagmbPTeZm8lzknzhz3ldd21oBV5viQUIGudY2Z2kn0mH6k e6kgBOMx8ARentTOB4SZbIwncp5v5y/mO/Si0vJaEjnvCUhLmufgZGByXg8wQ9yk vbswxVpHR4fDm7yix7D+vl3Fy3AwME4rvykcNBbQRrtRfuoWdeH3Lkk/5DrCNrq3 UM67zwJrybd4D0FfuRiDrrBawRtHEWwJ2LczcMYLF5UpCRgoQPGP30BW04PGGXee MLwGk+M5AgMBAAECggEALjDJHruonS2r/CBb6rO5sg3Euu08FDW2vi4MZUICl73V 5RqIdGXj2c/vPAJyciOx6zT9GiqEizBOyhDdjcNnLhtH3QVOTJc9bhoMMG5pksfJ yj5qgLsOFyZykLFe7InbqgyuHl2EwMO6b1y6FU2aM0Le391dVhvBhT1NqF2xzZwa Rigf9yJmoJSwqQqqN2M1TtrtUPjLTrI7DuqGxqG6AV2OQseu9bhQ93uq24MfaFxE fiiVhkKuoqxxzMT2gDBQYL7BdC0Jdb1A4HDjOi+hiGFZImIyhK3xiH20MdEsdNXk OXqBDpZJnkjwzok8Gwcy2PCmY3oe4cgpOzczZyMD5QKBgQD/9aBA2PauW2USxyX8 xAj0hhTOOCUI/NlgWUdFaZY8HQTJXDvUx1ZUemZ1yXvI+vP1PNZA8JTyqVcJIS+Y cso802Y4QQctuQ5qniuzVB7SMhsZRJSgeD7hUi3Sh9mkuvtLqSvPTmSWeUNQ3xNy gL1wvRsMINN1rZtLnSE8yRA5vwKBgQDU5sESQYcx0EfamZ2kdM4LlOts7hebuxoY VFzr4iQt7sqgTJbefTe+fCjFoqnurvM1slCxCNIo03rNsPQCnBz4/Wr1dFUuimnq 3O8bvuiFMUJv+lqo2FkI8IgSoYmLSOqY/9T8UygoEhke+yqBjnfSjD7TFx5PJ691 u1CUWZtxBwKBgHlam4AjXdGMw38DrJ8K0rQcXgDn3adFOkrUCVZ/mRsnJv3RHQzk 9alX3vw5atb/JGtBTNO9POFQKFPLyCUfR4NPN0e0jRLAinVCSLXdTD+cQfzY5x6t 5CIwNEl831Oa00osCvle0ZIGLERLf4zqPOcWwZwedCN3DAntlbScH3VBAoGBAMAo xnrDylKbuz8DB9Y31wF9GEDpZUWaSqNLAdOl+SG8NgcZGdMXEglL50D64IYeQkZk +4/OdmGC/4RIAvWYEk5p7PA+X+Px6kehwe85EIWnQF/xh4J+Q15eO3MVeh/NYHFX 99UG+WexbhsYd/UXse7HxqygYSrwlt2cg85iUnphAoGAa6E/CDFDXXWPWU0wubus qm3qWVK2AOQNi756RrOfqGA4bpF7uhbFYabam+Jr/HOMCeUi4Dx/InINmsVHUqMy hFO8NBfFT+UTd4b+qBlKejaKJ+fC6mkAM/Gh4DE1IcWIZYawjG7751q/zdXFYtG7 4ndulDsAhZBb9ZKDjyPmckk= -----END PRIVATE KEY-----';
	}

	private string function _getTestCertPem() {
		return '-----BEGIN CERTIFICATE----- MIICvTCCAaWgAwIBAgIEEPO/jDANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDEwR0 ZXN0MB4XDTI0MDMwNTE1MzMyNloXDTQ0MDIyOTE1MzMyNlowDzENMAsGA1UEAxME dGVzdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANTeIG4ciegrzPrg MSnPp64w+nM1kpzTZC078ACMHxDyeWtZ1ngczpSUtiy1ya6QQ/Q+Snmlyf11iB3N 6bB8hAO3dAaAaSnF9qCZs9N5mbyXOSfOHPeV13bWgFXm+JBQga51jZnaSfSYfqR7 qSAE4zHwBF6e1M4HhJlsjCdynm/nL+Y79KLS8loSOe8JSEua5+BkYHJeDzBD3KS9 uzDFWkdHh8ObvKLHsP6+XcXLcDAwTiu/KRw0FtBGu1F+6hZ14fcuST/kOsI2urdQ zrvPAmvJt3gPQV+5GIOusFrBG0cRbAnYtzNwxgsXlSkJGChA8Y/fQFbTg8YZd54w vAaT4zkCAwEAAaMhMB8wHQYDVR0OBBYEFJotgSMDJutN0LikqIAk9tdFfF0SMA0G CSqGSIb3DQEBCwUAA4IBAQB44ZYjYgnFwOiQxEy6jQQQvXp7GXcutFGS7XQlVomB kA3h6vKkua0cxg9SlvYXG2CfqmiRNuTKsDvzx0i+EHf927r4Hl6qEJIZ7KploM7V xEe8kpjlNUnNC2dGzpDsan882xe9ikxaKNa+A+asfLQTDPXp5F+hC8CfhlKEPhe7 fXi8oRgDWhJ8qcw92WKV9No3bKMxYEGTKO/bbkgWgOo+Zru1TLPpnc6a7LbCgDVc Tv1xHwRAuTbXWEzSQVfrhRJem8tl4wimcELWzBWN0mAzEspPEryE+hir8/+iLYbk zmZZj7DSwD7o4N3M2QG1kfbp0uL7NRwKY8NYCeELjXRx -----END CERTIFICATE-----';
	}
}
