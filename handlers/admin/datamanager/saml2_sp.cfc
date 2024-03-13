component extends="Saml2DataManagerBase" {

	property name="samlCertificateService" inject="samlCertificateService";

	variables.permissionBase = "saml2.consumer";

	variables.infoCol1 = [ "ssoType", "accessCondition" ];

// GENERAL DATAMANAGER CUSTOMISATIONS
	private string function preRenderAddRecordForm( event, rc, prc, args={} ) {
		event.include( "/js/admin/specific/saml2addprovider/" );

		return "";
	}

	private array function getTopRightButtonsForObject() {
		return [];
	}

	private string function postRenderListing( ) {
		if ( event.getCurrentEvent() == "admin.datamanager.object" ) {
			var addLink = event.buildAdminLink( objectName="saml2_sp", operation="addRecord" );
			var addText = translateResource( "preside-objects.saml2_sp:add.record.btn" );
			return '<div class="text-center"><a class="btn btn-primary" href="#addLink#"><i class="fa fa-fw fa-plus"></i> #addText#</a></div>' & super.postRenderListing( argumentCollection=arguments );
		}
		return "";
	}

	private void function preAddRecordAction( event, rc, prc, args={} ) {
		var configMethod = args.formData.configuration_method ?: "";

		if ( ( configMethod == "metadata" ) ) {
			var sourceField = super._getMetadataSourceField( args );

			if ( !Len( sourceField ) ) {
				args.validationResult.addError( "rawmeta" , "saml2:error.no.meta.supplied" );
				args.validationResult.addError( "metaurl" , "saml2:error.no.meta.supplied" );
				args.validationResult.addError( "metafile", "saml2:error.no.meta.supplied" );
			} else {
				var metadata = super._getRawMetadataFromField( args, sourceField );

				if ( !Len( Trim( metadata ) ) ) {
					if ( !args.validationResult.fieldHasError( sourceField ) ) {
						args.validationResult.addError( sourceField, "saml2:error.could.not.read.meta" );
					}
				} else {
					StructAppend( args.formData, super._extractSpDetailsFromMetadata( args, sourceField, metadata ) );
				}
			}
		}

		if ( Len( Trim( args.formData.signing_certificate ?: "" ) ) ) {
			args.formData.signing_certificate = formatX509Certificate( args.formData.signing_certificate );
		}

		if ( args.validationResult.validated() ) {
			var keyPair = samlCertificateService.generateKeyPair();

			args.formData.private_key = keypair.private;
			args.formData.public_cert = keypair.public;
		}
	}

	private void function preEditRecordAction( event, rc, prc, args={} ) {
		var editDetail = args.formData.editDetail ?: "";

		switch( editDetail ) {
			case "meta":
				var sourceField = super._getMetadataSourceField( args );

				if ( !Len( sourceField ) ) {
					args.validationResult.addError( "rawmeta" , "saml2:error.no.meta.supplied" );
					args.validationResult.addError( "metaurl" , "saml2:error.no.meta.supplied" );
					args.validationResult.addError( "metafile", "saml2:error.no.meta.supplied" );
				} else {
					var metadata = super._getRawMetadataFromField( args, sourceField );

					if ( !Len( Trim( metadata ) ) ) {
						if ( !args.validationResult.fieldHasError( sourceField ) ) {
							args.validationResult.addError( sourceField, "saml2:error.could.not.read.meta" );
						}
					} else {
						StructAppend( args.formData, super._extractSpDetailsFromMetadata( args, sourceField, metadata ) );
					}
				}
			break;
			case "idpcert":
				switch( args.formData.method ?: "" ) {
					case "manual":
						args.formData.public_cert = args.formData.new_public_cert ?: "";
						args.formData.private_key = args.formData.new_private_key ?: "";
					break;
					case "auto":
						var keyPair = samlCertificateService.generateKeyPair();

						args.formData.private_key = keypair.private;
						args.formData.public_cert = keypair.public;
					break;
				}
			break;
		}
	}

	private string function buildEditRecordLink( event, rc, prc, args={} ) {
		var qs = "object=saml2_sp&id=#args.recordId#";

		if ( Len( rc.editDetail ?: "" ) ) {
			if ( Len( args.queryString ?: "" ) ) {
				args.queryString &= "&editDetail=#rc.editDetail#";
			} else {
				args.queryString = "editDetail=#rc.editDetail#";
			}
		}

		if ( Len( args.queryString ) ) {
			qs &= "&#args.queryString#";
		}

		return event.buildAdminLink( linkto="datamanager.editrecord", queryString=qs );
	}

	private string function getRecordDeletionPromptMatch( event, rc, prc, args={} ) {
		return args.record.name ?: "CONFIRM";
	}

	private string function getEditRecordFormName( event, rc, prc, args={} ) {
		switch( rc.editDetail ?: "" ) {
			case "meta":
				prc.pageSubTitle = translateResource( "preside-objects.saml2_sp:reupload.meta.subtitle" );
				return "preside-objects.saml2_sp.admin.edit.meta";
			break;
			case "idpcert":
				prc.pageSubTitle = translateResource( "preside-objects.saml2_sp:replace.idpcert.subtitle" );
				event.include( "/js/admin/specific/saml2editcertificate/" );
				return "preside-objects.saml2_sp.admin.edit.idpcert";
			break;
		}

		return "preside-objects.saml2_sp.admin.edit";
	}

// VIEW RECORD CUSTOMISATIONS
	private string function _defaultTab( event, rc, prc, args={} ) {
		args.editMetaLink = event.buildAdminLink( objectName="saml2_sp", recordId=args.recordId, operation="editRecord", queryString="editDetail=meta" );
		args.editCertLink = event.buildAdminLink( objectName="saml2_sp", recordId=args.recordId, operation="editRecord", queryString="editDetail=idpcert" );

		args.renderedSpProps  = [];
		args.renderedIdpProps = [];
		args.renderedAccessProps = [];

		var spProps = [ "entity_id", "requests_will_be_signed", "want_assertions_signed", "assertion_consumer_location", "assertion_consumer_binding", "signing_certificate" ];
		if ( isFeatureEnabled( "samlSsoProviderSlo" ) && Len( args.record.single_logout_location ) ) {
			ArrayAppend( spProps, [ "single_logout_location", "single_logout_binding" ], true );
		}
		for( var prop in  spProps ) {
			var renderedValue = adminDataViewsService.renderField(
				  objectName   = "saml2_sp"
				, propertyName = prop
				, recordId     = args.recordId
				, value        = args.record[ prop ] ?: ""
			);

			ArrayAppend( args.renderedSpProps, {
				  propertyTitle = translatePropertyName( "saml2_sp", prop )
				, rendered      = Len( Trim( renderedValue ) ) ? renderedValue : translateResource( uri="cms:preside-objects.default.field.no_value.title", defaultValue="" )
			} );
		}

		var idpProps = [ "metadata_url", "idp_entity_id", "idp_sso_location", "public_cert", "id_attribute", "id_attribute_format", "use_attributes" ];
		for( var prop in  idpProps ) {
			var renderedValue = adminDataViewsService.renderField(
				  objectName   = "saml2_sp"
				, propertyName = prop
				, recordId     = args.recordId
				, value        = args.record[ prop ] ?: ""
			);

			ArrayAppend( args.renderedIdpProps, {
				  propertyTitle = translatePropertyName( "saml2_sp", prop )
				, rendered      = Len( Trim( renderedValue ) ) ? renderedValue : translateResource( uri="cms:preside-objects.default.field.no_value.title", defaultValue="" )
			} );
		}

		return renderView( view="/admin/datamanager/saml2_sp/_defaultTab", args=args );
	}

	private string function _infoCardSsoType( event, rc, prc, args={} ) {
		if ( args.record.sso_type == "idp" ) {
			var loginLink = event.buildLink( saml2SpSlug=args.record.slug );
			loginLink = '<a href="#loginLink#" target="_blank"><i class="fa fa-fw fa-external-link"></i> #loginLink#</a>';

			return translateResource( uri="preside-objects.saml2_sp:infocol.login.link" , data=[ loginLink ] );;
		}

		return "";
	}

	private string function _infoCardAccessCondition( event, rc, prc, args={} ) {
		var restriction = "";

		if ( Len( args.record.access_condition ) ) {
			restriction = adminDataViewsService.renderField( "saml2_sp", "access_condition", args.recordId, args.record.access_condition );
		} else {
			restriction = translateResource( "preside-objects.saml2_sp:infocol.access.filter.none" )
		}

		return translateResource( uri="preside-objects.saml2_sp:infocol.access.filter" , data=[ restriction ] );
	}
}