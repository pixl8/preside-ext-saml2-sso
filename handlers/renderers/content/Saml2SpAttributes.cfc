component {

	property name="attributes" inject="coldbox:setting:saml2.attributes.supported";

	function default( event, rc, prc, args={} ) {
		var rendered = [];
		var configured = Len( args.data ?: "" ) ? ListToArray( args.data ) : StructKeyArray( attributes );

		for( var attribName in configured ) {
			ArrayAppend( rendered, attributes[ attribName ].friendlyName ?: attribName );
		}

		return ArrayToList( rendered, ", " );
	}
}