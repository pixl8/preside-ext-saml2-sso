/**
 * @singleton      true
 * @presideService true
 */
component {

	property name="logDao" inject="presidecms:object:saml2_debug_log";

	function init() {
		return this;
	}

	public void function log(
		required boolean success
		,        string  sp            = ""
		,        string  idp           = ""
		,        string  failurereason = ""
		,        string  requesttype   = ""
		,        string  samlXml       = ""
		,        string  relayState    = ""
		,        string  error         = ""
	) {
		if ( !_loggingEnabled( arguments.success ) ) {
			return;
		}

		logDao.insertData({
			  sp             = arguments.sp
			, idp            = arguments.idp
			, request_type   = arguments.requesttype
			, failure_reason = arguments.failurereason
			, success        = arguments.success
			, saml_xml       = arguments.samlXml
			, relay_state    = arguments.relayState
			, error          = arguments.error
		});
	}


// PRIVATE HELPERS
	private boolean function _loggingEnabled( success ) {
		var behaviour = $getPresideSetting( "saml2Provider", "debug_logs", "off" );

		if ( behaviour == "all" ) {
			return true;
		}
		if ( behaviour == "errorOnly" ) {
			return !arguments.success
		}

		return false;
	}
}