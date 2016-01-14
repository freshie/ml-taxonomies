import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";


declare namespace sem = "http://marklogic.com/semantics";

declare variable $base := "http://lds.org/sem/";
declare variable $core := "http://lds.org/sem/core/";

let $term := xdmp:get-request-field( "term", "" )
(: let $term := fn:concat( $term, "*" ) :)
let $predicates := 
(
    "http://www.w3.org/2004/02/skos/core#prefLabel", 
    "http://www.w3.org/2004/02/skos/core#hiddenLabel", 
    "http://www.lds.org/core#doctrinalStatement"
)
let $results := semantics:getTripleByPredicateDirectioryWord($predicates, $taxonomy-path, $term)
let $json :=
    fn:concat( "[",
        fn:string-join(
            for $triple in $results
            let $subject := $triple/sem:subject/xs:string(.)
            return '"' || $subject || '"'
        , ", " ),
        "]" )
return $json
