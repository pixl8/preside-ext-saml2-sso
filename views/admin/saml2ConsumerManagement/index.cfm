<cfscript>
	providers = prc.providers ?: [];
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<cfloop array="#providers#" item="provider" index="i">
			<div class="well">
				<h3 class="blue">
					<a href="#event.buildAdminLink( linkto='saml2ConsumerManagement.editProvider', queryString='id=' & provider.id )#">#provider.title#</a>
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
					<cfif IsTrue( provider.admin ) and IsTrue( provider.enabled ?: "" )>
						<cfset link = event.buildLink( saml2AdminIdpProvider=provider.id ) />
						<dt>#translateResource( "saml2:consumer.idp.login.url" )#:</dt>
						<dd><a href="#link#">#link#</a></dd>
					</cfif>
				</dl>
			</div>
		</cfloop>
	</cfsavecontent>

	#renderView(
		  view = "/admin/saml2ConsumerManagement/_samlConsumerManagementTabs"
		, args = { body=body, tab="providers" }
	)#
</cfoutput>