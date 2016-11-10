<cfparam name="args.samlResponse"     default="" />
<cfparam name="args.samlRelayState"   default="" />
<cfparam name="args.redirectLocation" default="" />
<cfparam name="args.serviceName"      default="" />

<cfoutput><!DOCTYPE html>
<html>
  <head>
    <title>SAML2 Single Sign On</title>
  </head>
  <body>
    <form id="samlform" action="#args.redirectLocation#" method="POST">
      <input type="hidden" name="SAMLResponse" value="#ToBase64( args.samlResponse )#" />
      <input type="hidden" name="RelayState" value="#args.samlRelayState#" />
    </form>
    <p>Please while you are redirected to <strong>#args.serviceName#</strong> (#args.redirectLocation#)</p>
    <script type="text/javascript">
      document.getElementById("samlform").submit();
    </script>
  </body>
</html></cfoutput>