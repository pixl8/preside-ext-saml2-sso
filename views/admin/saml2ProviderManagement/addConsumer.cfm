<cfoutput>
	#renderView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "saml2_consumer"
		, addRecordAction       = event.buildAdminLink( linkTo='saml2ProviderManagement.addConsumerAction' )
		, cancelAction          = event.buildAdminLink( linkTo='saml2ProviderManagement' )
		, allowAddAnotherSwitch = false
	} )#
</cfoutput>