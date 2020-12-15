component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public string function encode( required string samlXml ) {
		var os            = CreateObject( "java", "java.io.ByteArrayOutputStream" );
		var deflaterClass = CreateObject( "java", "java.util.zip.Deflater" );
        var deflater      = deflaterClass.init( deflaterClass.DEFAULT_COMPRESSION, true );
        var deflaterOutputStream = CreateObject( "java", "java.util.zip.DeflaterOutputStream" ).init( os, deflater );
        var utf8 = CreateObject( "java", "java.nio.charset.StandardCharsets" ).UTF_8;

        deflaterOutputStream.write( arguments.samlXml.getBytes( "UTF-8" ) );
        deflaterOutputStream.close();
        os.close();

        var encoded = CreateObject( "java", "java.util.Base64" ).getMimeEncoder().encode( os.toByteArray() );
        var base64 = CreateObject( "java", "java.lang.String" ).init( encoded, utf8 );

        return CreateObject( "java", "java.net.URLEncoder" ).encode( base64, "UTF-8" );
    }
}