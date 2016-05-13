xquery version "1.0-ml";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

let $key := xdmp:get-request-field( "taxonomy", "graph" )
let $taxonomy := 
	cts:search(
		fn:doc(), 
		cts:element-attribute-value-query(
  		xs:QName("taxonomy"),
  		xs:QName("key"),
  		$key) 
  	)/element()

let $taxonomy-title := $taxonomy/title/text()
let $taxonomy-path := $taxonomy/path/text()

let $_ := xdmp:set-session-field( "taxonomy", $key )
let $_ := xdmp:set-session-field( "taxonomy-title", $taxonomy-title )
let $_ := xdmp:set-session-field( "taxonomy-path", $taxonomy-path )
return xdmp:redirect-response( $core:siteRootURL || "search/" )