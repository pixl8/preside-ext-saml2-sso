<cfoutput>
	<div class="row">
		<div class="col-md-6">
			<div class="widget-box">
				<div class="widget-header">
					<h4 class="widget-title lighter smaller">
						<i class="fa fa-fw #translateResource( 'preside-objects.saml2_certificate:iconClass')#"></i>
						#translateResource( 'preside-objects.saml2_certificate:infobox.title')#
					</h4>
				</div>

				<div class="widget-body">
					<div class="widget-main padding-20">
						#args.certSummary#
					</div>
				</div>
			</div>
		</div>

		<div class="col-md-6">
			#renderViewlet( event="admin.datahelpers.displayGroup", args={
				  objectName = "saml2_certificate"
				, recordId   = prc.recordId
				, properties = [ "id", "datecreated", "datemodified" ]
				, title     = translateResource( "cms:admin.view.system.group.title" )
				, iconClass = translateResource( "cms:admin.view.system.group.iconClass" )
			} )#
		</div>
	</div>
</cfoutput>