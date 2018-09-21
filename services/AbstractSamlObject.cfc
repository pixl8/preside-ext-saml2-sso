component {

// CONSTRUCTOR
	public any function init( required string xml ) {
		_setXmlObject( XmlParse( _stripNameSpaces( arguments.xml ) ) );

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
		var dateMinusOptionalMilliseconds = ReReplace( arguments.theDate, "\.[0-9]+Z$", "Z" );

		return formatter.parse( dateMinusOptionalMilliseconds );
	}

// PRIVATE HELPERS
	private string function _stripNameSpaces( required string sourceXml ) {
		var namespaces = _getNamespaces( arguments.sourceXml );
		var strippedXml = arguments.sourceXml;

		for( var namespace in namespaces ) {
			strippedXml = replaceNoCase( strippedXml, "<#namespace#:", "<", "all" );
			strippedXml = replaceNoCase( strippedXml, "</#namespace#:", "</", "all" );
			strippedXml = replaceNoCase( strippedXml, "xmlns:#namespace#=", "xmlns=", "all" );
		}

		return strippedXml;
	}

	private array function _getNamespaces( required string sourceXml ) {
		var match      = "";
		var pos        = 0;
		var matched    = false;
		var namespaces = [];

		do {
			match = ReFind( "xmlns:([a-zA-Z0-9]+)=", arguments.sourceXml, pos, true );
			matched = IsArray( match.match ?: "" ) && match.match.len() == 2;
			if( matched ) {
				pos = match.pos[ 1 ] + match.len[ 1 ];
				namespaces.append( Mid( arguments.sourceXml, match.pos[ 2 ], match.len[ 2 ] ) );
			}
		} while ( matched );

		return namespaces;
	}



// GETTERS AND SETTERS
	private xml function _getXmlObject() {
		return _xmlObject;
	}
	private void function _setXmlObject( required xml xmlObject ) {
		_xmlObject = arguments.xmlObject;
	}

}
