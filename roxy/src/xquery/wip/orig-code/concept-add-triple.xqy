declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";


let $subject := xdmp:get-request-field( "subject", "" )
let $predicate := xdmp:get-request-field( "predicate", "" )
let $object := xdmp:get-request-field( "object", "" )
let $triple :=
    if ( $subject and $predicate and $object )
        then
            <sem:triple>
                <sem:subject>{ $subject }</sem:subject>
                <sem:predicate>{ $predicate }</sem:predicate>
                <sem:object>{ $object }</sem:object>
            </sem:triple>
        else ()
let $parent-triple := xdmp:directory( $core, "infinity" )//sem:triple[
    sem:subject = $subject and
    sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]/..
let $redirect := fn:concat( "concept.xqy?s=", $subject, "&amp;p=", fn:escape-uri( $predicate, fn:true() ) )
return
    (xdmp:node-insert-child( $parent-triple, $triple ),
    xdmp:redirect-response( $redirect ))
