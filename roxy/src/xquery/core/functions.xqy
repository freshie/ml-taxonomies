module namespace core = "org.lds.gte.core-functions";

declare namespace sem = "http://marklogic.com/semantics";

declare variable $applicationConfig := fn:doc("/configuration/application.xml")/element();

declare variable $applicationURI := "http://" || $applicationConfig/name || ".com/";

declare variable $siteRootURL := $applicationConfig/siteRootURL/text();
declare variable $cdnURL := $applicationConfig/cdnURL/text();

declare variable $baseURI := $applicationConfig/baseURI/text();

declare variable $model :=  $baseURI || "model/";

declare variable $taxonomy := xdmp:get-session-field( "taxonomy",  $applicationConfig/defaults/taxonomy/text() );
declare variable $taxonomy-title := xdmp:get-session-field( "taxonomy-title", $applicationConfig/defaults/taxonomy-title/text() );
declare variable $taxonomy-path := xdmp:get-session-field( "taxonomy-path", $applicationConfig/defaults/taxonomy-path/text() );

declare variable $core:SEM-RELS :=
    (
    "http://www.w3.org/2004/02/skos/core#broadMatch",
    "http://www.w3.org/2004/02/skos/core#broader",
    "http://www.w3.org/2004/02/skos/core#broaderTransitive",
    "http://www.w3.org/2004/02/skos/core#closeMatch",
    "http://www.w3.org/2004/02/skos/core#exactMatch",
    "http://www.w3.org/2004/02/skos/core#mappingRelation",
    "http://www.w3.org/2004/02/skos/core#narrowMatch",
    "http://www.w3.org/2004/02/skos/core#narrower",
    "http://www.w3.org/2004/02/skos/core#narrowerTransitive",
    "http://www.w3.org/2004/02/skos/core#related",
    "http://www.w3.org/2004/02/skos/core#relatedMatch",
    "http://www.w3.org/2004/02/skos/core#semanticRelation"
    );

declare function core:getMenuItem(
    $type as xs:string
) as element (menu-item)* {
    cts:search(
        /menu-items/menu-item, 
          cts:and-query((
            cts:document-query("/configuration/menu.xml"),
            cts:element-attribute-word-query(xs:QName("menu-item"), xs:QName("type"),  $type, "exact")
          ))
    )
};

declare function core:cleanInput(
    $input as xs:string
) as xs:string {
    fn:normalize-space($input) ! fn:replace(., "'",  "") ! fn:replace(., '"',  '') ! fn:replace(., '\\',  '')
};

declare function core:getTaxonomys() as node()* {
    cts:search(
        /taxonomy, 
        cts:and-query((
            cts:directory-query( $core:baseURI || "admin/taxonomies/")
        ))
    )
};

declare function core:getTaxonomyByKey(
    $key as xs:string
) as element(taxonomy) {
    cts:search(
        fn:doc(),
        cts:and-query((
            cts:element-attribute-value-query(xs:QName("taxonomy"),  xs:QName("key"), $key),
            cts:directory-query( $core:baseURI || "admin/taxonomies/")
        ))
    )/taxonomy
};