/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="x509CertReader" inject="x509CertReader";
	property name="rsaKeyReader"   inject="rsaKeyReader";

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public string function getFormattedX509Certificate( required string certificateId, boolean multiline=false ) {
		var cert = $getPresideObject( "saml2_certificate" ).selectData(
			  id = arguments.certificateId
			, selectFields = [ "public_cert" ]
		).public_cert;

		if ( !arguments.multiline ) {
			cert = cert.replace("-----BEGIN CERTIFICATE-----", "");
	        cert = cert.replace("-----END CERTIFICATE-----", "");
	        cert = cert.reReplace("\s+","", "all");
	        cert = cert.reReplace("\n","", "all");
		} else if ( !ReFind( "\n", cert ) ) {
			var raw = cert;

			cert = "-----BEGIN CERTIFICATE-----" & Chr( 10 );

			for( var i=1; i <= raw.len(); i++ ) {
				cert &= raw[i];
				if ( !i mod 64 && i < raw.len() ) {
					cert &= Chr( 10 );
				}
			}
			cert &= Chr(10) & "-----END CERTIFICATE-----";
		}

		return cert;
	}

	public struct function getKeyPairForSigningCredential( required string certificateId ) {
		var cert = $getPresideObject( "saml2_certificate" ).selectData(
			  id = arguments.certificateId
			, selectFields = [ "public_cert", "private_key" ]
		);

		if ( !cert.recordCount ) {
			throw( type="saml2.certificate.not.found", message="Certificate with id [#arguments.certificateId#] not found." );
		}

		return {
			  privateKey        = rsaKeyReader.read( cert.private_key )
			, publicCertificate = x509CertReader.read( cert.public_cert )
		};
	}

// PRIVATE HELPERS

// GETTERS AND SETTERS

}