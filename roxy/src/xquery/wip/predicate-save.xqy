import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";
declare variable $model := "http://lds.org/sem/model/";


let $label := xdmp:get-request-field( "label", "" )
let $iri := xdmp:get-request-field( "iri", "" )
let $name := fn:tokenize( $iri, "#" )[fn:last()]
let $prefix := xdmp:get-request-field( "prefix", "" )
let $datatype := xdmp:get-request-field( "datatype", "" )
let $note := xdmp:get-request-field( "note", "" )
let $link := xdmp:get-request-field( "link", "" )

let $triples :=
    <sem:triples xmlns:sem="http://marklogic.com/semantics">
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
            <sem:object>{ $label }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
            <sem:object>http://www.lds.org/core#predicate</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
            <sem:object>http://www.lds.org/concept-scheme/model</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.lds.org/core#prefix</sem:predicate>
            <sem:object>{ $prefix }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.lds.org/core#dataType</sem:predicate>
            <sem:object>{ $datatype }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $iri }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#note</sem:predicate>
            <sem:object>{ $note }</sem:object>
        </sem:triple>
    </sem:triples>
let $err-label-empty := if ( $label = "" ) then 1 else 0
let $err-iri-empty := if ( $iri = "" ) then 1 else 0
let $err-iri-exists :=
    if ( fn:exists( xdmp:directory( $model, "infinity" )//sem:triple[
        sem:subject = $iri and
        sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
        sem:object = "http://www.lds.org/core#predicate"] ) )
        then 1 else 0
let $errors := ($err-label-empty,$err-iri-exists,$err-iri-empty)
let $error-string := for $item in $errors return xs:string( $item )
let $response := fn:concat( "?errors=", fn:string-join( $error-string, "," ), "&amp;", "label=", $label, "&amp;", "iri=", fn:escape-uri( $iri, fn:true() ), "&amp;prefix=", $prefix, "&amp;datatype=", $datatype, "&amp;note=", $note, "&amp;link=", $link )
let $path := fn:concat( "http://lds.org/sem/model/", $prefix, "/", $name, ".xml" )
return
    if ( fn:sum( $errors) > 0 )
        then xdmp:redirect-response( fn:concat( "predicate-add.xqy", $response ) )
        else (xdmp:document-insert( $path, $triples ),xdmp:redirect-response( "predicate-add.xqy" ))
