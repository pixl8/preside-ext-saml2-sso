component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "init()", function(){
			it( "should initialize by passing valid metadata to its constructor", function(){
				var md = _getMetadata( FileRead( "/tests/resources/metadata/metadata_a.xml" ) );

				expect( md ).toBeInstanceOf( "samlIdProvider.core.SamlMetadata" );
			} );
		} );

		describe( "getEntityId()", function(){
			it( "should return the ID defined in the metadata", function(){
				var md = _getMetadata( FileRead( "/tests/resources/metadata/metadata_a.xml" ) );

				expect( md.getEntityId() ).toBe( "https://app.goodpractice.net" );
			} );
		} );

		describe( "getServiceProviderSSORequirements()", function(){
			it( "should return a structure with details of the Service Provider's SSO requirements", function(){
				var md         = _getMetadata( FileRead( "/tests/resources/metadata/metadata_a.xml" ) );
				var ssoDetails = md.getServiceProviderSSORequirements();
				var expected   = {
					  requestsWillBeSigned     = false
					, wantAssertionsSigned     = true
					, nameIdFormats            = [ "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent", "urn:oasis:names:tc:SAML:2.0:nameid-format:transient" ]
					, defaultAssertionConsumer = { index="0", binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", location="https://app.goodpractice.net/security/saml2/response" }
					, requestAttributes        = [
						  { friendlyName="Email"                 , name="urn:oid:0.9.2342.19200300.100.1.3", nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
						, { friendlyName="DisplayName"           , name="urn:oid:2.16.840.1.113730.3.1.241", nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
						, { friendlyName="FirstName"             , name="urn:oid:2.5.4.42",                  nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
						, { friendlyName="LastName"              , name="urn:oid:2.5.4.4",                   nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
						, { friendlyName="eduPersonPrincipalName", name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6",  nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
						, { friendlyName="eduPersonTargetedID"   , name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10", nameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", required=false }
					  ]
					, x509Certificate          = "MIIDHDCCAgSgAwIBAgIJAPkZY/RifCMCMA0GCSqGSIb3DQEBCwUAMA8xDTALBgNV
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
GvUxcf3q5ZXwJL6K+o0lrNadM/TN+8gZW441MEjl8Fc="
				};

				expect( ssoDetails ).toBe( expected );
			} );
		} );
	}

	private any function _getMetadata( required string md ) {
		return new samlIdProvider.core.SamlMetadata( arguments.md );
	}

}