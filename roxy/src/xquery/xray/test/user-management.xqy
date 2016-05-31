xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare %test:case function editor-user-has-edit-privileges()
{
  let $test := 
    try {
      xdmp:eval(
        '
          let $test :=
            xdmp:security-assert("' || $core:applicationURI || 'editor", "execute")
          return fn:true()', 
        (),
        <options xmlns="xdmp:eval">
          <user-id>{xdmp:user("editor")}</user-id>
        </options>
      )
    } catch ($e) {
      fn:false()
    }
   return assert:true($test)
};

declare %test:case function viewer-user-does-not-have-edit-privileges()
{
  let $user := $core:applicationConfig/name/text() ||  "-user"
  let $test := 
   try {
      xdmp:eval(
        '
          let $test :=
            xdmp:security-assert("' || $core:applicationURI || 'editor", "execute")
          return fn:true()', 
        (),
        <options xmlns="xdmp:eval">
          <user-id>{xdmp:user($user)}</user-id>
        </options>
      )
    } catch ($e) {
      fn:false()
    }
   return assert:false($test)
};