/**
 * @labelfield name
 *
 */
component  {
	property name="name"                  type="string" dbtype="varchar" maxlength=200 required=true uniqueindexds="consumer_name";
	property name="metadata"              type="string" dbtype="text"    required=true;
	property name="login_message"         type="string" dbtype="text";
	property name="access_denied_message" type="string" dbtype="text";

	property name="access_condition" relationship="many-to-one" relatedto="rules_engine_condition";
}