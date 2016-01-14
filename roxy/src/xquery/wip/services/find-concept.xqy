declare namespace sem = "http://marklogic.com/semantics";

declare variable $base := "http://lds.org/sem/";
declare variable $core := "http://lds.org/sem/core/";

let $term := xdmp:get-request-field( "q", "" )
(: let $term := fn:concat( $term, "*" ) :)
let $query :=
    cts:and-query((
        cts:directory-query( "http://lds.org/sem/taxonomies/vrl/", "infinity" ),
        cts:element-value-query(
            xs:QName( "sem:predicate" ),
            (
            "http://www.w3.org/2004/02/skos/core#prefLabel",
            "http://www.w3.org/2004/02/skos/core#altLabel",
            "http://www.w3.org/2004/02/skos/core#hiddenLabel"
            ) ),
        cts:word-query( $term )
    ))
let $results := cts:search( //sem:triple, $query )
let $json :=
    fn:concat(
        "[",
        fn:string-join(
            for $triple in $results[1 to 40]
            return fn:concat( '{"id": "', xs:string( $triple//sem:object ), '", "name": "', xs:string( $triple//sem:object ), '"}' )
        , "," ),
        "]" )
return $json

(:
let $json :=
    '[{"id": "hello world", "name": "hello world"},{"id": "movies", "name": "movies"},{"id": "ski", "name": "ski"},{"id": "snowbord", "name": "snowbord"},{"id": "computer", "name": "computer"},{"id": "apple", "name": "apple"},{"id": "pc", "name": "pc"},{"id": "ipod", "name": "ipod"},{"id": "ipad", "name": "ipad"},{"id": "iphone", "name": "iphone"},{"id": "iphon4", "name": "iphone4"},{"id": "iphone5", "name": "iphone5"},{"id": "samsung", "name": "samsung"},{"id": "blackberry", "name": "blackberry"}]'
let $foo := xdmp:set-response-content-type( "application/json" )
return $json
:)

(: header("Content-type: application/json"); :)