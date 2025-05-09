/**
 * @labelfield                          name
 * @datamanagerEnabled                  true
 * @datamanagerGridFields               name,slug,datemodified
 * @datamanagerDisallowedOperations     viewversions,clone
 * @datamanagerTypeToConfirmDelete      true
 * @datamanagerTypeToConfirmBatchDelete true
 */
component  {
	property name="name"                      type="string"  dbtype="varchar" maxlength=200 required=true  uniqueindexes="sp_name"                 adminRenderer="none";
	property name="slug"                      type="string"  dbtype="varchar" maxlength=200 required=false uniqueindexes="sp_slug" renderer="code" adminRenderer="none";

	property name="entity_id"                   type="string"  dbtype="varchar" maxlength=255 required=true renderer="code";
	property name="requests_will_be_signed"     type="boolean" dbtype="boolean" required=true;
	property name="want_assertions_signed"      type="boolean" dbtype="boolean" required=true;
	property name="assertion_consumer_location" type="string"  dbtype="varchar" maxlength=255 required=true renderer="code";
	property name="assertion_consumer_binding"  type="string"  dbtype="varchar" maxlength=13  required=true  enum="saml2BindingMethods";
	property name="signing_certificate"         type="string"  dbtype="text" r                required=false renderer="x509Summary" autofilter=false;
	property name="single_logout_location"      type="string"  dbtype="varchar" maxlength=255 required=false renderer="code"             feature="samlSsoProviderSlo";
	property name="single_logout_binding"       type="string"  dbtype="varchar" maxlength=13  required=false enum="saml2BindingMethods"  feature="samlSsoProviderSlo";

	property name="sso_type"                  type="string"  dbtype="varchar" maxlength=3 enum="samlSsoType" renderer="samlSsoType";
	property name="sso_link"                  type="string" formula="case when ${prefix}sso_type = 'idp' then Concat( '/saml2/idpsso/', ${prefix}slug, '/' ) else '' end" renderer="saml2IdpLink";
	property name="login_message"             type="string"  dbtype="text";
	property name="access_condition" relationship="many-to-one" relatedto="rules_engine_condition";
	property name="access_denied_message"     type="string"  dbtype="text";

	property name="metadata_url" type="string" formula="${prefix}id" renderer="saml2spmetadataUrl";

	property name="idp_entity_id"    type="string" formula="${prefix}slug" renderer="saml2SpEntityId" autofilter=false;
	property name="idp_sso_location" type="string" formula="${prefix}slug" renderer="saml2SpSsoLocation" autofilter=false;

	property name="public_cert"  type="string" dbtype="text" required=false renderer="x509Summary" autofilter=false batcheditable=false;
	property name="private_key"  type="string" dbtype="text" required=false adminrenderer="none" encrypt=true excludeDataExport=true autofilter=false batcheditable=false adminrenderer="none";

	property name="id_attribute"              type="string"  dbtype="varchar" maxlength=200 adminRenderer="saml2SpIdAttribute";
	property name="id_attribute_format"       type="string"  dbtype="varchar" maxlength=15 enum="samlNameIdFormat" adminRenderer="saml2SpIdAttributeFormat";
	property name="use_attributes"            type="string"  dbtype="text" adminRenderer="saml2SpAttributes";
	property name="id_attribute_is_transient" type="boolean" dbtype="boolean" default=false                        adminRenderer="none"; // field is deprecated, but here for backward compatibility
}