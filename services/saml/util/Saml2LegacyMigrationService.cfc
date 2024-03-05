/**
 * @singleton true
 * @presideservice true
 */
component {

	property name="sqlRunner"              inject="sqlRunner";
	property name="samlKeyStore"           inject="samlKeyStore";
	property name="samlCertificateService" inject="samlCertificateService";
	property name="idpService"             inject="samlIdentityProviderService";

	function init() {
		return this;
	}

	function migrate() {
		var keyPair = _getLegacyDefaultKeyPair();

		_migrateLegacyServiceProviders( keyPair );
		_migrateLegacyIdProviders( keyPair );
	}

// PRIVATE HELPERS
	private struct function _getLegacyDefaultKeyPair() {
		var kp = {};
		try {
			kp = {
				  public  = samlKeyStore.getCert()
				, private = samlKeyStore.getPrivateKey()
			};
		} catch( any e ) {
			$raiseError( e );
		}

		if ( !Len( Trim( kp.public ?: "" ) ) || !Len( Trim( kp.private ?: "" ) ) ) {
			kp = samlCertificateService.generateKeyPair();
		}

		return kp;
	}

	private function _migrateLegacyServiceProviders( keyPair ) {
		var legacySps = "";
		var dao       = $getPresideObject( "saml2_sp" );

		try {
			legacySps = sqlRunner.runSql(
				  sql = "select * from pobj_saml2_consumer"
				, dsn = dao.getDsn()
			);
		} catch( database e ) {
			$raiseError( e )
			return "";
		}

		for( var sp in legacySps ) {
			var newSp = _craftNewSpRecord( sp, keyPair );
			if ( dao.dataExists( filter={ slug=newSp.slug } ) ) {
				dao.updateData( filter={ slug=newSp.slug }, data=newSp );
			} else {
				dao.insertData( newSp );
			}
		}
	}

	private function _migrateLegacyIdProviders( keyPair ) {
		var legacyIdps = "";
		var dao       = $getPresideObject( "saml2_idp" );

		try {
			legacyIdps = sqlRunner.runSql(
				  sql = "select idp.id, idp.slug, idp.metadata, idp.enabled, c.private_key, c.public_cert from pobj_saml2_identity_provider idp left join pobj_saml2_certificate c on c.id = idp.certificate"
				, dsn = dao.getDsn()
			);
		} catch( database e ) {
			try {
				legacyIdps = sqlRunner.runSql(
					  sql = "select id,slug,metadata,enabled from pobj_saml2_identity_provider"
					, dsn = dao.getDsn()
				);
			} catch( database e ) {
				$raiseError( e )
				return "";
			}
		}

		for( var idp in legacyIdps ) {
			var newIdp = _craftNewIdpRecord( idp, keyPair );
			if ( StructCount( newIdp ) ) {
				if ( dao.dataExists( filter={ slug=newIdp.slug } ) ) {
					dao.updateData( filter={ slug=newIdp.slug }, data=newIdp );
				} else {
					dao.insertData( newIdp );
				}
			}
		}
	}

	private function _craftNewSpRecord( oldSp, keyPair ) {
		var meta  = _readMeta( arguments.oldSp.metadata ?: "" );
		var newSp = {
			  id                        = arguments.oldSp.id                        ?: ""
			, name                      = arguments.oldSp.name                      ?: ""
			, slug                      = arguments.oldSp.slug                      ?: ""
			, sso_type                  = arguments.oldSp.sso_type                  ?: ""
			, login_message             = arguments.oldSp.login_message             ?: ""
			, access_condition          = arguments.oldSp.access_condition          ?: ""
			, access_denied_message     = arguments.oldSp.access_denied_message     ?: ""
			, id_attribute              = arguments.oldSp.id_attribute              ?: ""
			, id_attribute_format       = arguments.oldSp.id_attribute_format       ?: ""
			, use_attributes            = arguments.oldSp.use_attributes            ?: ""
			, id_attribute_is_transient = arguments.oldSp.id_attribute_is_transient ?: ""
			, public_cert               = arguments.keyPair.public
			, private_key               = arguments.keyPair.private
		};

		newSp.entity_id                   = meta.id ?: "";
		newSp.signing_certificate         = meta.serviceProviderSsoRequirements.x509Certificate ?: "";
		newSp.requests_will_be_signed     = $helpers.isTrue( meta.serviceProviderSsoRequirements.requestsWillBeSigned ?: "" );
		newSp.want_assertions_signed      = $helpers.isTrue( meta.serviceProviderSsoRequirements.wantAssertionsSigned ?: "" );
		newSp.assertion_consumer_location = meta.serviceProviderSsoRequirements.defaultAssertionConsumer.location ?: "";
		newSp.assertion_consumer_binding  = ListLast( meta.serviceProviderSsoRequirements.defaultAssertionConsumer.binding ?: "", ":" );

		if ( $isFeatureEnabled( "samlSsoProviderSlo" ) ) {
			newSp.single_logout_location = meta.serviceProviderSsoRequirements.logoutService.location ?: "";
			newSp.single_logout_binding  = ListLast( meta.serviceProviderSsoRequirements.logoutService.binding ?: "" );
		}

		return newSp;
	}

	private function _craftNewIdpRecord( oldIdp, keyPair ) {
		var configuredIdp = idpService.getProvider( arguments.oldIdp.slug ?: "" );
		if ( StructIsEmpty( configuredIdp ) ) {
			return {};
		}

		var meta  = _readMeta( arguments.oldIdp.metadata ?: "" );
		var newIdp = {
			  id      = arguments.oldIdp.id      ?: ""
			, slug    = arguments.oldIdp.slug    ?: ""
			, enabled = arguments.oldIdp.enabled ?: ""
		};

		newIdp.name                = configuredIdp.title  ?: ""
		newIdp.entity_id           = meta.id              ?: "";
		newIdp.sso_location        = meta.idpSsoLocation  ?: "";
		newIdp.name_id_format      = meta.idpNameIdFormat ?: "";
		newIdp.signing_certificate = meta.x509Certificate ?: "";

		return newIdp;

	}

	private function _readMeta( metadata ) {
		try {
			return new "app.extensions.preside-ext-saml2-sso.services.saml.metadata.SamlMetadata"( arguments.metadata ).getMemento();
		} catch( any e ) {
			$raiseError( e );
		}

		return {};
	}
}