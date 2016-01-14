import module namespace semf = "org.lds.common.semantic-functions" at "/lib/semantic/semantic-functions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";


let $user := xdmp:get-session-field( "user", "public" )
let $role := core:get-user-roles( $user )

let $subject := xdmp:get-request-field( "subject", "" )
let $scheme-prefix := xdmp:get-request-field( "scheme", "" )

let $subject-iri := semf:format-as-uri( $subject )
let $scheme-iri-full := semantics:get-scheme-iri-from-prefix( $scheme-prefix )
let $path := fn:concat( "http://lds.org/sem/core/", $scheme-prefix, "/", $subject-iri, ".xml" )
let $subject-iri-full := fn:concat( "http://www.lds.org/concept/", $scheme-prefix, "/", $subject-iri )
let $triples :=
    <sem:triples>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/1999/02/22-rdf-syntax-ns#type</sem:predicate>
            <sem:object>http://www.w3.org/2004/02/skos/core#Concept</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
            <sem:object>{ $scheme-iri-full }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.w3.org/2004/02/skos/core#prefLabel</sem:predicate>
            <sem:object>{ $subject }</sem:object>
        </sem:triple>
        <sem:triple>
            <sem:subject>{ $subject-iri-full }</sem:subject>
            <sem:predicate>http://www.lds.org/core#creator</sem:predicate>
            <sem:object>{ $user }</sem:object>
        </sem:triple>
    </sem:triples>
let $exists := xdmp:directory( $core, "infinity" )//sem:triple[
    sem:subject = $subject-iri-full and
    sem:predicate = "http://www.w3.org/2004/02/skos/core#inScheme" and
    sem:object = $scheme-iri-full]
let $response := fn:concat( "&amp;", "subject=", $subject, "&amp;", "scheme=", $scheme-prefix )
return
    if ( $user = "public" )
        then xdmp:redirect-response( "login.xqy" )
        else
    if ( $exists )
        then xdmp:redirect-response( fn:concat( "concept-add.xqy?error=dup", $response ) )
        else (xdmp:document-insert( $path, $triples ),xdmp:redirect-response( fn:concat( "concept.xqy?s=", $subject-iri-full ) ))
