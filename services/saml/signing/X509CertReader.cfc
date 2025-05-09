component {

	public any function read( required string x509Cert ) {
		var x509 = arguments.x509Cert.replace("-----BEGIN CERTIFICATE-----", "");
        x509 = x509.replace("-----END CERTIFICATE-----", "");
        x509 = x509.reReplace("\s+","", "all");
        x509 = x509.reReplace("\n","", "all");

        var cf = CreateObject( "java", "java.security.cert.CertificateFactory" ).getInstance("X.509");
        var is = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( toBinary( x509 ) );

        return cf.generateCertificate( is );
	}

}