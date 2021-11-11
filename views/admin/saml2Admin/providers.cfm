<cfscript>
	providers = prc.providers ?: [];
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<cfif not providers.len()>
			<p class="alert alert-warning">
				<i class="fa fa-exclamation-circle"></i>
				#translateResource( "saml2:no.providers.message" )#
			</p>
		</cfif>
		<cfloop array="#providers#" item="provider" index="i">
			<cfset downloadMetaLink = event.buildAdminLink( linkto="saml2admin.downloadSpMetadata", queryString="id=" & provider.id ) />
			<div class="well">
				<h3 class="blue">
					<a href="#event.buildAdminLink( linkto='saml2Admin.editProvider', queryString='id=' & provider.id )#">
						#provider.title#
						<sup><i class="fa fa-fw fa-pencil"></i></sup>
					</a>
				</h3>
				<cfif provider.description.len()>
					<p>#provider.description#</p>
				</cfif>
				<dl class="dl-horizontal">
					<dt>#translateResource( "saml2:consumer.idp.status" )#:</dt>
					<dd>
						<cfif IsTrue( provider.enabled ?: '' )>
							<i class="fa fa-fw fa-check-circle green"></i>
							#translateResource( "saml2:consumer.idp.enabled" )#
						<cfelse>
							<i class="fa fa-fw fa-times-circle red"></i>
							#translateResource( "saml2:consumer.idp.disabled" )#
						</cfif>
					</dd>
					<dt>#translateResource( "saml2:consumer.idp.usefor" )#:</dt>
					<dd>
						<cfif IsTrue( provider.web )>
							#translateResource( "saml2:consumer.idp.useFor.web" )#
						<cfelse>
							#translateResource( "saml2:consumer.idp.useFor.admin" )#
						</cfif>
					</dd>
					<cfif isFeatureEnabled( "saml2CertificateManager" )>
						<dt>#translateResource( "saml2:consumer.idp.cert" )#:</dt>
						<dd>
							<cfif Len( provider.certificate )>
								<a href="#event.buildAdminLink( objectName="saml2_certificate", recordId=provider.certificate )#">
									<i class="fa fa-fw #translateResource( 'preside-objects.saml2_certificate:iconClass' )#"></i>
									#renderLabel( "saml2_certificate", provider.certificate )#
								</a>
							<cfelse>
								<em class="light-grey">#translateResource( "saml2:consumer.idp.cert.default" )#</em>
							</cfif>
						</dd>
					</cfif>
					<dt>#translateResource( "saml2:consumer.idp.download.meta" )#:</dt>
					<dd>
						<a href="#downloadMetaLink#"><i class="fa fa-fw fa-download"></i></a>&nbsp;
						<a href="#downloadMetaLink#">
							#provider.id#-sp-metadata.xml
						</a>
					</dd>
					<cfif IsTrue( provider.enabled ?: "" )>
						<cfset link = event.buildLink( saml2IdpProvider=provider.id ) />
						<dt>#translateResource( "saml2:consumer.idp.login.url" )#:</dt>
						<dd><a href="#link#">#link#</a></dd>
					</cfif>
				</dl>
			</div>
		</cfloop>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2Admin/_samlAdminTabs"
		, args = { body=body, tab="providers" }
	)#
</cfoutput>