component extends="preside.system.base.AdminHandler" {

	property name="consumerDao" inject="presidecms:object:saml2_consumer";

	public void function preHandler( event ) {
		super.preHandler( argumentCollection=arguments );

		if ( !hasCmsPermission( "saml2.provider.navigate" ) ) {
			event.adminAccessDenied();
		}

		prc.pageIcon = "fa-key";
		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2ProviderManagement" )
		);
	}

	public void function index( event, rc, prc ) {
		prc.pageTitle    = translateResource( "saml2:provider.page.title" );
		prc.pageSubTitle = translateResource( "saml2:provider.page.subtitle" );

		prc.consumersExist  = consumerDao.dataExists();
		prc.canAdd          = hasCmsPermission( "saml2.provider.manage" )
		prc.addConsumerLink = prc.canAdd ? event.buildAdminLink( "saml2ProviderManagement.addConsumer" ) : "";
	}

	public void function getConsumersForAjaxDataTables( event, rc, prc ) {
		runEvent(
			  event          = "admin.DataManager._getObjectRecordsForAjaxDataTables"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object      = "saml2_consumer"
				, gridFields  = "name"
				, actionsView = "/admin/saml2ProviderManagement/_consumerGridActions"
			}
		);
	}

	public void function addConsumer( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.provider.manage" ) ) {
			event.adminAccessDenied();
		}

		prc.pageTitle    = translateResource( "saml2:provider.addconsumer.page.title" );
		prc.pageSubTitle = translateResource( "saml2:provider.addconsumer.page.subtitle" );

		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.addconsumer.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2ProviderManagement.addconsumer" )
		);
	}

	public void function addConsumerAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.provider.manage" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._addRecordAction"
			, prePostExempt  = true
			, private        = true
			, eventArguments = {
				  object            = "saml2_consumer"
				, errorAction       = "saml2ProviderManagement.addConsumer"
				, viewRecordAction  = "saml2ProviderManagement.editConsumer"
				, successAction     = "saml2ProviderManagement"
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2providerconsumer"
				, auditAction       = "add_consumer"
			}
		);
	}

	public void function editConsumer( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.provider.manage" ) ) {
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
			, link  = event.buildAdminLink( linkto="saml2ProviderManagement.editConsumer", queryString="id=" & consumerId )
		);
	}

	public void function editConsumerAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.provider.manage" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._editRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object            = "saml2_consumer"
				, errorUrl          = event.buildAdminLink( linkto="saml2ProviderManagement.editConsumer", querystring="id=" & ( rc.id ?: "" )  )
				, successUrl        = event.buildAdminLink( linkto="saml2ProviderManagement" )
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2providerconsumer"
				, auditAction       = "edit_consumer"
			}
		);

	}

	function deleteConsumerAction( event, rc, prc ) {
		if( !hasCmsPermission( "saml2.provider.deleteConsumer" ) ) {
			event.adminAccessDenied();
		}

		runEvent(
			  event          = "admin.DataManager._deleteRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object      = "saml2_consumer"
				, postAction  = "saml2ProviderManagement"
				, audit       = true
				, auditType   = "saml2providerconsumer"
				, auditAction = "edit_consumer"
			}
		);
	}


}