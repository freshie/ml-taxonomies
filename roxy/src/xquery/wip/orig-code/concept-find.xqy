declare namespace sem = "http://marklogic.com/semantics";

declare variable $core := "http://lds.org/sem/core/";

let $term := xdmp:get-request-field( "term", "" )
(: let $term := fn:concat( $term, "*" ) :)
let $query :=
    cts:and-query((
        cts:directory-query( $core, "infinity" ),
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
    fn:concat( "[",
        fn:string-join(
            for $triple in $results
            return fn:concat( '"', xs:string( $triple//sem:subject ), '"' )
        , ", " ),
        "]" )
return $json

(:
let $query :=
    cts:and-query((
        cts:directory-query( $core, "infinity" ),
        cts:or-query((
            cts:element-value-query( xs:QName( "sem:predicate" ), "http://www.w3.org/2004/02/skos/core#prefLabel" ),
            cts:element-value-query( xs:QName( "sem:predicate" ), "http://www.w3.org/2004/02/skos/core#altLabel" ),
            cts:element-value-query( xs:QName( "sem:predicate" ), "http://www.w3.org/2004/02/skos/core#hiddenLabel" )
        )),
        cts:element-value-query( xs:QName( "sem:object" ), $term, ("wildcarded","case-insensitive") )
    ))
:)