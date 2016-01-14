module namespace relate = "org.lds.gte.relate.functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

declare variable $nodeIDs := map:map();
declare variable $links := map:map();

declare function relate:getTransitiveClosure(
    $subject as xs:string,  
    $target as xs:string
) as map:map* {
    if ($subject ne "" and $target ne "")
    then
        let $subjectIRI := semantics:getSubjectByLabel($subject)
        let $targetIRI := semantics:getSubjectByLabel($target)
        return 
            if (fn:empty($subjectIRI) or fn:empty($targetIRI) )
            then ()
            else
                let $targetMap := semantics:transitive-closure(sem:iri($subjectIRI), sem:iri("http://www.w3.org/2004/02/skos/core#related"), 99) ! map:get(., $targetIRI)
                let $_ := 
                    for $key in map:keys($targetMap)
                    return
                        if (fn:count(map:get($targetMap, $key)[. eq $targetIRI]) gt 1)
                        then map:delete($targetMap, $key)
                        else ()
                let $subjectMap := semantics:transitive-closure(sem:iri($targetIRI), sem:iri("http://www.w3.org/2004/02/skos/core#related"), 99) ! map:get(., $subjectIRI)
                let $_ := 
                    for $key in map:keys($subjectMap)
                    return
                        if (fn:count(map:get($subjectMap, $key)[. eq $subjectIRI]) gt 1)
                        then map:delete($subjectMap, $key)
                        else ()
                return ($targetMap, $subjectMap)
    else ()
};

declare function relate:getPaths(
    $maps as map:map*
) {
    for $map in $maps
    return
        for $key in map:keys($map)
        let $value  := map:get($map, $key)
        let $count := fn:count($value)
        order by $count
        return 
        (
            for $item at $index in $value
            let $related := 
                if ($index lt $count)
                then " &#187; "
                else ()
            return (
                    $item, 
                    $related
                    ),
            <hr/>
        )
};

declare function relate:getNodeId(
  $item as xs:string
) as xs:int {
 if (map:contains($nodeIDs, $item))
 then map:get($nodeIDs, $item)
 else 
   let $count := map:count($nodeIDs)
   let $_ := map:put($nodeIDs, $item, $count)
   return $count
};

declare function relate:getGrpah(
    $maps as map:map*
) {
     let $_:=
        for $map in $maps
        return
            for $key in map:keys($map)
            return 
                let $keys := map:get($map, $key)
                for $item at $index in $keys
                let $_:= 
                  if ($index gt 1 )
                  then 
                    let $value := '{"source": ' || relate:getNodeId($item) || ',  "target": ' || relate:getNodeId($keys[$index - 1]) || "}"
                    return map:put($links, xs:string(map:count($links)), $value)
                  else ()
                return ()

    let $linksOutput :=  
    "[" || fn:string-join(map:keys($links) ! map:get($links, .), ",") || "]" 
    
    let $nodesOutput := 
       for $iri in map:keys($nodeIDs)
       let $number :=  map:get($nodeIDs, $iri)
       let $label  :=  semantics:get-label($iri)
       order by $number
       return '{ "iri": "' || $iri || '", "label": "' ||  $label ||'"}'
    
    return  
     ( 
       '{"links":' ||  $linksOutput || ",", 
       '"nodes": [' ||  fn:string-join($nodesOutput, ",") || "]}" 
     )
  
};