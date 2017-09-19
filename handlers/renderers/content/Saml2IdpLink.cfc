component {

	public string function default( event, rc, prc, args={} ){
		var linkPath = args.data ?: "";

		if ( linkPath.len() ) {
			var baseUrl = event.getSiteUrl( includePath=false, includeLanguageSlug=false ).reReplace( "/$", "" );

			return '<a href="#baseUrl##linkPath#" target="_blank"><i class="fa fa-fw fa-external-link"></i> #linkPath#</a>';
		}

		return "";
	}

}