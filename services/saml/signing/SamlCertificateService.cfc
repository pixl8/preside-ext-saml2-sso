/**
 * @presideService true
 * @singleton      true
 */
component {

	property name="samlProviderMetadataGenerator" inject="delayedInjector:samlProviderMetadataGenerator";
	property name="defaultKeySize"                inject="coldbox:setting:saml2.certs.defaultKeySize";
	property name="defaultSigAlg"                 inject="coldbox:setting:saml2.certs.defaultSigAlg";

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

	public struct function generateKeyPair( expiryDays=7300, cn=_getCnForCertificates(), keySize=defaultKeySize, sigAlg=defaultSigAlg ) {
		var filePath     = ExpandPath( "/uploads/saml2/tmpkeystore#CreateUUId()#" );
		var certAlias    = "generated";
		var certPassword = CreateUUId();
		var password     = CreateUUId();
		var keyToolArgs  = '-genkeypair -validity #arguments.expiryDays# -alias #certAlias# -keyalg RSA -sigalg #arguments.sigAlg# -storetype JKS -keystore #filePath# -storepass #password# -keysize #arguments.keySize# -keypass #certPassword# -dname CN=#arguments.cn#'.split( "\s+" );

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

	public string function getCertificateFingerprint( required any x509Cert, string algorithm="SHA-256" ) {
		var certObj   = IsSimpleValue( arguments.x509Cert ) ? x509CertReader.read( arguments.x509Cert ) : arguments.x509Cert;
		var derBytes  = certObj.getEncoded();
		var digest    = CreateObject( "java", "java.security.MessageDigest" ).getInstance( arguments.algorithm );
		var hashBytes = digest.digest( derBytes );
		var sb        = CreateObject( "java", "java.lang.StringBuilder" );

		for ( var i = 1; i <= ArrayLen( hashBytes ); i++ ) {
			if ( i > 1 ) {
				sb.append( ":" );
			}
			var hex = FormatBaseN( BitAnd( hashBytes[ i ], 255 ), 16 );
			sb.append( UCase( hex.len() == 1 ? "0#hex#" : hex ) );
		}

		return sb.toString();
	}

	private string function _getCnForCertificates() {
		var shortName = samlProviderMetadataGenerator.getMetaDataSettings().organisation_short_name;

		return ReReplace( shortName, "\s+", "-", "all" );
	}

}