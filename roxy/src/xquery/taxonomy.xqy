let $key := xdmp:get-request-field( "taxonomy", "graph" )
let $taxonomy := xdmp:directory( "/published/gospel-topical-explorer/", "infinity" )//taxonomy[@key = $key]
let $taxonomy-title := $taxonomy/title/text()
let $taxonomy-path := $taxonomy/path/text()

let $foo := xdmp:set-session-field( "taxonomy", $key )
let $foo := xdmp:set-session-field( "taxonomy-title", $taxonomy-title )
let $foo := xdmp:set-session-field( "taxonomy-path", $taxonomy-path )
return xdmp:redirect-response( "search/" )