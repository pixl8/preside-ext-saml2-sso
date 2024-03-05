<cfscript>
	certElId = "certificate-" & CreateUUId();
</cfscript>
<cfoutput>
	<div class="table-responsive-lg">
		<table class="table-condensed table-no-header table-non-clickable table-admin-view-record">
			<tbody>
				<tr>
					<th style="vertical-align:top;width:20%;">#translateResource( "saml2:x509.info.table.expires.th")#</th>
					<td style="vertical-align:top">
						#renderContent( "boolean", args.certInfo.valid, "admin" )#
						#renderContent( "date", args.certInfo.expires, "admin" )#
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "saml2:x509.info.table.casigned.th")#</th>
					<td style="vertical-align:top">#renderContent( "boolean", !args.certInfo.selfIssued, "admin" )#</td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "saml2:x509.info.table.issuer.th")#</th>
					<td style="vertical-align:top"><code>#args.certInfo.issuer#</code></td>
				</tr>
				<tr>
					<th style="vertical-align:top">#translateResource( "saml2:x509.info.table.certificate.th")#</th>
					<td><a data-toggle="collapse" data-target="###certElId#" aria-expanded="false" aria-controls="#certElId#"><i class="fa fa-fw fa-eye"></i></a></td>
				</tr>
				<tr id="#certElId#" class="collapse">
					<td style="vertical-align:top" colspan="2"><pre><code>#args.data#</code></pre </td>
				</tr>
			</tbody>
		</table>
	</div>
</cfoutput>