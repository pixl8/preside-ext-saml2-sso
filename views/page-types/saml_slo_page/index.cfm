<cf_presideparam name="args.title"         field="page.title"        editable="true" />
<cf_presideparam name="args.main_content"  field="page.main_content" editable="true" />
<cfscript>
	defaultMessage = '<p>You have successfully been logged out of the system.</p>';
	spResponseUrl = args.spResponseUrl ?: "";
	spRequestUrls = args.spRequestUrls ?: [];
</cfscript>

<cfset  />

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

	<cfif !isEmptyString( spResponseUrl )>
		<iframe src="#spResponseUrl#" style="position: absolute; width:0; height:0; border:0;" width="0" height="0" frameborder="0"></iframe>
	</cfif>
	<cfloop array="#spRequestUrls#" item="spRequestUrl" index="i">
		<iframe src="#spRequestUrl#" style="position: absolute; width:0; height:0; border:0;" width="0" height="0" frameborder="0"></iframe>
	</cfloop>
</cfoutput>