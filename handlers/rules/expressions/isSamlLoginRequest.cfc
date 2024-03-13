/**
 * @expressionCategory browser
 * @expressionContexts webrequest
**/
component {

	property name="samlRequestParser" inject="samlRequestParser";

	/**
	 * @serviceProviders.fieldType object
	 * @serviceProviders.object    saml2_sp
	 * @serviceProviders.multiple  true
	 */
	private boolean function evaluateExpression( event, rc, prc, boolean _is=true, string serviceProviders="" ){
		var isSamlLoginRequest = false;
		var samlRequest        = "";

		if ( !StructKeyExists( rc, "samlRequest" ) || !IsStruct( rc.samlRequest ) ) {
			try {
				samlRequest = samlRequestParser.parse();

				if ( !IsStruct( samlRequest ) || StructKeyExists( samlRequest, "error" ) ||  !Len( samlRequest.samlRequest.type ?: "" ) || !StructKeyExists( samlRequest, "issuerentity" ) || !Len( samlRequest.issuerEntity ) ) {
					samlRequest = "";
				}
			} catch( any e ) {
				samlRequest = "";
			}
		} else {
			samlRequest = rc.samlRequest;
		}

		if ( IsStruct( samlRequest ) ) {
			isSamlLoginRequest = !Len( Trim( arguments.serviceProviders ) ) || ListFindNoCase( arguments.serviceProviders, samlRequest.issuerEntity.consumerRecord.id ?: "" );
		}

		return isSamlLoginRequest == arguments._is;
	}
}