/**
 * @labelfield name
 *
 */
component  {
	property name="name"              type="string"  dbtype="varchar" maxlength=200 required=true  uniqueindexes="idp_name";
	property name="slug"              type="string"  dbtype="varchar" maxlength=200 required=false uniqueindexes="idp_slug";
	property name="metadata"          type="string"  dbtype="text"    required=true;
	property name="login_message"     type="string"  dbtype="text";
	property name="idp_type"          type="string"  dbtype="varchar" maxlength=5 enum="samlIdpType" renderer="samlIdpType";
	property name="auto_create_users" type="boolean" dbtype="boolean" default=true;

	property name="add_to_admin_groups" relationship="many-to-many" relatedto="security_group";
}