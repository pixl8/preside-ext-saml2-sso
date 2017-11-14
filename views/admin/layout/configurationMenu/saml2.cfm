<cfif ( isFeatureEnabled( "samlSsoProvider" ) && hasCmsPermission( "saml.provider.navigate" ) or ( isFeatureEnabled( "samlSsoConsumer" ) && hasCmsPermission( "saml.consumer.navigate" ) ) )>
	<cfoutput>
		<li>
			<a href="#event.buildAdminLink( linkTo="saml2Admin" )#">
				<i class="fa fa-fw fa-key"></i>
				#translateResource( 'saml2:sso.menu.title' )#
			</a>
		</li>
	</cfoutput>
</cfif>