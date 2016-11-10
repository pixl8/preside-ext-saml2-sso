/**
 * @singleton      true
 * @presideService true
 *
 */
component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public array function listEntities() {
		var consumers = $getPresideObject( "saml2_consumer" ).selectData( selectFields=[ "metadata" ] );
		var entities  = [];

		for( var consumer in consumers ) {
			var entity   = _getEntityFromMetadata( consumer.metadata );
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

	public struct function getEntity( required string entityId ) {
		var consumers = $getPresideObject( "saml2_consumer" ).selectData();

		for( var consumer in consumers ) {
			var entity        = _getEntityFromMetadata( consumer.metadata ).getMemento();
			var savedEntityId = entity.id;
			if ( savedEntityId.len() && arguments.entityId == savedEntityId ) {
				entity.consumerRecord = consumer;

				return entity;
			}
		}

		throw(
			  type    = "entitypool.missingentity"
			, message = "The entity, [#arguments.entityId#], could not be found"
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
}