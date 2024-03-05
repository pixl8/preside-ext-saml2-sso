(function( $ ){

	var $form                  = $( "[name=configuration_method]" ).closest( "form" )
	  , $manualConfigFieldsets = $form.find( "fieldset[id^=fieldset-manual-]" )
	  , $metaFieldset          = $form.find( "fieldset#fieldset-metadata" )
	  , $confMethodField       = $form.find( "[name=configuration_method]" )
	  , $reqSignedField        = $form.find( "[name=requests_will_be_signed]" )
	  , $x509CertField         = $form.find( "[name=signing_certificate]" ).closest( ".form-group" )
	  , toggleMetaAndConfig, toggleSigningCert, getConfigMethod;

	getConfigMethod = function(){
		return $confMethodField.filter( ":checked" ).val();
	};

	toggleMetaAndConfig = function() {
		if ( getConfigMethod() == "metadata" ) {
			$metaFieldset.show();
			$manualConfigFieldsets.hide();
		} else {
			$manualConfigFieldsets.show();
			toggleSigningCert();
			$metaFieldset.hide();
		}
	};

	toggleSigningCert = function() {
		if ( getConfigMethod() == "manual" && $reqSignedField.is( ":checked" ) ) {
			$x509CertField.show();
		} else {
			$x509CertField.hide();
		}
	}

	toggleMetaAndConfig();
	toggleSigningCert();

	$confMethodField.on( "click", toggleMetaAndConfig );
	$reqSignedField.on( "click", toggleSigningCert );


})( presideJQuery );