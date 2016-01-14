import module namespace core = "org.lds.gte.core-functions" at "/sem/lib/core-functions.xqy";

declare namespace sem = "http://marklogic.com/semantics";

for $triples in (xdmp:directory( "http://lds.org/sem/taxonomies/doctrine/", "infinity" )//sem:triples)[1]
let $prefLabel := fn:normalize-space( $triples/sem:triple[sem:predicate = "http://www.w3.org/2004/02/skos/core#prefLabel"]/sem:object/string() )
let $uri := fn:concat( "https://api.silkapp.com/v1.4.0/site/uri/doctrine-test.silkapp.com/page/", $prefLabel )
let $article :=
    <article>
        <section class="body">
            <div class="layout meta"> <!-- left column -->
                <div class="block header text" data-component-uri="http://silkapp.com/component/block/text">
                    <h1>Test</h1>
                    <p>Test Subtitle</p>
                </div>
            </div>
        
            <div class="layout content">
                <div class="block" data-component-uri="http://silkapp.com/component/block/keyvalue">
                    <div data-component-uri="http://typlab.com/2010/components/keyvalue" class="component">
                        <table>
                            <tbody>
                                <tr>
                                    <td class="key">Gender</td> <!-- example tag: gender -->
                                    <td class="value">
                                        <a data-tag-uri="http://doctrine-test.silkapp.com/tag/gender">Male</a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </section>
    </article>
let $credentials := xdmp:quote( <signin><email>shellinese@ldschurch.org</email><password>palisade07</password></signin> )
let $options :=
    <options xmlns="xdmp:http" xmlns:get="xdmp:document-get">
        <authentication method="digest">
            <username>shellinese@ldschurch.org</username>
            <password>palisade07</password>
        </authentication>
        <headers>
            <content-type>application/xml</content-type>
        </headers>
        <get:format>text</get:format>
        <data>{ $credentials }</data>
    </options>
return xdmp:http-post( "https://api.silk.co/v1.4.0/user/signin", $options )
(: return (xdmp:set-response-content-type( "application/xml" ),xdmp:http-put( $uri, $options )) :)


(:
https://api.silk.co/v1.4.0/user/signin
BAD: https://api.silkapp.com/v1.4.0/user/signin

https://doctrine.silk.co/page/Zeezrom

curl https://api.silkapp.com/v1.4.0/site/uri/yoursite.silkapp.com/page/test
  -d '<article>...</article>'
  -b 'silk_sid=...'
  -X PUT
  -H 'Content-Type: application/xml'
  
$ curl https://api.silkapp.com/v1.4.0/user/signin
  -d "<signin><email>yourEmail</email><password>yourPassword</password></signin>"
  -H "Content-Type: application/xml"
  -X POST
  -i
:)
