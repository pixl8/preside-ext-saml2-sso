/**
 * @validationProvider true
 */
component {

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

}