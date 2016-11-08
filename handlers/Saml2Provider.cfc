component {

	private struct function retrieveAttributes( event, rc, prc ) {
		var userDetails = getLoggedInUserDetails();

		return {
			  email       = ( userDetails.email_address ?: "" )
			, displayName = ( userDetails.display_name ?: "" )
			, firstName   = ListFirst( userDetails.display_name ?: "", " " )
			, lastName    = ListRest( userDetails.display_name ?: "", " " )
		};
	}

}