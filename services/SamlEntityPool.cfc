/**
 * @singleton      true
 * @presideService true
 *
 */
component {

// CONSTRUCTOR
	/**
	 * @identityProviderService.inject identityProviderService
	 *
	 */
	public any function init( required any identityProviderService ) {
		_setIdentityProviderService( arguments.identityProviderService );

		return this;
	}

// PUBLIC API METHODS
	public array function listEntities( string entityType="sp" ) {
		var records = $getPresideObject( arguments.entityType == "sp" ? "saml2_consumer" : "saml2_identity_provider" ).selectData( selectFields=[ "metadata" ] );
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

	public struct function getEntity( required string entityId, string entityType="sp" ) {
		var sourceObject = "saml2_consumer";
		var entityKey    = "consumerRecord";

		if ( arguments.entityType == "idp" ) {
			sourceObject = "saml2_identity_provider";
			entityKey    = "idpRecord";
		}

		var records = $getPresideObject( sourceObject ).selectData();

		for( var record in records ) {
			var entity        = _getEntityFromMetadata( record.metadata ).getMemento();
			var savedEntityId = entity.id;
			if ( savedEntityId.len() && arguments.entityId == savedEntityId ) {
				if ( arguments.entityType == "idp" ) {
					entity[ entityKey ] = _getIdentityProviderService().getProvider( record.slug );
				} else {
					entity[ entityKey ] = record;
				}

				return entity;
			}
		}

		throw(
			  type    = "entitypool.missingentity"
			, message = "The entity, [#arguments.entityId#], could not be found"
		);
	}

	public struct function getEntityBySlug( required string slug, string entityType="sp" ) {
		var sourceObject = "saml2_consumer";
		var entityKey    = "consumerRecord";

		if ( arguments.entityType == "idp" ) {
			sourceObject = "saml2_identity_provider";
			entityKey    = "idpRecord";
		}

		var record = $getPresideObject( sourceObject ).selectData( filter={ slug=arguments.slug } );

		for( var r in record ) {
			var entity        = _getEntityFromMetadata( r.metadata ).getMemento();
			var savedEntityId = entity.id;

			entity[ entityKey ] = r;
			return entity;
		}

		throw(
			  type    = "entitypool.missingentity"
			, message = "The entity, [#arguments.slug#], could not be found"
		);
	}

// PRIVATE HELPERS
	private any function _getEntityFromMetadata( required string metadata ) {
		try {
			return new SamlMetadata( arguments.metadata );
		} catch ( any e ) {
			return new SamlMetadata( ToString( XmlNew() ) );
		}
	}

	private any function _getIdentityProviderService() {
		return _identityProviderService;
	}
	private void function _setIdentityProviderService( required any identityProviderService ) {
		_identityProviderService = arguments.identityProviderService;
	}
}