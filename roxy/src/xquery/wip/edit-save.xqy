import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";

let $subject := xdmp:get-request-field( "subject-hidden", "" )
let $predicate := xdmp:get-request-field( "predicate-hidden", "" )
let $object-old := xdmp:get-request-field( "object-hidden", "" )
let $object := xdmp:get-request-field( "object", "" )

return

let $old-triple := xdmp:directory( $core, "infinity" )//sem:triple[
    sem:subject = $subject and
    sem:predicate = $predicate and
    sem:object = $object-old]
let $new-triple :=
    <sem:triple>
        <sem:subject>{ $subject }</sem:subject>
        <sem:predicate>{ $predicate }</sem:predicate>
        <sem:object>{ $object }</sem:object>
    </sem:triple>
let $response := fn:concat( "&amp;s=", $subject, "&amp;p=", $predicate, "&amp;o=", $object )
return
    if ( $object = "" or fn:empty( $object ) )
        then xdmp:redirect-response( fn:concat( "concept-edit.xqy?error=empty", $response ) )
        else (xdmp:node-replace( $old-triple, $new-triple ),xdmp:redirect-response( fn:concat( "concept.xqy?s=", $subject ) ))
