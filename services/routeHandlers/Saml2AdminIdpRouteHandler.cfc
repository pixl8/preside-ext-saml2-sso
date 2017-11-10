/**
 * @singleton
 */
component  {

	/**
	 * @adminPath.inject           coldbox:setting:preside_admin_path
	 * @configuredProviders.inject coldbox:setting:saml2.identityProviders
	 */
	public any function init(
		  required string adminPath
		, required struct configuredProviders
	) {
		_setAdminPath( arguments.adminPath );
		_setConfiguredProviders( arguments.configuredProviders.keyArray() );
	}

// route handler methods
	public boolean function match( required string path, required any event ) {
		return ReFindNoCase( _getPathRegex(), arguments.path );
	}

	public void function translate( required string path, required any event ) {
		var providerSlug = arguments.path.reReplaceNoCase( _getPathRegex(), "\1" );

		event.setValue( "providerSlug", providerSlug );
		event.setValue( "event", "admin.saml2.login" );
	}

	public boolean function reverseMatch( required struct buildArgs, required any event ) {
		return arguments.buildArgs.keyExists( "saml2AdminIdpProvider" );
	}

	public string function build( required struct buildArgs, required any event ) {
		var link = "/#_getAdminPath()#/saml2login/#buildArgs.saml2AdminIdpProvider#/";

		if ( Len( Trim( buildArgs.queryString ?: "" ) ) ) {
			link &= "?" & buildArgs.queryString;
		}

		return event.getSiteUrl( includePath=false, includeLanguageSlug=false ) & link;
	}

// PRIVATE HELPERS
	private string function _getPathRegex() {
		return "^/#_getAdminPath()#/saml2login/(#_getConfiguredProviders().toList('|')#)/";
	}

// GETTERS AND SETTERS
	private string function _getAdminPath() {
		return _adminPath;
	}
	private void function _setAdminPath( required string adminPath ) {
		_adminPath = arguments.adminPath;
	}

	private array function _getConfiguredProviders() {
		return _configuredProviders;
	}
	private void function _setConfiguredProviders( required array configuredProviders ) {
		_configuredProviders = arguments.configuredProviders;
	}
}