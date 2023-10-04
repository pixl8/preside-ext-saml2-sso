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
		if ( !isStruct( rc.samlRequest ?: "" ) ) {
			return false;
		}

		if ( len( arguments.serviceProviders ) ) {
			return listFindNoCase( arguments.serviceProviders, ( rc.samlRequest.issuerEntity.consumerRecord.id ?: "" ) );
		}

		return true;
	}
}