component {

// CONSTRUCTOR
	public any function init( required string xml ) {
		_setXmlObject( XmlParse( arguments.xml ) );

		return this;
	}

// PUBLIC API METHODS
	public xml function getXmlObject() {
		return _getXmlObject();
	}

	public xml function getRootNode() {
		return _getXmlObject().xmlRoot;
	}

	public date function readDate( required string thedate ) {
		var formatter = CreateObject( "java", "java.text.SimpleDateFormat" ).init( "yyyy-MM-dd'T'HH:mm:ss'Z'" );
		var dateMinusOptionalMilliseconds = ReReplace( arguments.theDate, "\.[0-9]{3}Z$", "Z" );

		return formatter.parse( dateMinusOptionalMilliseconds );
	}

// GETTERS AND SETTERS
	private xml function _getXmlObject() {
		return _xmlObject;
	}
	private void function _setXmlObject( required xml xmlObject ) {
		_xmlObject = arguments.xmlObject;
	}

}