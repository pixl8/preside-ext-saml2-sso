<cfscript>
	metadata = prc.metadata ?: "";

	providerEnabled = IsTrue( prc.providerEnabled ?: "" );
	idpMetadata     = prc.idpMetadata ?: "";
	x509Cert        = prc.x509Cert    ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<div class="tabbable tabs-left">
			<ul class="nav nav-tabs">
				<cfif Len( Trim( idpMetadata ) )>
					<li class="active">
						<a data-toggle="tab" href="##tab-idp">
							<i class="fa fa-fw fa-code"></i>&nbsp;
							Identity Provider MetaData
						</a>
					</li>
				</cfif>
				<cfif Len( Trim( x509Cert ) )>
					<li>
						<a data-toggle="tab" href="##tab-cert">
							<i class="fa fa-fw fa-certificate"></i>&nbsp;
							x509 Certificate
						</a>
					</li>
				</cfif>
			</ul>

			<div class="tab-content">

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
				<cfif Len( Trim( x509Cert ) )>
					<div id="tab-cert" class="tab-pane">
						<pre>#Trim( x509Cert )#</pre>
					</div>
				</cfif>
			</div>
		</div>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2Admin/_samlAdminTabs"
		, args = { body=body, tab="meta" }
	)#
</cfoutput>