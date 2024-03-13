/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @samlEntityPool.inject                   samlEntityPool
	 * @httpPostRequestBindingParser.inject     httpPostRequestBindingParser
	 * @httpRedirectRequestBindingParser.inject httpRedirectRequestBindingParser
	 * @workflowService.inject                  samlSsoWorkflowService
	 * @openSamlUtils.inject                    openSamlUtils
	 *
	 */
	public any function init(
		  required any samlEntityPool
		, required any httpPostRequestBindingParser
		, required any httpRedirectRequestBindingParser
		, required any workflowService
		, required any openSamlUtils
	) {
		_setHttpPostRequestBindingParser( arguments.httpPostRequestBindingParser );
		_setHttpRedirectRequestBindingParser( arguments.httpRedirectRequestBindingParser );
		_setSamlEntityPool( arguments.samlEntityPool );
		_setWorkflowService( arguments.workflowService );
		_setOpenSamlUtils( arguments.openSamlUtils );

		return this;
	}

// PUBLIC API METHODS
	public struct function parse() {
		if ( !_getWorkflowService().loadSamlVarsFromStoredWorkflow() ) {
			_getWorkflowService().storeSamlVarsInWorkflow();
		}

		var parsedRequest = ( _isPostRequest() ? _getHttpPostRequestBindingParser() : _getHttpRedirectRequestBindinParser() ).parse();
		parsedRequest.samlRequest = parsedRequest.samlRequest.getMemento()

		if ( Len( Trim( parsedRequest.samlRequest.issuer ?: "" ) ) ) {
			parsedRequest.issuerEntity = $getPresideObject( "saml2_sp" ).selectData(
				filter={ entity_id=parsedRequest.samlRequest.issuer }
			);
			if ( parsedRequest.issuerEntity.recordCount ) {
				parsedRequest.issuerEntity = parsedRequest.issuerEntity.recordCount ? $helpers.queryRowToStruct( parsedRequest.issuerEntity ) : {};
			}

			if ( StructCount( parsedRequest.issuerEntity ) ) {
				if ( $helpers.isTrue( parsedRequest.issuerEntity.requests_will_be_signed ) ) {
					var sigValid = _getOpenSamlUtils().validateRequestSignature(
						  samlRequest = parsedRequest.samlXml
						, signingCert = parsedRequest.issuerEntity.signing_certificate
					);

					if ( !sigValid ) {
						parsedRequest.error = "invalidsignature";
					}
				}
			}

		} else {
			parsedRequest.issuerEntity = {};
		}
		return parsedRequest;
	}

// PRIVATE HELPERS
	private boolean function _isPostRequest() {
		var req = getHTTPRequestData( false );

		return ( req.method ?: "GET" ) == "POST";
	}

// GETTERS AND SETTERS
	private any function _getHttpPostRequestBindingParser() {
		return _httpPostRequestBindingParser;
	}
	private void function _setHttpPostRequestBindingParser( required any httpPostRequestBindingParser ) {
		_httpPostRequestBindingParser = arguments.httpPostRequestBindingParser;
	}

	private any function _getHttpRedirectRequestBindinParser() {
		return _HttpRedirectRequestBindinParser;
	}
	private void function _setHttpRedirectRequestBindingParser( required any HttpRedirectRequestBindinParser ) {
		_HttpRedirectRequestBindinParser = arguments.HttpRedirectRequestBindinParser;
	}

	private any function _getSamlEntityPool() {
		return _samlEntityPool;
	}
	private void function _setSamlEntityPool( required any samlEntityPool ) {
		_samlEntityPool = arguments.samlEntityPool;
	}

	private any function _getWorkflowService() {
		return _workflowService;
	}
	private void function _setWorkflowService( required any workflowService ) {
		_workflowService = arguments.workflowService;
	}

	private any function _getOpenSamlUtils() {
	    return _openSamlUtils;
	}
	private void function _setOpenSamlUtils( required any openSamlUtils ) {
	    _openSamlUtils = arguments.openSamlUtils;
	}
}