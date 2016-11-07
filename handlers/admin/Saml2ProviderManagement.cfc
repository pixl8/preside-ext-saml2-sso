component extends="preside.system.base.AdminHandler" {

	public void function preHandler( event ) {
		super.preHandler( argumentCollection=arguments );

		var prc = event.getCollection( private=true );

		prc.pageIcon = "fa-key";
		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2ProviderManagement" )
		);
	}


	public void function index( event, rc, prc ) {
		prc.pageTitle    = translateResource( "saml2:provider.page.title" );
		prc.pageSubTitle = translateResource( "saml2:provider.page.subtitle" );
	}

}