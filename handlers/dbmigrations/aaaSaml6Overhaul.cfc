/**
 * Migration for SAML extension v5 (and earlier) to v6
 */
component {

	property name="saml2LegacyMigrationService" inject="saml2LegacyMigrationService";

	private boolean function runAsync() {
		var alreadyRun = getPresideObject( "db_migration_history" ).dataExists( filter={ migration_key="Saml6Overhaul-async" } );

		if ( !alreadyRun ) {
			saml2LegacyMigrationService.migrate();
		}

		return true;
	}

}