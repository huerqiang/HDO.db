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


## DOOFFSPRING
HDOOFFSPRING <- HDOANCESTOR[, c(2, 1)]
colnames(HDOOFFSPRING) <- c("doid", "offspring")
dbWriteTable(conn = db, "do_offspring", HDOOFFSPRING, row.names=FALSE)

## gene2DO
# old DISEASE-ALLIANCE_HUMAN.tsv.gz download from https://github.com/DiseaseOntology/HumanDiseaseOntology
# new DISEASE-ALLIANCE_HUMAN.tsv.gz download from https://fms.alliancegenome.org/download/DISEASE-ALLIANCE_HUMAN.tsv.gz
library(data.table)
anno <- fread("DISEASE-ALLIANCE_HUMAN.tsv.gz")[, c("DBObjectSymbol", "DOID")]
class(anno) <- "data.frame"
library(clusterProfiler)
library(org.Hs.eg.db)
anno_bitr <- bitr(anno[, 1], "SYMBOL", "ENTREZID", OrgDb = org.Hs.eg.db)
anno_bitr <- anno_bitr[!duplicated(anno_bitr[, 1]), ]
rownames(anno_bitr) <- anno_bitr[, 1]
anno[, 1] <- anno_bitr[anno[, 1], 2]
anno <- anno[!is.na(anno[, 1]), ]
colnames(anno) <- c("gene", "doid")
## add old data
load("olddata\\DO2EG.rda")
anno_old <- stack(DO2EG)
colnames(anno_old) <- c("gene", "doid")
anno <- rbind(anno, anno_old)
anno <- unique(anno)
HDOGENE <- anno[, c(2, 1)]
dbWriteTable(conn = db, "do_gene", HDOGENE, row.names=FALSE)
## gene2DGN
# download from https://www.disgenet.org/downloads
# 1. ALL gene-disease associations
# 2. ALL variant-disease associations
# x <- read.delim("all_gene_disease_associations.tsv", comment.char="#", stringsAsFactor=F, encoding = "latin1")
# DGNNAME1 <- unique(x[, c("diseaseId", "diseaseName")])
# DGNGENE <- unique(x[, c("diseaseId", "geneId")])

# y <- read.delim("all_variant_disease_associations.tsv", comment.char="#", stringsAsFactor=F)
# DGNNAME2 <- unique(y[, c("diseaseId", "diseaseName")])
# DGNNAME <- rbind(DGNNAME1, DGNNAME2) |> unique()
# DGNSNP <- unique(y[, c("diseaseId", "snpId")])
# colnames(DGNNAME) <- c("dgn", "name")
# colnames(DGNGENE) <- c("dgn", "gene")
# colnames(DGNSNP) <- c("dgn", "snp")
# dbWriteTable(conn = db, "dgn_name", DGNNAME, row.names=FALSE)
# dbWriteTable(conn = db, "dgn_gene", DGNGENE, row.names=FALSE)
# dbWriteTable(conn = db, "dgn_snp", DGNSNP, row.names=FALSE)
## gene2NCG
# download from http://ncg.kcl.ac.uk/download.php
# NCG 6.0: All cancer genes -> •List of 2372 cancer genes and supporting literature
# NCG 7.0: List of all 3347 cancer drivers and their annotation and supporting evidence
x=read.delim("NCG_cancerdrivers_annotation_supporting_evidence.tsv", stringsAsFactor=F, encoding = "latin1")
y=read.delim("NCG_healthydrivers_annotation_supporting_evidence.tsv", stringsAsFactor=F, encoding = "latin1")
path2gene1 <- x[, c("cancer_type", "entrez")]
path2gene2 <- y[, c("tissue_type", "entrez")]
colnames(path2gene1) <- colnames(path2gene2) <- c("ncg", "gene")
NCGGENE <- rbind(path2gene1, path2gene2)
NCGGENE <- NCGGENE[NCGGENE[, 1] != "", ]
HDOGENENCG <- NCGGENE[, c(2, 1)]
dbWriteTable(conn = db, "gene_ncg", HDOGENENCG, row.names=FALSE)

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



map.counts <- rbind(c("TERM", nrow(HDOTERM)),
        c("CHILDREN", nrow(HDOCHILDREN)),
        c("PARENTS", nrow(HDOPARENTS)),
        c("ANCESTOR", nrow(HDOANCESTOR)),
        c("OFFSPRING", nrow(HDOOFFSPRING)),
        c("HDOGENE", nrow(HDOGENE)),
        # c("DGNNAME", nrow(DGNNAME)),
        # c("DGNGENE", nrow(DGNGENE)),
        # c("DGNSNP", nrow(DGNSNP)),
        c("HDOGENENCG", nrow(HDOGENENCG)))


map.counts <- as.data.frame(map.counts)
colnames(map.counts) <- c("map_name","count")
# dbWriteTable(conn = db, "map.counts", map.counts, row.names=FALSE)
dbWriteTable(conn = db, "map_counts", map.counts, row.names=FALSE, overwrite = TRUE)

dbListTables(db)
dbListFields(conn = db, "metadata")
dbReadTable(conn = db,"metadata")


map.metadata <- rbind(c("TERM", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20240723"),
            c("CHILDREN", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20240723"),
            c("PARENTS", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20240723"),
            c("ANCESTOR", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20240723"),
            c("OFFSPRING", "Disease Ontology", "https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo","20240723"),
            c("GENE", "alliancegenome", "https://fms.alliancegenome.org/download/DISEASE-ALLIANCE_HUMAN.tsv.gz","20240723"),        
            # c("DGN", "DGN", "https://www.disgenet.org/downloads","20200409"),
            c("NCG", "NCG", "http://ncg.kcl.ac.uk/download.php","20240723")
            )	
map.metadata <- as.data.frame(map.metadata)
colnames(map.metadata) <- c("map_name","source_name","source_url","source_date")
dbWriteTable(conn = db, "map_metadata", map.metadata, row.names=FALSE, overwrite = TRUE)


dbListTables(db)
dbListFields(conn = db, "map_metadata")
dbReadTable(conn = db,"map_metadata")
dbDisconnect(db)

