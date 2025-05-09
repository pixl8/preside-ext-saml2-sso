/**
 * @labelField                      name
 * @datamanagerEnabled              true
 * @datamanagerAllowedOperations    read,edit
 * @datamanagerDisallowedOperations batchedit
 * @datamanagerGridFields           enabled,name,slug,datemodified
 */
component  {
	property name="name"     type="string"  dbtype="varchar" maxlength=200 required=true  uniqueindexes="name";
	property name="slug"     type="string"  dbtype="varchar" maxlength=200 required=false uniqueindexes="idp_slug" renderer="code";
	property name="enabled"  type="boolean" dbtype="boolean" required=false default=false;

	property name="entity_id"           type="string" dbtype="varchar" maxlength=255 required=false renderer="code";
	property name="sso_location"        type="string" dbtype="varchar" maxlength=255 required=false renderer="code";
	property name="name_id_format"       type="string" dbtype="varchar" maxlength=255 required=false renderer="code";
	property name="signing_certificate" type="string" dbtype="text" required=false renderer="x509Summary" autofilter=false;

	property name="private_key" type="string" dbtype="text" required=true adminrenderer="none" encrypt=true excludeDataExport=true autofilter=false;
	property name="public_cert" type="string" dbtype="text" required=true renderer="x509Summary" autofilter=false;
}