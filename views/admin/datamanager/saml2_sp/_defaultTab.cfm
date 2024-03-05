<cfscript>
	renderedSpProps  = args.renderedSpProps  ?: [];
	renderedIdpProps = args.renderedIdpProps ?: [];
</cfscript>
<cfoutput>
	<div class="row">
		<div class="col-md-6">
			<div class="widget-box">
				<div class="widget-header">
					<h4 class="widget-title lighter smaller">
						<i class="fa fa-fw fa-globe"></i>
						#translateResource( "preside-objects.saml2_sp:viewgroup.sp.title" )#
					</h4>
				</div>

				<div class="widget-body">
					<div class="widget-main padding-20">
						<p class="alert alert-info">
							<i class="fa fa-fw fa-info-circle"></i>
							#translateResource( "preside-objects.saml2_sp:sp.details.intro" )#
						</p>
						<div class="table-responsive-lg">
		 					<table class="table table-condensed table-no-header table-non-clickable table-admin-view-record">
		 						<tbody>
									<cfloop array="#renderedSpProps#" item="prop" index="i">
										<tr>
											<cfif isTrue( prop.displayTitle ?: true )>
												<th>#prop.propertyTitle#:</th>
											</cfif>
											<td>#prop.rendered#</td>
										</tr>
									</cfloop>
								</tbody>
							</table>
						</div>

						<div class="text-center">
							<a href="#args.editMetaLink#" class="btn btn-primary">
								<i class="fa fa-fw fa-upload"></i>
								#translateResource( "preside-objects.saml2_sp:edit.meta.btn" )#
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="col-md-6">
			<div class="widget-box">
				<div class="widget-header">
					<h4 class="widget-title lighter smaller">
						<i class="fa fa-fw fa-users"></i>
						#translateResource( "preside-objects.saml2_sp:viewgroup.idp.title" )#
					</h4>
				</div>

				<div class="widget-body">
					<div class="widget-main padding-20">
						<p class="alert alert-info">
							<i class="fa fa-fw fa-info-circle"></i>
							#translateResource( "preside-objects.saml2_sp:idp.details.intro" )#
						</p>
						<div class="table-responsive-lg">
		 					<table class="table table-condensed table-no-header table-non-clickable table-admin-view-record">
		 						<tbody>
									<cfloop array="#renderedIdpProps#" item="prop" index="i">
										<tr>
											<cfif isTrue( prop.displayTitle ?: true )>
												<th>#prop.propertyTitle#:</th>
											</cfif>
											<td>#prop.rendered#</td>
										</tr>
									</cfloop>
								</tbody>
							</table>
						</div>

						<div class="text-center">
							<a href="#args.editCertLink#" class="btn btn-secondary">
								<i class="fa fa-fw fa-certificate"></i>
								#translateResource( "preside-objects.saml2_sp:edit.idpcert.btn" )#
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>