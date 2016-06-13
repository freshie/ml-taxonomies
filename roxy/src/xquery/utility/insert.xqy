	xquery version "1.0-ml";

	declare variable $URI as xs:string external;
	declare variable $ROOT as element() external;
	declare variable $PERMISSIONS as element(permissions) external;
	declare variable $COLLECTIONS as element(collections) external;
	declare variable $QUALITY as xs:int external;
	declare variable $FORESTS as element(forests) external;

	let $permissions := $PERMISSIONS/element()
	let $collections := $COLLECTIONS/element()/text()
	let $forests := $FORESTS/element()/text()

	return 
		xdmp:document-insert($URI, $ROOT, $permissions, $collections, $QUALITY, $forests)