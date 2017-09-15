component {
	this.name = "SAML Apis test suite";

	this.mappings[ '/tests'                                ] = ExpandPath( "/" );
	this.mappings[ '/testbox'                              ] = ExpandPath( "/testbox" );
	this.mappings[ '/javaloader'                           ] = ExpandPath( "/cbjavaloader/models/javaloader" );
	this.mappings[ '/samlIdProvider'                       ] = ExpandPath( "../services/" );
	this.mappings[ '/app/extensions/preside-ext-saml2-sso' ] = ExpandPath( "../" );

	setting requesttimeout="6000";

	public void function onRequest( required string requestedTemplate ) output=true {
		include template=arguments.requestedTemplate;
	}
}
