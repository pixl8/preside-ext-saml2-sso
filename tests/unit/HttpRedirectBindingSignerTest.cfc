component extends="testbox.system.BaseSpec" {

	variables.logoutRequestXml = '<?xml version="1.0" encoding="UTF-8"?><samlp:LogoutRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Version="2.0" ID="a123" IssueInstant="2026-09-17T13:01:40Z" Destination="https://sp.example.com/slo"><saml:Issuer>https://idp.example.com/</saml:Issuer><saml:NameID>289937</saml:NameID><samlp:SessionIndex>68fef764d731c594ffbd3cc8900ff9ea</samlp:SessionIndex></samlp:LogoutRequest>';

	function run() {
		describe( "buildSignedQueryString()", function(){
			it( "should return a query string with the encoded SAML message, SigAlg and Signature parameters in that order", function(){
				var signer = _getSigner();

				var qs     = _build( signer );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLRequest", "SigAlg", "Signature" ] );
				expect( UrlDecode( params.values.SigAlg ) ).toBe( "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256" );
				expect( Len( params.values.Signature ) ).toBeGT( 0 );
			} );

			it( "should include RelayState between the SAML message and SigAlg when supplied", function(){
				var signer = _getSigner();

				var qs     = _build( signer, { relayState="some relay/state" } );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLRequest", "RelayState", "SigAlg", "Signature" ] );
				expect( UrlDecode( params.values.RelayState ) ).toBe( "some relay/state" );
			} );

			it( "should use the supplied parameter name for the SAML message", function(){
				var signer = _getSigner();

				var qs     = _build( signer, { paramName="SAMLResponse" } );
				var params = _parseQueryString( qs );

				expect( params.names ).toBe( [ "SAMLResponse", "SigAlg", "Signature" ] );
			} );

			it( "should deflate and base64 encode the SAML message so that it decodes back to the original XML", function(){
				var signer = _getSigner();

				var qs     = _build( signer );
				var params = _parseQueryString( qs );

				expect( _inflate( UrlDecode( params.values.SAMLRequest ) ) ).toBe( logoutRequestXml );
			} );

			it( "should produce a signature over the raw query string (minus the Signature param) that validates against the signing certificate", function(){
				var signer = _getSigner();
				var utils  = _getOpenSamlUtils();

				var qs            = _build( signer, { relayState=CreateUUId() } );
				var params        = _parseQueryString( qs );
				var signedContent = ListDeleteAt( qs, ListLen( qs, "&" ), "&" );

				expect( utils.validateRedirectBindingSignature(
					  signedContent = signedContent
					, signature     = UrlDecode( params.values.Signature )
					, sigAlg        = UrlDecode( params.values.SigAlg )
					, signingCert   = _getTestCertPem()
				) ).toBeTrue();

				expect( utils.validateRedirectBindingSignature(
					  signedContent = signedContent & "x"
					, signature     = UrlDecode( params.values.Signature )
					, sigAlg        = UrlDecode( params.values.SigAlg )
					, signingCert   = _getTestCertPem()
				) ).toBeFalse();
			} );

			it( "should sign with the private key passed to it", function(){
				var signer   = _getSigner();
				var utils    = _getOpenSamlUtils();
				var otherKey = _generateOtherKeyPair();

				var qs            = _build( signer, { privateKey=otherKey.privatePem } );
				var params        = _parseQueryString( qs );
				var signedContent = ListDeleteAt( qs, ListLen( qs, "&" ), "&" );
				var signature     = UrlDecode( params.values.Signature );

				expect( _javaVerify( otherKey.publicKey, "SHA256withRSA", signedContent, signature ) ).toBeTrue();

				expect( utils.validateRedirectBindingSignature(
					  signedContent = signedContent
					, signature     = signature
					, sigAlg        = UrlDecode( params.values.SigAlg )
					, signingCert   = _getTestCertPem()
				) ).toBeFalse();
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getOpenSamlUtils() {
		return new samlIdProvider.saml.signing.OpenSamlUtils();
	}

	private any function _getSigner() {
		return new samlIdProvider.saml.signing.HttpRedirectBindingSigner(
			  deflateEncoder         = new samlIdProvider.saml.request.HttpRedirectRequestDeflateEncoder()
			, samlCertificateService = new samlIdProvider.saml.signing.SamlCertificateService()
			, openSamlUtils          = _getOpenSamlUtils()
		);
	}

	private string function _build( required any signer, struct overrides={} ) {
		var args = {
			  samlXml           = logoutRequestXml
			, privateKey        = _getTestPrivateKeyPem()
			, publicCertificate = _getTestCertPem()
		};

		StructAppend( args, arguments.overrides, true );

		return arguments.signer.buildSignedQueryString( argumentCollection=args );
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

	private struct function _generateOtherKeyPair() {
		var generator = CreateObject( "java", "java.security.KeyPairGenerator" ).getInstance( "RSA" );

		generator.initialize( 2048 );

		var keyPair = generator.generateKeyPair();

		return {
			  publicKey  = keyPair.getPublic()
			, privatePem = "-----BEGIN PRIVATE KEY-----" & Chr( 10 ) & ToBase64( keyPair.getPrivate().getEncoded() ) & Chr( 10 ) & "-----END PRIVATE KEY-----"
		};
	}

	private boolean function _javaVerify( required any publicKey, required string algorithm, required string content, required string signature ) {
		var verifier = CreateObject( "java", "java.security.Signature" ).getInstance( arguments.algorithm );

		verifier.initVerify( arguments.publicKey );
		verifier.update( arguments.content.getBytes( "UTF-8" ) );

		return verifier.verify( BinaryDecode( arguments.signature, "base64" ) );
	}

	private string function _getTestPrivateKeyPem() {
		return '-----BEGIN PRIVATE KEY----- MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDU3iBuHInoK8z6 4DEpz6euMPpzNZKc02QtO/AAjB8Q8nlrWdZ4HM6UlLYstcmukEP0Pkp5pcn9dYgd zemwfIQDt3QGgGkpxfagmbPTeZm8lzknzhz3ldd21oBV5viQUIGudY2Z2kn0mH6k e6kgBOMx8ARentTOB4SZbIwncp5v5y/mO/Si0vJaEjnvCUhLmufgZGByXg8wQ9yk vbswxVpHR4fDm7yix7D+vl3Fy3AwME4rvykcNBbQRrtRfuoWdeH3Lkk/5DrCNrq3 UM67zwJrybd4D0FfuRiDrrBawRtHEWwJ2LczcMYLF5UpCRgoQPGP30BW04PGGXee MLwGk+M5AgMBAAECggEALjDJHruonS2r/CBb6rO5sg3Euu08FDW2vi4MZUICl73V 5RqIdGXj2c/vPAJyciOx6zT9GiqEizBOyhDdjcNnLhtH3QVOTJc9bhoMMG5pksfJ yj5qgLsOFyZykLFe7InbqgyuHl2EwMO6b1y6FU2aM0Le391dVhvBhT1NqF2xzZwa Rigf9yJmoJSwqQqqN2M1TtrtUPjLTrI7DuqGxqG6AV2OQseu9bhQ93uq24MfaFxE fiiVhkKuoqxxzMT2gDBQYL7BdC0Jdb1A4HDjOi+hiGFZImIyhK3xiH20MdEsdNXk OXqBDpZJnkjwzok8Gwcy2PCmY3oe4cgpOzczZyMD5QKBgQD/9aBA2PauW2USxyX8 xAj0hhTOOCUI/NlgWUdFaZY8HQTJXDvUx1ZUemZ1yXvI+vP1PNZA8JTyqVcJIS+Y cso802Y4QQctuQ5qniuzVB7SMhsZRJSgeD7hUi3Sh9mkuvtLqSvPTmSWeUNQ3xNy gL1wvRsMINN1rZtLnSE8yRA5vwKBgQDU5sESQYcx0EfamZ2kdM4LlOts7hebuxoY VFzr4iQt7sqgTJbefTe+fCjFoqnurvM1slCxCNIo03rNsPQCnBz4/Wr1dFUuimnq 3O8bvuiFMUJv+lqo2FkI8IgSoYmLSOqY/9T8UygoEhke+yqBjnfSjD7TFx5PJ691 u1CUWZtxBwKBgHlam4AjXdGMw38DrJ8K0rQcXgDn3adFOkrUCVZ/mRsnJv3RHQzk 9alX3vw5atb/JGtBTNO9POFQKFPLyCUfR4NPN0e0jRLAinVCSLXdTD+cQfzY5x6t 5CIwNEl831Oa00osCvle0ZIGLERLf4zqPOcWwZwedCN3DAntlbScH3VBAoGBAMAo xnrDylKbuz8DB9Y31wF9GEDpZUWaSqNLAdOl+SG8NgcZGdMXEglL50D64IYeQkZk +4/OdmGC/4RIAvWYEk5p7PA+X+Px6kehwe85EIWnQF/xh4J+Q15eO3MVeh/NYHFX 99UG+WexbhsYd/UXse7HxqygYSrwlt2cg85iUnphAoGAa6E/CDFDXXWPWU0wubus qm3qWVK2AOQNi756RrOfqGA4bpF7uhbFYabam+Jr/HOMCeUi4Dx/InINmsVHUqMy hFO8NBfFT+UTd4b+qBlKejaKJ+fC6mkAM/Gh4DE1IcWIZYawjG7751q/zdXFYtG7 4ndulDsAhZBb9ZKDjyPmckk= -----END PRIVATE KEY-----';
	}

	private string function _getTestCertPem() {
		return '-----BEGIN CERTIFICATE----- MIICvTCCAaWgAwIBAgIEEPO/jDANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDEwR0 ZXN0MB4XDTI0MDMwNTE1MzMyNloXDTQ0MDIyOTE1MzMyNlowDzENMAsGA1UEAxME dGVzdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANTeIG4ciegrzPrg MSnPp64w+nM1kpzTZC078ACMHxDyeWtZ1ngczpSUtiy1ya6QQ/Q+Snmlyf11iB3N 6bB8hAO3dAaAaSnF9qCZs9N5mbyXOSfOHPeV13bWgFXm+JBQga51jZnaSfSYfqR7 qSAE4zHwBF6e1M4HhJlsjCdynm/nL+Y79KLS8loSOe8JSEua5+BkYHJeDzBD3KS9 uzDFWkdHh8ObvKLHsP6+XcXLcDAwTiu/KRw0FtBGu1F+6hZ14fcuST/kOsI2urdQ zrvPAmvJt3gPQV+5GIOusFrBG0cRbAnYtzNwxgsXlSkJGChA8Y/fQFbTg8YZd54w vAaT4zkCAwEAAaMhMB8wHQYDVR0OBBYEFJotgSMDJutN0LikqIAk9tdFfF0SMA0G CSqGSIb3DQEBCwUAA4IBAQB44ZYjYgnFwOiQxEy6jQQQvXp7GXcutFGS7XQlVomB kA3h6vKkua0cxg9SlvYXG2CfqmiRNuTKsDvzx0i+EHf927r4Hl6qEJIZ7KploM7V xEe8kpjlNUnNC2dGzpDsan882xe9ikxaKNa+A+asfLQTDPXp5F+hC8CfhlKEPhe7 fXi8oRgDWhJ8qcw92WKV9No3bKMxYEGTKO/bbkgWgOo+Zru1TLPpnc6a7LbCgDVc Tv1xHwRAuTbXWEzSQVfrhRJem8tl4wimcELWzBWN0mAzEspPEryE+hir8/+iLYbk zmZZj7DSwD7o4N3M2QG1kfbp0uL7NRwKY8NYCeELjXRx -----END CERTIFICATE-----';
	}
}
