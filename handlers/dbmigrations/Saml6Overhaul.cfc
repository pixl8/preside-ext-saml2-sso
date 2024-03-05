/**
 * Migration for SAML extension v5 (and earlier) to v6
 */
component {

	property name="saml2LegacyMigrationService" inject="saml2LegacyMigrationService";

	private boolean function runAsync() {
		saml2LegacyMigrationService.migrate();

		return true;
	}

}