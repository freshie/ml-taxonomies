xquery version "1.0-ml";

module namespace test = "http://github.com/robwhitby/xray/test";

import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";
import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";
import module namespace user = "org.lds.gte.core-user-functions" at "/core/user-functions.xqy";

declare %test:case function editor-user-has-edit-privileges()
{
  let $user := $core:applicationConfig/name/text() || "-editor"
  
  let $login := xdmp:login($user)
  
  let $test := xdmp:has-privilege($core:applicationURI || "editor", "execute")
  
  return assert:true($test)
};

declare %test:case function viewer-user-does-not-have-edit-privileges()
{
  let $user := $core:applicationConfig/name/text() ||  "-public"
  
  let $login := xdmp:login($user)

  let $test := xdmp:has-privilege($core:applicationURI || "editor", "execute")
     
  return assert:false($test)
};

declare %test:case function isEditor-true-case()
{
  let $user := $core:applicationConfig/name/text() || "-editor"
  
  let $login := xdmp:login($user)
  
  let $test := user:isEditor()
  
  return assert:true($test)
};

declare %test:case function isEditor-false-case()
{
  let $user := $core:applicationConfig/name/text() ||  "-public"
  
  let $login := xdmp:login($user )
  
  let $test := user:isEditor()
   
  return assert:false($test)
};

declare %test:case function get-current-user-public()
{
  let $user := $core:applicationConfig/name/text() ||  "-public"

  let $login := xdmp:login($user)

  let $test := user:get-current-user() 

  return assert:equal($test, "public")
};

declare %test:case function get-current-user-editor()
{
  let $user := $core:applicationConfig/name/text() ||  "-editor"

  let $login := xdmp:login($user)

  let $test := user:get-current-user() 

  return assert:equal($test, "editor")
};