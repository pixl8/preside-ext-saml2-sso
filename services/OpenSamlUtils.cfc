component {

// CONSTRUCTOR
	public any function init() {
		_setupJavaloader();
		_bootstrapOpenSamlConfiguration();
		_setSignatureMappings( {
			"SHA256withRSA": "ALGO_ID_SIGNATURE_RSA_SHA256"
		} );
		_setDigestMappings( {
			"SHA256withRSA": "ALGO_ID_DIGEST_SHA256"
		} );

		return this;
	}

// PUBLIC API METHODS
	public any function openSamlObjectToXml( required any openSaml, boolean toString=true ) {
		var mf         = _create( "org.opensaml.Configuration" ).getMarshallerFactory();
		var marshaller = mf.getMarshaller( arguments.openSaml );
		var marshalled = marshaller.marshall( arguments.openSaml );

		if ( toString ) {
			return _create( "org.opensaml.xml.util.XMLHelper" ).nodeToString( marshalled );
		}
	}

	public any function xmlToOpenSamlObject( required string xml ) {
		var parserPool  = _create( "org.opensaml.xml.parse.BasicParserPool" ).init();
			parserPool.setNamespaceAware( true );

		var inputStream = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( arguments.xml.getBytes( "utf-8" ) );
		var DOM         = parserPool.parse( inputStream ).getDocumentElement();

		var unmarshallerFactory = _create( "org.opensaml.Configuration" ).getUnmarshallerFactory();
		var unmarshaller        = unmarshallerFactory.getUnmarshaller( DOM );

		if ( IsNull( unmarshaller ) ){
			throw( type="saml.invalid.saml", message="The XML passed was not valid saml", detail=arguments.xml );
		}

		var obj = unmarshaller.unmarshall( DOM );

		obj.validate( true );

		return obj;
	}

	public any function getOpenSamlCredential( required any privateKey, required any certificate ) {
		var credential = _create( "org.opensaml.xml.security.x509.BasicX509Credential" );

		credential.setPrivateKey( arguments.privateKey );
		credential.setEntityCertificate( arguments.certificate );

		return credential;
	}

	public any function createAndPrepareOpenSamlSignature( required any credential ) {
		var bf                 = _create( "org.opensaml.Configuration" ).getBuilderFactory();
		var signature          = bf.getBuilder( _create( "org.opensaml.xml.signature.Signature" ).DEFAULT_ELEMENT_NAME ).buildObject();
		var signatureConstants = _create( "org.opensaml.xml.signature.SignatureConstants" );
		var algorithmName      = credential.getEntityCertificate().getSigAlgName();
		var signatureMappings  = _getSignatureMappings();

		signature.setSigningCredential( credential );

		if ( StructKeyExists( signatureMappings, algorithmName ) ) {
			signature.setSignatureAlgorithm( signatureConstants[ signatureMappings[ algorithmName ] ] );
		}

		_create( "org.opensaml.xml.security.SecurityHelper" ).prepareSignatureParams( signature, credential, NullValue(), NullValue() );

		return signature;
	}

	public any function setDigestAlgorithm( required any signature ) {
		var signatureConstants = _create( "org.opensaml.xml.signature.SignatureConstants" );
		var algorithmName      = signature.getSigningCredential().getEntityCertificate().getSigAlgName();
		var digestMappings     = _getDigestMappings();

		if ( StructKeyExists( digestMappings, algorithmName ) ) {
			signature.getContentReferences().get( 0 ).setDigestAlgorithm( signatureConstants[ digestMappings[ algorithmName ] ] );
		}
	}

	public void function signSamlObject( required any signature ) {
		_create( "org.opensaml.xml.signature.Signer" ).signObject( arguments.signature );
	}

	public boolean function validateSignatures( required string samlResponse, required string idpMeta ) {
		var samlResponseObj = xmlToOpenSamlObject( samlResponse );
		var signatures      = [];
		var responseSig     = samlResponseObj.getSignature();
		var assertions      = samlResponseObj.getAssertions();

		if ( !IsNull( responseSig ) ) {
			signatures.append( responseSig );
		}
		for( var assertion in assertions ) {
			assertionSig = assertion.getSignature();
			if ( !IsNull( assertionSig ) ) {
				signatures.append( assertionSig );
			}
		}

		if ( signatures.len() ) {
			var credential = _getCredentialFromMetadata( arguments.idpMeta );
			for( var signature in signatures ) {
				if ( !validateSignature( signature=signature, credential=credential ) ) {
					return false;
				}
			}
		}

		return true;
	}

	public boolean function validateRequestSignature( required string samlRequest, required string signingCert ) {
		var samlRequestObj = xmlToOpenSamlObject( samlRequest );
		var requestSig     = samlRequestObj.getSignature();

		if ( IsNull( requestSig ) ) {
			return false;
		}

		return validateSignature( signature=requestSig, credential=_getCredentialFromCert( arguments.signingCert ) );
	}

	public boolean function validateSignature( required any signature, required any credential ) {
		var profileValidator = _create( "org.opensaml.security.SAMLSignatureProfileValidator" ).init();
		try {
			profileValidator.validate( arguments.signature );
		} catch( any e ) {
			return false;
		}

		var validator = _create( "org.opensaml.xml.signature.SignatureValidator" ).init( arguments.credential );
		try {
			validator.validate( signature );
		} catch( any e ) {
			return false;
		}

		return true;
	}

// PRIVATE HELPERS
	private any function _create( required string classPath ) {
		return server._saml2Jl.create( arguments.classPath );
	}

	private void function _bootstrapOpenSamlConfiguration() {
		try {
      		_create( "org.opensaml.DefaultBootstrap" ).bootstrap();
      	} catch ( any e ){}
	}

	private any function _getCredentialFromMetadata( required string idpMeta ) {
		return _getCredentialFromCert( new SamlMetadata( arguments.idpMeta ).getX509Certificate() );
	}

	private any function _getCredentialFromCert( required string cert ) {
		var x509Cert        = _ensureCertWrappedInHeaderAndFooter( Trim( arguments.cert ) );
		var byteArrayOfCert = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( x509Cert.getBytes() );
		var certFactory     = CreateObject( "java", "java.security.cert.CertificateFactory" ).getInstance( "X.509" );
		var cert            = certFactory.generateCertificate( byteArrayOfCert );
		var credential      = _create( "org.opensaml.xml.security.x509.BasicX509Credential" );

		credential.setEntityCertificate( cert );

		return credential;
	}

	private void function _setupJavaloader() {
		if ( !StructKeyExists( server, "_saml2Jl" ) ) {
			var libs = DirectoryList( ExpandPath( "/app/extensions/preside-ext-saml2-sso/services/lib" ), false, "path", "*.jar" );

			application.applicationName = application.applicationName ?: ( application.name ?: Hash( ExpandPath( "/" ) ) );

			server._saml2Jl = new javaloader.JavaLoader( loadPaths=libs, loadColdFusionClassPath=true );
		}
	}

	private string function _ensureCertWrappedInHeaderAndFooter( required string cert ) {
		if ( !arguments.cert.startsWith( "-----BEGIN CERTIFICATE-----" ) ) {
			return "-----BEGIN CERTIFICATE-----" & Chr( 10 ) & arguments.cert & "-----END CERTIFICATE-----"
		}

		return arguments.cert;
	}

	private struct function _getSignatureMappings() {
		return _signatureMappings;
	}
	private void function _setSignatureMappings( required struct signatureMappings ) {
		_signatureMappings = arguments.signatureMappings;
	}

	private struct function _getDigestMappings() {
		return _digestMappings;
	}
	private void function _setDigestMappings( required struct digestMappings ) {
		_digestMappings = arguments.digestMappings;
	}

}