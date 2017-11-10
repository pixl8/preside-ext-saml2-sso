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
}