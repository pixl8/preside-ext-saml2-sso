component extends="samlIdProvider.util.AbstractSamlObject" {

// PUBLIC API METHODS
	public struct function getMemento() {
		return {
			  id                             = getEntityId()
			, serviceProviderSsoRequirements = getServiceProviderSSORequirements()
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

		var spSSONode = XmlSearch( _getXmlObject(), "/md:EntityDescriptor/md:SPSSODescriptor" );

		if ( !spSSONode.len() ) {
			return {};
		}

		var reqs = {};

		reqs.requestsWillBeSigned = spSSONode.xmlAttributes.authnRequestsSigned ?: false;
		reqs.wantAssertionsSigned = spSSONode.xmlAttributes.wantAssertionsSigned ?: true;
		reqs.nameIdFormats        = [];

		var formats = XmlSearch( _getXmlObject(), "/md:EntityDescriptor/md:SPSSODescriptor/md:NameIDFormat" );
		for( var format in formats ) {
			reqs.nameIdFormats.append( format.xmlText );
		}

		var assertionConsumer = XmlSearch( _getXmlObject(), "/md:EntityDescriptor/md:SPSSODescriptor/md:AssertionConsumerService[@isDefault='true']" );
		if ( assertionConsumer.len() ) {
			reqs.defaultAssertionConsumer = {
				  index    = assertionConsumer[1].xmlAttributes.index    ?: 0
				, binding  = assertionConsumer[1].xmlAttributes.binding  ?: ""
				, location = assertionConsumer[1].xmlAttributes.location ?: ""
			}
		}

		reqs.requestAttributes = [];
		var attributes = XmlSearch( _getXmlObject(), "/md:EntityDescriptor/md:SPSSODescriptor/md:AttributeConsumingService[@isDefault='true']/md:RequestedAttribute" );
		for( var attrib in attributes ) {
			reqs.requestAttributes.append( {
				  friendlyName = attrib.xmlAttributes.friendlyName ?: ""
				, name         = attrib.xmlAttributes.name         ?: ""
				, NameFormat   = attrib.xmlAttributes.NameFormat   ?: ""
				, required     = IsBoolean( attrib.xmlAttributes.required ?: "" ) && attrib.xmlAttributes.required
			} );
		}

		// absurdly brutal:
		var keyDescriptors = XmlSearch( _getXmlObject(), "/md:EntityDescriptor/md:SPSSODescriptor/md:KeyDescriptor" );
		reqs.x509Certificate = Trim( keyDescriptors[1][ "ds:KeyInfo" ][ "ds:X509Data" ][ "ds:X509Certificate" ].xmlText ?: "" );

		return reqs;
	}

}