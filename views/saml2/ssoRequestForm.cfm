<cfparam name="args.samlRequest"      default="" />
<cfparam name="args.samlRelayState"   default="" />
<cfparam name="args.redirectLocation" default="" />
<cfparam name="args.serviceName"      default="" />
<cfparam name="args.noRelayState"     default="false" />

<cfoutput><!DOCTYPE html>
<html>
  <head>
    <title>SAML2 Single Sign On</title>
  </head>
  <body>
    <form id="samlform" action="#EncodeForHTMLAttribute( args.redirectLocation )#" method="POST">
      <input type="hidden" name="SAMLRequest" value="#ToBase64( args.samlRequest )#" />
      <cfif not args.noRelayState>
        <input type="hidden" name="RelayState" value="#EncodeForHTMLAttribute( args.samlRelayState )#" />
      </cfif>
    </form>
    <p>Please wait while you are redirected to <strong>#EncodeForHtml( args.serviceName )#</strong> (#EncodeForHtml( args.redirectLocation )#)</p>
    <script type="text/javascript" nonce="#event?.getRequestNonce()#">
      document.getElementById("samlform").submit();
    </script>
  </body>
</html></cfoutput>
