/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @configuredProviders.inject coldbox:setting:saml2.identityProviders
	 *
	 */
	public any function init( required struct configuredProviders ) {
		_setConfiguredProviders( arguments.configuredProviders );

		return this;
	}

// PUBLIC API
	public array function listProviders() {
		var providers = _getConfiguredProviders();
		var list      = [];

		for( var providerId in providers ) {
			list.append( {
				  id              = providerId
				, admin           = providers[ providerId ].admin           ?: true
				, web             = providers[ providerId ].web             ?: false
				, autoRegister    = providers[ providerId ].autoRegister    ?: true
				, postAuthHandler = providers[ providerId ].postAuthHandler ?: ""
				, title           = providers[ providerId ].title           ?: providerId
				, description     = providers[ providerId ].description     ?: ""
			} );
		}

		return list.sort( function( a, b ){
			return a.title > b.title ? 1 : -1;
		} );
	}


// GETTERS / SETTERS
	private struct function _getConfiguredProviders() {
		return _configuredProviders;
	}
	private void function _setConfiguredProviders( required struct configuredProviders ) {
		_configuredProviders = arguments.configuredProviders;
	}
}