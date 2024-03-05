component extends="preside.system.base.AdminHandler" {

	property name="consumerDao"                   inject="presidecms:object:saml2_sp";
	property name="samlProviderMetadataGenerator" inject="samlProviderMetadataGenerator";
	property name="samlIdentityProviderService"       inject="samlIdentityProviderService";
	property name="systemConfigurationService"    inject="systemConfigurationService";
	property name="messageBox"                    inject="coldbox:plugin:messageBox";

	public void function preHandler( event ) {
		super.preHandler( argumentCollection=arguments );

		if ( !hasCmsPermission( "saml2.general.navigate" ) ) {
			event.adminAccessDenied();
		}

		prc.pageTitle    = translateResource( "saml2:admin.page.title" );
		prc.pageSubTitle = translateResource( "saml2:admin.page.subtitle" );
		prc.pageIcon     = "fa-key";

		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin" )
		);
	}

	public void function index( event, rc, prc ) {
		if ( IsFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml2.provider.navigate" ) ) {
			setNextEvent( url=event.buildAdminLink( objectName="saml2_sp" ) );
		} else if ( IsFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml2.consumer.navigate" )) {
			setNextEvent( url=event.buildAdminLink( objectName="saml2_idp" ) );
		}

		event.adminAccessDenied();
	}

	public void function settings( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.general.manage" ) ) {
			event.adminAccessDenied();
		}

		prc.configuration = samlProviderMetadataGenerator.getMetadataSettings();
		StructAppend( prc.configuration, getSystemCategorySettings( "saml2Provider" ) );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:provider.settings.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin.settings" )
		);
	}

	public void function saveSettingsAction( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.general.manage" ) ) {
			event.adminAccessDenied();
		}

		var formName         = "saml2.settings";
		var formData         = event.getCollectionForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( !validationResult.validated() ) {
			messageBox.error( translateResource( uri="saml2:provider.settings.error" ) );
			formData.validationResult = validationResult;
			setNextEvent( url=event.buildAdminLink( linkTo="saml2Admin.settings" ), persistStruct=formData );

		}

		for( var setting in formData ){
			systemConfigurationService.saveSetting(
				  category = "saml2Provider"
				, setting  = setting
				, value    = formData[ setting ]
			);
		}

		try {
			event.audit(
				  action = "saml2provider"
				, type   = "save_settings"
				, detail = formData
			);
		} catch ( any e ) {
			logError( e );
		}

		messageBox.info( translateResource( uri="saml2:provider.settings.saved" ) );

		setNextEvent( url=event.buildAdminLink( linkTo="saml2Admin" ) );

	}
}