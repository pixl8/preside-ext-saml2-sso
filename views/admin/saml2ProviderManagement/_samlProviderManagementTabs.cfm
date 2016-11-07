<cfparam name="args.body" default="" />
<cfparam name="args.tab"  default="consumers" />

<cfscript>
	tabs       = [];

	tabs.append({
		  id     = "consumers"
		, icon   = "fa-globe green"
		, title  = translateResource( "saml2:provider.tabs.consumers" )
		, active = ( args.tab == "consumers" )
		, link   = ( args.tab == "consumers" ) ? "" : event.buildAdminLink( linkTo="saml2ProviderManagement" )
	});
	tabs.append({
		  id     = "meta"
		, icon   = "fa-code blue"
		, title  = translateResource( "saml2:provider.tabs.meta" )
		, active = ( args.tab == "meta" )
		, link   = ( args.tab == "meta" ) ? "" : event.buildAdminLink( linkTo="saml2ProviderManagement.previewMetadata" )
	});
	tabs.append({
		  id     = "settings"
		, icon   = "fa-cogs grey"
		, title  = translateResource( "saml2:provider.tabs.settings" )
		, active = ( args.tab == "settings" )
		, link   = ( args.tab == "settings" ) ? "" : event.buildAdminLink( linkTo="saml2ProviderManagement.settings" )
	});
</cfscript>

<cfoutput>
	<div class="tabbable">
		<ul class="nav nav-tabs">
			<cfloop array="#tabs#" index="i" item="tab">
				<li <cfif tab.active>class="active"</cfif>>
					<a href="#tab.link#">
						<i class="fa fa-fw #tab.icon#"></i>&nbsp;
						#tab.title#
					</a>
				</li>
			</cfloop>
		</ul>
		<div class="tab-content">
			<div class="tab-pane active">#args.body#</div>
		</div>
	</div>
</cfoutput>