component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "parse()", function(){
			it( "should return a samlRequestObject based on the POST data", function(){
				var parser = _getParser();

				parser.$( "_isPostRequest", true );

				form.SAMLRequest = toBase64( fileRead( "/tests/resources/request/request_a.xml" ) );

				var result = parser.parse();

				expect( result.samlRequest ?: "" ).toBeInstanceOf( "samlIdProvider.core.SamlRequest" );
				expect( result.samlRequest.getId() ).toBe( "_bec424fa5103428909a30ff1e31168327f79474984" );
			} );

			it( "should throw an informative error when the request is not a POST request", function(){
				var parser = _getParser();

				form.clear();

				parser.$( "_isPostRequest", false );

				expect( function(){
					parser.parse();
				} ).toThrow( "saml.httpPostRequest.invalidMethod" );
			} );

			it( "should throw an informative error when the request does not contain the required parameters", function(){
				var parser = _getParser();

				form.clear();

				parser.$( "_isPostRequest", true );

				expect( function(){
					parser.parse();
				} ).toThrow( "saml.httpPostRequest.missingParams" );
			} );

			it( "should return a RelayState if present in the POST params", function(){
				var parser = _getParser();
				var postParams = {
					  SAMLRequest = toBase64( fileRead( "/tests/resources/request/request_a.xml" ) )
					, relayState  = CreateUUId()
				};

				parser.$( "_isPostRequest", true );
				parser.$( "_getPostParams", postParams );


				var result = parser.parse();

				expect( result.relayState ?: "" ).toBe( postParams.relayState );
			} );
		} );
	}

	private any function _getParser() {
		return getMockBox().createMock( object=new samlIdProvider.core.HttpPostRequestBindingParser() );
	}

}