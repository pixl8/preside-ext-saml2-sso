component {

	property name="samlProviderMetadataGenerator" inject="samlProviderMetadataGenerator";

	function default( event, rc, prc, args={} ) {
		var settings = samlProviderMetadataGenerator.getMetadataSettings();

		return "<code>#settings.sso_endpoint_root#</code>";
	}
}