<cfoutput>
	<div class="table-responsive-lg">
		<table class="table-condensed table-no-header table-non-clickable table-admin-view-record">
			<tbody>
				<tr>
					<th style="vertical-align:top;width:20%;">#translateResource( "preside-objects.saml2_certificate:info.table.expires.th")#</th>
					<td style="vertical-align:top">
						#renderContent( "boolean", args.certInfo.valid, "admin" )#
						#renderContent( "date", args.certInfo.expires, "admin" )#
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "preside-objects.saml2_certificate:info.table.casigned.th")#</th>
					<td style="vertical-align:top">#renderContent( "boolean", !args.certInfo.selfIssued, "admin" )#</td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "preside-objects.saml2_certificate:info.table.issuer.th")#</th>
					<td style="vertical-align:top">#args.certInfo.issuer#</td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "preside-objects.saml2_certificate:info.table.subject.th")#</th>
					<td style="vertical-align:top">#args.certInfo.subject#</td>
				</tr>
			</tbody>
		</table>
	</div>
</cfoutput>