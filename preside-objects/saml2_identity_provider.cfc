/**
 * @labelfield name
 *
 */
component  {
	property name="slug"     type="string" dbtype="varchar" maxlength=200 required=false uniqueindexes="idp_slug";
	property name="metadata" type="string" dbtype="text"    required=true;
}