# SAML2 Single Sign On for Preside

[![Build Status](https://travis-ci.org/pixl8/preside-ext-saml2-sso.svg?branch=stable "Stable")](https://travis-ci.org/pixl8/preside-ext-saml2-sso)

This extension provides single sign on for Preside applications using [SAML2](https://en.wikipedia.org/wiki/SAML_2.0).

In its current form, it allows your website, for front-end website users, to be used as an Identity Provider.

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

```
extension enable preside-ext-saml2-sso
reload all
```

### JAR Dependencies

If you see errors such as `java.lang.AbstractMethodError: javax.xml.parsers.DocumentBuilderFactory.setFeature(Ljava/lang/String;Z)V`, you'll need to install Xerces and Xalan libs in your Lucee lib directory. The jars that we have tested working can be found here:

* XercesImpl 2.9.1 [http://dist.wso2.org/maven2/org/apache/xerces/xercesImpl/2.9.1/xercesImpl-2.9.1.jar](http://dist.wso2.org/maven2/org/apache/xerces/xercesImpl/2.9.1/xercesImpl-2.9.1.jar)
* Xalan 2.7.1 [http://dist.wso2.org/maven2/org/apache/xalan/xalan/2.7.1/xalan-2.7.1.jar](http://dist.wso2.org/maven2/org/apache/xalan/xalan/2.7.1/xalan-2.7.1.jar)

### CommandBox (box.json) method

From the root of your application, type the following command:

```
box install preside-ext-saml2-sso
```

### Git Submodule method

From the root of your application, type the following command:

```
git submodule add https://github.com/pixl8/preside-ext-saml2-sso.git application/extensions/preside-ext-saml2-sso
```

## Customization guide

### Provide alternative response data attributes

If you require non-default data attributes to be passed back to your external Service Provider applications, you can do so my registering your attributes in `Config.cfc` and providing an alternative handler for retrieving attributes for the currently logged in user. For example:

```
// Config.cfc
// configure additional supported attribute:
settings.saml2.attributes.supported.membershipNumber = {
	  friendlyName="MembershipNumber"
	, samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
};

// configure alternative attribute retrieval handler
settings.saml2.attributes.retrievalHandler = "mycustom.attribHandlerAction";
```

```
// /handler/MyCustom.cfc
...

private struct function attribHandlerAction() {
	var userDetails = membershipService.getMemberDetails( userId=getLoggedInUserId() );

	return {
		  email            = userDetails.email_address
		, displayName      = userDetails.full_name
		, firstName        = userDetails.first_name
		, lastName         = userDetails.last_name
		, memberShipNumber = userDetails.membership_number
	};
}
...
```

### Provide alternative authentication logic

The extension performs logic to authenticate user's that uses the built-in website user system to check login and to run any additional access conditions that are set against the particular third party Service Provider. To provide your own logic, specify an alternative coldbox handler in `Config.cfc`:

```
settings.saml2.authCheckHandler = "mycustom.authHandlerAction";
```

See `/handlers/Saml2.cfc$authenticationCheck()` for the default implementation.

### Customize your login page

When logging into the system as a result of a Single-Sign-On request, users may be able to see a custom login message that has been entered specifically for the external Service Provider application. 

Your login page should check for a `rc.ssoLoginMessage` variable and display it should it not be empty. You may wish to seek some design input if it has not already been considered.

### Customize your access denied page

When a user does not have access to the external Service Provider application, the system will show the standard access denied message (see [Preside documentation for creating custom access denied pages](https://docs.presidecms.com/devguides/customerrorpages.html#401-access-denied-pages)). In addition, it may send through an editorially created error message specifically for the external Service Provider application.

Your access denied page should check for an `args.accessDeniedMessage` variable and display it should it not be empty. You may wish to seek some design input if it has not already been considered.

### Customize the 'Bad request' page

The extension adds a new system page type, `samlSsoBadRequest`. This page will be shown when the system cannot corrently parse the current single sign on request (e.g. missing SAML XML, etc.).

Your content editors can visit the site tree and customize the content of this page and you may wish to tweak the HTML markup, etc. of the page to match your site's design. You can override the view at `/views/page-types/samlSsoBadRequest/index.cfm`.

## Security guide

The system securely signs its SAML responses in order to verify the integrity of the response. In order to do this, the system requires access to a private/public key pair.

The *default* implementation of this requires a Java `keystore` to be present in the file system that contains your secure keys. Configuration options in your Config.cfc or through environment variables provide the credentials to access the keystore. 

### Generating a keystore

The default configured location for the store is at `/uploads/saml2/keystore`, the following commandline command will generate the keystore with a self signed certificate (which is sufficient for this use case):

```
keytool -genkey -alias saml2key -keyalg RSA -keystore /path/to/site/uploads/saml2/keystore -storepass "astrongpassword" -keysize 2048 -keypass "astrongpassword"
```

This will create a file `keystore` that contains a private/public key pair with an alias of `saml2key`. Both the keystore and key are "secured" with the password, `astrongpassword` (you should, of course, use your own passwords here).

### Telling the system about the keystore

#### Method 1: Environment variables

The application will detect the following environment variables on the host system and use them to setup access to your keystore file:

* `PRESIDE_SAMLKEYSTOREFILE` full filesystem path to the keystore file
* `PRESIDE_SAMLKEYSTOREPASSWORD` password to access the keystore
* `PRESIDE_SAMLCERTALIAS` alias of the certificate within the store
* `PRESIDE_SAMLCERTPASSWORD` password of the certificate within the store

#### Method 2: Preside Server Manager

If you are using Preside Server Manager (currently a private internal tool at Pixl8), these settings can also be setup for your application instances using:

```
samlKeyStoreFile=/path/to/keystore
samlKeyStorePassword=somepassword
samlCertAlias=samlkey
samlCertPassword=keypassword
```

#### Method 3: In plain Config.cfc (not recommended)

You can store the keystore location and credentials directly in your application's config.cfc with:

```
settings.saml2.keystore = {
	  filepath     = ExpandPath( "/uploads/saml2/keystore" )
	, password     = "astrongpassword"
	, certAlias    = "saml2key"
	, certPassword = "astrongpassword"
};
```

### Using your own logic

If you require a more secure approach (the above should be 'ok' in many SSO scenarios), you can override the core logic to supply keys to the system in any way you like.

To do this, add your own `/services/SamlKeyStore.cfc` file that supplies the following methods (that take no arguments):

* `getPrivateKey()`, should return a `sun.security.provider.DSAPrivateKey` Java object
* `getCert()`, should return a `sun.security.x509.X509CertImpl` Java object
* `getFormattedX509Certificate()`, should return a formatted X509 Certificate string (formatted as you would expect it to appear in your application's metadata file)

