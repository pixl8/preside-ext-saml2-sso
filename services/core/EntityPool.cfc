component {

// CONSTRUCTOR
	public any function init( required string metaDataDir ) {
		_setMetadataDir( arguments.metaDataDir );
		_loadEntitiesFromMetaData();

		return this;
	}

// PUBLIC API METHODS
	public array function listEntities() {
		return _getEntities().keyArray();
	}

	public boolean function entityExists( required string entityId ) {
		return _getEntities().keyExists( arguments.entityId );
	}

	public any function getEntity( required string entityId ) {
		var entities = _getEntities();
		return entities[ arguments.entityId ] ?: throw(
			  type    = "entitypool.missingentity"
			, message = "The entity, [#arguments.entityId#], could not be found"
		);
	}

// PRIVATE HELPERS
	private void function _loadEntitiesFromMetaData() {
		var xmlFiles = DirectoryList( _getMetadataDir(), false, "path", "*.xml" );
		var entities = {};

		for( var xmlFile in xmlFiles ){
			try {
				var entityMd = new samlMetadata( FileRead( xmlFile ) )
				entities[ entityMd.getEntityId() ] = entityMd;
			} catch ( any e ) {
				// TODO, something useful here
			}
		}

		_setEntities( entities );
	}

// GETTERS AND SETTERS
	private any function _getMetadataDir() {
		return _metaDataDir;
	}
	private void function _setMetadataDir( required any metaDataDir ) {
		_metaDataDir = arguments.metaDataDir;
	}

	private struct function _getEntities() {
		return _entities;
	}
	private void function _setEntities( required struct entities ) {
		_entities = arguments.entities;
	}
}