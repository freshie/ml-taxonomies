module namespace semantics = "org.lds.gte.core-semantics-functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

(: 
  A wrapper function for cts:triples 
  It takes each part of the triple and addes the needed casting to it
  It checks inputs to make sure they arent empty strings
  It coverts the triple to xml
:)
declare function semantics:getTriple(
    $subjectsIn as xs:string*,
    $predicatesIn as xs:string*,
    $objectsIn as xs:string*,
    $directioryIn as xs:string,
    $addtionalQueryIn as cts:query?
) as element(sem:triple)* {
   let $subjects := 
        for $subject in $subjectsIn
        return semantics:stringToTriplePart($subject)
   let $predicates := 
        for $predicate in $predicatesIn
        return semantics:stringToTriplePart($predicate)
   let $objects := 
        for $object in $objectsIn
        return semantics:stringToTriplePart($object)
   return 
   if ("" eq ($objects,$predicates,$subjects,$directioryIn))
   then ()
   else
      let $triples :=
        <triples>
        {
          cts:triples(
            $subjects,
            $predicates,
            $objects,
            (),
            ("concurrent"),
             cts:and-query((
                cts:directory-query($directioryIn, "infinity"),
                $addtionalQueryIn
              ))
          )
        }
        </triples>
      return $triples/element()
};

declare function semantics:getTriple(
    $subjectsIn as xs:string*,
    $predicatesIn as xs:string*,
    $objectsIn as xs:string*,
    $directioryIn as xs:string
) {
  semantics:getTriple(
    $subjectsIn,
    $predicatesIn,
    $objectsIn,
    $directioryIn,
    ()
  )
};

declare function semantics:stringToTriplePart( 
  $part as xs:string
) as item()* {
  sem:iri($part),
  sem:unknown($part, sem:iri("sem:iri"))
};

declare function semantics:getTripleByObjectPredicateDirectioryLetter(
    $object as xs:string,
    $predicate as xs:string,
    $directioryIn as xs:string,
    $letter as xs:string
) as element(sem:triple)* {
  let $params := 
    map:new((
      map:entry(
        "predicate", 
        sem:iri($predicate)
       ),
        map:entry(
        "object", 
        sem:unknown($object, sem:iri("sem:iri"))
       )
      ))
  let $filter := 
    if ($letter ne "all") 
    then 'FILTER regex(?subject, "(/[' || $letter || '][^/]*$)", "i")'
    else ()
  return 
    <t>
    {
      sem:sparql('
      CONSTRUCT { ?subject ?predicate ?object }
      WHERE
      { ?subject ?predicate ?object 
       ' || $filter || '
      } ',
      $params, ("document"), cts:directory-query($directioryIn, "infinity"))
    }
    </t>/element()
};

declare function semantics:getTripleByPredicateDirectiory(
    $predicates as xs:string*,
    $directiory as xs:string
) as element(sem:triple)* {
  semantics:getTriple(
    (),
    $predicates,
    (),
    $directiory,
    ()
  )
};

declare function semantics:getTripleByPredicateDirectioryWord(
    $predicates as xs:string*,
    $directiory as xs:string,
    $word as xs:string
) as element(sem:triple)* {
if ($word eq "")
then ()
else
  semantics:getTriple(
    (),
    $predicates,
    (),
    $directiory,
    cts:word-query($word)
  )
};

declare function semantics:getTripleBySubjectDirectiory(
    $subjects as xs:string*,  
    $directiory as xs:string
) as element(sem:triple)* {
  semantics:getTriple(
    $subjects,
    (),
    (),
    $directiory
  )
};

declare function semantics:getTripleBySubjectObjectDirectiory(
    $subjects as xs:string*,
    $objects as xs:string*, 
    $directiory as xs:string
) as element(sem:triple)* {
  semantics:getTriple(
      $subjects,
      (),
      $objects,
      $directiory
   )
};

declare function semantics:getTripleByObjectPredicateDirectiory(
    $objects as xs:string*,
    $predicates as xs:string*,
    $directiory as xs:string
) as element(sem:triple)* {
  semantics:getTriple(
      (),
      $predicates,
      $objects,
      $directiory
   )
};

