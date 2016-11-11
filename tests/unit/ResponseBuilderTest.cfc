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
				);

				expect( IsXml( response ) ).toBeTrue();

				var openSamlObjectRepresentingResponse = new samlIdProvider.OpenSamlUtils().xmlToOpenSamlObject( response );
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
		var testKeyStore = new samlIdProvider.SamlKeyStore( ExpandPath( "/tests/resources/keystore/teststore" ), "teststorepass", "testkey", "testkeypass" );
		var xmlSigner    = new samlIdProvider.SamlXmlSigner( testKeyStore );

		return getMockBox().createMock( object = new samlIdProvider.SamlResponseBuilder( xmlSigner=xmlSigner ) );
	}

}