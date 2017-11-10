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

		_ensureProvidersExistInDb();

		return this;
	}

// PUBLIC API
	public array function listProviders() {
		var providers      = _getConfiguredProviders();
		var dbProviders    = $getPresideObject( "saml2_identity_provider" ).selectData();
		var dbProvidersMap = {};
		var list           = [];

		for( var provider in dbProviders ) {
			dbProvidersMap[ provider.slug ] = provider;
		}

		for( var providerId in providers ) {
			var provider = dbProvidersMap[ providerId ] ?: {};

			provider.append( {
				  id              = providerId
				, admin           = providers[ providerId ].admin           ?: true
				, web             = providers[ providerId ].web             ?: false
				, autoRegister    = providers[ providerId ].autoRegister    ?: true
				, postAuthHandler = providers[ providerId ].postAuthHandler ?: ""
				, title           = providers[ providerId ].title           ?: providerId
				, description     = providers[ providerId ].description     ?: ""
			} );

			list.append( provider );
		}

		return list.sort( function( a, b ){
			return a.title > b.title ? 1 : -1;
		} );
	}

// PRIVATE HELPERS
	private void function _ensureProvidersExistInDb() {
		var providers = _getConfiguredProviders();
		var dao       = $getPresideObject( "saml2_identity_provider" );

		for( var providerId in providers ) {
			if ( !dao.dataExists( filter={ slug=providerId } ) ) {
				dao.insertData( { slug=providerId } );
			}
		}
	}

// GETTERS / SETTERS
	private struct function _getConfiguredProviders() {
		return _configuredProviders;
	}
	private void function _setConfiguredProviders( required struct configuredProviders ) {
		_configuredProviders = arguments.configuredProviders;
	}
}