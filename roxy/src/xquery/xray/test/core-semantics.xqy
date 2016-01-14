xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace semantics = "org.lds.gte.core-semantics-functions" at "/core/semantics-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare %test:case function getTripleByObjectPredicateDirectioryLetter-aLetter()
{
  let $test := semantics:getTripleByObjectPredicateDirectioryLetter("http://www.w3.org/2004/02/skos/core#Concept", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type","/", 'a')
  return assert:not-empty($test)
};

declare %test:case function getTripleByObjectPredicateDirectioryLetter-all()
{
  let $test := semantics:getTripleByObjectPredicateDirectioryLetter("http://www.w3.org/2004/02/skos/core#Concept", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type","/", 'all')
  return assert:not-empty($test)
};

declare %test:case function getTripleByObjectPredicateDirectioryLetter-unknownLetter()
{
  let $test := semantics:getTripleByObjectPredicateDirectioryLetter("http://www.w3.org/2004/02/skos/core#Concept", "http://www.w3.org/1999/02/22-rdf-syntax-ns#type","/", '$')
  return assert:empty($test)
};


declare %test:case function getSubjectByLabel()
{
  let $test := semantics:getSubjectByLabel("love")
  return assert:equal($test, "http://www.lds.org/concept/gs/love")
};

declare %test:case function getSubjectByLabel_withCase()
{
  let $test := semantics:getSubjectByLabel("Love")
  return assert:equal($test, "http://www.lds.org/concept/gs/love")
};

declare %test:case function getSubjectByLabel_withCommon()
{
  let $test := semantics:getSubjectByLabel("Joseph Smith, Jr.")
  return assert:equal($test, "http://www.lds.org/concept/gs/joseph-smith-jr")
};


declare %test:case function getTriple-with-just-addtionalQuery()
{
  let $test := 
    semantics:getTriple(
      (),
      (),
      (),
      ("/"),
      cts:word-query("love")
  )
  return assert:not-empty($test)
};



declare %test:case function getTriple-objectWithlang()
{
  let $object := <sem:object xml:lang="eng" xmlns:sem="http://marklogic.com/semantics">This book is the second of a two-part work written by Luke to Theophilus. The first part is known as the Gospel According to Luke.  record some of the major missionary activities of the Twelve Apostles under the direction of Peter immediately following the Savior’s death and resurrection.  outline some of the Apostle Paul’s travels and missionary work.</sem:object>
  let $test := 
    semantics:getTriple(
      "http://www.lds.org/concept/gs/acts-of-the-apostles",
      "http://www.w3.org/2004/02/skos/core#definition",
      $object,
      ("/"),
      cts:word-query("Luke")
  )
  return assert:empty($test, "marklogic doesnt allow you to get triples from cts:triple with langs")
};

declare %test:case function getTriple-wordQuery()
{
  let $expected := <sem:object xml:lang="eng" xmlns:sem="http://marklogic.com/semantics">This book is the second of a two-part work written by Luke to Theophilus. The first part is known as the Gospel According to Luke.  record some of the major missionary activities of the Twelve Apostles under the direction of Peter immediately following the Savior’s death and resurrection.  outline some of the Apostle Paul’s travels and missionary work.</sem:object>
  let $test := 
    semantics:getTriple(
      "http://www.lds.org/concept/gs/acts-of-the-apostles",
      "http://www.w3.org/2004/02/skos/core#definition",
      (),
      ("/"),
      cts:word-query("Luke")
  )
  return assert:equal($test/sem:object, $expected)
};

declare %test:case function getTriple-partWithIRIDataType()
{
  let $expected :=
    <sem:triple xmlns:sem="http://marklogic.com/semantics">
      <sem:subject>http://www.lds.org/concept/cpg/agency</sem:subject>
      <sem:predicate>http://www.w3.org/2004/02/skos/core#inScheme</sem:predicate>
      <sem:object datatype="sem:iri">http://www.lds.org/concept-scheme/curriculum-planning-guide</sem:object>
    </sem:triple>
  let $actual := 
    semantics:getTriple(
      "http://www.lds.org/concept/cpg/agency",
      "http://www.w3.org/2004/02/skos/core#inScheme",
      "http://www.lds.org/concept-scheme/curriculum-planning-guide",
      "/"
    )
  return assert:equal($actual, $expected)
};

declare %test:case function getTriple-aPartAsEmptyString()
{
  let $actual := 
    semantics:getTriple(
      "",
      "http://www.w3.org/2004/02/skos/core#inScheme",
      "http://www.lds.org/concept-scheme/curriculum-planning-guide",
      "/"
    )
  return assert:empty($actual)
};

declare %test:case function getTripleByPredicateDirectioryWord-noArgsEmpty()
{
  let $predicates := 
  (
      "http://www.w3.org/2004/02/skos/core#prefLabel", 
      "http://www.w3.org/2004/02/skos/core#hiddenLabel", 
      "http://www.lds.org/core#doctrinalStatement"
  )
  let $actual := 
    semantics:getTripleByPredicateDirectioryWord($predicates,'/',"love")
  return assert:not-empty($actual)
};

declare %test:case function getTripleByPredicateDirectioryWord-callWithWordAsEmptyString()
{
  let $predicates := 
  (
      "http://www.w3.org/2004/02/skos/core#prefLabel", 
      "http://www.w3.org/2004/02/skos/core#hiddenLabel", 
      "http://www.lds.org/core#doctrinalStatement"
  )
  let $actual := 
    semantics:getTripleByPredicateDirectioryWord($predicates,'/',"")
  return assert:empty($actual)
};


declare %test:case function get-label-simpleString()
{
  let $label := semantics:get-label("http://www.w3.org/2004/02/skos/core#related")
  return assert:equal($label, "Related")
};

declare %test:case function get-label-simpleStringWithUnknowLabel()
{
  let $label := semantics:get-label("http://www.lds.org/core#partOfSpeech")
  return assert:empty($label)
};
declare %test:case function get-label-withEmptySequence()
{
  let $label := semantics:get-label(())
  return assert:equal($label, ())
};

declare %test:case function get-scheme-withEmptySequence()
{
  let $scheme := semantics:get-scheme(())
  return assert:equal($scheme, ())
};

declare %test:case function get-scheme-simpleString()
{
  let $scheme := semantics:get-scheme("http://www.lds.org/concept/cpg/attributes-of-successful-families")
  return assert:equal($scheme, "Attributes of successful families")
};

declare %test:case function get-scheme-datatypeIri()
{
  let $object := <sem:object datatype="sem:iri">http://www.lds.org/concept/cpg/home-and-family</sem:object>
  let $scheme := semantics:get-scheme($object/xs:string(.))
  return assert:equal($scheme, "Home and Family")
};

declare %test:case function get-scheme-langString()
{
  let $object := <sem:object xml:lang="eng" datatype="xsd:string">male</sem:object>
  let $scheme := semantics:get-scheme($object/xs:string(.))
  return assert:empty($scheme)
};

declare %test:case function get-rel-count-predicateInCoreSEMRELS()
{
  let $expected := 2
  let $actual := semantics:get-rel-count("http://www.lds.org/concept/gs/nehor","http://www.w3.org/2004/02/skos/core#semanticRelation")
  return assert:equal($actual, $expected)
};

declare %test:case function get-rel-count-predicateNotInCoreSEMRELS()
{
  let $expected := 0
  let $actual := semantics:get-rel-count("http://www.lds.org/concept/gs/nehor","http://www.lds.org/core#instanceOf")
  return assert:equal($actual, $expected)
};

declare %test:case function get-predicates-list()
{
  let $actual := semantics:get-predicates-list()
  return assert:not-empty($actual)
};

declare %test:case function get-classes-list()
{
  let $actual := semantics:get-classes-list()
  return assert:not-empty($actual)
};

declare %test:case function get-schemes-list() 
{
  let $actual := semantics:get-schemes-list() 
  return assert:not-empty($actual)
};

declare %test:case function get-prefixes-list()
{
  let $actual := semantics:get-prefixes-list()
  return assert:not-empty($actual)
};

declare %test:case function getObjectBySubjectPredicateDirectiory-subjectAsADefinition()
{
  let $subject := "(a Greek word) and (a Hebrew word) mean “the anointed.” Jesus Christ is the Firstborn of the Father in the spirit (; ). He is the Only Begotten of the Father in the flesh (; ). He is Jehovah () and was foreordained to his great calling before the creation of the world. Under the direction of the Father, Jesus created the earth and everything on it (; ). He was born to Mary at Bethlehem, lived a sinless life, and made a perfect atonement for the sins of all mankind by shedding of his blood and giving his life on the cross (; ; ; ). He rose from the dead, thus assuring the eventual resurrection of all mankind. Through Jesus’ atonement and resurrection, those who repent of their sins and obey God’s commandments can live eternally with Jesus and the Father (; ; )."
  let $actual := semantics:getObjectBySubjectPredicateDirectiory($subject, "http://www.w3.org/2004/02/skos/core#inScheme", "/")
  return assert:empty($actual)
};

declare %test:case function transitive-closure()
{
  let $subjectIRI := "http://www.lds.org/concept/gs/smith-joseph-jr"
  let $targetIRI := "http://www.lds.org/concept/gs/joseph-smith-jr"
  let $map := semantics:transitive-closure(sem:iri($subjectIRI), sem:iri("http://www.w3.org/2004/02/skos/core#related"), 99) ! map:get(., $targetIRI)
                
  return assert:equal($map, "http://www.lds.org/concept/gs/love")
};