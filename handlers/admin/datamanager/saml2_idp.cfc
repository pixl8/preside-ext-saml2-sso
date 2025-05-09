component extends="Saml2DataManagerBase" {

	property name="samlCertificateService"        inject="samlCertificateService";
	property name="samlProviderMetadataGenerator" inject="samlProviderMetadataGenerator";

	variables.permissionBase = "saml2.provider";

	variables.infoCol1 = [ "loginLink" ];
	variables.infoCol3 = [ "status" ];


// PUBLIC ACTIONS
	public function deactivateAction( event, rc, prc ) {
		event.initializeDatamanagerPage( "saml2_idp", rc.id ?: "" );
		if ( !Len( prc.recordId ) || !prc.record.recordCount ) {
			event.notFound();
		}
		if ( !prc.canEdit ) {
			event.adminAccessDenied();
		}

		getPresideObject( "saml2_idp" ).updateData( id=prc.recordId, data={ enabled=false } );

		setNextEvent( url=event.buildAdminLink( objectName="saml2_idp", operation="viewRecord", recordId=prc.recordId ) );
	}

	public function activateAction( event, rc, prc ) {
		event.initializeDatamanagerPage( "saml2_idp", rc.id ?: "" );
		if ( !Len( prc.recordId ) || !prc.record.recordCount ) {
			event.notFound();
		}
		if ( !prc.canEdit ) {
			event.adminAccessDenied();
		}

		getPresideObject( "saml2_idp" ).updateData( id=prc.recordId, data={ enabled=true } );

		setNextEvent( url=event.buildAdminLink( objectName="saml2_idp", operation="viewRecord", recordId=prc.recordId ) );
	}

// GENERAL DATAMANAGER CUSTOMISATIONS
	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		// a little hacky, but we can use this to modify how the data table gets rendered
		args.allowFilter = false;
		args.allowSearch = false;


		return "";
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
						StructAppend( args.formData, super._extractIdpDetailsFromMetadata( args, sourceField, metadata ) );
						if ( args.validationResult.validated() ) {
							args.formData.enabled = true;
						}
					}
				}
			break;
			case "spcert":
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
		var qs = "object=saml2_idp&id=#args.recordId#";

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

	private array function getTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		if ( isTrue( args.record.enabled ) ) {
			return [{
				  link      = event.buildAdminLink( linkto="datamanager.saml2_idp.deactivateAction", querystring="id=#args.record.id#" )
				, btnClass  = "btn-danger"
				, iconClass = "fa-ban"
				, title     = translateResource( "preside-objects.saml2_idp:deactivate.btn" )
				, prompt    = translateResource( "preside-objects.saml2_idp:deactivate.btn.prompt" )
				, match     = args.record.name
			}];

		} else if ( Len( Trim( args.record.entity_id ) ) && Len( Trim( args.record.sso_location ) ) ) {
			return [{
				  link      = event.buildAdminLink( linkto="datamanager.saml2_idp.activateAction", querystring="id=#args.record.id#" )
				, btnClass  = "btn-primary"
				, iconClass = "fa-check"
				, title     = translateResource( "preside-objects.saml2_idp:activate.btn" )
				, prompt    = translateResource( "preside-objects.saml2_idp:activate.btn.prompt" )
			}];
		}

		return [];
	}

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		return [{
			  link       = event.buildAdminLink( objectName="saml2_idp", recordId=args.record.id )
			, icon       = "fa-eye"
			, contextKey = "v"
		}];
	}

	private string function getEditRecordFormName( event, rc, prc, args={} ) {
		switch( rc.editDetail ?: "" ) {
			case "meta":
				prc.pageSubTitle = translateResource( "preside-objects.saml2_idp:reupload.meta.subtitle" );
				return "preside-objects.saml2_idp.admin.edit.meta";
			break;
			case "spcert":
				prc.pageSubTitle = translateResource( "preside-objects.saml2_idp:replace.spcert.subtitle" );
				event.include( "/js/admin/specific/saml2editcertificate/" );
				return "preside-objects.saml2_idp.admin.edit.spcert";
			break;
		}

		return "preside-objects.saml2_idp.admin.edit";
	}


