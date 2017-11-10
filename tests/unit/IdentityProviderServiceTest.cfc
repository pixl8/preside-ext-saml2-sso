component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "listProviders()", function() {
			it( "should return empty array when no providers configured in Config.cfc", function(){
				var service = _getService( {} );
				var results = service.listProviders();

				expect( results ).toBe( [] );
			} );

			it( "should list configured providers, filling in any default values for provider attributes", function(){
				var service   = _getService();
				var results   = service.listProviders();
				var providers = _defaultConfiguredProviders();
				var expected  = [];

				providers.jumpCloud.append( {
					  admin           = true
					, web             = false
					, autoRegister    = true
					, postAuthHandler = ""
					, title           = "jumpCloud"
					, description     = ""
				} );

				for( var p in providers ) {
					var provider = providers[ p ];
					provider.id = p;

					expected.append( provider );
				}

				expected.sort( function( a, b ){
					return a.title > b.title ? 1 : -1;
				} );

				expect( results ).toBe( expected );
			} );
		} );
	}

	private any function _getService( struct configuredProviders=_defaultConfiguredProviders() ) {
		var svc = CreateObject( "app.extensions.preside-ext-saml2-sso.services.IdentityProviderService" ).init(
			argumentCollection = arguments
		);

		svc = CreateMock( object=svc );

		return svc;
	}

	private struct function _defaultConfiguredProviders() {
		return {
			"google" : {
				  admin           = false
				, web             = true
				, autoRegister    = false
				, postAuthHandler = "some.handler"
				, title           = "Google, init!"
				, description     = "So, this is nice..."
			},
			"JumpCloud" : {}
		};
	}

}