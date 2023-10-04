/**
 * @expressionCategory browser
 * @expressionContexts webrequest
**/
component {
	/**
	 * @serviceProviders.fieldType object
	 * @serviceProviders.object    saml2_consumer
	 * @serviceProviders.multiple  true
	 */
	private boolean function evaluateExpression( event, rc, prc, boolean _is=true, string serviceProviders="" ){
		var isSamlLoginRequest = false;

		if ( isStruct( rc.samlRequest ?: "" ) ) {
			if ( !len( arguments.serviceProviders ) || listFindNoCase( arguments.serviceProviders, rc.samlRequest.issuerEntity.consumerRecord.id ?: "" ) ) {
				isSamlLoginRequest = true;
			}
		}

		return isSamlLoginRequest == arguments._is;
	}
}