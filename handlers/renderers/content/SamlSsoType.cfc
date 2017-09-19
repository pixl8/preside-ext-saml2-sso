component {

	public string function default( event, rc, prc, args={} ){
		var type = args.data ?: "";

		if ( type.len() ) {
			return translateResource( uri="enum.samlSsoType:#type#.label", defaultValue=type );
		}

		return "";
	}

}