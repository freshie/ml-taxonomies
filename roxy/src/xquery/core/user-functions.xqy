module namespace user = "org.lds.gte.core-user-functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare function user:isEditor() as xs:boolean {
  xdmp:has-privilege($core:applicationURI || "editor", "execute")
};

