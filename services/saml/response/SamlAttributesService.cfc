/**
 * @singleton      true
 * @presideService true
 */
component {

// CONSTRUCTOR
	/**
	 * @supportedAttributes.inject coldbox:setting:saml2.attributes.supported
	 * @attributeRetrievalHandler.inject coldbox:setting:saml2.attributes.retrievalHandler
	 *
	 */
	public any function init( required struct supportedAttributes, required string attributeRetrievalHandler ) {
		_setSupportedAttributes( arguments.supportedAttributes );
		_setAttributeRetrievalHandler( arguments.attributeRetrievalHandler );

		return this;
	}

// PUBLIC API METHODS
	public struct function getSupportedAttributes() {
		return _getSupportedAttributes();
	}

	public struct function getAttributeValues() {
		return $getColdbox().runEvent(
			  event          = _getAttributeRetrievalHandler()
			, eventArguments = { supportedAttributes=_getSupportedAttributes() }
			, private        = true
			, prepostExempt  = true
		);
	}

	public string function getNameIdFormat( required struct consumerRecord ) {
		var explicitFormat = consumerRecord.id_attribute_format ?: "";

		if ( !Len( explicitFormat ) ) {
			if ( IsBoolean( consumerRecord.id_attribute_is_transient ?: "" ) && consumerRecord.id_attribute_is_transient ) {
				explicitFormat = "transient";
			} else {
				explicitFormat = "auto";
			}
		}

		if ( explicitFormat == "auto" ) {
			var attribConfig = _getSupportedAttributes();
			var idField = consumerRecord.id_attribute ?: "";
			if ( !Len( idField ) ) {
				idField = "id";
			}
			explicitFormat = attribConfig[ idField ].nameIdFormat ?: "unspecified";
		}

		return $translateResource( uri="enum.samlNameIdFormat:#explicitFormat#.uri", defaultValue="" );
	}

// GETTERS AND SETTERS
	private struct function _getSupportedAttributes() {
		return _supportedAttributes;
	}
	private void function _setSupportedAttributes( required struct supportedAttributes ) {
		_supportedAttributes = arguments.supportedAttributes;
	}

	private string function _getAttributeRetrievalHandler() {
		return _attributeRetrievalHandler;
	}
	private void function _setAttributeRetrievalHandler( required string attributeRetrievalHandler ) {
		_attributeRetrievalHandler = arguments.attributeRetrievalHandler;
	}
}