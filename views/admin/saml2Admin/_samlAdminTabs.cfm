<cfparam name="args.body" default="" />
<cfparam name="args.tab"  default="consumers" />

<cfscript>
	tabs = [];

	if ( IsFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml2.provider.navigate" ) ) {
		tabs.append({
			  id     = "consumers"
			, icon   = "fa-globe green"
			, title  = translateResource( "saml2:provider.tabs.consumers" )
			, active = ( args.tab == "consumers" )
			, link   = ( args.tab == "consumers" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.consumers" )
		});
	}
	if ( IsFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml2.consumer.navigate" )) {
		tabs.append({
			  id     = "providers"
			, icon   = "fa-key orange"
			, title  = translateResource( "saml2:consumer.tabs.providers" )
			, active = ( args.tab == "providers" )
			, link   = ( args.tab == "providers" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.providers" )
		});
	}
	tabs.append({
		  id     = "settings"
		, icon   = "fa-cogs grey"
		, title  = translateResource( "saml2:provider.tabs.settings" )
		, active = ( args.tab == "settings" )
		, link   = ( args.tab == "settings" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.settings" )
	});
	if ( IsFeatureEnabled( "saml2CertificateManager" ) && hasCmsPermission( "saml2.certificates.navigate" )) {
		tabs.append({
			  id     = "certificates"
			, icon   = "fa-certificate purple"
			, title  = translateResource( "saml2:consumer.tabs.certificates" )
			, active = ( args.tab == "certificates" )
			, link   = ( args.tab == "certificates" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.certificates" )
		});
	}
	if ( IsFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml2.provider.navigate" ) ) {
		tabs.append({
			  id     = "meta"
			, icon   = "fa-code blue"
			, title  = translateResource( "saml2:provider.tabs.meta" )
			, active = ( args.tab == "meta" )
			, link   = ( args.tab == "meta" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.previewMetadata" )
		});
	}
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