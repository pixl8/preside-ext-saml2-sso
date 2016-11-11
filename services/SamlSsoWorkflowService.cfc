/**
 * @singleton      true
 * @presideService true
 */
component {
	/**
	 * @workflowService.inject workflowService
	 *
	 */
	public any function init( required any workflowService ) {
		_setWorkflowService( arguments.workflowService );

		return this;
	}

// PUBLIC API
	public boolean function loadSamlVarsFromStoredWorkflow() {
		var stateScope = _isPostRequest() ? form : url;

		if ( Len( Trim( stateScope.SAMLRequest ?: "" ) ) ) {
			return false;
		}

		var existingState = _getWorkflowService().getState( argumentCollection=_getWorkflowStateArgs() );
		stateScope.append( {
			  SAMLRequest = existingState.state.SAMLRequest ?: ""
			, relayState  = existingState.state.relayState  ?: ""
		}, false );

		return true;
	}

	public boolean function storeSamlVarsInWorkflow() {
		var stateScope = _isPostRequest() ? form : url;

		if ( !Len( Trim( stateScope.SAMLRequest ?: "" ) ) ) {
			return false;
		}

		var stateArgs  = _getWorkflowStateArgs();
		stateArgs.append( {
			  status  = 1
			, expires = DateAdd( 'n', 20, Now() )
			, state   = {
				  SAMLRequest = stateScope.SAMLRequest ?: ""
				, relayState  = stateScope.relayState  ?: ""
			  }
		} );

		_getWorkflowService().saveState( argumentCollection=stateArgs );

		return true;
	}

	public void function completeWorkflow() {
		_getWorkflowService().complete( argumentCollection=_getWorkflowStateArgs() );
	}


// PRIVATE HELPERS
	private struct function _getWorkflowStateArgs() {
		var stateArgs = { workflow = "saml2sso", reference="saml2sso" };
		if ( $isWebsiteUserLoggedIn() ) {
			stateArgs.owner = $getWebsiteLoggedInUserId();
		}

		return stateArgs;
	}

	private boolean function _isPostRequest() {
		var req = getHTTPRequestData();

		return ( req.method ?: "GET" ) == "POST";
	}

// GETTERS AND SETTERS
	private any function _getWorkflowService() {
		return _workflowService;
	}
	private void function _setWorkflowService( required any workflowService ) {
		_workflowService = arguments.workflowService;
	}
}