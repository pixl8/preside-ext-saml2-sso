component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "init()", function(){
			it( "should initialize by passing a valid SAML request to its constructor", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );
				expect( rq ).toBeInstanceOf( "samlIdProvider.core.SamlRequest" );
			} );
		} );

		describe( "getId()", function(){
			it( "should return the request id of the request object", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );
				expect( rq.getId() ).toBe( "_bec424fa5103428909a30ff1e31168327f79474984" );
			} );
		} );

		describe( "getIssuer()", function(){
			it( "should return the issuer of the request object", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );
				expect( rq.getIssuer() ).toBe( "urn:mace:feide.no:services:no.feide.moodle" );
			} );
		} );

		describe( "getIssueInstant()", function(){
			it( "should return the date of the request object", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );
				expect( rq.getIssueInstant() ).toBe( "2007-12-10 11:39:34" );
			} );
		} );

		describe( "getType()", function(){
			it( "should return 'AuthnRequestType'", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );

				expect( rq.getType() ).toBe( "AuthnRequest" );
			} );
		} );

		describe( "mustForceAuthentication()", function(){
			it( "should return false by default", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a.xml" ) );

				expect( rq.mustForceAuthentication() ).toBeFalse();
			} );

			it( "should return true when request demands it", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a_with_forced_auth.xml" ) );

				expect( rq.mustForceAuthentication() ).toBeTrue();
			} );
		} );

		describe( "getNameIdPolicy()", function(){
			it( "should return a structure of name id policy info", function(){
				var rq = _getRequest( FileRead( "/tests/resources/request/request_a_with_forced_auth.xml" ) );

				expect( rq.getNameIdPolicy() ).toBe( {
					  format          = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
					, spNameQualifier = "moodle.bridge.feide.no"
					, allowCreate     = true
				} );
			} );
		} );
	}

	private any function _getRequest( required string requestPath ) {
		return new samlIdProvider.core.SamlRequest( arguments.requestPath );
	}

}