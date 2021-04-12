<cfif hasCmsPermission( "saml2.general.navigate" )>
	<cfoutput>
		<li>
			<a href="#event.buildAdminLink( linkTo="saml2Admin" )#">
				<i class="fa fa-fw fa-key"></i>
				#translateResource( 'saml2:sso.menu.title' )#
			</a>
		</li>
	</cfoutput>
</cfif>