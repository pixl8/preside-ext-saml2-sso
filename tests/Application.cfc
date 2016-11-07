component {
	this.name = "SAML Apis test suite";

	this.mappings[ '/tests'          ] = ExpandPath( "/" );
	this.mappings[ '/testbox'        ] = ExpandPath( "/tests/testbox" );
	this.mappings[ '/samlIdProvider' ] = ExpandPath( "../services/" );

	setting requesttimeout="6000";

	public void function onRequest( required string requestedTemplate ) output=true {
		include template=arguments.requestedTemplate;
	}
}