<cfscript>
	addCertLink = event.buildAdminLink( objectName="saml2_certificate", operation="addRecord" );
	addCertBtnLabel = translateResource( "preside-objects.saml2_certificate:add.record.btn" );

</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		#objectDataTable( objectName="saml2_certificate", args={ allowManageFilter=false, allowFilter=false, allowDataExport=false } )#

		<p class="text-center">
			<a class="btn btn-success" href="#addCertLink#">
				<i class="fa fa-fw fa-plus"></i>
				#addCertBtnLabel#
			</a>
		</p>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2Admin/_samlAdminTabs"
		, args = { body=body, tab="certificates" }
	)#
</cfoutput>