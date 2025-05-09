<cfparam name="args.samlResponse"     default="" />
<cfparam name="args.samlRelayState"   default="" />
<cfparam name="args.redirectLocation" default="" />
<cfparam name="args.serviceName"      default="" />
<cfparam name="args.noRelayState"     default="false" />

<cfoutput><!DOCTYPE html>
<html>
	<head>
		<title>SAML2 Single Sign On</title>
		<style>
			body {
				font    : 16px/1.5 sans-serif;
				padding : 2em;
			}
			p {
				margin : 1.5em 0;
			}
			span.target-url {
				font-size : 14px;
				color     : ##999;
			}
			form {
				text-align : center;
			}
			input[type=submit] {
				font: inherit;
				padding : .5em 1em;
			}

			##spinner {
				height        : 50px;
				width         : 50px;
				margin        : 0 auto;
				border        : 4px rgba( 0, 0, 0, 0.25 ) solid;
				border-top    : 4px black solid;
				border-radius : 50%;
				animation     : spin 1s infinite linear;
			}

			@keyframes spin {
				from {
					transform: rotate( 0deg );
				}
				to {
					transform: rotate( 359deg );
				}
			}
		</style>
	</head>

	<body>
		<form id="samlform" action="#args.redirectLocation#" method="POST">
			<input type="hidden" name="SAMLResponse" value="#ToBase64( args.samlResponse )#" />
			<cfif not args.noRelayState>
				<input type="hidden" name="RelayState" value="#args.samlRelayState#" />
			</cfif>

			<div id="spinner"></div>
			<p>
				Please wait while you are redirected to <strong>#args.serviceName#</strong><br>
				<span class="target-url">#args.redirectLocation#</span>
			</p>
		</form>

		<script type="text/javascript">
			document.getElementById( "samlform" ).submit();
		</script>
	</body>
</html></cfoutput>
