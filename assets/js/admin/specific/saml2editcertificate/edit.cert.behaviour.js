(function( $ ){

	var $methodField = $( "[name=method]" )
	  , $certField   = $( "[name=new_public_cert]" ).closest( ".form-group" )
	  , $keyField    = $( "[name=new_private_key]" ).closest( ".form-group" )
	  , toggleFields;

	getConfigMethod = function(){
		return $methodField.filter( ":checked" ).val();
	};

	toggleFields = function() {
		if ( getConfigMethod() == "auto" ) {
			$certField.hide();
			$keyField.hide();
		} else {
			$certField.show();
			$keyField.show();
		}
	};

	toggleFields();

	$methodField.on( "click", toggleFields );

})( presideJQuery );