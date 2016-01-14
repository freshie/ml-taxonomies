module namespace concept = "org.lds.gte.concept.functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

declare function concept:getConceptByLetter(
    $letterIn as xs:string,  
    $selected-schemeIn as xs:string
) as element (concepts) {      

    <concepts>
        {
        let $letter := fn:lower-case($letterIn)    
        let $selected-scheme := fn:lower-case($selected-schemeIn)
        for $triple in semantics:getTripleByObjectPredicateDirectioryLetter("http://www.w3.org/2004/02/skos/core#Concept", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", $core:taxonomy-path, $letter)
        let $subject := $triple/sem:subject/xs:string(.)
        let $scheme := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.w3.org/2004/02/skos/core#inScheme", $core:taxonomy-path)
        let $parent := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.w3.org/2004/02/skos/core#narrower", $core:taxonomy-path) 
        where ( $selected-scheme eq "all" or $scheme eq $selected-scheme )
        return
            <concept uri="{$subject}">
                <label>{ semantics:get-label( $subject )}</label>
                <parent>{ semantics:get-label( $parent )}</parent>
                <scheme>{ $scheme }</scheme>
            </concept>
        }
    </concepts>
};

declare function concept:nav(
    $activePageIn as xs:string,
    $subject as xs:string
) as element (p){
    let $activePage := fn:lower-case($activePageIn)
    let $pages := 
    (
        "Outbound",
        "Inbound",
        "Graph"
    )
    return 
        <p>
            {
                for $page in $pages
                let $lowercasePage := fn:lower-case($page)
                let $pageClass := 
                    if ($lowercasePage eq $activePage)
                    then "btn-default"
                    else "btn-info"
                return 
                (
                    <a href="{$core:siteRootURL}concept/{$lowercasePage}.xqy?s={ $subject }" class="btn  {$pageClass} btn-xs" type="button">{$page}</a>, 
                    "&nbsp;"
                )
            }
       </p>
};

declare function concept:getConceptFromTriples(
    $triples as element(sem:triple)
) as element(concept)* {
    for $triple in $triples
    let $object := $triple/sem:object/xs:string(.)
    (: TODO: see if we can do this all in one query :)
    
    let $scheme-label :=  concept:getSchemeLabel($object)
  
    let $object-label :=
        if ( fn:starts-with( $object, "http:" ) )
        then semantics:get-label( $object )
        else $object

    let $object-label := 
        if ( fn:empty( $object-label ) ) 
        then $object 
        else $object-label

    let $s := fn:escape-uri( $triple/sem:subject/xs:string(.), fn:true() )
   
    let $o := fn:escape-uri( $object, fn:true() )
    let $lang := xs:string( $triple/sem:object/@xml:lang )
    order by $object-label
    return
        <concept>
            <subject>{$s}</subject>
            <object>{$o}</object>
            <objectLabel>{$object-label}</objectLabel>
            <schemeLabel>{$scheme-label}</schemeLabel>
            <lang>{$lang}</lang>
        </concept>
};

declare function concept:getSchemeLabel(
    $object as xs:string*
) as xs:string* {
    let $scheme := semantics:getObjectBySubjectPredicateDirectiory($object, "http://www.w3.org/2004/02/skos/core#inScheme", $core:taxonomy-path)
    return semantics:get-scheme( $scheme )
};

declare function concept:getInboundConceptFromSubject(
    $subjectIn as xs:string
) as element(concept)* {
    for $predicate in $core:SEM-RELS
        let $predicate-label := semantics:get-label( $predicate )
    return 
        for $conceptSubject in semantics:getSubjectByObjectPredicateDirectiory($subjectIn, $predicate, "/")
        let $label := semantics:get-label( $conceptSubject )
        order by $predicate-label, $label
        return
            <concept>
                <subject>{$conceptSubject}</subject>
                <label>{$label}</label>
                <predicate-label>{$predicate-label}</predicate-label>  
            </concept>
};

declare function concept:getGroup(
    $predicate as xs:string 
) as xs:string {
    if ($predicate eq "http://www.lds.org/core#instanceOf")
    then "instances"
    else if ($predicate eq ("http://www.w3.org/2004/02/skos/core#related", "http://www.w3.org/2004/02/skos/core#narrower", "http://www.w3.org/2004/02/skos/core#broader"))
    then "relationships"
    else "properties"
};


declare function concept:getConnectedConceptsBySubjectGroup(
    $subjectIn as xs:string,
    $groupIn as xs:string
) as element(concepts) {
    let $groupWanted := fn:lower-case($groupIn)
    let $triples := semantics:getTripleBySubjectDirectiory($subjectIn, $core:taxonomy-path)
    let $mainLabel := $triples[sem:predicate eq "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/xs:string(.)
    let $mainRels := semantics:getObjectBySubjectPredicateDirectiory($subjectIn, "http://www.lds.org/core#relCount", $core:baseURI)
    let $mainRels := 
        if ($mainRels lt 10) 
        then $mainRels + 10 
        else $mainRels
    let $unwantedPredicates :=
    (
        "http://www.w3.org/2004/02/skos/core#prefLabel",
        "http://www.w3.org/2004/02/skos/core#definition",
        "http://www.w3.org/2004/02/skos/core#editorialNote",
        "http://www.w3.org/2004/02/skos/core#historyNote",
        "http://www.lds.org/core#relCount",
        "http://www.lds.org/core#weight"
    )
    return
        <concepts mainLabel="{$mainLabel}" mainRels="{$mainRels}" subjectId="0">
            {
                for $concept in $triples[fn:not(sem:predicate/xs:string(.) eq $unwantedPredicates)]
                let $predicate := $concept/sem:predicate/xs:string(.)
                let $object := $concept/sem:object/xs:string(.)
                let $datatype := semantics:get-data-type($predicate)
                
                let $label :=
                    if ($datatype eq "http://www.w3.org/2001/XMLSchema#string")
                    then $object                
                    else if ($datatype eq "http://www.w3.org/2001/XMLSchema#anyURI")
                    then $object
                    else semantics:get-label($object)
                let $label :=
                    if (fn:empty($label) or $label eq "")
                    then $object
                    else $label
                let $label := 
                    if (fn:contains( $label, "'" )) 
                    then fn:replace( $label, "'", "\\'" ) 
                    else $label
                let $label :=
                    if (fn:empty($label) or $label eq "") 
                    then $predicate
                    else $label
                 let $title :=
                    if ($label eq  " ")
                    then ',title="' || $object || '"'
                    else ()
                let $group := concept:getGroup($predicate)
                let $rels := semantics:get-rel-count($object, $predicate)
                where $groupWanted eq ("all",$group)
                return 
                    <concept>
                        {$concept/element()}
                        <label>{$label}</label>
                        <title>{$title}</title>
                        <group>{$group}</group>
                        <rels>{$rels}</rels>
                    </concept>
            }
        </concepts>
};