// VIEW RECORD CUSTOMISATIONS
	private string function _defaultTab( event, rc, prc, args={} ) {
		args.renderedSpProps  = [];
		args.renderedIdpProps = [];

		var metaSettings = samlProviderMetadataGenerator.getIdpSpMetadataSettings( args.record.slug );

		for( var prop in [ "sp_meta_url", "sp_entity_id", "requests_will_be_signed", "want_assertions_signed", "sp_consumer_location", "public_cert" ] ) {
			var renderedValue = "";

			switch( prop ) {
				case "sp_meta_url":
					var link = event.buildLink( linkto="saml2.spmeta", queryString="idp=#args.recordId#" );
					renderedValue = '<a href="#link#" target="_blank"><i class="fa fa-fw fa-external-link"></i> #abbreviate( link, 50 )#</a>';
				break;
				case "sp_entity_id":
					renderedValue = '<code>' & metaSettings.entityId & '</code>';
				break;
				case "requests_will_be_signed":
					renderedValue = renderContent( "boolean", true, "admin" );
				break;
				case "want_assertions_signed":
					renderedValue = renderContent( "boolean", true, "admin" );
				break;
				case "sp_consumer_location":
					renderedValue = '<code>' & metaSettings.assertionConsumerLocation & '</code>';
				break;
				default:
					renderedValue = adminDataViewsService.renderField(
						  objectName   = "saml2_idp"
						, propertyName = prop
						, recordId     = args.recordId
						, value        = args.record[ prop ] ?: ""
					);
			}

			ArrayAppend( args.renderedSpProps, {
				  propertyTitle = translatePropertyName( "saml2_idp", prop )
				, rendered      = Len( Trim( renderedValue ) ) ? renderedValue : translateResource( uri="cms:preside-objects.default.field.no_value.title", defaultValue="" )
			} );
		}

		if ( isTrue( args.record.enabled ?: "" ) ) {
			for( var prop in [ "entity_id", "sso_location", "name_id_format", "signing_certificate" ] ) {
				var renderedValue = adminDataViewsService.renderField(
					  objectName   = "saml2_idp"
					, propertyName = prop
					, recordId     = args.recordId
					, value        = args.record[ prop ] ?: ""
				);

				ArrayAppend( args.renderedIdpProps, {
					  propertyTitle = translatePropertyName( "saml2_idp", prop )
					, rendered      = Len( Trim( renderedValue ) ) ? renderedValue : translateResource( uri="cms:preside-objects.default.field.no_value.title", defaultValue="" )
				} );
			}
		}

		args.editMetaLink = event.buildAdminLink( objectName="saml2_idp", recordId=prc.recordId, operation="editRecord", queryString="editDetail=meta" );
		args.editCertLink = event.buildAdminLink( objectName="saml2_idp", recordId=prc.recordId, operation="editRecord", queryString="editDetail=spcert" );
		args.editLink     = event.buildAdminLink( objectName="saml2_idp", recordId=prc.recordId, operation="editRecord" );

		return renderView( view="/admin/datamanager/saml2_idp/_defaultTab", args=args );
	}

	private string function _infoCardStatus( event, rc, prc, args={} ) {
		var enabled           = isTrue( args.record.enabled ?: "" );
		var booleanBadgeStyle = enabled ? "success" : "danger";
		var booleanBadgeValue = translateResource( "preside-objects.saml2_idp:#( enabled ? 'enabled' : 'disabled' )#.badge");

		return  '<span class="badge badge-pill badge-#booleanBadgeStyle#">#booleanBadgeValue#</span>';
	}

	private string function _infoCardLoginLink( event, rc, prc, args={} ) {
		if ( isFalse( args.record.enabled ) ) {
			return "";
		}

		var link = event.buildLink( saml2IdpProvider=args.record.slug );

		return translateResource(
			  uri  = "preside-objects.saml2_idp:infocard.login.link"
			, data = [ '<a href="#link#" target="_blank"><i class="fa fa-fw fa-external-link"></i> #link#</a>' ]
		);
	}

}