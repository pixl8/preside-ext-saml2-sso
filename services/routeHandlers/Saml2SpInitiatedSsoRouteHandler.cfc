/**
 * @singleton
 */
component  {

	/**
	 * @samlIdentityProviderService.inject delayedInjector:samlIdentityProviderService
	 */
	public any function init( required struct samlIdentityProviderService ) {
		_setSamlIdentityProviderService( arguments.samlIdentityProviderService );
	}

// route handler methods
	public boolean function match( required string path, required any event ) {
		return _getSsoPaths().findNoCase( arguments.path );
	}

	public void function translate( required string path, required any event ) {
		var providers    = _getSamlIdentityProviderService().listProviders();
		var providerSlug = "";

		for( var provider in providers ) {
			if ( provider.loginUrl == arguments.path ) {
				providerSlug = provider.slug;
				break;
			}
		}

		event.setValue( "providerSlug", providerSlug );
		event.setValue( "event", "saml2.spSso" );
	}

	public boolean function reverseMatch( required struct buildArgs, required any event ) {
		return arguments.buildArgs.keyExists( "saml2IdpProvider" );
	}

	public string function build( required struct buildArgs, required any event ) {
		var providers    = _getSamlIdentityProviderService().listProviders();
		var link         = "";

		for( var provider in providers ) {
			if ( provider.slug == buildArgs.saml2IdpProvider ) {
				link = provider.loginUrl;
			}
		}

		if ( Len( Trim( buildArgs.queryString ?: "" ) ) ) {
			link &= "?" & buildArgs.queryString;
		}

		return event.getSiteUrl( includePath=false, includeLanguageSlug=false ) & link;
	}

// PRIVATE HELPERS
	private array function _getSsoPaths() {
		if ( variables.keyExists( "_cachedPaths" ) ) {
			return _cachedPaths;
		}
		var providers = _getSamlIdentityProviderService().listProviders();

		variables._cachedPaths = [];

		for( var provider in providers ) {
			_cachedPaths.append( provider.loginUrl );
		}


		return _cachedPaths;
	}

// GETTERS AND SETTERS
	private any function _getSamlIdentityProviderService() {
		return _samlIdentityProviderService;
	}
	private void function _setSamlIdentityProviderService( required any samlIdentityProviderService ) {
		_samlIdentityProviderService = arguments.samlIdentityProviderService;
	}
}