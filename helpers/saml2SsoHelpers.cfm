<cfscript>
	function formatX509Certificate( required string raw ) {
		var x509cert = "-----BEGIN CERTIFICATE-----" & Chr( 10 );
		var stripped = ReReplace( arguments.raw, "[\s\n]", "", "all" );

		stripped = Replace( stripped, "-----BEGIN CERTIFICATE-----", "" );
		stripped = Replace( stripped, "-----END CERTIFICATE-----", "" );

		for( var i=1; i <= Len( stripped ); i++ ) {
			x509cert &= stripped[i];
			if ( !i mod 64 && i < stripped.len() ) {
				x509cert &= Chr( 10 );
			}
		}
		x509cert &= Chr(10) & "-----END CERTIFICATE-----";

		return x509cert;
	}
</cfscript>