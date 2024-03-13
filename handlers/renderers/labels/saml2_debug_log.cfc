component {

	private array function _selectFields( event, rc, prc ) {
		return [
			  "saml2_debug_log.datecreated"
			, "saml2_debug_log.idp"
			, "saml2_debug_log.sp"
			, "saml2_debug_log.success"
			, "saml2_debug_log.request_type"
		];
	}

	private string function _renderLabel( datecreated, idp, sp, success, request_type ) {
		var i18nPrefix  = "preside-objects.saml2_debug_log:label.#( isTrue( arguments.success ) ? 'success' : 'failure' )#";
		var on          = renderContent( "datetime", arguments.datecreated, "relative" );
		var typ         = renderEnum( arguments.request_type, "saml2RequestType" );
		var provider    = "";

		if ( Len( arguments.sp ) ) {
			provider = renderLabel( "saml2_sp", arguments.sp );
		}
		if ( Len( arguments.idp ) ) {
			provider = renderLabel( "saml2_idp", arguments.idp );
		}

		if ( Len( provider ) ) {
			return translateResource( uri="#i18nPrefix#.with.provider", data=[ typ, provider, on ] )
		}
		return translateResource( uri="#i18nPrefix#.no.provider", data=[ typ, on ] )
	}

}