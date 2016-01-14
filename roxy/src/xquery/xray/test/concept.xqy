xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";
import module namespace concept = "org.lds.gte.concept.functions" at "/concept/modules/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare %test:case function getConceptByLetter-All()
{
   let $test := concept:getConceptByLetter("All","All")
   let $assertion := <concepts/>
   return assert:not-equal($test,$assertion)
};

declare %test:case function getConceptByLetter-aSchemeWithContent()
{
  let $test := concept:getConceptByLetter("A","http://lds.org/concept-scheme/doctrinal-statements")
  let $assertion := <concepts/>
  return assert:equal($test,$assertion)
};

declare %test:case function getConceptByLetter-aSchemeWithOutContent()
{
  let $test := concept:getConceptByLetter("A","http://www.lds.org/concept-scheme/guide-to-the-scriptures")
  let $assertion := <concepts/>
  return assert:not-equal($test,$assertion)
};


declare %test:case function getConceptByLetter-aLetter()
{
  let $test := concept:getConceptByLetter("A","All")
  let $assertion := <concepts/>
  return assert:not-equal($test,$assertion)
};

declare %test:case function getConceptByLetter-unknownLetter()
{
  let $test := concept:getConceptByLetter("$","All")
  let $assertion := <concepts/>
  return assert:equal($test,$assertion)
};

declare %test:case function getConceptFromTriples-outbound()
{
  let $triples := semantics:getTripleBySubjectDirectiory("http://www.lds.org/concept/gs/jesus-christ", "/")
  let $test := concept:getConceptFromTriples($triples)

  return assert:not-empty($test)
};

declare %test:case function getSchemeLabel-emtpyScheme()
{
  let $object := "(a Greek word) and (a Hebrew word) mean “the anointed.” Jesus Christ is the Firstborn of the Father in the spirit (; ). He is the Only Begotten of the Father in the flesh (; ). He is Jehovah () and was foreordained to his great calling before the creation of the world. Under the direction of the Father, Jesus created the earth and everything on it (; ). He was born to Mary at Bethlehem, lived a sinless life, and made a perfect atonement for the sins of all mankind by shedding of his blood and giving his life on the cross (; ; ; ). He rose from the dead, thus assuring the eventual resurrection of all mankind. Through Jesus’ atonement and resurrection, those who repent of their sins and obey God’s commandments can live eternally with Jesus and the Father (; ; )."
  let $test := concept:getSchemeLabel($object)
  return assert:empty($test)
};

declare %test:case function getSchemeLabel-hasScheme()
{
  let $object := "http://www.lds.org/concept/gs/advocate"
  let $test := concept:getSchemeLabel($object)
  return assert:not-empty($test)
};

declare %test:case function getInboundConceptFromSubject-test()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $test := concept:getInboundConceptFromSubject($subject)
  return assert:not-empty($test)
};

declare %test:case function getGroup-instances()
{
  let $predicate := "http://www.lds.org/core#instanceOf"
  let $test := concept:getGroup($predicate)
  return assert:equal($test, "instances")
};

declare %test:case function getGroup-relationships()
{
  let $predicates := ("http://www.w3.org/2004/02/skos/core#related", "http://www.w3.org/2004/02/skos/core#narrower", "http://www.w3.org/2004/02/skos/core#broader")
  let $values :=
  	for $predicate in $predicates
  	return concept:getGroup($predicate)
  let $test := fn:distinct-values($values)
  return assert:equal($test, "relationships")
};

declare %test:case function getGroup-properties()
{
  let $predicate := "http://www.lds.org/Topic"
  let $test := concept:getGroup($predicate)
  return assert:equal($test, "properties")
};

declare %test:case function getConnectedConceptsBySubjectGroup-all()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $all := concept:getConnectedConceptsBySubjectGroup($subject, "all")
  let $test := fn:count($all/concept)
  let $assertion := 
  	fn:count(concept:getConnectedConceptsBySubjectGroup($subject, "relationships")/concept) + fn:count(concept:getConnectedConceptsBySubjectGroup($subject, "properties")/concept) + fn:count(concept:getConnectedConceptsBySubjectGroup($subject, "instances")/concept)

  return assert:equal($test, $assertion)
};

declare %test:case function getConnectedConceptsBySubjectGroup-relationships()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $test := concept:getConnectedConceptsBySubjectGroup($subject, "relationships")
 
  return assert:not-empty($test)
};

declare %test:case function getConnectedConceptsBySubjectGroup-instances()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $test := concept:getConnectedConceptsBySubjectGroup($subject, "instances")
 
  return assert:not-empty($test)
};

declare %test:case function getConnectedConceptsBySubjectGroup-properties()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $test := concept:getConnectedConceptsBySubjectGroup($subject, "properties")
 
  return assert:not-empty($test)
};

declare %test:case function getConnectedConceptsBySubjectGroup-notARealGroup()
{
  let $subject := "http://www.lds.org/concept/gs/jesus-christ"
  let $test := concept:getConnectedConceptsBySubjectGroup($subject, "something")
  let $assertion := 
  	<concepts mainLabel="Jesus Christ" mainRels="60" subjectId="0"/>
  return assert:equal($test, $assertion)
};