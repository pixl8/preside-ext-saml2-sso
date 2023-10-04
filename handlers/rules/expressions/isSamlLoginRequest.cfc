/**
 * @expressionCategory browser
 * @expressionContexts webrequest
**/
component {

	property name="samlRequestParser" inject="samlRequestParser";

	/**
	 * @serviceProviders.fieldType object
	 * @serviceProviders.object    saml2_consumer
	 * @serviceProviders.multiple  true
	 */
	private boolean function evaluateExpression( event, rc, prc, boolean _is=true, string serviceProviders="" ){
		var isSamlLoginRequest = false;
		var samlRequest        = prc.samlRequest ?: "";

		if ( !IsStruct( samlRequest ) ) {
			try {
				samlRequest = samlRequestParser.parse();
				if ( !IsStruct( samlRequest ) || StructKeyExists( samlRequest, "error" ) ||  !Len( samlRequest.samlRequest.type ?: "" ) || !StructKeyExists( samlRequest, "issuerentity" ) || !Len( samlRequest.issuerEntity ) ) {
					samlRequest = "";
				} else {
					prc.samlRequest = samlRequest;
				}
			} catch( any e ) {
				samlRequest = "";
			}
		}

		if ( IsStruct( samlRequest ) ) {
			isSamlLoginRequest = !Len( Trim( arguments.serviceProviders ) ) || ListFindNoCase( arguments.serviceProviders, samlRequest.issuerEntity.consumerRecord.id ?: "" ) );
		}

		return isSamlLoginRequest == arguments._is;
	}
}