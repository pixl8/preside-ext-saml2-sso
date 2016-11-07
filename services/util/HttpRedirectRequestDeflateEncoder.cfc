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

        deflaterOutputStream.write( arguments.samlXml.getBytes( "UTF-8" ) );
        deflaterOutputStream.close();
        os.close();

        var base64 = CreateObject( "java", "sun.misc.BASE64Encoder" ).encodeBuffer( os.toByteArray() );

        return CreateObject( "java", "java.net.URLEncoder" ).encode( base64, "UTF-8" );
    }
}