declare function semantics:getObjectBySubjectPredicateDirectiory(
    $subjects as xs:string*, 
    $predicates as xs:string*, 
    $directiory as xs:string
) as xs:anyAtomicType* {
  let $triples := 
    semantics:getTriple(
        $subjects,
        $predicates,
        (),
        $directiory
      )
  return $triples/sem:object/xs:anyAtomicType(.)
};

declare function semantics:getObjectByPredicateDirectiory(
    $predicates as xs:string*, 
    $directiory as xs:string
) as xs:anyAtomicType* {
  let $triples := 
    semantics:getTriple(
        (),
        $predicates,
        (),
        $directiory
      )
  return $triples/sem:object/xs:anyAtomicType(.)
};

declare function semantics:getSubjectByObjectPredicateDirectiory(
    $objects as xs:string*, 
    $predicates as xs:string*, 
    $directiory as xs:string*
) as xs:anyAtomicType* {
  let $triples := 
    semantics:getTriple(
        (),
        $predicates,
        $objects,
        $directiory
      )
  return $triples/sem:subject/xs:anyAtomicType(.)
};

declare function semantics:get-label(
    $subjects as xs:string*
) as xs:string* {
    if (fn:empty($subjects))
    then ()
    else semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.w3.org/2004/02/skos/core#prefLabel", $core:baseURI)
};

declare function semantics:getSubjectByLabel(
    $label as xs:string
) as xs:string?  {
  
    cts:search(
        /sem:triples/sem:triple,
        cts:and-query((
          
          cts:element-value-query(xs:QName("sem:object"), $label, "case-insensitive"),
          cts:element-value-query(xs:QName("sem:predicate"), "http://www.w3.org/2004/02/skos/core#prefLabel", "exact"),
     
          cts:directory-query( $core:taxonomy-path || "doctrine/",  "infinity" )
        ))
        
      )[1]/sem:subject/xs:string(.)
 
};

declare function semantics:get-scheme(
    $subjects as xs:string*
) as xs:string* {
    if (fn:empty($subjects))
    then ()
    else semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.w3.org/2004/02/skos/core#prefLabel", $core:taxonomy-path)
};

declare function semantics:get-prefix(
    $subjects as xs:string*
) as xs:anyAtomicType* {
    semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.lds.org/core#prefix", $core:baseURI)
};

declare function semantics:get-scheme-iri-from-prefix(
    $objects as xs:string*
) as xs:anyAtomicType* {
    semantics:getSubjectByObjectPredicateDirectiory($objects, "http://www.lds.org/core#prefix", $core:taxonomy-path)
};

declare function semantics:get-data-type(
    $subjects as xs:string*
) as xs:anyAtomicType* {
    semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.lds.org/core#dataType", $core:taxonomy-path)
};

declare function semantics:get-data-type(
    $subjects as xs:string*, 
    $short as xs:boolean
) as xs:string {
    let $datatype := semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.lds.org/core#dataType", $core:baseURI)
    let $datatype-str :=
        cts:search(
          /datatypes/datatype, 
            cts:and-query((
              cts:document-query( $core:model || "datatypes.xml"),
              cts:element-word-query(xs:QName("datatype"),  $datatype, "exact")
            ))
          )
    return
        if ( $short )
        then $datatype-str/@short/xs:string(.)
        else $datatype-str/xs:string(.)
};

declare function semantics:get-rel-count(
    $subjects as xs:string*, 
    $predicate as xs:string
) as xs:anyAtomicType* {
    if ( fn:index-of( $core:SEM-RELS, $predicate ) gt 0 )
    then
        xs:integer( 
            semantics:getObjectBySubjectPredicateDirectiory($subjects, "http://www.lds.org/core#relCount", $core:baseURI)
        )
    else 0
};

