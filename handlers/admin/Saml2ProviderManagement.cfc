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

}