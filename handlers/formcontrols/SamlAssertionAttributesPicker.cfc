component {

	property name="samlAttributesService" inject="samlAttributesService";

	private string function index( event, rc, prc, args={} ) {
		var allAttributes = samlAttributesService.getSupportedAttributes();
		var isMultiple    = IsTrue( args.multiple ?: "" );

		args.values = [];
		args.labels = [];

		for( var attributeId in allAttributes ) {
			args.values.append( attributeId );
			args.labels.append( allAttributes[ attributeId ].friendlyName ?: attributeId );
		}

		if ( isMultiple ) {
			return renderView( view="/formcontrols/checkboxlist/index", args=args );
		} else {
			args.values.prepend( "" );
			args.labels.prepend( "" );

			return renderView( view="/formcontrols/select/index", args=args );
		}
	}

}