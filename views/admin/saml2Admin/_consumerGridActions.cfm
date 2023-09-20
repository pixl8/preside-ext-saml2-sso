<cfparam name="args.id"   type="string" />
<cfparam name="args.name" type="string" />
<cfscript>
	canEdit   = hasCmsPermission( "saml2.consumer.manage"         );
	canDelete = hasCmsPermission( "saml2.consumer.deleteConsumer" );

	if ( canEdit ) {
		editLink = event.buildAdminLink( linkto="saml2Admin.editConsumer", queryString="id=" & args.id );
		editTitle = HtmlEditFormat( translateResource( uri="saml2:provider.edit.consumer.link.title", data=[ args.name ] ) );
	}

	if ( canDelete ) {
		deleteLink = event.buildAdminLink( linkto="saml2Admin.deleteConsumerAction", queryString="id=" & args.id );
		deleteTitle = HtmlEditFormat( translateResource( uri="saml2:provider.delete.consumer.link.title", data=[ args.name ] ) );

	}
</cfscript>

<cfif canEdit or canDelete>
	<cfoutput>
		<div class="action-buttons btn-group">
			<cfif canEdit>
				<a href="#editLink#" data-context-key="e" title="#editTitle#">
					<i class="fa fa-fw fa-lg fa-pencil"></i>
				</a>
			</cfif>

			<cfif canDelete>
				<a class="confirmation-prompt" data-context-key="d" href="#deleteLink#" title="#deleteTitle#">
					<i class="fa fa-fw fa-lg fa-trash-o"></i>
				</a>
			</cfif>
		</div>
	</cfoutput>
</cfif>