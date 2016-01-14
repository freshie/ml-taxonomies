import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

let $json :=
    fn:concat( "[",
        fn:string-join(
            for $label in semantics:getTripleByPredicateDirectiory("http://www.w3.org/2004/02/skos/core#prefLabel", $core:taxonomy-path || "doctrine/gs/")
            let $object := $label/sem:object/xs:string(.)
            return '{ "name": "' || $object  || '"}'
        , ", " ),
        "]" )
return 
( xdmp:set-response-content-type("application/json"),
  $json
)