# Changelog

## v5.1.3

* [SAML-8](https://projects.pixl8.london/browse/SAML-8) - Minor styling on SAML redirect pages

## v5.1.2

* [SAML-7](https://projects.pixl8.london/browse/SAML-7) - Add preSamlSsoLoginResponse interceptor

## v5.1.1

* Remove extra testing code for digest algorithm

## v5.1.0

* Ensure correct signing algorithm is used to match certificate (RSA SHA-256)
* Include default namespace when stripping namespace attributes

## v5.0.2

* Sign Single Logout Responses
* Ensure ID attribute on logout responses meets SAML spec and does not start with a number

## v5.0.1

* [#11](https://github.com/pixl8/preside-ext-saml2-sso/issues/11) Remove unused private methods (hope to resolve sporadic Lucee bug errors in some environments)

## v5.0.0

* Add beta support for SLO when acting as a frontend IdP (add feature flag `settings.features.samlSsoProviderSlo.enabled=true`)
* Add beta feature for allowing custom certificates to be input for IdP integrations (add feature flag `settings.features.saml2CertificateManager.enabled=true`)
* Add validation of SAML request signatures
* Add admin ability to specify NameID format used for service provider SAML Assertion responses

## v4.1.5

* Hopeful fix, and more useful error information, for "Invalid signature" failures on apparently valid SAML responses.
* Convert to GH actions flow
* Fix for later versions of JAVA that drop support for sun.misc.BASE64Encoder

## v4.1.4

* Do not read HTTP request body every time we want to check the request method

## v4.1.3

* Do not refer to the session scope directly. Use sessionStorage abstraction instead.

## v4.1.2

* Return multiple values of SamlResponse attributes if found

## v4.1.1

* Fix tests

## v4.1.0

* Add ability to download IDP-specific service provider metadata for each registered IDP when Preside is being used as a service Provider

## v4.0.5

* Build fixes

## v4.0.4

* Version bump

## v4.0.3

* Use correct issuer (entity ID) for IDP initiated SSO processes

## v4.0.2

* Ensure assertion is valid until 2 minutes AFTER the instance of assertion, not BEFORE!

## v4.0.1

* Fix bad reference to isFeatureEnabled() function

## v4.0.0

* Fix wrong Issuer instruction in assertion response while adding a feature flag to help patch backward compatibility if SPs are working around our bad ISSUER responses (they should be the entityID, NOT the sso URL)
* Ensure that we use root URL for entity ID and NOT the org URL
* Add UI to allow users to see multiline formatted X509 cert
* Ensure X509 certificate is output on single line and without BEGIN/END cert prefixes
* Ensure test server runs with correct name
* Update test runner code to work with latest commandbox

## v3.0.14

* Add back the Assertion node to the the response attribute parser

## v3.0.13

* Work around apparent jar class conflict where SAML decides to set the default owasp security configuration when it is not already set which subsequently causes issues with the rest of the Java environment that does not have access to the SAML classpath

## v3.0.12

* Add fix for Lucee 4 and default namespaces

## v3.0.11

* Strip namespaces from all our SAML xml metadata, responses and requests so that we can consistently and easily parse different SAML implementations that choose either different namespaces, or no namespaces at all

## v3.0.10

* Setup try catch to handle log error in 10.6

## v3.0.9

* Catch incomplete Jumpcloud / SAML2 installation

## v3.0.8

* Fix samlResponse name not using friendly name

## v3.0.7

* Do not attempt to process or parse entities that are not fully setup whenmatching IDPs

## v3.0.6

* Again, fix filter for slug

## v3.0.5

* Fix bad filter on slug for IDPs
* Only wrap certificate strings in header and footer when necessary
* Add a 'hack' to work with Preside SAML IDPs who are returning entity ID + /saml2/sso/ as entity ID in auth responses
* Ensure no double slash in issuer ID for responses
* Remove hardcoded entity ID for service provider
* Support saml responses that use a SAML xml namespace rather than SAML2

## v3.0.4

* Remove the Z at the end of dates in saml responses

## v3.0.3

* Second attempt at working around classloader conflict issues

## v3.0.2

* Fix for missing log4j jars (that sometimes break when present and system already has jar loaded - pita)

## v3.0.0

* Move README to github wiki
* Update code to make compatible with Preside 10.6
* Ignore all /saml2/ endpoints when determinig request language
* Implement actual custom login URL route handling
* Add a setting to be able to customize the endpoint that will initiate IDP login for external IDPs
* Allow identity provider title/description to be translatable in the admin
* Refactor service name to be inline with all the other services in this extension
* Allow downloading of both SP and IDP metadata
* Show message when no IDPs configured
* Rejig admin so that all settings are together in one place
* Begin to move pieces around for more sensible architecture
* Make SP initiated SSO work
* Add SAML2 response handler :)
* Add ability to activate and edit metadata for an IDP
* Display configured IDPs in list
* Add DB configured options for IDPs into retrieval of IDPs from service
* Add a description field to IDPs
* Setup tabs for SP configuration
* Add barebones IDP management page
* Add a service method to list configured IDPs
* Add an 'enabled' flag to IDPs so that they can be turned off
* Scale back ambitions - expect SAML IDPs to be configured in code, with just metadata being editorial
* Add identity provider object
* FIx up navigation and wording to properly use SAML language (Service Provider vs Identity Provider) + enable both features to be enabled at once

## v2.0.2

cec5378 Strip whitespace from X509 cert in SAML response. Causes trouble with some systems

## v2.0.1

* Make postlogin URL work for both SP and IDP initiated SSO workflows

# v2.0.0

* Apply attribute configuration options to SAML response creation
* Add fields to allow each service provider to have the attributes return configurable
* Tweak display of actions grid for SSO consumers
* Add working IDP initiated SAML assertion
* Add a custom route for IDP initiated single sign-on
* Add fields for configuring SSO type and producing a link to initiate SSO for IDP initiated flows

## v1.0.11

* Get Javaloader into test suite

## v1.0.10

* Use javaloader to load all opensaml classes

## v1.0.8

* Ammend regex for detecting bad ms formatted dates

## v1.0.7

* Add proper fix instructions for xml document reader bug

## v1.0.6

* Update README to include fix instructions for Xerces and Xalan libs

## v1.0.5

* Improve documentation around providing custom key management logic
* Remove redundant function and correct return types
* Make the SamlKeyStore object wrap all of the security logic around getting public and private certificate credentials for the Saml signing certificate

## v1.0.4

* Provide more documentation around customizing authentication and returned data attributes

## v1.0.3

* Add a forgebox type to the repo

## v1.0.2

* Add a download location so forgebox knows where to go get it

## v1.0.1

* Add a build status badge

## v1.0.0

* First release
