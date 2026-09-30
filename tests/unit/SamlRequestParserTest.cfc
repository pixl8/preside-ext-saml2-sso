component extends="testbox.system.BaseSpec" {

	variables.rsaSha256 = "http://www.w3.org/2001/04/xmldsig-more##rsa-sha256";

	function run() {
		describe( "parse()", function(){
			describe( "signature validation for SPs whose record says requests will be signed", function(){
				it( "should validate using the detached HTTP-Redirect binding signature when SigAlg and Signature URL params were sent, and not attempt XML signature validation", function(){
					var utils           = _getUtilsMock( redirectValid=true, xmlValid=false );
					var redirectRequest = _getRedirectRequest( signature="c2lnbmF0dXJl", sigAlg=rsaSha256 );
					var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=true );

					var result = parser.parse();

					expect( result.issuerEntity.id ?: "" ).toBe( "sp-record-id" );
					expect( result.error ?: "" ).toBe( "" );

					var callLog = utils.$callLog();
					expect( ArrayLen( callLog.validateRedirectBindingSignature ) ).toBe( 1 );
					expect( ArrayLen( callLog.validateRequestSignature ) ).toBe( 0 );
					expect( callLog.validateRedirectBindingSignature[ 1 ] ).toBe( {
						  signedContent = redirectRequest.signedContent
						, signature     = redirectRequest.signature
						, sigAlg        = redirectRequest.sigAlg
						, signingCert   = "TESTCERT"
					} );
				} );

				it( "should flag an invalidsignature error when the detached HTTP-Redirect binding signature is invalid, without falling back to XML signature validation", function(){
					var utils           = _getUtilsMock( redirectValid=false, xmlValid=true );
					var redirectRequest = _getRedirectRequest( signature="c2lnbmF0dXJl", sigAlg=rsaSha256 );
					var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=true );

					var result = parser.parse();

					expect( result.error ?: "" ).toBe( "invalidsignature" );
					expect( ArrayLen( utils.$callLog().validateRequestSignature ) ).toBe( 0 );
				} );

				it( "should fall back to validating an XML signature embedded in the request when no Signature URL param was sent", function(){
					var utils           = _getUtilsMock( redirectValid=false, xmlValid=true );
					var redirectRequest = _getRedirectRequest();
					var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=true );

					var result = parser.parse();

					expect( result.error ?: "" ).toBe( "" );

					var callLog = utils.$callLog();
					expect( ArrayLen( callLog.validateRedirectBindingSignature ) ).toBe( 0 );
					expect( ArrayLen( callLog.validateRequestSignature ) ).toBe( 1 );
					expect( callLog.validateRequestSignature[ 1 ] ).toBe( {
						  samlRequest = redirectRequest.samlXml
						, signingCert = "TESTCERT"
					} );
				} );

				it( "should flag an invalidsignature error when neither a detached nor an embedded XML signature is valid", function(){
					var utils           = _getUtilsMock( redirectValid=false, xmlValid=false );
					var redirectRequest = _getRedirectRequest();
					var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=true );

					var result = parser.parse();

					expect( result.error ?: "" ).toBe( "invalidsignature" );
				} );
			} );

			it( "should not attempt any signature validation when the SP record does not say requests will be signed", function(){
				var utils           = _getUtilsMock( redirectValid=false, xmlValid=false );
				var redirectRequest = _getRedirectRequest( signature="c2lnbmF0dXJl", sigAlg=rsaSha256 );
				var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=false );

				var result = parser.parse();

				expect( result.error ?: "" ).toBe( "" );

				var callLog = utils.$callLog();
				expect( ArrayLen( callLog.validateRedirectBindingSignature ) ).toBe( 0 );
				expect( ArrayLen( callLog.validateRequestSignature ) ).toBe( 0 );
			} );

			it( "should return the sigAlg, signature and signedContent from the binding parser in the parsed result", function(){
				var utils           = _getUtilsMock( redirectValid=true, xmlValid=true );
				var redirectRequest = _getRedirectRequest( signature="c2lnbmF0dXJl", sigAlg=rsaSha256 );
				var parser          = _getParser( utils=utils, redirectRequest=redirectRequest, requestsWillBeSigned=true );

				var result = parser.parse();

				expect( result.sigAlg        ?: "" ).toBe( redirectRequest.sigAlg );
				expect( result.signature     ?: "" ).toBe( redirectRequest.signature );
				expect( result.signedContent ?: "" ).toBe( redirectRequest.signedContent );
			} );
		} );
	}

// PRIVATE HELPERS
	private any function _getParser(
		  required any     utils
		, required struct  redirectRequest
		, required boolean requestsWillBeSigned
	) {
		var workflowService = createStub();
		var redirectParser  = createStub();
		var spDao           = createStub();
		var spRecord        = QueryNew(
			  "id,entity_id,requests_will_be_signed,signing_certificate"
			, "varchar,varchar,bit,varchar"
			, [ [ "sp-record-id", "https://sp.example.com/", arguments.requestsWillBeSigned, "TESTCERT" ] ]
		);

		workflowService.$( "loadSamlVarsFromStoredWorkflow", true );
		redirectParser.$( "parse", arguments.redirectRequest );
		spDao.$( "selectData", spRecord );

		var parser = getMockBox().createMock( object=CreateObject( "app.extensions.preside-ext-saml2-sso.services.saml.request.SamlRequestParser" ).init(
			  samlEntityPool                   = createStub()
			, httpPostRequestBindingParser     = createStub()
			, httpRedirectRequestBindingParser = redirectParser
			, workflowService                  = workflowService
			, openSamlUtils                    = arguments.utils
		) );

		parser.$( "_isPostRequest", false );
		parser.$( "$getPresideObject" ).$args( "saml2_sp" ).$results( spDao );
		parser.$property( propertyName="$helpers", mock=_getHelpers() );

		return parser;
	}

	private struct function _getHelpers() {
		return {
			  isTrue           = function( value ){ return IsBoolean( arguments.value ) && arguments.value; }
			, queryRowToStruct = function( qry, row=1 ){
				var result = {};

				for( var column in ListToArray( arguments.qry.columnList ) ) {
					result[ column ] = arguments.qry[ column ][ arguments.row ];
				}

				return result;
			  }
		};
	}

	private any function _getUtilsMock( required boolean redirectValid, required boolean xmlValid ) {
		var utils = createStub();

		utils.$( method="validateRedirectBindingSignature", returns=arguments.redirectValid, callLogging=true );
		utils.$( method="validateRequestSignature"        , returns=arguments.xmlValid     , callLogging=true );

		return utils;
	}

	private struct function _getRedirectRequest( string signature="", string sigAlg="" ) {
		var samlXml     = FileRead( "/tests/resources/request/request_a.xml" );
		var samlRequest = createStub();

		samlRequest.$( "getMemento", { issuer="https://sp.example.com/", type="LogoutRequest", id="abc123" } );

		return {
			  samlRequest   = samlRequest
			, relayState    = "relay"
			, samlXml       = samlXml
			, sigAlg        = arguments.sigAlg
			, signature     = arguments.signature
			, signedContent = "SAMLRequest=abc&RelayState=relay&SigAlg=" & UrlEncodedFormat( arguments.sigAlg )
		};
	}
}
