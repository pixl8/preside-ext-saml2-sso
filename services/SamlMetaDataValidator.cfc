/**
 * @validationProvider true
 * @singleton          true
 * @presideService     true
 */
component {

	property name="rsaKeyReader"   inject="rsaKeyReader";
	property name="x509CertReader" inject="x509CertReader";

	public any function init() {
		return this;
	}

	/**
	 * @validatorMessage saml2:invalid.metadata.message
	 */
	public boolean function samlMetadata( string value="" ) {
		if ( Len( Trim( arguments.value ) ) ) {
			try {
				var samlMeta = new SamlMetadata( arguments.value );

				return samlMeta.getEntityId().len() > 0;
			} catch( any e ) {
				return false;
			}
		}

		return true;
	}
	public string function samlMetadata_js() {
		return "function(){ return true; }";
	}


	/**
	 * @validatorMessage saml2:invalid.rsa.message
	 */
	public boolean function rsaPrivateKey( string value="" ) {
		if ( Len( arguments.value ) ) {
			try {
				rsaKeyReader.read( arguments.value )
			} catch( any e ) {
				$raiseError( e );
				return false;
			}
		}

		return true;
	}
	public string function rsaPrivateKey_js() {
		return "function(){ return true; }";
	}

	/**
	 * @validatorMessage saml2:invalid.x509.message
	 */
	public boolean function x509Cert( string value="" ) {
		if ( Len( arguments.value ) ) {
			try {
				x509CertReader.read( arguments.value )
			} catch( any e ) {
				$raiseError( e );
				return false;
			}
		}

		return true;
	}
	public string function x509Cert_js() {
		return "function(){ return true; }";
	}


}