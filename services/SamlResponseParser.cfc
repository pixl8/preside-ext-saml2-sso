component {

// CONSTRUCTOR
	/**
	 * @httpPostResponseBindingParser.inject     httpPostResponseBindingParser
	 * @httpRedirectResponseBindingParser.inject httpRedirectResponseBindingParser
	 * @samlEntityPool.inject                    samlEntityPool
	 *
	 */
	public any function init(
		  required any httpPostResponseBindingParser
		, required any httpRedirectResponseBindingParser
		, required any samlEntityPool
	) {
		_setHttpPostResponseBindingParser( arguments.httpPostResponseBindingParser );
		_setHttpRedirectResponseBindingParser( arguments.httpRedirectResponseBindingParser );
		_setSamlEntityPool( arguments.samlEntityPool );
		_setOpenSamlUtils( new OpenSamlUtils() );

		return this;
	}

// PUBLIC API METHODS
	public struct function parse( string issuerType="idp" ) {
		var parsedResponse = ( _isPostRequest() ? _getHttpPostResponseBindingParser() : _getHttpRedirectResponseBindinParser() ).parse();

		parsedResponse.samlResponse = parsedResponse.samlResponse.getMemento()

		if ( Len( Trim( parsedResponse.samlResponse.issuer ?: "" ) ) ) {
			try {
				parsedResponse.issuerEntity = _getSamlEntityPool().getEntity(
					  entityId   = parsedResponse.samlResponse.issuer
					, entityType = arguments.issuerType
					, audience   = parsedResponse.samlResponse.audience
				);

				if ( arguments.issuerType == "idp" ) {
					if ( !IsBoolean( parsedResponse.issuerEntity.idpRecord.enabled ?: "" ) || ! parsedResponse.issuerEntity.idpRecord.enabled ) {
						throw( type="entitypool.missingidentity" );
					}
				} else {

				}

				var nowish = DateConvert( "local2Utc", Now() );
				if ( nowish > parsedResponse.samlResponse.notAfter || nowish < parsedResponse.samlResponse.notBefore ) {
					throw( type="saml2responseparser.assertion.timed.out", message="This login request has timed out. Please try again." );
				}

				if ( arguments.issuerType == "idp" ) {
					var signaturesValid = _getOpenSamlUtils().validateSignatures(
						  samlResponse = parsedResponse.samlXml
						, idpMeta      = parsedResponse.issuerEntity.idpRecord.metadata ?: ""
					);
					if ( !signaturesValid ) {
						throw(
							  type    = "saml2responseparser.invalid.signature"
							, message = "The assertion response failed signature validation."
							, detail  = parsedResponse.samlXml
						);
					}
				}
			} catch ( "entitypool.missingentity" e ) {
				parsedResponse.issuerEntity = {};
			}

		} else {
			parsedResponse.issuerEntity = {};
		}
		return parsedResponse;
	}

// PRIVATE HELPERS
	private boolean function _isPostRequest() {
		var req = getHTTPRequestData( false );

		return ( req.method ?: "GET" ) == "POST";
	}

// GETTERS AND SETTERS
	private any function _getHttpPostResponseBindingParser() {
		return _httpPostResponseBindingParser;
	}
	private void function _setHttpPostResponseBindingParser( required any httpPostResponseBindingParser ) {
		_httpPostResponseBindingParser = arguments.httpPostResponseBindingParser;
	}

	private any function _getHttpRedirectResponseBindinParser() {
		return _HttpRedirectResponseBindinParser;
	}
	private void function _setHttpRedirectResponseBindingParser( required any HttpRedirectResponseBindinParser ) {
		_HttpRedirectResponseBindinParser = arguments.HttpRedirectResponseBindinParser;
	}

	private any function _getSamlEntityPool() {
		return _samlEntityPool;
	}
	private void function _setSamlEntityPool( required any samlEntityPool ) {
		_samlEntityPool = arguments.samlEntityPool;
	}

	private any function _getOpenSamlUtils() {
		return _openSamlUtils;
	}
	private void function _setOpenSamlUtils( required any openSamlUtils ) {
		_openSamlUtils = arguments.openSamlUtils;
	}
}