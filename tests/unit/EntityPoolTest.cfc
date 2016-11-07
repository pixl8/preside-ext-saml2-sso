component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "listEntities()", function(){
			it( "should return an array of the ids of entities as parsed from their files", function(){
				var pool           = _getPool();
				var expectedIdList = [ "http://www.test.com", "https://anothertest.com", "https://app.goodpractice.net" ]

				expect( pool.listEntities().sort( "text" ) ).toBe( expectedIdList );
			} );
		} );

		describe( "entityExists()", function(){
			it( "should return true when the passed id is one of the registered entity IDs", function(){
				var pool = _getPool();

				expect( pool.entityExists( "http://www.test.com" ) ).toBeTrue();
			} );

			it( "should return false when the passed id is NOT one of the regeistered entity IDs", function(){
				var pool = _getPool();

				expect( pool.entityExists( "meh" ) ).toBeFalse();
			} );
		} );

		describe( "getEntity()", function(){
			it( "should return the entity indicated by the passed id", function(){
				var pool   = _getPool();
				var id     = "http://www.test.com";
				var entity = pool.getentity( id );

				expect( entity.getEntityId() ).toBe( id );
			} );

			it( "should throw an informative error when the entity does not exist", function(){
				var pool   = _getPool();
				var id     = "balls";

				expect( function(){
					pool.getentity( id );
				} ).toThrow( "entitypool.missingentity"  );
			} );
		} );
	}

	private any function _getPool() {
		return new samlIdProvider.SamlEntityPool( metadataDir="/tests/resources/entityPool/" );
	}

}