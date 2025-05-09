component {

	public string function default( event, rc, prc, args={} ){
		var success       = isTrue( Trim( ListFirst( args.data ?: "", "|", true ) ) );
		var failureReason = Trim( ListRest(  args.data ?: "", "|", true ) );

		if ( success ) {
			return '<i class="fa fa-fw fa-check-circle green"></i>';
		}

		if ( Len( failureReason ) ) {
			return '<i class="fa fa-fw fa-times-circle red"></i> ' & translateResource( uri="enum.saml2failurereason:#failureReason#.label", defaultValue=failureReason );
		}


		return '<i class="fa fa-fw fa-question light-grey"></i>';
	}

}