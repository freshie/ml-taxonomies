# ml-taxonomies
A simple tool for managing taxonomies in marklogic

This project started as the Gospel topical explorer (GTE) which went into the GTE v2.0 (https://www.lds.org/gte20/) and is now being worked in a more generic taxonomy manager. The goal of this project is to showcase what improvements can be gained from having a taxonomy with your content. Since MarkLogic version 7 you can have both a triple store and a document store in the same database. This project is mostly focusing on the triple store but shows how those triples will help improve the discovery and enrichment of content.


## Requirements
* Marklogic version 7.0+ 
* [Roxy](https://github.com/freshie/ml-taxonomies/blob/master/roxy/README.mdown#requirements) requirments 

## Installing
This section describes the steps needed to install this project and get it running.

This appliaction uses roxy for its deployer. First you'll want to check the confiurations. Then do a roxy boostrap a modules deploy and finally a content deploy. Onces all that is finished and you have changed the default port you can open up a broswer and go to http://localhost:9679 and start using the application. 

### Configure your application
This application uses roxy so if you want to change any of the default settings edit the local-config.properties file.
Some of the settings you might want to change are the user and password. Its setup to use admin/admin.
Another setting might be the application ports those can also be foudn in the local-config.properties file.
```

#
# Admin username/password that will exist on the local/dev/prod servers
#
user=admin
password=admin

#
# The ports used by your application
#
app-port=9679

#
# the xcc server is used for push the content
#
xcc-port=9678

```

### Configure MarkLogic Server
Since we are using roxy framework for our deployer you'll just have to run the roxy commands for deploying, see below.

1. Open a command prompt in the root folder of Roxy.  
 `$ ml local bootstrap`
2. If the roxy deploy scripts say a restart is required then you'll have to restart. Use this command to restart.  
  `$ ml local restart`

### Deploying Code
*This step describes how to deploy your Roxy application into your MarkLogic Server modules database.*

1. Open a command prompt in the root folder of Roxy
	`$ ml local deploy modules`

### Deploying content
*This step describes how to deploy your content to the MarkLogic Server content database.*

1. Open a command prompt in the root folder of Roxy
	`$ ml local deploy content`
