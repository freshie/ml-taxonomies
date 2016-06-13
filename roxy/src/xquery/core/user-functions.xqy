module namespace user = "org.lds.gte.core-user-functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare variable $user := user:get-current-user();
declare variable $privileges := user:get-current-user-privileges();

declare function user:isEditor() as xs:boolean {
  xdmp:has-privilege($core:applicationURI || "editor", "execute")
};

declare function user:get-current-user() as xs:string {
    let $user := fn:substring-after(xdmp:get-current-user(), $core:applicationConfig/name/text() || "-")
    return 
        if (fn:empty($user) or $user eq "") then ("public") else ($user)
};

declare function user:get-current-user-privileges() as xs:string*{
    let $privileges :=  xdmp:eval(
        '
            import module namespace sec="http://marklogic.com/xdmp/security" at "/MarkLogic/security.xqy";
            declare variable $user as xs:string external;
            sec:user-privileges( $user ) 
        ', 
        (xs:QName( "user" ), $core:applicationConfig/name/text() || "-" || $user), 
        <options xmlns="xdmp:eval">
            <database>{ xdmp:security-database() }</database>
        </options> 
    )
    return $privileges ! ./sec:action[fn:starts-with(. ,$core:applicationURI)]/text() ! fn:substring-after(., $core:applicationURI)
};

declare function user:assertPrivilege(
    $privilege as xs:string
) as item()* {
  xdmp:security-assert($core:applicationURI || "editor", "execute")
};