component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol3 = [];

	private string function rootBreadcrumb() {
		event.addAdminBreadCrumb( title=translateResource( "saml2:admin.page.breadcrumb" ), link=event.buildAdminLink( linkto="saml2admin" ) );
	}

	private string function preRenderListing( event, rc, prc, args={} ) {
		if ( event.getCurrentEvent() == "admin.datamanager.object" ) {
			switch( args.objectName ?: "" ) {
				case "saml2_sp":
					args.tab = "sps";
				break;
				case "saml2_idp":
					args.tab = "idps";
				break;
				case "saml2_debug_log":
					args.tab = "debug";
				break;
			}

			args.tabTopOnly = true;

			return renderView( view="/admin/saml2Admin/_samlAdminTabs", args=args );
		}
	}

	private string function postRenderListing( ) {
		if ( event.getCurrentEvent() == "admin.datamanager.object" ) {
			prc.pageTitle = translateResource( "saml2:admin.page.title" )

			args.tabTopOnly    = false;
			args.tabBottomOnly = true;

			return renderView( view="/admin/saml2Admin/_samlAdminTabs", args=args );
		}
	}

// HELPERS
	private string function _getMetadataSourceField( args ) {
		if ( Len( args.formData.rawmeta ?: "" ) ) {
			return "rawmeta";
		} else if ( Len( args.formData.metaurl ?: "" ) ) {
			return "metaurl";
		} else if ( IsStruct( args.formData.metaFile ?: "" ) && IsBinary( args.formData.metafile.binary ?: "" ) ) {
			return "metafile";
		}

		return "";
	}

	private string function _getRawMetadataFromField( args, sourceField ) {
		var metadata = "";

		switch( sourceField ) {
			case "rawmeta":
				return args.formData.rawMeta;
			case "metaurl":
				try {
					var result = "";
					http url=args.formData.metaurl timeout=10 throwonerror=true result="result";
					return result.filecontent ?: "";
				} catch( any e ) {
					logError( e );
					args.validationResult.addError( "metaurl", "saml2:error.fetching.meta.from.url" );
				}
				return "";
			case "metafile":
				return toString( args.formData.metafile.binary );
		}

		return "";
	}

	private struct function _extractSpDetailsFromMetadata( args, sourceField, metadata ) {
		var meta = _readMeta( argumentCollection=arguments );

		var data = {
			  entity_id                   = meta.id ?: ""
			, signing_certificate         = meta.serviceProviderSsoRequirements.x509Certificate ?: ""
			, requests_will_be_signed     = isTrue( meta.serviceProviderSsoRequirements.requestsWillBeSigned ?: "" )
			, want_assertions_signed      = isTrue( meta.serviceProviderSsoRequirements.wantAssertionsSigned ?: "" )
			, assertion_consumer_location = meta.serviceProviderSsoRequirements.defaultAssertionConsumer.location ?: ""
			, assertion_consumer_binding  = ListLast( meta.serviceProviderSsoRequirements.defaultAssertionConsumer.binding ?: "", ":" )
		};

		if ( isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			data.single_logout_location = meta.serviceProviderSsoRequirements.logoutService.location ?: "";
			data.single_logout_binding  = ListLast( meta.serviceProviderSsoRequirements.logoutService.binding ?: "" );
		}

		if ( !_validateMeta( argumentCollection=arguments, objectName="saml2_sp", data=data ) ) {
			return {};
		}

		return data;
	}

	private struct function _extractIdpDetailsFromMetadata( args, sourceField, metadata ) {
		var meta = _readMeta( argumentCollection=arguments );
		var data = {
			  entity_id           = meta.id              ?: ""
			, sso_location        = meta.idpSsoLocation  ?: ""
			, name_id_format      = meta.idpNameIdFormat ?: ""
			, signing_certificate = meta.x509Certificate ?: ""
		};

		if ( !_validateMeta( argumentCollection=arguments, objectName="saml2_idp", data=data ) ) {
			return {};
		}

		return data;
	}

	private struct function _readMeta( args, sourceField, metadata ) {
		try {
			return new "app.extensions.preside-ext-saml2-sso.services.saml.metadata.SamlMetadata"( arguments.metadata ).getMemento();
		} catch( any e ) {
			args.validationResult.addError( arguments.sourceField, "saml2:error.could.not.read.meta" );
		}

		return {};
	}

	private boolean function _validateMeta( args, sourceField, data, formname, objectName ) {
		var validationResult = validateForm( formName="preside-objects.#arguments.objectName#.meta.validator", formData=arguments.data );

		if ( !validationResult.validated() ) {
			var errors   = validationResult.getMessages();
			var rendered = [];
			for( var field in errors ) {
				ArrayAppend( rendered, '<strong>#translatePropertyName( arguments.objectName, field )#</strong>: #translateResource( uri=errors[ field ].message, data=errors[ field ].params, defaultValue=errors[ field ].message )#' );
			}

			var errorMessage = translateResource( uri="saml2:error.invalid.meta", data=[ ArrayToList( rendered, '<br>' ) ] );

			args.validationResult.addError( arguments.sourceField, errorMessage );
		}

		return validationResult.validated();
	}
}