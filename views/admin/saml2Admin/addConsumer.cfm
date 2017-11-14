<cfoutput>
	#renderView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "saml2_consumer"
		, addRecordAction       = event.buildAdminLink( linkTo='saml2Admin.addConsumerAction' )
		, cancelAction          = event.buildAdminLink( linkTo='saml2Admin' )
		, allowAddAnotherSwitch = false
	} )#
</cfoutput>