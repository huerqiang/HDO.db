# setwd("E:\\enrichplot_export\\DOSE数据更新\\create_dodb\\2022_7_15数据更新")
setwd("E:\\enrichplot_export\\DOSE数据更新\\create_dodb\\2024_7_23数据更新")
packagedir <- getwd()
sqlite_path <- paste(packagedir, sep=.Platform$file.sep, "inst", "extdata")
if(!dir.exists(sqlite_path)){dir.create(sqlite_path,recursive = TRUE)}
dbfile <- file.path(sqlite_path, "HDO.sqlite")
unlink(dbfile)

###################################################
### create database
###################################################
## Create the database file
library(RSQLite)
drv <- dbDriver("SQLite")
db <- dbConnect(drv, dbname=dbfile)
## dbDisconnect(db)
# ontologyIndex::get_ontology
obo <- ontologyIndex::get_ontology("HumanDO.obo", extract_tags = "everything")
## HDOTERM
HDOTERM <- data.frame(doid = names(obo$name), term = obo$name)
# 筛选掉is_obsolete
not_obsolete <- names(obo$obsolete)[obo$obsolete == FALSE] |> intersect(HDOTERM$doid)
# just keep DO:
not_obsolete <- grep("^DOID:", not_obsolete, value = TRUE)
HDOTERM <- HDOTERM[not_obsolete, ]
colnames(HDOTERM) <- c("doid", "term")
dbWriteTable(conn = db, "do_term", HDOTERM, row.names=FALSE, overwrite = TRUE)

## ALIAS 
# 跟gcy相比，我这个删去了NA，最后看看行不行
ALIAS <- stack(obo$alt_id)[, c(2, 1)]
colnames(ALIAS) <- c("doid", "alias")
dbWriteTable(conn = db, "do_alias", ALIAS, row.names=FALSE, overwrite = TRUE)

## SYNONYM
SYNONYM <- stack(obo$synonym)[, c(2, 1)]
colnames(SYNONYM) <- c("doid", "synonym")
dbWriteTable(conn = db, "do_synonym", SYNONYM, row.names=FALSE, overwrite = TRUE)

## DOPARENTS
HDOPARENTS <- stack(obo$parents)[, c(2, 1)]
colnames(HDOPARENTS) <- c("doid", "parent")
dbWriteTable(conn = db, "do_parent", HDOPARENTS, row.names=FALSE)


## DOCHILDREN
HDOCHILDREN <- stack(obo$children)[, c(2, 1)]
colnames(HDOCHILDREN) <- c("doid", "children")
dbWriteTable(conn = db, "do_children", HDOCHILDREN, row.names=FALSE)

## DOANCESTOR
HDOANCESTOR <- stack(obo$ancestors)[, c(2, 1)]
HDOANCESTOR <- HDOANCESTOR[HDOANCESTOR[, 1] != HDOANCESTOR[, 2], ]
colnames(HDOANCESTOR) <- c("doid", "ancestor")
dbWriteTable(conn = db, "do_ancestor", HDOANCESTOR, row.names=FALSE)


# DOOFFSPRING
HDOOFFSPRING <- HDOANCESTOR[, c(2, 1)]
colnames(HDOOFFSPRING) <- c("doid", "offspring")
dbWriteTable(conn = db, "do_offspring", HDOOFFSPRING, row.names=FALSE)

metadata <-rbind(c("DBSCHEMA","HDO_DB"),
        c("DBSCHEMAVERSION","1.0"),
        c("HDOSOURCENAME","Disease Ontology"),
        c("HDOSOURCURL","https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo"),
        c("HDOSOURCEDATE","20240723"),
        c("Db type", "HDODb"))
        #c("DOVERSION","2806"))	

metadata <- as.data.frame(metadata)
colnames(metadata) <- c("name", "value") 
dbWriteTable(conn = db, "metadata", metadata, row.names=FALSE, overwrite = TRUE)



map.counts<-rbind(c("TERM", nrow(HDOTERM)),
        # c("OBSOLETE","$obsolete_counts"),
        c("CHILDREN", nrow(HDOCHILDREN)),
        c("PARENTS", nrow(HDOPARENTS)),
        c("ANCESTOR", nrow(HDOANCESTOR)),
        c("OFFSPRING", nrow(HDOOFFSPRING)))


map.counts <- as.data.frame(map.counts)
colnames(map.counts) <- c("map_name","count")
# dbWriteTable(conn = db, "map.counts", map.counts, row.names=FALSE)
dbWriteTable(conn = db, "map_counts", map.counts, row.names=FALSE, overwrite = TRUE)

dbListTables(db)
dbListFields(conn = db, "metadata")
dbReadTable(conn = db,"metadata")


map.metadata <- rbind(c("TERM", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"),
            # c("OBSOLETE", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"),
            c("CHILDREN", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"),
            c("PARENTS", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"),
            c("ANCESTOR", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"),
            c("OFFSPRING", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20220706"))	
map.metadata <- as.data.frame(map.metadata)
colnames(map.metadata) <- c("map_name","source_name","source_url","source_date")
dbWriteTable(conn = db, "map_metadata", map.metadata, row.names=FALSE, overwrite = TRUE)


dbListTables(db)
dbListFields(conn = db, "map_metadata")
dbReadTable(conn = db,"map_metadata")
dbDisconnect(db)

