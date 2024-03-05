/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @samlCertificateService.inject samlCertificateService
	 * @configuredProviders.inject    coldbox:setting:saml2.identityProviders
	 */
	public any function init(
		  required any    samlCertificateService
		, required struct configuredProviders
	) {
		variables.samlCertificateService = arguments.samlCertificateService;
		variables.configuredProviders    = arguments.configuredProviders;

		return this;
	}

	public any function postInit() {
		_ensureProvidersExistInDb();
	}

// PUBLIC API
	public array function listProviders() {
		var dbProviders    = $getPresideObject( "saml2_idp" ).selectData();
		var dbProvidersMap = {};
		var list           = [];

		for( var provider in dbProviders ) {
			dbProvidersMap[ provider.slug ] = provider;
		}

		for( var providerId in configuredProviders ) {
			var provider = dbProvidersMap[ providerId ] ?: {};

			provider.append( {
				  id              = providerId
				, admin           = configuredProviders[ providerId ].admin           ?: true
				, web             = configuredProviders[ providerId ].web             ?: false
				, autoRegister    = configuredProviders[ providerId ].autoRegister    ?: true
				, postAuthHandler = configuredProviders[ providerId ].postAuthHandler ?: ""
				, loginUrl        = configuredProviders[ providerId ].loginUrl        ?: "/saml2/login/#providerId#/"
				, entityIdSuffix  = configuredProviders[ providerId ].entityIdSuffix  ?: ""
				, title           = $translateResource( uri="saml2.identityProviders:#providerId#.title"      , defaultValue=providerId )
				, description     = $translateResource( uri="saml2.identityProviders:#providerId#.description", defaultValue=""         )
			} );

			list.append( provider );
		}

		return list.sort( function( a, b ){
			return a.title > b.title ? 1 : -1;
		} );
	}

	public struct function getProvider( required string id ) {
		var providers = configuredProviders;

		for( var providerId in providers ) {
			if ( providerId == arguments.id ) {
				var provider = StructCopy( providers[ providerId ] );
				var providerRecord = $getPresideObject( "saml2_idp" ).selectData( filter={ slug=arguments.id } );

				for ( var pr in providerRecord ) {
					StructAppend( provider, pr, false );
				}

				provider.title       = $translateResource( uri="saml2.identityProviders:#providerId#.title"      , defaultValue=providerId );
				provider.description = $translateResource( uri="saml2.identityProviders:#providerId#.description", defaultValue=""         );

				return provider;
			}
		}

		return {};
	}

	public string function getIdpIdBySlug( required string slug ) {
		var providerRecord = $getPresideObject( "saml2_idp" ).selectData(
			  filter       = { slug=arguments.slug }
			, selectFields = [ "id" ]
		);

		return providerRecord.id ?: "";
	}

	public string function getIdpByResponseAudience( required string responseAudience ) {
		var settings = $getPresideCategorySettings( "saml2Provider" );
		var baseUrl = settings.sso_endpoint_root ?: "";

		if ( !Len( Trim( baseUrl ) ) || baseUrl == arguments.responseAudience ) {
			return "";
		}

		for( var idp in listProviders() ) {
			if ( baseUrl & idp.entityIdSuffix == arguments.responseAudience ) {
				return idp.id;
			}
		}
	}

// PRIVATE HELPERS
	private void function _ensureProvidersExistInDb() {
		var dao = $getPresideObject( "saml2_idp" );

		for( var providerId in configuredProviders ) {
			if ( !dao.dataExists( filter={ slug=providerId } ) ) {
				var kp = samlCertificateService.generateKeyPair();
				dao.insertData( {
					  slug        = providerId
					, name        = $translateResource( uri="saml2.identityProviders:#providerId#.title", defaultValue=providerId )
					, private_key = kp.private
					, public_cert = kp.public
				} );
			}
		}
	}

}