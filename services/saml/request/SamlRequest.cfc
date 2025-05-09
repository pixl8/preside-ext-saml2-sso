component extends="app.extensions.preside-ext-saml2-sso.services.saml.util.AbstractSamlObject" {

	public struct function getMemento() {
		var memento = {
			  id           = getId()
			, issuer       = getIssuer()
			, issueInstant = getIssueInstant()
			, type         = getType()
		};

		if ( memento.type == "authnRequest" ) {
			memento.append({
				  forceAuthentication = mustForceAuthentication()
				, nameIdPolicy        = getNameIdPolicy()
			});
		} else if ( memento.type == "logoutRequest" ) {
			memento.append({
				  nameId       = getNameId()
				, sessionIndex = getSessionIndex()
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

		return Trim( rootEl[ "Issuer" ].xmlText ?: "" );
	}

	public date function getIssueInstant() {
		var rootEl = getRootNode();

		return readDate( rootEl.xmlAttributes.IssueInstant ?: "" );
	}

	public string function getType() {
		var rootEl = getRootNode();
		return ListLast( rootEl.xmlName, ":" );
	}

// AUTHENTICATION REQUEST METHODS
	public boolean function mustForceAuthentication() {
		var rootEl = getRootNode();

		return IsBoolean( rootEl.xmlAttributes.ForceAuthn ?: "" ) && rootEl.xmlAttributes.ForceAuthn;
	}

	public struct function getNameIdPolicy() {
		var rootEl = getRootNode();
		var policyNode = rootEl[ "NameIDPolicy" ] ?: NullValue();

		if ( !IsNull( policyNode ) ) {
			return {
				  format          = policyNode.xmlAttributes.format ?: ""
				, spNameQualifier = policyNode.xmlAttributes.spNameQualifier ?: ""
				, allowCreate     = IsBoolean( policyNode.xmlAttributes.allowCreate ?: "" ) && policyNode.xmlAttributes.allowCreate
			};
		}

		return {};
	}

	public string function getNameId() {
		var rootEl = getRootNode();

		return rootEl[ "NameID" ].xmlText ?: "";
	}

	public string function getSessionIndex() {
		var rootEl = getRootNode();

		return rootEl[ "sessionindex" ].xmlText ?: "";
	}
}