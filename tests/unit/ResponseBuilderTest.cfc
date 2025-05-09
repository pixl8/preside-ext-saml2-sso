component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "buildAuthenticationAssertion()", function(){
			it( "should return minimal authentication assertion response XML with minimal args", function(){
				var builder  = _getBuilder();
				var response = builder.buildAuthenticationAssertion(
					  issuer              = "http://www.thewebsite.com/"
					, nameIdFormat        = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
					, nameIdValue         = "test@test.com"
					, inResponseTo        = "aaf23196-1773-2113-474a-fe114412ab72"
					, recipientUrl        = "https://sp.example.com/SAML2/SSO/POST"
					, audience            = "https://sp.example.com/SAML2"
					, sessionTimeout      = 30
					, sessionIndex        = "C894146D-598F-4D9B-8733ACF80280C4B7"
					, attributes          = { email = "test@test.com", displayName="Test user", firstName="Test", lastName="user" }
					, privateKey          = testPk
					, publicCertificate   = testCert
				);

				expect( IsXml( response ) ).toBeTrue();
				expect( response contains "<saml:NameID Format" ).toBeTrue();

				var openSamlObjectRepresentingResponse = openSamlUtils.xmlToOpenSamlObject( response );
				try {
					openSamlObjectRepresentingResponse.validate( true );
				} catch ( any e ) {
					fail( "SAML did not validate" );
				}
			} );

			it( "should leave out format attribute of nameId when format is empty", function(){
				var builder  = _getBuilder();
				var response = builder.buildAuthenticationAssertion(
					  issuer              = "http://www.thewebsite.com/"
					, nameIdFormat        = ""
					, nameIdValue         = "test@test.com"
					, inResponseTo        = "aaf23196-1773-2113-474a-fe114412ab72"
					, recipientUrl        = "https://sp.example.com/SAML2/SSO/POST"
					, audience            = "https://sp.example.com/SAML2"
					, sessionTimeout      = 30
					, sessionIndex        = "C894146D-598F-4D9B-8733ACF80280C4B7"
					, attributes          = { email = "test@test.com", displayName="Test user", firstName="Test", lastName="user" }
					, privateKey          = testPk
					, publicCertificate   = testCert
				);

				expect( IsXml( response ) ).toBeTrue();
				expect( response contains "<saml:NameID>test@test.com</saml:NameID>" ).toBeTrue();
				expect( response contains "<saml:NameID Format" ).toBeFalse();

				var openSamlObjectRepresentingResponse = openSamlUtils.xmlToOpenSamlObject( response );
				try {
					openSamlObjectRepresentingResponse.validate( true );
				} catch ( any e ) {
					fail( "SAML did not validate" );
				}
			} );
		} );

		describe( "buildErrorResponse()", function(){
			it( "should return a signed error response", function(){
				var builder  = _getBuilder();
				var response = builder.buildErrorResponse(
					  statusCode          = "urn:oasis:names:tc:SAML:2.0:status:Responder"
					, subStatusCode       = "urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported"
					, statusMessage       = "My Error message"
					, issuer              = "http://www.thewebsite.com/"
					, inResponseTo        = "aaf23196-1773-2113-474a-fe114412ab72"
					, recipientUrl        = "https://sp.example.com/SAML2/SSO/POST"
				);

				expect( IsXml( response ) ).toBeTrue();
			} );
		} );
	}

	private any function _getBuilder() {
		variables.openSamlUtils = new samlIdProvider.saml.signing.OpenSamlUtils();

		var xmlSigner = new samlIdProvider.saml.signing.SamlXmlSigner(
			  samlCertificateService = new samlIdProvider.saml.signing.SamlCertificateService()
			, openSamlUtils          = openSamlUtils
		);

		variables.testPk = '-----BEGIN PRIVATE KEY----- MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDU3iBuHInoK8z6 4DEpz6euMPpzNZKc02QtO/AAjB8Q8nlrWdZ4HM6UlLYstcmukEP0Pkp5pcn9dYgd zemwfIQDt3QGgGkpxfagmbPTeZm8lzknzhz3ldd21oBV5viQUIGudY2Z2kn0mH6k e6kgBOMx8ARentTOB4SZbIwncp5v5y/mO/Si0vJaEjnvCUhLmufgZGByXg8wQ9yk vbswxVpHR4fDm7yix7D+vl3Fy3AwME4rvykcNBbQRrtRfuoWdeH3Lkk/5DrCNrq3 UM67zwJrybd4D0FfuRiDrrBawRtHEWwJ2LczcMYLF5UpCRgoQPGP30BW04PGGXee MLwGk+M5AgMBAAECggEALjDJHruonS2r/CBb6rO5sg3Euu08FDW2vi4MZUICl73V 5RqIdGXj2c/vPAJyciOx6zT9GiqEizBOyhDdjcNnLhtH3QVOTJc9bhoMMG5pksfJ yj5qgLsOFyZykLFe7InbqgyuHl2EwMO6b1y6FU2aM0Le391dVhvBhT1NqF2xzZwa Rigf9yJmoJSwqQqqN2M1TtrtUPjLTrI7DuqGxqG6AV2OQseu9bhQ93uq24MfaFxE fiiVhkKuoqxxzMT2gDBQYL7BdC0Jdb1A4HDjOi+hiGFZImIyhK3xiH20MdEsdNXk OXqBDpZJnkjwzok8Gwcy2PCmY3oe4cgpOzczZyMD5QKBgQD/9aBA2PauW2USxyX8 xAj0hhTOOCUI/NlgWUdFaZY8HQTJXDvUx1ZUemZ1yXvI+vP1PNZA8JTyqVcJIS+Y cso802Y4QQctuQ5qniuzVB7SMhsZRJSgeD7hUi3Sh9mkuvtLqSvPTmSWeUNQ3xNy gL1wvRsMINN1rZtLnSE8yRA5vwKBgQDU5sESQYcx0EfamZ2kdM4LlOts7hebuxoY VFzr4iQt7sqgTJbefTe+fCjFoqnurvM1slCxCNIo03rNsPQCnBz4/Wr1dFUuimnq 3O8bvuiFMUJv+lqo2FkI8IgSoYmLSOqY/9T8UygoEhke+yqBjnfSjD7TFx5PJ691 u1CUWZtxBwKBgHlam4AjXdGMw38DrJ8K0rQcXgDn3adFOkrUCVZ/mRsnJv3RHQzk 9alX3vw5atb/JGtBTNO9POFQKFPLyCUfR4NPN0e0jRLAinVCSLXdTD+cQfzY5x6t 5CIwNEl831Oa00osCvle0ZIGLERLf4zqPOcWwZwedCN3DAntlbScH3VBAoGBAMAo xnrDylKbuz8DB9Y31wF9GEDpZUWaSqNLAdOl+SG8NgcZGdMXEglL50D64IYeQkZk +4/OdmGC/4RIAvWYEk5p7PA+X+Px6kehwe85EIWnQF/xh4J+Q15eO3MVeh/NYHFX 99UG+WexbhsYd/UXse7HxqygYSrwlt2cg85iUnphAoGAa6E/CDFDXXWPWU0wubus qm3qWVK2AOQNi756RrOfqGA4bpF7uhbFYabam+Jr/HOMCeUi4Dx/InINmsVHUqMy hFO8NBfFT+UTd4b+qBlKejaKJ+fC6mkAM/Gh4DE1IcWIZYawjG7751q/zdXFYtG7 4ndulDsAhZBb9ZKDjyPmckk= -----END PRIVATE KEY-----';
		variables.testCert = '-----BEGIN CERTIFICATE----- MIICvTCCAaWgAwIBAgIEEPO/jDANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDEwR0 ZXN0MB4XDTI0MDMwNTE1MzMyNloXDTQ0MDIyOTE1MzMyNlowDzENMAsGA1UEAxME dGVzdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANTeIG4ciegrzPrg MSnPp64w+nM1kpzTZC078ACMHxDyeWtZ1ngczpSUtiy1ya6QQ/Q+Snmlyf11iB3N 6bB8hAO3dAaAaSnF9qCZs9N5mbyXOSfOHPeV13bWgFXm+JBQga51jZnaSfSYfqR7 qSAE4zHwBF6e1M4HhJlsjCdynm/nL+Y79KLS8loSOe8JSEua5+BkYHJeDzBD3KS9 uzDFWkdHh8ObvKLHsP6+XcXLcDAwTiu/KRw0FtBGu1F+6hZ14fcuST/kOsI2urdQ zrvPAmvJt3gPQV+5GIOusFrBG0cRbAnYtzNwxgsXlSkJGChA8Y/fQFbTg8YZd54w vAaT4zkCAwEAAaMhMB8wHQYDVR0OBBYEFJotgSMDJutN0LikqIAk9tdFfF0SMA0G CSqGSIb3DQEBCwUAA4IBAQB44ZYjYgnFwOiQxEy6jQQQvXp7GXcutFGS7XQlVomB kA3h6vKkua0cxg9SlvYXG2CfqmiRNuTKsDvzx0i+EHf927r4Hl6qEJIZ7KploM7V xEe8kpjlNUnNC2dGzpDsan882xe9ikxaKNa+A+asfLQTDPXp5F+hC8CfhlKEPhe7 fXi8oRgDWhJ8qcw92WKV9No3bKMxYEGTKO/bbkgWgOo+Zru1TLPpnc6a7LbCgDVc Tv1xHwRAuTbXWEzSQVfrhRJem8tl4wimcELWzBWN0mAzEspPEryE+hir8/+iLYbk zmZZj7DSwD7o4N3M2QG1kfbp0uL7NRwKY8NYCeELjXRx -----END CERTIFICATE-----';

		return getMockBox().createMock( object = new samlIdProvider.saml.response.SamlResponseBuilder( xmlSigner=xmlSigner ) );
	}

}