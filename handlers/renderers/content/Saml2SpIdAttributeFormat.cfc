component {

	property name="samlAttributesService" inject="samlAttributesService";

	function default( event, rc, prc, args={} ) {
		var record = prc.record ?: getPresideObject( ).selectData( id=args.recordId ?: "");

		return "<code>" & samlAttributesService.getNameIdFormat( QueryRowToStruct( record ) ) & "</code>";
	}
}