declare function semantics:get-predicates-list() as element (predicates) {
    <predicates>
    {
        for $subject in semantics:getSubjectByObjectPredicateDirectiory("http://www.lds.org/core#predicate", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", $core:model)
        let $prefix := semantics:get-prefix( $subject )
        let $label := semantics:get-label( $subject )
        let $datatype := semantics:get-data-type( $subject )
        order by $label
        return
            <predicate schema="{ $prefix }" value="{ $subject }" datatype="{ $datatype }">{ $label }</predicate>
    }
    </predicates>
};

declare function semantics:get-classes-list() as element (classes) {
    <classes>
    {
    for $subject in semantics:getSubjectByObjectPredicateDirectiory("http://www.w3.org/1999/02/22-rdf-syntax-ns#type", "http://www.w3.org/2002/07/owl#Class", $core:model)
    let $prefix := semantics:get-prefix( $subject )
    let $label := semantics:get-label( $subject )
    order by $label
    return
        <class schema="{ $prefix }" value="{ $subject }">{ $label }</class>
    }
    </classes>
};

declare function semantics:get-schemes-list() as element (schemes) {
    <schemes>
    {
    for $subject in semantics:getSubjectByObjectPredicateDirectiory("http://www.w3.org/2004/02/skos/core#ConceptScheme", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", $core:taxonomy-path)
    let $prefix := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.lds.org/core#prefix", $core:taxonomy-path)
    let $label := semantics:get-label( $subject )
    order by $label
    return
        <scheme prefix="{ $prefix }" label="{ $label }">{ $subject }</scheme>
    }
    </schemes>
};

declare function semantics:get-prefixes-list() as element (prefixes)  {
    <prefixes>
    {
    for $triple in semantics:getTripleByObjectPredicateDirectiory("http://www.lds.org/core#prefix", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", $core:model)
    let $subject := $triple/sem:subject/xs:string(.)
    let $label := semantics:get-label($subject)
    let $prefix := semantics:getObjectBySubjectPredicateDirectiory($subject,"http://www.lds.org/core#prefix", $core:model)
    order by $prefix
    return
        <prefix label="{ $label }" iri="{ $subject }">{ $prefix }</prefix>
    }
    </prefixes>
};

declare function semantics:build-triple(
    $subject as xs:string, 
    $predicate as xs:string, 
    $object as xs:string, 
    $datatype as xs:string,
    $lang as xs:string?
) as element (sem:triple) {
    <sem:triple>
        <sem:subject>{ $subject }</sem:subject>
        <sem:predicate>{ $predicate }</sem:predicate>
        {
          if ( $datatype = "xsd:string" )
          then <sem:object xml:lang="{ $lang }" datatype="{ $datatype }">{ $object }</sem:object>
          else <sem:object datatype="{ $datatype }">{ $object }</sem:object>
        }
    </sem:triple>
};



declare function semantics:bfs(
  $s as sem:iri*, 
  $limit as xs:int, 
  $adjV
) as map:map {
    let $visited := map:map()
    let $_ := 
      for $spart in $s 
      let $spartMap := map:map()
      let $_ := map:put($spartMap, $spart, xs:string($spart))
      return map:put($visited, $spart, $spartMap)
    let $queue :=  map:map()
    let $_ := $s ! map:put($queue, ., xs:string(.))
    return semantics:bfs-inner($visited, $queue, $limit, $adjV)
};

declare function semantics:bfs-inner(
  $visited as map:map, 
  $queue as map:map?, 
  $limit as xs:int, 
  $adjacentVertices
)  as map:map {
    if (map:count($queue) eq 0 or $limit le 1)
    then $visited
    else
        let $nextQueue := $adjacentVertices($queue)
        let $notVisted  :=
            for $key in  map:keys($nextQueue)
            let $path := map:get($nextQueue, $key)
            return
                if (map:contains($visited, $key))
                then
                  let $visitedMap := map:get($visited, $key)
                  let $_ := map:put($visitedMap,  xs:string(map:count($visitedMap)), $path)
                  let $_ := map:put($visited,  $key, $visitedMap)
                  return ()
                else 
                  let $pathMap := map:map()
                  let $_ := map:put($pathMap, "0", $path)
                  let $_ := map:put($visited, $key, $pathMap) 
                  return $key
        let $thingstoQueue := map:map()
        let $_ := $notVisted ! map:put($thingstoQueue, ., map:get($nextQueue, .))
        return  semantics:bfs-inner($visited, $thingstoQueue, ($limit -1), $adjacentVertices)
};

declare function semantics:transitive-closure(
   $seeds as sem:iri*,
   $preds as sem:iri*,
   $limit as xs:int
) as map:map {
    semantics:bfs($seeds, $limit, function($queue as map:map) as map:map { 
       let $level := map:map()
       let $_ := cts:triples( (map:keys($queue) ! sem:iri(.)) ,$preds,()) ! map:put($level,  sem:triple-object(.), (map:get($queue, sem:triple-subject(.)), sem:triple-object(.)))
       return $level
    })
};