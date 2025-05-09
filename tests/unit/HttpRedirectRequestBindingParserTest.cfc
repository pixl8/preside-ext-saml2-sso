component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "parse()", function(){
			it( "should return a samlRequestObject based on the encoded GET data", function(){
				var parser   = _getParser();

				parser.$( "_isGetRequest", true );

				url.SAMLRequest = UrlDecode( "fZHNTsMwEIRfJfLdjp2mTWIlqULTQyX%2BRBEHLsgKJolwbWNvoLw9bkulcuG6O9%2FO7my53O9U9CmdH42uECMULevSi52yvJlg0A%2FyY5IeoiDTnh8bFZqc5kb40XMtdtJz6Pi2ubnmCaHcOgOmMwpdIP8TwnvpIPij6Om8SKijaNNW6IUWSUEXVzle0fUKp0Wa4ryYZ3idtotZlhcLxpog9X6SG%2B1BaAg0ZSlmDM%2FoY8L4POMpJdl89oyiNtwyagFHkwHA8jhWb4PEdqA0IYHvR90nxI57lePBHNQ96QyZ3uPt9i5Gp3D40c%2FVhwk%2BjBDWnlnSG%2FNqnehg7CTREsr4kvjN9jaksGnvjRq776hRynytnBQgKwRukiiuT9TfJ9Q%2F" );

				var result = parser.parse();

				expect( result.samlRequest ?: "" ).toBeInstanceOf( "samlIdProvider.saml.request.SamlRequest" );
				expect( result.samlRequest.getId() ).toBe( "_092906B8-C0EC-4944-8957-E4D63789611A" );
			} );

			it( "should throw an informative error when the request is not a GET request", function(){
				var parser = _getParser();

				url.clear();

				parser.$( "_isGetRequest", false );

				expect( function(){
					parser.parse();
				} ).toThrow( "saml.httpRedirectRequest.invalidMethod" );
			} );

			it( "should throw an informative error when the request does not contain the required parameters", function(){
				var parser = _getParser();

				url.clear();

				parser.$( "_isGetRequest", true );

				expect( function(){
					parser.parse();
				} ).toThrow( "saml.httpRedirectRequest.missingParams" );
			} );

			it( "should return a RelayState if present in the GET params", function(){
				var parser = _getParser();

				parser.$( "_isGetRequest", true );

				url.SAMLRequest = UrlDecode( "fZHNTsMwEIRfJfLdjp2mTWIlqULTQyX%2BRBEHLsgKJolwbWNvoLw9bkulcuG6O9%2FO7my53O9U9CmdH42uECMULevSi52yvJlg0A%2FyY5IeoiDTnh8bFZqc5kb40XMtdtJz6Pi2ubnmCaHcOgOmMwpdIP8TwnvpIPij6Om8SKijaNNW6IUWSUEXVzle0fUKp0Wa4ryYZ3idtotZlhcLxpog9X6SG%2B1BaAg0ZSlmDM%2FoY8L4POMpJdl89oyiNtwyagFHkwHA8jhWb4PEdqA0IYHvR90nxI57lePBHNQ96QyZ3uPt9i5Gp3D40c%2FVhwk%2BjBDWnlnSG%2FNqnehg7CTREsr4kvjN9jaksGnvjRq776hRynytnBQgKwRukiiuT9TfJ9Q%2F" );
				url.relayState  = CreateUUId();

				var result = parser.parse();

				expect( result.relayState ?: "" ).toBe( relayState );
			} );
		} );
	}

	private any function _getParser() {
		return getMockBox().createMock( object=new samlIdProvider.saml.request.HttpRedirectRequestBindingParser() );
	}

}