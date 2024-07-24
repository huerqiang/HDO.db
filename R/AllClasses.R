HDODb <- setRefClass("HDODb", contains="AnnotationDb")
.keys <- getFromNamespace(".keys", "AnnotationDbi")
.cols <- getFromNamespace(".cols", "AnnotationDbi")
smartKeys <- getFromNamespace("smartKeys", "AnnotationDbi")

.queryForKeys <- getFromNamespace(".queryForKeys", "AnnotationDbi")
dbQuery <- getFromNamespace("dbQuery", "AnnotationDbi")


setMethod("keys", "HDODb",
    function(x, keytype, ...){
        if(missing(keytype)) keytype <- "doid"
        if (keytype == "gene") {
            return(unique(toTable(HDOGENE)[, keytype]))
        } else {
            return(unique(toTable(HDOTERM)[, keytype]))
        }
    }
)



setMethod("keytypes", "HDODb",
    function(x) {
        c("doid", "term", "gene")
    }

)


# # sqls <- "SELECT name FROM sqlite_master WHERE type='table' order by name"
# # tables <- AnnotationDbi:::dbQuery(dbconn(x), sqls)
# sqls <- "select * from sqlite_master"
# tables <- AnnotationDbi:::dbQuery(dbconn(x), sqls)
# left <- right <- rep(0, nrow(tables))
# for (i in seq_len(length(left))) {
#   sql2 <- paste("PRAGMA table_info(", tables[i, 2], ")")
#   res <- AnnotationDbi:::dbQuery(dbconn(x), sql2)
#   left[i] <- res[1,2]
#   right[i] <- res[2,2]
# }
# tables$left <- left
# tables$right <- right

# tables <- rbind(c("do_parents", "doid ", "parent"),
#                 c("do_term ", "doid", "term"),
#                 c("do_alias", "doid", "alias"),
#                 c("do_synonym", "doid", "synonym"),
#                 c("do_children", "doid", "children"),
#                 c("do_ancestor", "doid", "ancestor"),
#                 c("do_offspring", "doid", "offspring"))
# colnames(tables) <- c("name", "left", "right")
# setMethod("select", "HDODb",
#     function(x, keys, columns, keytype, ...){
#         if (missing(keytype)) keytype <- "doid"
#         keytype <- match.arg(keytype, c("doid","term"))
#         ## 获取doid
#         strKeys <- paste0("\"", keys, "\"", collapse = ",")
#         if (keytype == "term") {
#             sql_key <- paste("SELECT doid FROM do_term WHERE term in (",
#                 strKeys, ")")
#             doids <- dbQuery(dbconn(x), sql_key)[, 1]
#             strKeys <- paste0("\"", doids, "\"", collapse = ",")
#         }
#         columns <- unique(c("doid", columns))

#         sqls <- paste("SELECT ", paste(columns, collapse = ","),
#             " FROM do_term")
#         columns2 <- setdiff(columns, c("doid", "term"))
#         for (col in columns2) {
#             leftJoin <- paste0("LEFT JOIN  ", paste0("do_",col,
#                 " USING (doid)"))
#             sqls <- c(sqls, leftJoin)
#         }
#         sqls <- c(sqls, paste0("WHERE do_term.doid in (", strKeys, ")"))
#         sqls <- paste(sqls, collapse = " ")
#         res <- dbQuery(dbconn(x), sqls)
#         res
#     }
# )

setMethod("select", "HDODb",
    function(x, keys, columns, keytype = "doid", ...){
        if (missing(keytype)) keytype <- "doid"
        keytype <- match.arg(keytype, c("doid","term", "gene"))
        strKeys <- paste0("\"", keys, "\"", collapse = ",")

        columns <- unique(c(keytype, columns))
        if (length(setdiff(columns, c("gene", "ncg"))) > 0) {
            columns <- unique(c("doid", columns))
        }
        if (keytype == "gene") {
            columns2 <- setdiff(columns, c("gene", "ncg"))
            if (length(columns2) > 0) {
                sqls <- paste("SELECT ", paste(columns, collapse = ","),
                    " FROM do_gene")
                if ("ncg" %in% columns) {
                    leftJoin <- "LEFT JOIN  gene_ncg USING (gene)"
                    sqls <- c(sqls, leftJoin)
                }
                columns3 <- setdiff(columns, c("gene", "doid", "ncg"))
                for (col in columns3) {
                    leftJoin <- paste0("LEFT JOIN  ", paste0("do_",col,
                        " USING (doid)"))
                    sqls <- c(sqls, leftJoin)
                }
                sqls <- c(sqls, paste0("WHERE do_gene.gene in (", strKeys, ")"))
            } else {
                sqls <- paste("SELECT ", paste(columns, collapse = ","),
                    " FROM gene_ncg")
                sqls <- c(sqls, paste0("WHERE gene_ncg.gene in (", strKeys, ")"))
            }
        }
        if (keytype == "term") {
            sqls <- paste("SELECT ", paste(columns, collapse = ","),
                " FROM do_term")
            columns2 <- setdiff(columns, c("term", "doid"))
            if (length(columns2) > 0) {
                for (col in columns2) {
                    leftJoin <- paste0("LEFT JOIN  ", paste0("do_",col,
                        " USING (doid)"))
                    sqls <- c(sqls, leftJoin)
                }
            }
            sqls <- c(sqls,
                    paste0("WHERE do_term.term in (", strKeys, ")"))
        }

        if (keytype == "doid") {
            sqls <- paste("SELECT ", paste(columns, collapse = ","),
                " FROM do_term")
            columns2 <- setdiff(columns, c("doid", "term"))
            if (length(columns2) > 0) {
                for (col in columns2) {
                    leftJoin <- paste0("LEFT JOIN  ", paste0("do_",col,
                        " USING (doid)"))
                    sqls <- c(sqls, leftJoin)
                }
            }
            sqls <- c(sqls,
                    paste0("WHERE do_term.doid in (", strKeys, ")"))
        }
        sqls <- paste(sqls, collapse = " ")
        # res <- dbQuery(dbconn(x), sqls)
        res <- DBI::dbGetQuery(dbconn(x), sqls)
        return(res)
    }
)

setMethod("columns", "HDODb",
    function(x) {
        c("doid","term", "alias", "synonym", "parent", "children",
            "ancestor", "offspring", "gene", "ncg")
    }
)
