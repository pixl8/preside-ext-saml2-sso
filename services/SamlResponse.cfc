component extends="AbstractSamlObject" {

	public struct function getMemento() {
		var memento = {
			  id                = getId()
			, type              = getType()
			, issuer            = getIssuer()
			, issueInstant      = getIssueInstant()
			, nameId            = getNameId()
			, attributes        = getAttributes()
			, notBefore         = getNotBefore()
			, notAfter          = getNotAfter()
			, assertionIsSigned = getAssertionIsSigned()
		};

		if ( memento.type == "authnRequest" ) {
			memento.append({
				  forceAuthentication = mustForceAuthentication()
				, nameIdPolicy        = getNameIdPolicy()
			});
		}

		return memento;
	}

// GENERIC REQUEST METHODS
	public string function getId() {
		var rootEl = getRootNode();

		return rootEl.xmlAttributes.ID ?: "";
	}

	public string function getIssuer() {
		var rootEl = getRootNode();

		return Trim( rootEl[ "saml2:Issuer" ].xmlText ?: ( rootEl[ "saml:Issuer" ].xmlText ?: "" ) );
	}

	public date function getIssueInstant() {
		var rootEl = getRootNode();

		return readDate( rootEl.xmlAttributes.IssueInstant ?: "" );
	}

	public string function getType() {
		var rootEl = getRootNode();
		return ListLast( rootEl.xmlName, ":" );
	}

	public string function getNameId() {
		var rootEl = getRootNode();
        return rootEl[ "saml2:Assertion" ][ "saml2:Subject" ][ "saml2:NameID" ].xmlText ?: ( rootEl[ "saml:Assertion" ][ "saml:Subject" ][ "saml:NameID" ].xmlText ?: "" );
	}

	public date function getNotBefore() {
		var rootEl = getRootNode();
		var notBefore = rootEl[ "saml2:Assertion" ][ "saml2:Conditions" ].xmlAttributes[ "NotBefore" ] ?: ( rootEl[ "saml:Assertion" ][ "saml:Conditions" ].xmlAttributes[ "NotBefore" ] ?: "" );

		if ( IsDate( notBefore ) ) {
			return ReReplace( notBefore, "Z$", "" );
		}

		notBefore = DateConvert( "local2utc", Now() );

		return DateFormat( notBefore, "yyyy-mm-dd" ) & "T" & TimeFormat( notBefore, "HH:mm:ss.l" );
	}

	public date function getNotAfter() {
		var rootEl   = getRootNode();
		var notAfter = rootEl[ "saml2:Assertion" ][ "saml2:Conditions" ].xmlAttributes[ "NotOnOrAfter" ] ?: ( rootEl[ "saml:Assertion" ][ "saml:Conditions" ].xmlAttributes[ "NotOnOrAfter" ] ?: "" );

		if ( IsDate( notAfter ) ) {
			return ReReplace( notAfter, "Z$", "" );
		}

		notAfter = DateConvert( "local2utc", DateAdd( "n", 20, Now() ) );

		return DateFormat( notAfter, "yyyy-mm-dd" ) & "T" & TimeFormat( notAfter, "HH:mm:ss.l" );
	}

	public struct function getAttributes() {
		var attribs = {};
		var rootEl = getRootNode();
		var attribEls = rootEl[ "saml2:Assertion" ][ "saml2:AttributeStatement" ].xmlChildren ?: ( rootEl[ "saml:Assertion" ][ "saml:AttributeStatement" ].xmlChildren ?: [] );

		for( var attribEl in attribEls ) {
			if ( attribEl.xmlName == "saml2:Attribute" ) {
				var name = attribEl.xmlAttributes.name ?: "";

				if ( name.len() ) {
					attribs[ name ] = attribEl[ "saml2:AttributeValue" ].xmlText;
				}
			} else if ( attribEl.xmlName == "saml:Attribute" ) {
				var name = attribEl.xmlAttributes.name ?: "";

				if ( name.len() ) {
					attribs[ name ] = attribEl[ "saml:AttributeValue" ].xmlText;
				}
			}

		}

		return attribs;
	}

	public boolean function getAssertionIsSigned() {
		var rootEl = getRootNode();

		return Len( rootEl[ "saml2:Assertion" ][ "ds:Signature" ][ "ds:SignatureValue" ].xmlText ?: ( rootEl[ "saml:Assertion" ][ "ds:Signature" ][ "ds:SignatureValue" ].xmlText ?: "" ) ) > 0;
	}

// AUTHENTICATION REQUEST METHODS
	public boolean function mustForceAuthentication() {
		var rootEl = getRootNode();

		return IsBoolean( rootEl.xmlAttributes.ForceAuthn ?: "" ) && rootEl.xmlAttributes.ForceAuthn;
	}

	public struct function getNameIdPolicy() {
		var rootEl = getRootNode();
		var policyNode = rootEl[ "samlp:NameIDPolicy" ] ?: NullValue();

		if ( !IsNull( policyNode ) ) {
			return {
				  format          = policyNode.xmlAttributes.format ?: ""
				, spNameQualifier = policyNode.xmlAttributes.spNameQualifier ?: ""
				, allowCreate     = IsBoolean( policyNode.xmlAttributes.allowCreate ?: "" ) && policyNode.xmlAttributes.allowCreate
			};
		}

		return {};
	}
}
