<cfoutput>
	#renderView( view="/admin/datamanager/_editRecordForm", args={
		  object           = "saml2_consumer"
		, id               = ( rc.id ?: "" )
		, record           = prc.consumer ?: {}
		, editRecordAction = event.buildAdminLink( linkTo='saml2ProviderManagement.editConsumerAction' )
		, cancelAction     = event.buildAdminLink( linkTo='saml2ProviderManagement' )
	} )#
</cfoutput>