component {

	private string function rootBreadcrumb() {
		event.addAdminBreadCrumb(
			  title = translateResource( "saml2:provider.breadcrumb.title" )
			, link  = event.buildAdminLink( linkto="saml2Admin" )
		);
	}

	private string function buildListingLink( event, rc, prc ) {
		return event.buildAdminLink( linkto="saml2admin.certificates" );
	}

	private string function renderRecord( event, rc, prc, args={} ) {
		args.certSummary = renderField(
			  object   = "saml2_certificate"
			, property = "public_cert"
			, data     = prc.record.public_cert ?: ""
			, context  = "admin"
			, editable = false
			, recordId = prc.recordId ?: ""
			, record   = QueryRowToStruct( prc.record )
		);

		return renderView( view="/admin/datamanager/saml2_certificate/renderRecord", args=args );
	}

}