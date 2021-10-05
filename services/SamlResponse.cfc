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
			, audience          = getAudience()
			, assertionIsSigned = getAssertionIsSigned()
			, inResponseTo      = getInResponseTo()
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

		return Trim( rootEl.Issuer.xmlText ?: "" );
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
        return rootEl.Assertion.Subject.NameID.xmlText ?: "";
	}

	public date function getNotBefore() {
		var rootEl = getRootNode();
		var notBefore = rootEl.Assertion.Conditions.xmlAttributes[ "NotBefore" ] ?: "";

		if ( IsDate( notBefore ) ) {
			return ReReplace( notBefore, "Z$", "" );
		}

		notBefore = DateConvert( "local2utc", Now() );

		return DateFormat( notBefore, "yyyy-mm-dd" ) & "T" & TimeFormat( notBefore, "HH:mm:ss.l" );
	}

	public date function getNotAfter() {
		var rootEl   = getRootNode();
		var notAfter = rootEl.Assertion.Conditions.xmlAttributes[ "NotOnOrAfter" ] ?: "";

		if ( IsDate( notAfter ) ) {
			return ReReplace( notAfter, "Z$", "" );
		}

		notAfter = DateConvert( "local2utc", DateAdd( "n", 20, Now() ) );

		return DateFormat( notAfter, "yyyy-mm-dd" ) & "T" & TimeFormat( notAfter, "HH:mm:ss.l" );
	}

	public string function getAudience() {
		var rootEl = getRootNode();

		return rootEl.Assertion.Conditions.AudienceRestriction.Audience.xmlText ?: "";
	}

	public struct function getAttributes() {
		var attribs = {};
		var rootEl = getRootNode();
		var attribEls = rootEl.Assertion.AttributeStatement.xmlChildren ?: [];

		for ( var attribEl in attribEls ) {
			var name = attribEl.xmlAttributes.friendlyName ?: ( attribEl.xmlAttributes.name ?: "" );

			if ( name.len() ) {
				var values = [];
				for ( var attribVal in attribEl.xmlChildren ?: [] ) {
					ArrayAppend( values, attribVal.xmlText ?: "" );
				}

				if ( ArrayLen( values ) == 1 ) {
					attribs[ name ] = values[ 1 ];
				} else {
					attribs[ name ] = values;
				}
			}
		}

		return attribs;
	}

	public boolean function getAssertionIsSigned() {
		var rootEl = getRootNode();

		return Len( rootEl.Assertion.Signature.SignatureValue.xmlText ?: "" ) > 0
	}

	public string function getInResponseTo() {
		return rootEl.xmlAttributes.inResponseTo ?: "";
	}

// AUTHENTICATION REQUEST METHODS
	public boolean function mustForceAuthentication() {
		var rootEl = getRootNode();

		return IsBoolean( rootEl.xmlAttributes.ForceAuthn ?: "" ) && rootEl.xmlAttributes.ForceAuthn;
	}

	public struct function getNameIdPolicy() {
		var rootEl = getRootNode();
		var policyNode = rootEl.NameIDPolicy ?: NullValue();

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
