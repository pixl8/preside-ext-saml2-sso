component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "getCertificateFingerprint()", function() {
			it( "should return the correct SHA-256 fingerprint for a known certificate using the default algorithm", function() {
				var svc         = _getService();
				var fingerprint = svc.getCertificateFingerprint( _getTestCert() );

				expect( fingerprint ).toBe( "4A:C0:DE:C4:5D:0A:77:F0:76:49:34:49:E1:71:17:90:CC:E2:03:A4:51:A2:A1:24:0A:3D:18:29:6A:C1:AA:9F" );
			} );

			it( "should return the correct SHA-256 fingerprint when the certificate is wrapped in PEM headers", function() {
				var svc         = _getService();
				var certWithHeaders = "-----BEGIN CERTIFICATE-----" & Chr(10) & _getTestCert() & Chr(10) & "-----END CERTIFICATE-----";
				var fingerprint = svc.getCertificateFingerprint( certWithHeaders );

				expect( fingerprint ).toBe( "4A:C0:DE:C4:5D:0A:77:F0:76:49:34:49:E1:71:17:90:CC:E2:03:A4:51:A2:A1:24:0A:3D:18:29:6A:C1:AA:9F" );
			} );

			it( "should return the correct SHA-256 fingerprint when the SHA-256 algorithm is specified explicitly", function() {
				var svc         = _getService();
				var fingerprint = svc.getCertificateFingerprint( x509Cert=_getTestCert(), algorithm="SHA-256" );

				expect( fingerprint ).toBe( "4A:C0:DE:C4:5D:0A:77:F0:76:49:34:49:E1:71:17:90:CC:E2:03:A4:51:A2:A1:24:0A:3D:18:29:6A:C1:AA:9F" );
			} );

			it( "should return the correct SHA-1 fingerprint when the SHA-1 algorithm is specified", function() {
				var svc         = _getService();
				var fingerprint = svc.getCertificateFingerprint( x509Cert=_getTestCert(), algorithm="SHA-1" );

				expect( fingerprint ).toBe( "98:EF:0E:8E:21:9E:D4:2E:99:C5:C9:78:88:98:59:0C:58:F6:43:96" );
			} );

			it( "should return the correct SHA-256 fingerprint when passed a certificate object instead of a string", function() {
				var svc         = _getService();
				var certObj     = CreateObject( "app.extensions.preside-ext-saml2-sso.services.saml.signing.X509CertReader" ).read( _getTestCert() );
				var fingerprint = svc.getCertificateFingerprint( certObj );

				expect( fingerprint ).toBe( "4A:C0:DE:C4:5D:0A:77:F0:76:49:34:49:E1:71:17:90:CC:E2:03:A4:51:A2:A1:24:0A:3D:18:29:6A:C1:AA:9F" );
			} );

			it( "should format each byte as uppercase two-digit hex separated by colons", function() {
				var svc         = _getService();
				var fingerprint = svc.getCertificateFingerprint( _getTestCert() );

				expect( fingerprint ).toMatch( "^([0-9A-F]{2}:)+[0-9A-F]{2}$" );
			} );
		} );
	}

	private any function _getService() {
		return CreateObject( "app.extensions.preside-ext-saml2-sso.services.saml.signing.SamlCertificateService" ).init();
	}

	private string function _getTestCert() {
		return "MIIDHDCCAgSgAwIBAgIJAPkZY/RifCMCMA0GCSqGSIb3DQEBCwUAMA8xDTALBgNV
BAMTBHRlc3QwHhcNMTQxMTEyMTEwMTM1WhcNMjQxMTA5MTEwMTM1WjAPMQ0wCwYD
VQQDEwR0ZXN0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwbnYcv3B
IHH5O1Nu9aOw7IgjsYrzTFGmx/R/Lgbyh03t34FkAQ9SZ4ToKHRI7wJuHN2SveV2
LBjZ8PgoM7Nzkryl2fpF6sytuqMhKFzdSEbHEXMn1GqKCQoQGno5jzZAtcyqxXrF
iK5WrwSuPbopgGzu9UyPfaxaqmYVN0BW50z3NlKEZoQsc8w5WR9r1GDLNTSG0Jqx
sCpzRktkdKAsjskRiqp0X/gFquBEwajyWqF08PGsfwW0iqISc+bCmD1IWGZCQLcy
7eanVD3w13oFNPmqmxZSIiNNSXP5Gb7jcBZ+xWORwnIGOTBeThIPEWOlO4Kr7dDC
2fm1YW1OiJwRPQIDAQABo3sweTAJBgNVHRMEAjAAMCwGCWCGSAGG+EIBDQQfFh1P
cGVuU1NMIEdlbmVyYXRlZCBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUwN4Ob3oWtiCr
FwqrickuFNGD/e8wHwYDVR0jBBgwFoAUwN4Ob3oWtiCrFwqrickuFNGD/e8wDQYJ
KoZIhvcNAQELBQADggEBAEOVm9crJjxi8CPsqJZEfV4ZnO4IlDyEFt3zNpKyamsC
01KFXkldoUhg1YNjLkpueysSyCpYrVe3BgkWdEccPO1GrGWYCYOgT3lf9LQ9hH5z
KTrkC+vftsNFv8YwWQgrncNscMPldbC6ig0khE2IC3mGJMKR8MgHLJWlNV3txgR5
Ri4pgGB+Ax6on6oQHks4I4EvDti7vtarY62Vuu8K6lJHltPkM6BjmQo2n0qJE9Hd
4Cp1NN51cLFIhjRA/gurU7ZUJMg84oaEpG+CVQn0ckKLb9JiKajXSh8HvjX5+COk
GvUxcf3q5ZXwJL6K+o0lrNadM/TN+8gZW441MEjl8Fc=";
	}

}
