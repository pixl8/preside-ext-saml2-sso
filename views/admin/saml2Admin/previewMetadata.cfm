<cfscript>
	metadata = prc.metadata ?: "";

	providerEnabled = IsTrue( prc.providerEnabled ?: "" );
	consumerEnabled = IsTrue( prc.consumerEnabled ?: "" );
	tabsRequired    = IsTrue( prc.tabsRequired    ?: "" );
	idpMetadata     = prc.idpMetadata ?: "";
	spMetadata      = prc.spMetadata  ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<cfif tabsRequired>
			<div class="tabbable tabs-left">
				<ul class="nav nav-tabs">
					<li class="active">
						<a data-toggle="tab" href="##tab-idp">
							<i class="fa fa-fw fa-code"></i>&nbsp;
							Identity Provider MetaData
						</a>
					</li>
					<li>
						<a data-toggle="tab" href="##tab-sp">
							<i class="fa fa-fw fa-code"></i>&nbsp;
							Service Provider MetaData
						</a>
					</li>
				</ul>

				<div class="tab-content">
		</cfif>

		<cfif providerEnabled>
			<div id="tab-idp" class="tab-pane active">
				<div class="alert alert-info">
					<p>
						<i class="fa fa-fw fa-info-circle"></i>
						#translateResource( "saml2:provider.previewMetadata.explanation" )#
					</p>
					<p class="text-center">
						<a href="#event.buildAdminLink( 'saml2Admin.downloadMetadata' )#" class="btn btn-sm btn-info">
							<i class="fa fa-fw fa-download"></i>
							#translateResource( "saml2:provider.previewMetadata.download.btn" )#
						</a>
					</p>
				</div>
				<pre>#XmlFormat( Trim( idpMetadata ) )#</pre>
			</div>
		</cfif>
		<cfif consumerEnabled>
			<div id="tab-sp" class="tab-pane">
				<div class="alert alert-info">
					<p>
						<i class="fa fa-fw fa-info-circle"></i>
						#translateResource( "saml2:consumer.previewMetadata.explanation" )#
					</p>
					<p class="text-center">
						<a href="#event.buildAdminLink( linkto='saml2Admin.downloadMetadata', queryString='type=sp' )#" class="btn btn-sm btn-info">
							<i class="fa fa-fw fa-download"></i>
							#translateResource( "saml2:provider.previewMetadata.download.btn" )#
						</a>
					</p>
				</div>
				<pre>#XmlFormat( Trim( spMetadata ) )#</pre>
			</div>
		</cfif>

		<cfif tabsRequired>
			</div>
		</cfif>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2Admin/_samlAdminTabs"
		, args = { body=body, tab="meta" }
	)#
</cfoutput>