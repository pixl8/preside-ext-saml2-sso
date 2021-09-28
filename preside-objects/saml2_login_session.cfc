/**
 * This object is used as a log for logged in SP sessions.
 * These can then be used later when performing Single Logout
 * to only request logout from services that actually have been
 * logged in to.
 *
 * @nolabel        true
 * @nodatemodified true
 * @versioned      false
 * @feature        samlSsoProviderSlo
 */
component  {
	property name="owner"         type="string" dbtype="varchar" maxlength=35 required=true indexes="owner";
	property name="session_index" type="string" dbtype="varchar" maxlength=35 required=true indexes="sessionindex";
	property name="issuer"        type="string" dbtype="varchar" maxlength=35 required=true indexes="issuer";
}