/**
 * @labelfield name
 *
 */
component  {
	property name="name"                      type="string"  dbtype="varchar" maxlength=200 required=true  uniqueindexes="consumer_name";
	property name="slug"                      type="string"  dbtype="varchar" maxlength=200 required=false uniqueindexes="consumer_slug";
	property name="metadata"                  type="string"  dbtype="text"    required=true;
	property name="login_message"             type="string"  dbtype="text";
	property name="access_denied_message"     type="string"  dbtype="text";
	property name="sso_type"                  type="string"  dbtype="varchar" maxlength=3 enum="samlSsoType" renderer="samlSsoType";
	property name="use_attributes"            type="string"  dbtype="text";
	property name="id_attribute"              type="string"  dbtype="varchar" maxlength=200;
	property name="id_attribute_format"       type="string"  dbtype="varchar" maxlength=15 enum="samlNameIdFormat";

	property name="id_attribute_is_transient" type="boolean" dbtype="boolean" default=false; // field is deprecated, but here for backward compatibility

	property name="access_condition" relationship="many-to-one" relatedto="rules_engine_condition";

	property name="sso_link" type="string" formula="case when ${prefix}sso_type = 'idp' then Concat( '/saml2/idpsso/', ${prefix}slug, '/' ) else '' end" renderer="saml2IdpLink";
}