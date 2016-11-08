<cfscript>
	metadata = prc.metadata ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<div class="alert alert-info">
			<p>
				<i class="fa fa-fw fa-info-circle"></i>
				#translateResource( "saml2:provider.previewMetadata.explanation" )#
			</p>
			<p class="text-center">
				<a href="#event.buildAdminLink( 'saml2ProviderManagement.downloadMetadata' )#" class="btn btn-sm btn-info">
					<i class="fa fa-fw fa-download"></i>
					#translateResource( "saml2:provider.previewMetadata.download.btn" )#
				</a>
			</p>
		</div>
		<pre>#XmlFormat( Trim( metadata ) )#</pre>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2ProviderManagement/_samlProviderManagementTabs"
		, args = { body=body, tab="meta" }
	)#
</cfoutput>