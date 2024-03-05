component {

	variables.prettyPrintXslt = '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>';

	public string function default( event, rc, prc, args={} ){
		var src = args.data ?: "";

		if ( isXml( src ) ) {
			return '<pre><code>#XmlFormat( XmlTransform( src, prettyPrintXslt ) )#</code></pre>'
		}

		return "";
	}

}