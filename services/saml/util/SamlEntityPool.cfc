/**
 * @singleton      true
 * @presideService true
 *
 */
component {

// CONSTRUCTOR
	/**
	 * @samlIdentityProviderService.inject samlIdentityProviderService
	 *
	 */
	public any function init( required any samlIdentityProviderService ) {
		_setSamlIdentityProviderService( arguments.samlIdentityProviderService );

		return this;
	}

// PUBLIC API METHODS
	public array function listEntities( string entityType="sp" ) {
		var records = $getPresideObject( arguments.entityType == "sp" ? "saml2_sp" : "saml2_idp" ).selectData( selectFields=[ "metadata" ] );
		var entities  = [];

		for( var record in records ) {
			var entity   = _getEntityFromMetadata( record.metadata );
			var entityId = entity.getEntityId();

			if ( entityId.len() ) {
				entities.append( entityId );
			}
		}

		return entities;
	}

	public boolean function entityExists( required string entityId ) {
		return listEntities().findNoCase( arguments.entityId );
	}

	public struct function getEntity( required string entityId, string entityType="sp", string audience="" ) {
		return _getEntity( argumentCollection=arguments, entityFilters=[{ filter={ entity_id=arguments.entityId }}] );
	}

	public struct function getEntityBySlug( required string slug, string entityType="sp" ) {
		return _getEntity( argumentCollection=arguments, entityFilters=[{ filter={ slug=arguments.slug }}] );
	}

	public struct function getEntityById( required string id, string entityType="sp" ) {
		return _getEntity( argumentCollection=arguments, entityFilters=[{ filter={ id=arguments.id }}] );
	}

// PRIVATE HELPERS
	private struct function _getEntity( string entityType="sp", array entityFilters=[], string audience="" ) {
		var sourceObject     = "saml2_sp";
		var entityKey        = "consumerRecord";
		var matchingEntities = StructNew( "linked" );

		if ( arguments.entityType == "idp" ) {
			sourceObject = "saml2_idp";
			entityKey    = "idpRecord";
		}

		var records = $getPresideObject( sourceObject ).selectData( extraFilters=arguments.entityFilters );

		for( var record in records ) {
			if ( arguments.entityType == "idp" ) {
				entity[ entityKey ] = _getSamlIdentityProviderService().getProvider( record.slug );
				matchingEntities[ entity[ entityKey ].slug ] = entity;
			} else {
				entity[ entityKey ] = record;
				matchingEntities[ entity[ entityKey ].id ] = entity;
			}
		}

		// WHAT IS THIS?
		if ( StructCount( matchingEntities ) > 1 )  {
			var requestedIdp = "";

			if ( arguments.audience.len() ) {
				requestedIdp = _getSamlIdentityProviderService().getIdpByResponseAudience( arguments.audience );
			}
			if ( !Len( Trim( requestedIdp ) ) ) {
				requestedIdp = $getRequestContext().getValue( "idp", "" );
			}

			if ( Len( Trim( requestedIdp ) ) && StructKeyExists( matchingEntities, requestedIdp ) ) {
				return matchingEntities[ requestedIdp ];
			}
			return matchingEntities[ StructKeyArray( matchingEntities )[ 1 ] ];
		} else if ( StructCount( matchingEntities ) == 1 )  {
			return matchingEntities[ StructKeyList( matchingEntities ) ];
		}

		throw(
			  type    = "entitypool.missingentity"
			, message = "The entity could not be found"
		);
	}

	private any function _getSamlIdentityProviderService() {
		return _samlIdentityProviderService;
	}
	private void function _setSamlIdentityProviderService( required any samlIdentityProviderService ) {
		_samlIdentityProviderService = arguments.samlIdentityProviderService;
	}
}