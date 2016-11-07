<cfscript>
	if ( isFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml.provider.navigate" ) ) {
		WriteOutput( renderView(
			  view = "/admin/layout/sidebar/_menuItem"
			, args = {
				  active  = ListLast( event.getCurrentHandler(), ".") eq "saml2ProviderManagement"
				, link    = event.buildAdminLink( linkTo="saml2ProviderManagement" )
				, gotoKey = "s"
				, icon    = "fa-key"
				, title   = translateResource( 'saml2:provider.menu.title' )
			  }
		) );
	}

	if ( isFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml.consumer.navigate" ) ) {
		WriteOutput( renderView(
			  view = "/admin/layout/sidebar/_menuItem"
			, args = {
				  active  = ListLast( event.getCurrentHandler(), ".") eq "saml2ConsumerManagement"
				, link    = event.buildAdminLink( linkTo="saml2ConsumerManagement" )
				, gotoKey = "s"
				, icon    = "fa-key"
				, title   = translateResource( 'saml2:consumer.menu.title' )
			  }
		) );
	}
</cfscript>