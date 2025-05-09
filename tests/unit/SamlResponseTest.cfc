component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "init()", function(){
			it( "should initialize by passing a valid SAML response to its constructor", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				expect( rp ).toBeInstanceOf( "samlIdProvider.saml.response.SamlResponse" );
			} );
		} );

		describe( "getId()", function(){
			it( "should return the response id of the response object", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				expect( rp.getId() ).toBe( "id17743851592338314493643927" );
			} );
		} );

		describe( "getIssuer()", function(){
			it( "should return the issuer of the response object", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				expect( rp.getIssuer() ).toBe( "http://www.ssoidp.com/exk308r3dvLuLz7hs0i7" );
			} );
		} );

		describe( "getIssueInstant()", function(){
			it( "should return the date of the response object", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				expect( rp.getIssueInstant() ).toBe( "2019-11-06 13:13:29.580" );
			} );
		} );

		describe( "getType()", function(){
			it( "should return 'Response'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );

				expect( rp.getType() ).toBe( "Response" );
			} );
		} );

		describe( "getNameId()", function(){
			it( "should return 'AdminUser1@mysite.com'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );

				expect( rp.getNameId() ).toBe("AdminUser1@mysite.com");
			} );
		} );

		describe( "getNotBefore()", function(){
			it( "should return '2019-11-06T13:08:29.581'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );

				expect( rp.getNotBefore() ).toBe("2019-11-06T13:08:29.581");
			} );
		} );

		describe( "getNotAfter()", function(){
			it( "should return '2019-11-06T13:18:29.581'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );

				expect( rp.getNotAfter() ).toBe("2019-11-06T13:18:29.581");
			} );
		} );

		describe( "getAudience()", function(){
			it( "should return 'https://mysite.com/admin'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );

				expect( rp.getAudience() ).toBe("https://mysite.com/admin");
			} );
		} );

		describe( "getAttributes()", function(){
			it( "should return a structure with key 'Groups'", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				expect( rp.getAttributes() ).toHaveKey( "Groups" );
			} );
			it( "should return an array of strings if there are multiple values", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response.xml" ) );
				var attr = rp.getAttributes();
				expect( attr.groups ).toBeArray();
			} );
			it( "should return a string as its value if there's only one value", function(){
				var rp = _getResponse( FileRead( "/tests/resources/response/response_with_single_value_attribute.xml" ) );
				var attr = rp.getAttributes();
				expect( attr.groups ).toBeString();
			} );
		} );

	}

	private any function _getResponse( required string requestPath ) {
		return new samlIdProvider.saml.response.SamlResponse( arguments.requestPath );
	}

}