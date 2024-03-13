<cfscript>
	renderedIdpProps = args.renderedIdpProps ?: [];
	renderedSpProps  = args.renderedSpProps  ?: [];
</cfscript>
<cfoutput>
	<div class="row">
		<div class="col-md-6">
			<div class="widget-box">
				<div class="widget-header">
					<h4 class="widget-title lighter smaller">
						<i class="fa fa-fw fa-users"></i>
						#translateResource( "preside-objects.saml2_idp:viewgroup.idp.title" )#
					</h4>
				</div>

				<div class="widget-body">
					<div class="widget-main padding-20">
						<cfif isFalse( args.record.enabled ?: "" )>
							<p class="alert alert-warning">
								<i class="fa fa-fw fa-info-circle"></i>
								#translateResource( "preside-objects.saml2_idp:not.enabled.message" )#
							</p>
						<cfelse>
							<p class="alert alert-info">
								<i class="fa fa-fw fa-info-circle"></i>
								#translateResource( "preside-objects.saml2_idp:idp.details.intro" )#
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
						</cfif>

						<div class="text-center">
							<a href="#args.editMetaLink#" class="btn btn-primary">
								<i class="fa fa-fw fa-upload"></i>
								#translateResource( "preside-objects.saml2_idp:edit.meta.btn" )#
							</a>
							<a href="#args.editLink#" class="btn btn-secondary">
								<i class="fa fa-fw fa-pencil"></i>
								#translateResource( "preside-objects.saml2_idp:edit.btn" )#
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
						<i class="fa fa-fw fa-globe"></i>
						#translateResource( "preside-objects.saml2_idp:viewgroup.sp.title" )#
					</h4>
				</div>

				<div class="widget-body">
					<div class="widget-main padding-20">
						<p class="alert alert-info">
							<i class="fa fa-fw fa-info-circle"></i>
							#translateResource( "preside-objects.saml2_idp:sp.details.intro" )#
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
							<a href="#args.editCertLink#" class="btn btn-secondary">
								<i class="fa fa-fw fa-certificate"></i>
								#translateResource( "preside-objects.saml2_idp:edit.spcert.btn" )#
							</a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>