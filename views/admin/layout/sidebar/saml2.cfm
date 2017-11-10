<cfscript>
	idpEnabled = isFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml.provider.navigate" );
	spEnabled  = isFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml.consumer.navigate" );

	if ( idpEnabled || spEnabled ) {
		subMenuItems = [];

		if ( idpEnabled ) {
			subMenuItems.append( {
				  link   = event.buildAdminLink( linkTo="saml2ProviderManagement" )
				, title  = translateResource( 'saml2:provider.menu.title' )
				, active = ListLast( event.getCurrentHandler(), ".") eq "saml2ProviderManagement"
			} );
		}
		if ( spEnabled ) {
			subMenuItems.append( {
				  link   = event.buildAdminLink( linkTo="saml2ConsumerManagement" )
				, title  = translateResource( 'saml2:consumer.menu.title' )
				, active = ListLast( event.getCurrentHandler(), ".") eq "saml2ConsumerManagement"
			} );
		}

		if ( subMenuItems.len() == 2 ) {
			WriteOutput( renderView(
				  view = "/admin/layout/sidebar/_menuItem"
				, args = {
					  active       = subMenuItems[1].active || subMenuItems[2].active
					, icon         = "fa-key"
					, title        = translateResource( 'saml2:sso.menu.title' )
					, subMenuItems = subMenuItems
				  }
			) );
		} else  {
			WriteOutput( renderView(
				  view = "/admin/layout/sidebar/_menuItem"
				, args = {
					  active = subMenuItems[1].active
					, title  = translateResource( 'saml2:sso.menu.title' )
					, link   = subMenuItems[1].link
					, icon   = "fa-key"
				  }
			) );
		}
	}
</cfscript>