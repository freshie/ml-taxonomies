xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare %test:case function getMenuItem-left()
{
  let $date := core:getMenuItem("left")

  let $test := fn:exists($date)

  return assert:true($test)
};


declare %test:case function getTaxonomys()
{
  let $date := core:getTaxonomys()

  let $test := fn:exists($date)

  return assert:true($test)
};

declare %test:case function getTaxonomyByKey-graph()
{
  let $assert := "graph"

  let $date := core:getTaxonomyByKey( $assert)

  let $test :=   xs:string($date/@key)

  return assert:equal($test, $assert) 
};

declare %test:case function getTaxonomyByKey-SomeKeyThatIsntRealy()
{
  let $assert := "SomeKeyThatIsntRealy"

  let $date := core:getTaxonomyByKey( $assert)

  let $test :=  xs:string($date/@key)

  return assert:not-equal($test, $assert) 
};