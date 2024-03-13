component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "listProviders()", function() {
			it( "should return empty array when no providers configured in Config.cfc", function(){
				var service = _getService( {} );

				mockProviderDao.$( "selectData", QueryNew('') );

				expect( service.listProviders() ).toBe( [] );
			} );

			it( "should list configured providers, filling in any default values for provider attributes and adding attributes from database", function(){
				var service   = _getService();
				var providers = _defaultConfiguredProviders();
				var dbProviders = QueryNew( "slug,enabled,metadata", "varchar,bit,varchar", [ [ "jumpcloud", 1, "test" ], [ "google", 0, "" ] ] );
				var expected  = [];

				mockProviderDao.$( "selectData", dbProviders );
				service.$( "$translateResource" ).$args( uri="saml2.identityProviders:jumpCloud.title"      , defaultValue="jumpCloud" ).$results( "jumpCloud title"       );
				service.$( "$translateResource" ).$args( uri="saml2.identityProviders:jumpCloud.description", defaultValue=""          ).$results( "jumpCloud description" );
				service.$( "$translateResource" ).$args( uri="saml2.identityProviders:google.title"         , defaultValue="google"    ).$results( "google title"          );
				service.$( "$translateResource" ).$args( uri="saml2.identityProviders:google.description"   , defaultValue=""          ).$results( "google description"    );

				providers.jumpCloud.append( {
					  admin           = true
					, web             = false
					, autoRegister    = true
					, postAuthHandler = ""
					, title           = "jumpCloud title"
					, description     = "jumpCloud description"
					, slug            = dbProviders.slug[1]
					, enabled         = dbProviders.enabled[1]
					, metadata        = dbProviders.metadata[1]
					, loginUrl        = "/saml2/login/jumpcloud/"
					, entityIdSuffix  = ""
				} );
				providers.google.append( {
					  slug        = dbProviders.slug[2]
					, enabled     = dbProviders.enabled[2]
					, metadata    = dbProviders.metadata[2]
					, title       = "google title"
					, description = "google description"
				} );

				for( var p in providers ) {
					var provider = providers[ p ];
					provider.id = p;

					expected.append( provider );
				}

				expected.sort( function( a, b ){
					return a.title > b.title ? 1 : -1;
				} );

				expect( service.listProviders() ).toBe( expected );
			} );
		} );
	}

	private any function _getService( struct configuredProviders=_defaultConfiguredProviders(), samlCertificateService=_getStubCertService() ) {
		var svc = CreateObject( "app.extensions.preside-ext-saml2-sso.services.saml.idp.SamlIdentityProviderService" );

		mockProviderDao = CreateStub();

		svc = CreateMock( object=svc );
		svc.$( "_ensureProvidersExistInDb" );
		svc.$( "$getPresideObject" ).$args( "saml2_idp" ).$results( mockProviderDao );
		svc.$( "$translateResource", "" );

		svc.init(
			argumentCollection = arguments
		);


		return svc;
	}

	private function _getStubCertService() {
		return new samlIdProvider.saml.signing.SamlCertificateService(
			  samlProviderMetadataGenerator = CreateStub()
			, x509CertReader                = new samlIdProvider.saml.signing.X509CertReader()
			, rsaKeyReader                  = new samlIdProvider.saml.signing.RsaKeyReader()
		);
	}

	private struct function _defaultConfiguredProviders() {
		return {
			"google" : {
				  admin           = false
				, web             = true
				, autoRegister    = false
				, postAuthHandler = "some.handler"
				, entityIdSuffix  = ""
				, loginUrl        = "/test/"
			},
			"JumpCloud" : {}
		};
	}

}