<cfscript>
	consumersExist = IsTrue( prc.consumersExist ?: "" );
	canAdd         = IsTrue( prc.canAdd         ?: "" );
	addConsumerLink = prc.addConsumerLink ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<cfif consumersExist>
			#renderView( view="/admin/datamanager/_objectDataTable", args={
				  objectName      = "saml2_consumer"
				, useMultiActions = false
				, datasourceUrl   = event.buildAdminLink( linkTo="saml2ProviderManagement.getConsumersForAjaxDataTables" )
				, gridFields      = [ "name", "sso_type", "sso_link" ]
			} )#
		<cfelse>
			<p class="alert alert-warning">
				<i class="fa fa-exclamation-circle"></i>
				#translateResource( "saml2:provider.no.consumers.message" )#
			</p>
			<cfif canAdd>
				<div class="text-center">
					<a href="#addConsumerLink#" class="btn btn-success">
						<i class="fa fa-fw fa-plus"></i>
						#translateResource( "saml2:provider.add.consumer.btn" )#
					</a>
				</div>
			</cfif>
		</cfif>
	</cfsavecontent>

	<cfif canAdd>
		<div class="top-right-button-group">
			<a href="#addConsumerLink#" class="pull-right inline">
				<button class="btn btn-success btn-sm">
					<i class="fa fa-fw fa-plus"></i>
					#translateResource( "saml2:provider.add.consumer.btn" )#
				</button>
			</a>
		</div>
	</cfif>

	#renderView(
		  view = "/admin/saml2ProviderManagement/_samlProviderManagementTabs"
		, args = { body=body, tab="consumers" }
	)#
</cfoutput>