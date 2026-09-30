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

			it( "should return empty sigAlg, signature and signedContent when the request is not signed", function(){
				var parser = _getParser();

				url.clear();
				url.SAMLRequest = _getEncodedRequest();

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", "SAMLRequest=" & _getRawEncodedRequest() );

				var result = parser.parse();

				expect( result.sigAlg        ?: "x" ).toBe( "" );
				expect( result.signature     ?: "x" ).toBe( "" );
				expect( result.signedContent ?: "x" ).toBe( "SAMLRequest=" & _getRawEncodedRequest() );
			} );

			it( "should return SigAlg and Signature params when present in the GET params", function(){
				var parser    = _getParser();
				var sigAlg    = "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256";
				var signature = ToBase64( CreateUUId() );

				url.clear();
				url.SAMLRequest = _getEncodedRequest();
				url.SigAlg      = sigAlg;
				url.Signature   = signature;

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", "" );

				var result = parser.parse();

				expect( result.sigAlg    ?: "" ).toBe( sigAlg );
				expect( result.signature ?: "" ).toBe( signature );
			} );

			it( "should build signedContent from the raw query string, in SAMLRequest, RelayState, SigAlg order, preserving the sender's original encoding and excluding the Signature param", function(){
				var parser         = _getParser();
				var rawRequest     = _getRawEncodedRequest();
				var rawRelayState  = "LkHyk-gOkW1y4x8kceWexz4T";
				var rawSigAlg      = "http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256";
				var rawSignature   = "EtqhjtgbFx5PwO1SpzICDZov7hXyBOXR%2F8jMLmLaHzWJEKwS4tSzJy%2BjIg0lZUI%3D";
				var rawQueryString = "Signature=#rawSignature#&SigAlg=#rawSigAlg#&RelayState=#rawRelayState#&SAMLRequest=#rawRequest#";

				url.clear();
				url.SAMLRequest = UrlDecode( rawRequest );
				url.RelayState  = UrlDecode( rawRelayState );
				url.SigAlg      = UrlDecode( rawSigAlg );
				url.Signature   = UrlDecode( rawSignature );

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", rawQueryString );

				var result = parser.parse();

				expect( result.signedContent ?: "" ).toBe( "SAMLRequest=#rawRequest#&RelayState=#rawRelayState#&SigAlg=#rawSigAlg#" );
			} );

			it( "should omit RelayState from signedContent when not sent", function(){
				var parser         = _getParser();
				var rawRequest     = _getRawEncodedRequest();
				var rawSigAlg      = "http%3A%2F%2Fwww.w3.org%2F2000%2F09%2Fxmldsig%23rsa-sha1";
				var rawQueryString = "SAMLRequest=#rawRequest#&SigAlg=#rawSigAlg#&Signature=abc";

				url.clear();
				url.SAMLRequest = UrlDecode( rawRequest );
				url.SigAlg      = UrlDecode( rawSigAlg );
				url.Signature   = "abc";

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", rawQueryString );

				var result = parser.parse();

				expect( result.signedContent ?: "" ).toBe( "SAMLRequest=#rawRequest#&SigAlg=#rawSigAlg#" );
			} );

			it( "should preserve the parameter name casing used by the sender in signedContent", function(){
				var parser         = _getParser();
				var rawRequest     = _getRawEncodedRequest();
				var rawQueryString = "SAMLRequest=#rawRequest#&relaystate=abc&sigalg=rsa";

				url.clear();
				url.SAMLRequest = UrlDecode( rawRequest );
				url.RelayState  = "abc";
				url.SigAlg      = "rsa";
				url.Signature   = "sig";

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", rawQueryString );

				var result = parser.parse();

				expect( result.signedContent ?: "" ).toBe( "SAMLRequest=#rawRequest#&relaystate=abc&sigalg=rsa" );
			} );

			it( "should fall back to re-encoding the decoded url params for signedContent when the raw query string is unavailable", function(){
				var parser = _getParser();
				var sigAlg = "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256";

				url.clear();
				url.SAMLRequest = _getEncodedRequest();
				url.RelayState  = "relay state/with chars";
				url.SigAlg      = sigAlg;
				url.Signature   = "sig";

				parser.$( "_isGetRequest", true );
				parser.$( "_getRawQueryString", "" );

				var result  = parser.parse();
				var encoder = CreateObject( "java", "java.net.URLEncoder" );

				expect( result.signedContent ?: "" ).toBe( "SAMLRequest=#encoder.encode( _getEncodedRequest(), 'UTF-8' )#&RelayState=#encoder.encode( url.RelayState, 'UTF-8' )#&SigAlg=#encoder.encode( sigAlg, 'UTF-8' )#" );
			} );
		} );
	}

	private any function _getParser() {
		return getMockBox().createMock( object=new samlIdProvider.saml.request.HttpRedirectRequestBindingParser() );
	}

	private string function _getRawEncodedRequest() {
		return "fZHNTsMwEIRfJfLdjp2mTWIlqULTQyX%2BRBEHLsgKJolwbWNvoLw9bkulcuG6O9%2FO7my53O9U9CmdH42uECMULevSi52yvJlg0A%2FyY5IeoiDTnh8bFZqc5kb40XMtdtJz6Pi2ubnmCaHcOgOmMwpdIP8TwnvpIPij6Om8SKijaNNW6IUWSUEXVzle0fUKp0Wa4ryYZ3idtotZlhcLxpog9X6SG%2B1BaAg0ZSlmDM%2FoY8L4POMpJdl89oyiNtwyagFHkwHA8jhWb4PEdqA0IYHvR90nxI57lePBHNQ96QyZ3uPt9i5Gp3D40c%2FVhwk%2BjBDWnlnSG%2FNqnehg7CTREsr4kvjN9jaksGnvjRq776hRynytnBQgKwRukiiuT9TfJ9Q%2F";
	}

	private string function _getEncodedRequest() {
		return UrlDecode( _getRawEncodedRequest() );
	}

}