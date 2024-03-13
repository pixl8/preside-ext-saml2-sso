component {

	public string function default( event, rc, prc, args={} ){
		var sp  = Trim( ListFirst( args.data ?: "", "|", true ) );
		var idp = Trim( ListRest(  args.data ?: "", "|", true ) );

		if ( Len( sp ) ) {
			return '<i class="fa fa-fw fa-globe"></i> ' & renderLabel( "saml2_sp", sp );
		}

		if ( Len( idp ) ) {
			return '<i class="fa fa-fw fa-users"></i> ' & renderLabel( "saml2_idp", idp );
		}


		return '<i class="fa fa-fw fa-question light-grey"></i>';
	}

}