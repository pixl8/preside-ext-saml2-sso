component extends="AbstractSamlObject" {

// PUBLIC API METHODS
	public struct function getMemento() {
		return {
			  id                             = getEntityId()
			, serviceProviderSsoRequirements = getServiceProviderSSORequirements()
			, x509Certificate                = getX509Certificate()
			, idpNameIdFormat                = getIdpNameIdFormat()
			, idpSsoLocation                 = getIdpSsoLocation()
		};
	}

	public string function getEntityId() {
		var rootEl = getRootNode();

		return rootEl.xmlAttributes.entityId ?: "";
	}

	public struct function getServiceProviderSSORequirements() {
		// NOTE, this is far too brutal an approach to be globally useful.
		// TODO: create an SSOReqs. object for this that exposes methods for getting
		// at its data, etc.

		var spSSONode = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor" );

		if ( !spSSONode.len() ) {
			return {};
		}

		spSSONode = spSSONode[ 1 ];

		var reqs = {};

		reqs.requestsWillBeSigned = spSSONode.xmlAttributes.authnRequestsSigned ?: false;
		reqs.wantAssertionsSigned = spSSONode.xmlAttributes.wantAssertionsSigned ?: true;
		reqs.nameIdFormats        = [];

		var formats = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor/NameIDFormat" );
		for( var format in formats ) {
			reqs.nameIdFormats.append( format.xmlText );
		}

		var assertionConsumer = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor/AssertionConsumerService" );
		if ( assertionConsumer.len() ) {
			reqs.defaultAssertionConsumer = {
				  index    = assertionConsumer[1].xmlAttributes.index    ?: 0
				, binding  = assertionConsumer[1].xmlAttributes.binding  ?: ""
				, location = assertionConsumer[1].xmlAttributes.location ?: ""
			}
		}

		var logoutService = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor/SingleLogoutService" );
		if ( logoutService.len() ) {
			reqs.logoutService = {
				  binding  = logoutService[1].xmlAttributes.binding  ?: ""
				, location = logoutService[1].xmlAttributes.location ?: ""
			}
		}

		reqs.requestAttributes = [];
		var attributes = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor/AttributeConsumingService[@isDefault='true']/RequestedAttribute" );
		for( var attrib in attributes ) {
			reqs.requestAttributes.append( {
				  friendlyName = attrib.xmlAttributes.friendlyName ?: ""
				, name         = attrib.xmlAttributes.name         ?: ""
				, NameFormat   = attrib.xmlAttributes.NameFormat   ?: ""
				, required     = IsBoolean( attrib.xmlAttributes.required ?: "" ) && attrib.xmlAttributes.required
			} );
		}

		// absurdly brutal:
		var keyDescriptors = XmlSearch( _getXmlObject(), "/EntityDescriptor/SPSSODescriptor/KeyDescriptor" );
		reqs.x509Certificate = Trim( keyDescriptors[1][ "KeyInfo" ][ "X509Data" ][ "X509Certificate" ].xmlText ?: "" );

		return reqs;
	}

	public string function getIdpNameIdFormat() {
		var rootEl = getRootNode();

		return rootEl[ "IDPSSODescriptor"][ "NameIDFormat" ].xmlText ?: "";
	}

	public string function getIdpSsoLocation() {
		var rootEl = getRootNode();

		return rootEl[ "IDPSSODescriptor"][ "SingleSignOnService" ].xmlAttributes.location ?: "";
	}

	public string function getX509Certificate() {
		var rootEl = getRootNode();

		return rootEl[ "IDPSSODescriptor" ][ "KeyDescriptor" ][ "KeyInfo" ][ "X509Data" ][ "X509Certificate" ].xmlText ?: "";
	}
}