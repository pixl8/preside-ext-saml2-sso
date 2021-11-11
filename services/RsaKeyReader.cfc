component {

	public any function read( required string rsaPrivateKey ) {
		var pk = arguments.rsaPrivateKey.replace( "-----BEGIN PRIVATE KEY-----", "" );
        pk = pk.replace( "-----END PRIVATE KEY-----", "" );
        pk = pk.reReplace( "\s+", "", "all" );
        pk = pk.reReplace( "\n", "", "all" );

        var keySpec = CreateObject( "java", "java.security.spec.PKCS8EncodedKeySpec" ).init( toBinary( pk ) );
        var keyFactory = CreateObject( "java", "java.security.KeyFactory" ).getInstance( "RSA" );


        return keyFactory.generatePrivate( keySpec );
	}

}