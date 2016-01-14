import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $user := xdmp:get-session-field( "user", "public" );
declare variable $role := core:get-user-roles( $user );
declare variable $taxonomy := xdmp:get-session-field( "taxonomy", "graph" );
declare variable $taxonomy-title := xdmp:get-session-field( "taxonomy-title", "LDS Knowledge Graph" );
declare variable $taxonomy-path := xdmp:get-session-field( "taxonomy-path", "http://lds.org/sem/taxonomies/" );
declare variable $base := "http://lds.org/sem/";


let $prefix := xdmp:get-request-field( "prefix", "" )
let $scheme := xdmp:get-request-field( "scheme", "" )
let $note := xdmp:get-request-field( "note", "" )

let $scheme-iri := semf:format-as-uri( $scheme )
let $path := fn:concat( $taxonomy-path, "schemes/", $scheme-iri, ".xml" )
let $scheme-iri-full := fn:concat( "http://www.lds.org/concept-scheme/", $scheme-iri )
let $triples :=
<sem:triples xmlns:sem="http://marklogic.com/semantics">
    <sem:triple>
        <sem:subject>{ $scheme-iri-full }</sem:subject>
        <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
        <sem:object>http://www.w3.org/2004/02/skos/core#ConceptScheme</sem:object>
    </sem:triple>
    <sem:triple>
        <sem:subject>{ $scheme-iri-full }</sem:subject>
        <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
        <sem:object>{ $scheme }</sem:object>
    </sem:triple>
    <sem:triple>
        <sem:subject>{ $scheme-iri-full }</sem:subject>
        <sem:predicate>http://www.w3.org/2004/02/skos/core#note</sem:predicate>
        <sem:object>{ $note }</sem:object>
    </sem:triple>
    <sem:triple>
        <sem:subject>{ $scheme-iri-full }</sem:subject>
        <sem:predicate>http://www.lds.org/core#prefix</sem:predicate>
        <sem:object>{ $prefix }</sem:object>
    </sem:triple>
    <sem:triple>
        <sem:subject>{ $scheme-iri-full }</sem:subject>
        <sem:predicate>http://purl.org/dc/terms/creator</sem:predicate>
        <sem:object>{ $user }</sem:object>
    </sem:triple>
</sem:triples>
let $scheme-exists := xdmp:directory( $taxonomy-path, "infinity" )//sem:triple[
    sem:subject = $scheme-iri-full and
    sem:predicate = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" and
    sem:object = "http://www.w3.org/2004/02/skos/core#ConceptScheme"]
let $prefix-exists := xdmp:directory( $base, "infinity" )//sem:triple[
    sem:predicate = "http://www.lds.org/core#prefix" and
    sem:object = $prefix]
let $error :=
    if ( $scheme-exists and $prefix-exists )
        then 3
        else
    if ( $prefix-exists )
        then 2
        else
    if ( $scheme-exists )
        then 1
        else 0
let $response := fn:concat( "&amp;", "scheme=", $scheme, "&amp;", "prefix=", $prefix, "&amp;note=", $note )
return
    if ( $user = "public" or $user = "" )
        then xdmp:redirect-response( fn:concat( "sign-in.xqy?error=login-expired", $response ) )
        else
    if ( $error > 0 )
        then xdmp:redirect-response( fn:concat( "scheme-add.xqy?error={ $error }", $response ) )
        else (xdmp:document-insert( $path, $triples ),xdmp:redirect-response( "scheme-add.xqy" ))
