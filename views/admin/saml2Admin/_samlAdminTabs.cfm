<cfparam name="args.body"          default="" />
<cfparam name="args.tab"           default="sps" />
<cfparam name="args.tabTopOnly"    default="false" />
<cfparam name="args.tabBottomOnly" default="false" />

<cfscript>
	tabs = [];

	if ( IsFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml2.provider.navigate" ) ) {
		ArrayAppend( tabs, {
			  id     = "sps"
			, icon   = "fa-globe green"
			, title  = translateResource( "saml2:provider.tabs.consumers" )
			, active = ( args.tab == "sps" )
			, link   = ( args.tab == "sps" ) ? "" : event.buildAdminLink( objectName="saml2_sp" )
		});
	}
	if ( IsFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml2.consumer.navigate" )) {
		ArrayAppend( tabs, {
			  id     = "idps"
			, icon   = "fa-users orange"
			, title  = translateResource( "saml2:consumer.tabs.providers" )
			, active = ( args.tab == "idps" )
			, link   = ( args.tab == "idps" ) ? "" : event.buildAdminLink( objectName="saml2_idp" )
		});
	}
	ArrayAppend( tabs, {
		  id     = "debug"
		, icon   = "fa-bug red"
		, title  = translateResource( "saml2:provider.tabs.debug" )
		, active = ( args.tab == "debug" )
		, link   = ( args.tab == "debug" ) ? "" : event.buildAdminLink( objectName="saml2_debug_log" )
	});
	ArrayAppend( tabs, {
		  id     = "settings"
		, icon   = "fa-cogs grey"
		, title  = translateResource( "saml2:provider.tabs.settings" )
		, active = ( args.tab == "settings" )
		, link   = ( args.tab == "settings" ) ? "" : event.buildAdminLink( linkTo="saml2Admin.settings" )
	});
</cfscript>

<cfoutput>
<cfif not args.tabBottomOnly>
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
			<div class="tab-pane active">
</cfif>
<cfif not args.tabTopOnly>
				#args.body#
			</div>
		</div>
	</div>
</cfif>
</cfoutput>