import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $base := "http://lds.org/sem/";
declare variable $core := "http://lds.org/sem/core/";

declare function local:update-rel-count( $parent-triple, $subject, $predicate ) {
    (:
    1. Not a relationship predicate, so do nothing.
    2. Relationship predicate does not exist, so create one (node-insert-child)
    3. Relationship predicate exists, so update it (node-replace)
    :)
    let $old-rel-triple :=
        xdmp:directory( $base, "infinity" )//sem:triple[
            sem:subject = $subject and
            sem:predicate = "http://www.lds.org/core#relCount"]
    let $action :=
        if ( $predicate = $core:SEM-RELS )
            then
                if ( $old-rel-triple )
                    then "replace"
                    else "insert"
            else ()
    let $rel-count :=
        if ( $action = "replace" )
            then xs:integer( $old-rel-triple/sem:object/text() ) + 1
            else 1
    let $new-rel-triple :=
        <sem:triple>
            <sem:subject>{ $subject }</sem:subject>
            <sem:predicate>http://www.lds.org/core#relCount</sem:predicate>
            <sem:object datatype="xsd:integer">{ $rel-count }</sem:object>
        </sem:triple>
    return (:($old-rel-triple,$subject,$predicate,$action):)
        if ( $action = "insert" )
            then xdmp:node-insert-child( $parent-triple, $new-rel-triple )
            else
        if ( $action = "replace" )
            then xdmp:node-replace( $old-rel-triple, $new-rel-triple )
            else ()
};


let $subject := xdmp:get-request-field( "subject", "" )
let $predicate := xdmp:get-request-field( "predicate", "" )
let $object := xdmp:get-request-field( "object", "" )
let $language := xdmp:get-request-field( "language", "" )
let $datatype := semantics:get-data-type( $predicate )
let $triple :=
    if ( $subject and $predicate and $object )
        then
            <sem:triple>
                <sem:subject>{ $subject }</sem:subject>
                <sem:predicate>{ $predicate }</sem:predicate>
                {
                if ( $datatype = "http://www.w3.org/2001/XMLSchema#string" and $language ne "" )
                    then <sem:object xml:lang="{ $language }">{ $object }</sem:object>
                    else <sem:object>{ $object }</sem:object>
                }
            </sem:triple>
        else ()
let $parent-triple := xdmp:directory( $core, "infinity" )//sem:triple[
    sem:subject = $subject and
    sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]/..
let $foo := local:update-rel-count( $parent-triple, $subject, $predicate )
let $redirect := fn:concat( "concept.xqy?s=", $subject, "&amp;p=", fn:escape-uri( $predicate, fn:true() ) )
return
    (
    xdmp:node-insert-child( $parent-triple, $triple ),
    xdmp:redirect-response( $redirect )
    )
