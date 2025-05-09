component {

	property name="attributes" inject="coldbox:setting:saml2.attributes.supported";

	function default( event, rc, prc, args={} ) {
		return attributes[ args.data ?: "id" ].friendlyName ?: translateResource( "preside-objects.saml2_sp:default.id_attribute" );
	}
}