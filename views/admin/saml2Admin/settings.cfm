<cfscript>
	formId           = "saml2-provider-settings";
	configuration    = prc.configuration ?: {};
	validationResult = rc.validationResult ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<form id="#formId#" method="post" action="#event.buildAdminLink( linkTo='saml2Admin.saveSettingsAction' )#" data-auto-focus-form="true" data-dirty-form="protect" class="form-horizontal">
			#renderForm(
				  formName          = "saml2.provider.settings"
				, context           = "admin"
				, formId            = formId
				, savedData         = configuration
				, validationResult  = validationResult
			)#

			<div class="form-actions row">
				<div class="col-md-offset-2">
					<button class="btn btn-info" type="submit" tabindex="#getNextTabIndex()#">
						<i class="fa fa-check bigger-110"></i>
						#translateResource( "cms:save.btn" )#
					</button>
				</div>
			</div>
		</form>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2Admin/_samlProviderManagementTabs"
		, args = { body=body, tab="settings" }
	)#
</cfoutput>