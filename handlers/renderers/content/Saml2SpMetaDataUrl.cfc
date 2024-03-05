component {

	public string function default( event, rc, prc, args={} ){
		var linkPath  = event.buildLink( linkto="saml2.idpmeta", queryString="sp=#( args.data ?: "" )#" );

		return '<a href="#linkPath#" target="_blank" title="#linkPath#"><i class="fa fa-fw fa-external-link"></i> #abbreviate( linkPath, 50 )#</a>';
	}

}