/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="samlProviderMetadataGenerator" inject="delayedInjector:samlProviderMetadataGenerator";

// CONSTRUCTOR
	public any function init() {
		variables.x509CertReader = new X509CertReader();
		variables.rsaKeyReader   = new RsaKeyReader();

		return this;
	}

// PUBLIC API METHODS
	public struct function getKeyPairForSigningCredential( required string privateKey, required string publicCert ) {
		return {
			  privateKey        = rsaKeyReader.read( arguments.privateKey )
			, publicCertificate = x509CertReader.read( arguments.publicCert )
		};
	}

	public struct function generateKeyPair( expiryDays=7300, cn=_getCnForCertificates() ) {
		var filePath     = ExpandPath( "/uploads/saml2/tmpkeystore#CreateUUId()#" );
		var certAlias    = "generated";
		var certPassword = CreateUUId();
		var password     = CreateUUId();
		var keyToolArgs  = '-genkeypair -validity #arguments.expiryDays# -alias #certAlias# -keyalg RSA -storetype JKS -keystore #filePath# -storepass #password# -keysize 2048 -keypass #certPassword# -dname CN=#arguments.cn#'.split( "\s+" );

		// TODO, replace this with a java lib for generating the keypair
		// should keytool fail, it crashes the server :o
		DirectoryCreate( GetDirectoryFromPath( filePath ), true, true );
		CreateObject( "java", "sun.security.tools.keytool.Main" ).main( keyToolArgs );

		var ks = new SamlKeyStore(
			  keystoreFile     = filePath
			, keystorePassword = password
			, certAlias        = certAlias
			, certPassword     = certPassword
		);

		var result = {
			  public = ks.getFormattedX509Certificate( true )
			, private = ks.getFormattedPrivateKey( true )
		};

		FileDelete( filePath );

		return result;
	}

	private string function _getCnForCertificates() {
		var shortName = samlProviderMetadataGenerator.getMetaDataSettings().organisation_short_name;

		return ReReplace( shortName, "\s+", "-", "all" );
	}

}