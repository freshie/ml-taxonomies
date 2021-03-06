module namespace display = "org.lds.gte.core-display-functions";

import module namespace core = "org.lds.gte.core-functions" at "/core/functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

declare function display:menu-main(
    $active as xs:string
) as element (ul)* {
    let $left :=
        <ul class="nav navbar-nav">
        {
        for $menu-item in core:getMenuItem("left")
        let $sub-items := $menu-item/menu-items
        let $menuRoles := $menu-item/roles/xs:string(.)
        return
            if ( core:has-role( $core:roles, $menuRoles ) )
                then
                    if ( $sub-items )
                        then
                            let $class := 
                                if ($menu-item/label/xs:string(.) eq $active)
                                then ("active")
                                else ()
                            return 
                            <li class="dropdown">
                                <a href="{ $core:siteRootURL || $menu-item/url/xs:string(.) }" class="dropdown-toggle {$class}" data-toggle="dropdown">{ $menu-item/label/xs:string(.) } <b class="caret"></b></a>
                                <ul class="dropdown-menu">
                                {
                                for $sub-item in $sub-items/menu-item
                                return
                                    <li><a href="{$core:siteRootURL || $sub-item/url/xs:string(.) }">{ $sub-item/label/xs:string(.) }</a></li>
                                }
                              </ul>
                            </li>
                        else
                    if ( $menu-item/label/xs:string(.) = $active )
                        then <li class="active"><a href="{$core:siteRootURL || $menu-item/url/xs:string(.) }">{ $menu-item/label/xs:string(.) }</a></li>
                        else <li><a href="{$core:siteRootURL || $menu-item/url/xs:string(.) }">{ $menu-item/label/xs:string(.) }</a></li>
                else ()
        }
            <li>
                <form action="{$core:siteRootURL}search/" method="get" class="navbar-form">
                     <div class="scrollable-dropdown-menu">
                        <input type="text" name="keywords" value="" placeholder="QuickSearch" class="form-control typeahead"/>
                        <button class="hide" type="submit">Quick Search</button>
                    </div>
                </form>
            </li>
        </ul>
    let $right :=
        <ul class="nav navbar-nav pull-right">
        {
        for $menu-item in core:getMenuItem("right")
        let $sub-items := $menu-item/menu-items
        let $menuRoles := $menu-item/roles/xs:string(.)
        return
            if ( core:has-role( $core:roles, $menuRoles ) )
                then
                    if ( $sub-items )
                        then
                            <li class="dropdown">
                                <a href="{$core:siteRootURL || $menu-item/url/xs:string(.)}" class="dropdown-toggle" data-toggle="dropdown">{ $menu-item/label/xs:string(.)} <b class="caret"></b></a>
                                <ul class="dropdown-menu">
                                {
                                for $sub-item in $sub-items/menu-item
                                return
                                    <li><a href="{$core:siteRootURL || $sub-item/url/xs:string(.)}">{ $sub-item/label/xs:string(.)}</a></li>
                                }
                              </ul>
                            </li>
                        else
                    if ( $menu-item/label/xs:string(.)= $active )
                        then <li class="active"><a href="{$core:siteRootURL || $menu-item/url/xs:string(.)}">{ $menu-item/label/xs:string(.)}</a></li>
                        else <li><a href="{$core:siteRootURL || $menu-item/url/xs:string(.)}">{ $menu-item/label/xs:string(.)}</a></li>
                else ()
        }
        {
        if ( $core:user eq "public" )
            then
                <li><a href="{$core:siteRootURL}sign-in.xqy">Sign in</a></li>
            else
                <li class="dropdown">
                    <a href="{$core:siteRootURL}sign-in.xqy?logout=true" class="dropdown-toggle" data-toggle="dropdown">{ $core:user } <b class="caret"></b></a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="{$core:siteRootURL}sign-in.xqy?logout=true">Sign out</a>
                        </li>
                    </ul>
                </li>
        }
        </ul>
    return ($left,$right)
};

declare function display:nav(
    $activePage as xs:string
) as element (nav){
    <nav class="navbar navbar-default " role="navigation">
            <div class="container-fluid">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="{$core:siteRootURL}default.xqy">{$core:taxonomy-title}</a>
                </div>
                <div class="collapse navbar-collapse" id="navbar-collapse">
                { display:menu-main($activePage) }
                </div><!--/.nav-collapse -->
            </div>
    </nav> 
};

declare function display:head(
    $pageTitleIn as xs:string?
) as element (head){
    let $pageTitle := 
        if (fn:empty($pageTitleIn)) 
        then () 
        else ": " || $pageTitleIn
    return
        <head>
            <meta charset="utf-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta name="description" content=""/>
            <meta name="author" content=""/>

            <title>{$core:taxonomy-title || $pageTitle}</title>

            <!-- Latest compiled and minified CSS -->
            <link href="{$core:cdnURL}bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
            <link href="{$core:cdnURL}css/main.css" rel="stylesheet"/>
            
        </head>
};

declare function display:bottomIncludes() {
    <script type="text/javascript">
      var GTE = {{}};
    </script>,
    <script src="{$core:cdnURL}js/jquery.js"></script>,
    <script src="{$core:cdnURL}bootstrap/js/bootstrap.min.js"></script>,
    <script type="text/javascript" src="{$core:cdnURL}js/typeahead.bundle.js"></script>,
    <script src="{$core:cdnURL}js/main.js"></script>
};