component extends="preside.system.base.AdminHandler" {

	property name="consumerDao"                   inject="presidecms:object:saml2_consumer";
	property name="samlProviderMetadataGenerator" inject="samlProviderMetadataGenerator";
	property name="samlIdentityProviderService"       inject="samlIdentityProviderService";
	property name="systemConfigurationService"    inject="systemConfigurationService";
	property name="messageBox"                    inject="coldbox:plugin:messageBox";

	public void function preHandler( event ) {
		super.preHandler( argumentCollection=arguments );

		if ( !hasCmsPermission( "saml2.navigate" ) ) {
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
			setNextEvent( url=event.buildAdminLink( "saml2Admin.consumers" ) );
		} else if ( IsFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml2.consumer.navigate" )) {
			setNextEvent( url=event.buildAdminLink( "saml2Admin.providers" ) );
		}

		event.adminAccessDenied();
	}

	public void function consumers( event, rc, prc ) {
		prc.consumersExist  = consumerDao.dataExists();
		prc.canAdd          = hasCmsPermission( "saml2.manage" )
		prc.addConsumerLink = prc.canAdd ? event.buildAdminLink( "saml2Admin.addConsumer" ) : "";
	}

	public void function getConsumersForAjaxDataTables( event, rc, prc ) {
		runEvent(
			  event          = "admin.DataManager._getObjectRecordsForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object      = "saml2_consumer"
				, gridFields  = "name,sso_type,sso_link"
				, actionsView = "/admin/saml2Admin/_consumerGridActions"
			}
		);
	}

	public void function addConsumer( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		prc.pageTitle    = translateResource( "saml2:provider.addconsumer.page.title" );
		prc.pageSubTitle = translateResource( "saml2:provider.addconsumer.page.subtitle" );

		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.addconsumer.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin.addconsumer" )
		);
	}

	public void function addConsumerAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._addRecordAction"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object            = "saml2_consumer"
				, errorAction       = "saml2Admin.addConsumer"
				, viewRecordAction  = "saml2Admin.editConsumer"
				, successAction     = "saml2Admin"
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2providerconsumer"
				, auditAction       = "add_consumer"
			}
		);
	}

	public void function editConsumer( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		var consumerId = rc.id ?: "";

		prc.consumer = consumerDao.selectData( id=consumerId );
		if ( !prc.consumer.recordCount ) {
			event.notFound();
		}

		prc.consumer = QueryRowToStruct( prc.consumer );

		prc.pageTitle    = translateResource( uri="saml2:provider.editConsumer.page.title", data=[ prc.consumer.name ] );
		prc.pageSubTitle = translateResource( uri="saml2:provider.editConsumer.page.subtitle", data=[ prc.consumer.name ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:provider.editConsumer.breadcrumb.title", data=[ prc.consumer.name ] )
			, link  = event.buildAdminLink( linkto="saml2Admin.editConsumer", queryString="id=" & consumerId )
		);
	}

	public void function editConsumerAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._editRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object            = "saml2_consumer"
				, errorUrl          = event.buildAdminLink( linkto="saml2Admin.editConsumer", querystring="id=" & ( rc.id ?: "" )  )
				, successUrl        = event.buildAdminLink( linkto="saml2Admin" )
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2providerconsumer"
				, auditAction       = "edit_consumer"
			}
		);

	}

	public void function deleteConsumerAction( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.deleteConsumer" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._deleteRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object      = "saml2_consumer"
				, postAction  = "saml2Admin"
				, audit       = true
				, auditType   = "saml2providerconsumer"
				, auditAction = "edit_consumer"
			}
		);
	}

	public void function settings( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		prc.configuration = systemConfigurationService.getCategorySettings( "saml2Provider" );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:provider.settings.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin.settings" )
		);
	}

	public void function saveSettingsAction( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.manage" ) ) {
			event.adminAccessDenied();
		}

		var formName         = "saml2.provider.settings";
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

		event.audit(
			  action = "saml2provider"
			, type   = "save_settings"
			, detail = formData
		);
		messageBox.info( translateResource( uri="saml2:provider.settings.saved" ) );

		setNextEvent( url=event.buildAdminLink( linkTo="saml2Admin" ) );

	}

	public void function previewMetadata( event, rc, prc ) {
		prc.providerEnabled = IsFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml2.provider.navigate" );
		prc.consumerEnabled = IsFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml2.consumer.navigate" );
		prc.tabsRequired     =  prc.providerEnabled && prc.consumerEnabled;

		if ( prc.providerEnabled ) {
			prc.idpMetadata = samlProviderMetadataGenerator.generateIdpMetadata();
		}
		if ( prc.consumerEnabled ) {
			prc.spMetadata = samlProviderMetadataGenerator.generateSpMetadata();
		}

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:provider.previewMetadata.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin.previewMetadata" )
		);
	}

	public void function downloadMetadata( event, rc, prc ) {
		var downloadType = rc.type ?: "idp";
		var metadata     = "";
		var fileName     = "";

		if ( downloadType == "sp" ) {
			fileName = "SPMetaData.xml";
			metadata = samlProviderMetadataGenerator.generateSpMetadata();
		} else {
			fileName = "IDPMetaData.xml";
			metadata = samlProviderMetadataGenerator.generateIdpMetadata();
		}

		header name="Content-Disposition" value="attachment; filename=""#fileName#""";
		content reset=true type="application/xml";WriteOutput( metadata );abort;
	}

	public void function providers( event, rc, prc ) {
		prc.providers = samlIdentityProviderService.listProviders();
	}

	public void function editProvider( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.consumer.manage" ) ) {
			event.adminAccessDenied();
		}

		var providerId = rc.id ?: "";

		prc.provider = samlIdentityProviderService.getProvider( providerId );
		if ( !prc.provider.count() ) {
			event.notFound();
		}

		prc.pageTitle    = translateResource( uri="saml2:consumer.editProvider.page.title", data=[ prc.provider.title ] );
		prc.pageSubTitle = translateResource( uri="saml2:consumer.editProvider.page.subtitle", data=[ prc.provider.description ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:consumer.editProvider.breadcrumb.title", data=[ prc.provider.title ] )
			, link  = event.buildAdminLink( linkto="saml2Admin.editProvider", queryString="id=" & providerId )
		);
	}

	public void function editProviderAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.consumer.manage" ) ) {
			event.adminAccessDenied();
		}

		rc.id = samlIdentityProviderService.getIdpIdBySlug( rc.id ?: "" );

		runEvent(
			  event          = "admin.DataManager._editRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object            = "saml2_identity_provider"
				, errorUrl          = event.buildAdminLink( linkto="saml2Admin.editProvider", querystring="id=" & ( rc.id ?: "" )  )
				, successUrl        = event.buildAdminLink( linkto="saml2Admin" )
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2consumerprovider"
				, auditAction       = "edit_provider"
			}
		);
	}
}