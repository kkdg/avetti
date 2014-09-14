Current eCommerce application supports multiple solr cores.

for more information on solr multiCore see: 

http://wiki.apache.org/solr/MultipleIndexes
http://wiki.apache.org/solr/CoreAdmin

Two cores are currently in use by eCommerce:   
items-core  - holds information about items and item's properties.
categories-core  - holds information about categories and category's properties


 To use separate solr cores with eCommerce application  you have to copy from svn:

 - categories-core dir
 - items-core dir
 - solr.xml file

 into your $SOLR_HOME directory.


 Next you must copy your old config files (stopwords.txt,protwords.txt and synonyms.txt)
 to the $SOLR_HOME/items-core/conf directory.
 
 Next you have to rebuild application.
 
 If you want to change solr core names, you have to:

 - rename directories items-core and(or) categories-core
 - edit file $SOLR_HOME/solr.xml to set there new core names
 - add next lines to you maven profile:
 
   <commerce.defaultsolrcorename>items-core</commerce.defaultsolrcorename>
   <commerce.itemssolrcore>items-core</commerce.itemssolrcore>
   <commerce.categorysolrcorename>categories-core</commerce.categorysolrcorename>
  
   and set there new core names.