<cf_presideparam name="args.title"         field="page.title"        editable="true" />
<cf_presideparam name="args.main_content"  field="page.main_content" editable="true" />

<cfset defaultMessage = '<p>There was an error processing your Single-Sign-On request and we cannot proceed. Please contact the system administrator should the problem persist.</p>' />

<cfoutput>
	<h1>#args.title#</h1>
	<cfif Len( Trim( event.getPageProperty( "main_content" ) ) )>
		#args.main_content#
	<cfelse>
		#renderEditableContent(
			  renderer        = "richeditor"
			, object          = "page"
			, property        = "main_content"
			, recordId        = event.getCurrentPageId()
			, renderedContent = defaultMessage
			, rawContent      = defaultMessage
		)#
	</cfif>
</cfoutput>