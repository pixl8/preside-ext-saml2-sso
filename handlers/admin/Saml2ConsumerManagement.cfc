component extends="preside.system.base.AdminHandler" {

	property name="messageBox"              inject="coldbox:plugin:messageBox";
	property name="identityProviderService" inject="identityProviderService";

	public void function preHandler( event ) {
		super.preHandler( argumentCollection=arguments );

		if ( !hasCmsPermission( "saml2.consumer.navigate" ) ) {
			event.adminAccessDenied();
		}

		prc.pageIcon = "fa-key";
		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:consumer.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2ConsumerManagement" )
		);
	}

	public void function index( event, rc, prc ) {
		prc.pageTitle    = translateResource( "saml2:consumer.page.title" );
		prc.pageSubTitle = translateResource( "saml2:consumer.page.subtitle" );

		prc.providers = identityProviderService.listProviders();

	}

	public void function editProvider( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.consumer.manage" ) ) {
			event.adminAccessDenied();
		}

		var providerId = rc.id ?: "";

		prc.provider = identityProviderService.getProvider( providerId );
		if ( !prc.provider.count() ) {
			event.notFound();
		}

		prc.pageTitle    = translateResource( uri="saml2:consumer.editProvider.page.title", data=[ prc.provider.title ] );
		prc.pageSubTitle = translateResource( uri="saml2:consumer.editProvider.page.subtitle", data=[ prc.provider.description ] );

		event.addAdminBreadCrumb(
			  title = translateResource( uri="saml2:consumer.editProvider.breadcrumb.title", data=[ prc.provider.title ] )
			, link  = event.buildAdminLink( linkto="saml2ConsumerManagement.editProvider", queryString="id=" & providerId )
		);
	}

	public void function editProviderAction( event, rc, prc ) {
		if ( !hasCmsPermission( "saml2.consumer.manage" ) ) {
			event.adminAccessDenied();
		}

		rc.id = identityProviderService.getIdpIdBySlug( rc.id ?: "" );

		runEvent(
			  event          = "admin.DataManager._editRecordAction"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				  object            = "saml2_identity_provider"
				, errorUrl          = event.buildAdminLink( linkto="saml2ConsumerManagement.editProvider", querystring="id=" & ( rc.id ?: "" )  )
				, successUrl        = event.buildAdminLink( linkto="saml2ConsumerManagement" )
				, redirectOnSuccess = true
				, audit             = true
				, auditType         = "saml2consumerprovider"
				, auditAction       = "edit_provider"
			}
		);
	}
}