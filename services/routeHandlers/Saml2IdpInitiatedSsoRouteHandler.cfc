/**
 * @singleton
 */
component  {

	variables.urlPattern = "^\/saml2\/idpsso\/([\w\-\_]+)\/$";

// route handler methods
	public boolean function match( required string path, required any event ) {
		return arguments.path.reFindNoCase( urlPattern );
	}

	public void function translate( required string path, required any event ) {
		var providerSlug = arguments.path.reReplaceNoCase( urlPattern, "\1" );

		event.setValue( "providerSlug", providerSlug );
		event.setValue( "event", "saml2.idpsso" );
	}

	public boolean function reverseMatch( required struct buildArgs, required any event ) {
		return false;
	}

	public string function build( required struct buildArgs, required any event ) {
		return "";
	}
}