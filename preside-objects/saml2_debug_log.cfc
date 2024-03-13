/**
 * @datamanagerEnabled                  true
 * @datamanagerAllowedOperations        read,delete
 * @datamanagerGridFields               success_and_reason,provider,request_type,datecreated
 * @datamanagerTypeToConfirmDelete      false
 * @datamanagerTypeToConfirmBatchDelete false
 * @labelRenderer                       saml2_debug_log
 * @nodatemodified                      true
 * @nolabel                             true
 * @versioned                           false
 *
 */
component  {
	property name="id" type="numeric" dbtype="bigint" generator="increment" adminrenderer="none";
	property name="sp"  relationship="many-to-one" relatedto="saml2_sp"  required=false adminrenderer="none";
	property name="idp" relationship="many-to-one" relatedto="saml2_idp" required=false adminrenderer="none";

	property name="request_type"   type="string"  dbtype="varchar" maxlength=20 required=true  enum="saml2requesttype"   indexes="requesttype" adminrenderer="none";
	property name="failure_reason" type="string"  dbtype="varchar" maxlength=20 required=false enum="saml2failurereason" indexes="failurereason" adminrenderer="none";
	property name="success"        type="boolean" dbtype="boolean" required=true indexes="success" adminrenderer="none";
	property name="saml_xml"       type="string"  dbtype="text" renderer="saml2xml";
	property name="relay_state"    type="string"  dbtype="text" renderer="code";
	property name="error"          type="string"  dbtype="text" renderer="code";

	property name="provider"           formula="concat( coalesce( ${prefix}sp, '' ), '|', coalesce( ${prefix}idp, '' ) )"                 renderer="saml2DebugProvider" dataExportEnable=false autoFilter=false adminrenderer="none";
	property name="success_and_reason" formula="concat( coalesce( ${prefix}success, '' ), '|', coalesce( ${prefix}failure_reason, '' ) )" renderer="saml2DebugReason"   dataExportEnable=false autoFilter=false adminrenderer="none";
}