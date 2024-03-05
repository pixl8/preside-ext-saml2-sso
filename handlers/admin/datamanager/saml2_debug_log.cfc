component extends="Saml2DataManagerBase" {

	variables.permissionBase = "saml2.debuglogs";

	variables.infoCol1 = [ "error" ];
	variables.infoCol3 = [ "provider", "created" ];

// STANDARD DATAMANAGER CUSTOMISATIONS
	private string function preRenderListing( event, rc, prc, args={} ) {
		var prerender = super.preRenderListing( argumentCollection=arguments );

		if ( getSystemSetting( "saml2provider", "debug_logs", "off" ) == "off" ) {
			prerender &= '<p class="alert alert-warning"><i class="fa fa-fw fa-info-circle"></i> #translateResource( 'preside-objects.saml2_debug_log:debugging.turned.off.warning' )#</p>'
		}

		return prerender;

	}

// VIEW SCREEN CUSTOMISATIONS
	private string function _defaultTab( event, rc, prc, args={} ) {
		return renderViewlet( event="admin.datahelpers.viewRecord", args=args );
	}

	private function _infoCardProvider() {
		var field = "";
		var obj   = "";

		if ( Len( Trim( args.record.sp ) ) ) {
			field = "sp";
			obj   = "saml2_sp";
		} else if ( Len( Trim( args.record.idp ) ) ) {
			field = "idp";
			obj   = "saml2_idp";
		}

		if ( Len( field ) ) {
			var link = event.buildAdminLink( objectName=obj, recordId=args.record[ field ] );
			var label = renderLabel( obj, args.record[ field ] );
			var icon  = translateResource( "preside-objects.#obj#:iconClass" );

			return '<i class="fa fa-fw #icon#"></i>&nbsp <a href="#link#">#label#</a>';
		}
		return '<i class="fa fa-fw fa-question light-grey"></i>&nbsp <em class="light-grey">#translateResource( "preside-objects.saml2_debug_log:unknown.provider" )#</em>';
	}

	private function _infoCardError() {
		var icon = renderContent( "boolean", isTrue( args.record.success ), "admin" ) & "&nbsp; ";

		if ( isTrue( args.record.success ) ) {
			return icon & translateResource( "preside-objects.saml2_debug_log:successful.request" );
		}

		var title = "<strong>#renderEnum( args.record.failure_reason, "saml2FailureReason" )#</strong>";
		var description = translateResource( "enum.saml2FailureReason:#args.record.failure_reason#.description" );

		if ( Len( Trim( description ) ) ) {
			description = "<br>" & description;
		}

		return icon & title & description;
	}
}