component extends="testbox.system.BaseSpec" {

	function run() {
		describe( "getNameIdFormat", function() {
			it( "should return the full URI for the explicitly set format against a service provider", function(){
				var svc                = _getService();
				var fullUri            = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress";
				var stubConsumerRecord = {
					  id_attribute_format       = "email"
					, id_attribute_is_transient = 0
				};

				svc.$( "$translateResource" ).$args( uri="", defaultValue="enum.samlNameIdFormat:email.uri" ).$results( fullUri );
				svc.$( "$translateResource", "notfound" );

				expect( svc.getNameIdFormat( stubConsumerRecord ) ).toBe( fullUri );
			} );

			it( "should use email URI when the name id field is email and the saved format is 'auto'", function(){
				var svc                = _getService();
				var fullUri            = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress";
				var stubConsumerRecord = {
					  id_attribute_format       = "auto"
					, id_attribute_is_transient = 0
					, id_attribute              = "email"
				};

				svc.$( "$translateResource" ).$args( uri="", defaultValue="enum.samlNameIdFormat:email.uri" ).$results( fullUri );
				svc.$( "$translateResource", "notfound" );

				expect( svc.getNameIdFormat( stubConsumerRecord ) ).toBe( fullUri );
			} );

			it( "should use persistent URI when the name id field is id and the saved format is 'auto'", function(){
				var svc                = _getService();
				var fullUri            = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent";
				var stubConsumerRecord = {
					  id_attribute_format       = "auto"
					, id_attribute_is_transient = 0
					, id_attribute              = "id"
				};

				svc.$( "$translateResource" ).$args( uri="", defaultValue="enum.samlNameIdFormat:persistent.uri" ).$results( fullUri );
				svc.$( "$translateResource", "notfound" );

				expect( svc.getNameIdFormat( stubConsumerRecord ) ).toBe( fullUri );
			} );

			it( "should use unspecified URI when the name id field is not configured and the saved format is 'auto'", function(){
				var svc                = _getService();
				var fullUri            = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified";
				var stubConsumerRecord = {
					  id_attribute_format = "auto"
					, id_attribute        = "nonexistentidattrib"
				};

				svc.$( "$translateResource" ).$args( uri="", defaultValue="enum.samlNameIdFormat:unspecified.uri" ).$results( fullUri );
				svc.$( "$translateResource", "notfound" );

				expect( svc.getNameIdFormat( stubConsumerRecord ) ).toBe( fullUri );
			} );

			it( "should use transient URI when there is no saved format and when the legacy is_transient field is set to true", function(){
				var svc                = _getService();
				var fullUri            = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient";
				var stubConsumerRecord = {
					  id_attribute_format = ""
					, id_attribute_is_transient = 1
					, id_attribute = "id"
				};

				svc.$( "$translateResource" ).$args( uri="", defaultValue="enum.samlNameIdFormat:transient.uri" ).$results( fullUri );
				svc.$( "$translateResource", "notfound" );

				expect( svc.getNameIdFormat( stubConsumerRecord ) ).toBe( fullUri );
			} );
		} );
	}

	private any function _getService( struct supportedAttributes=_defaultSupportedAttibutes(), attributeRetrievalHandler="test.attrib.retrieval.handler" ) {
		var svc = CreateObject( "app.extensions.preside-ext-saml2-sso.services.SamlAttributesService" ).init( argumentCollection=arguments );

		svc = CreateMock( object=svc );

		return svc;
	}

	private struct function _defaultSupportedAttibutes() {
		return {
			  id          = { friendlyName="UserID"                                                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="persistent" }
			, email       = { friendlyName="Email"      , samlUrn="urn:oid:0.9.2342.19200300.100.1.3", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="email" }
			, displayName = { friendlyName="DisplayName", samlUrn="urn:oid:2.16.840.1.113730.3.1.241", samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
			, firstName   = { friendlyName="FirstName"  , samlUrn="urn:oid:2.5.4.42"                 , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
			, lastName    = { friendlyName="LastName"   , samlUrn="urn:oid:2.5.4.4"                  , samlNameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri", nameIdFormat="unspecified" }
		};
	}
}