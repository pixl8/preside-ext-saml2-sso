component {

	property name="x509CertReader"         inject="x509CertReader";
	property name="samlCertificateService" inject="samlCertificateService";

	public string function default( event, rc, prc, args={} ){
		var cert = args.data ?: "";

		if ( cert.len() ) {
			try {
				var certObj = x509CertReader.read( cert );

				args.certInfo = {
					  issuer            = certObj.getIssuerDN().toString()
					, selfIssued        = certObj.isSelfIssued( certObj )
					, expires           = certObj.getNotAfter()
					, valid             = true
					, fingerprintSha256 = samlCertificateService.getCertificateFingerprint( cert, "SHA-256" )
					, fingerprintSha1   = samlCertificateService.getCertificateFingerprint( cert, "SHA-1" )
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