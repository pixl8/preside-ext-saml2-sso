component {

	property name="x509CertReader"         inject="x509CertReader";
	property name="samlCertificateService" inject="samlCertificateService";

	public string function default( event, rc, prc, args={} ){
		var cert = args.data ?: "";

		if ( cert.len() ) {
			try {
				var certObj = x509CertReader.read( cert );

				args.certInfo = {
					  issuer            = certObj.getIssuerX500Principal().toString()
					, selfIssued        = certObj.getSubjectX500Principal().equals( certObj.getIssuerX500Principal() )
					, expires           = certObj.getNotAfter()
					, valid             = true
					, fingerprintSha256 = samlCertificateService.getCertificateFingerprint( certObj, "SHA-256" )
					, fingerprintSha1   = samlCertificateService.getCertificateFingerprint( certObj, "SHA-1" )
				};

				try {
					certObj.checkValidity();
				} catch( any e ) {
					args.certInfo.valid = false;
				}

			} catch( any e ) {
				return translateResource( uri="saml2:invalid.x509.message" );
			}

			return renderView( view="/renderers/content/x509summary/default", args=args );
		}

		return "";
	}

}