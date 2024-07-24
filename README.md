
<!-- README.md is generated from README.Rmd. Please edit that file -->

## :writing_hand: Authors

### Erqiang Hu

Department of Pathology, Albert Einstein College of Medicine, Bronx, NY
10461, USA.

Einstein Pathology Single-cell & Bioinformatics laboratory, Bronx, NY
10461, USA.

Montefiore Einstein Comprehensive Cancer Center, Albert Einstein College
of Medicine, Bronx, NY 10461, USA.

## Introduction

Disease Ontology (DO) was developed to create a consistent description
of gene products with disease perspectives, and is essential for
supporting functional genomics in disease context. Accurate disease
descriptions can discover new relationships between genes and disease,
and new functions for previous uncharacteried genes and alleles.We have
developed the [DOSE](https://bioconductor.org/packages/DOSE/) package
for semantic similarity analysis and disease enrichment analysis, and
`DOSE` import an Bioconductor package ‘DO.db’ to get the
relationship(such as parent and child) between DO terms. But `DO.db`
hasn’t been updated for years, and a lot of semantic information is
[missing](https://github.com/YuLab-SMU/DOSE/issues/57). So we developed
the new package `HDO.db` for Human Disease Ontology annotation.

``` r
library(HDO.db)
```

## Overview

``` r
library(AnnotationDbi)
#> 载入需要的程序包：stats4
#> 载入需要的程序包：BiocGenerics
#> 
#> 载入程序包：'BiocGenerics'
#> The following objects are masked from 'package:stats':
#> 
#>     IQR, mad, sd, var, xtabs
#> The following objects are masked from 'package:base':
#> 
#>     anyDuplicated, aperm, append, as.data.frame, basename, cbind,
#>     colnames, dirname, do.call, duplicated, eval, evalq, Filter, Find,
#>     get, grep, grepl, intersect, is.unsorted, lapply, Map, mapply,
#>     match, mget, order, paste, pmax, pmax.int, pmin, pmin.int,
#>     Position, rank, rbind, Reduce, rownames, sapply, setdiff, table,
#>     tapply, union, unique, unsplit, which.max, which.min
#> 载入需要的程序包：Biobase
#> Welcome to Bioconductor
#> 
#>     Vignettes contain introductory material; view with
#>     'browseVignettes()'. To cite Bioconductor, see
#>     'citation("Biobase")', and for packages 'citation("pkgname")'.
#> 载入需要的程序包：IRanges
#> 载入需要的程序包：S4Vectors
#> 
#> 载入程序包：'S4Vectors'
#> The following object is masked from 'package:utils':
#> 
#>     findMatches
#> The following objects are masked from 'package:base':
#> 
#>     expand.grid, I, unname
#> 
#> 载入程序包：'IRanges'
#> The following object is masked from 'package:grDevices':
#> 
#>     windows
```

The annotation data comes from
<https://github.com/DiseaseOntology/HumanDiseaseOntology/tree/main/src/ontology>,
and HDO.db provide these AnnDbBimap object:

``` r
ls("package:HDO.db")
#>  [1] "columns"      "HDO"          "HDO.db"       "HDO_dbconn"   "HDO_dbfile"  
#>  [6] "HDO_dbInfo"   "HDO_dbschema" "HDOALIAS"     "HDOANCESTOR"  "HDOCHILDREN" 
#> [11] "HDOGENE"      "HDOGENENCG"   "HDOMAPCOUNTS" "HDOmetadata"  "HDOOFFSPRING"
#> [16] "HDOPARENTS"   "HDOSYNONYM"   "HDOTERM"      "keys"         "keytypes"    
#> [21] "select"
packageVersion("HDO.db")
#> [1] '1.0.0'
```

You can use `help` function to get their documents: `help(DOOFFSPRING)`

``` r
toTable(HDOmetadata)
#>              name
#> 1        DBSCHEMA
#> 2 DBSCHEMAVERSION
#> 3   HDOSOURCENAME
#> 4     HDOSOURCURL
#> 5   HDOSOURCEDATE
#> 6         Db type
#>                                                                                        value
#> 1                                                                                     HDO_DB
#> 2                                                                                        1.0
#> 3                                                                           Disease Ontology
#> 4 https://github.com/DiseaseOntology/HumanDiseaseOntology/blob/main/src/ontology/HumanDO.obo
#> 5                                                                                   20240723
#> 6                                                                                      HDODb
HDOMAPCOUNTS
#>   HDOANCESTOR   HDOCHILDREN    HDOHDOGENE HDOHDOGENENCG  HDOOFFSPRING 
#>       "70537"       "11636"       "77019"        "8244"       "70537" 
#>    HDOPARENTS       HDOTERM 
#>       "11636"       "11598"
```

## Fetch whole DO terms

In HDO.db, `HDOTERM` represet the whole DO terms and their names. The
users can also get their aliases and synonyms from `HDOALIAS` and
`HDOSYNONYM`, respectively.

convert HDOTERM to table

``` r
doterm <- toTable(HDOTERM)
head(doterm)
#>           doid                     term
#> 1 DOID:0001816             angiosarcoma
#> 2 DOID:0002116                pterygium
#> 3 DOID:0014667    disease of metabolism
#> 4 DOID:0040001           shrimp allergy
#> 5 DOID:0040002          aspirin allergy
#> 6 DOID:0040003 benzylpenicillin allergy
```

convert HDOTERM to list

``` r
dotermlist <- as.list(HDOTERM)
head(dotermlist)
#> $`DOID:0001816`
#> [1] "angiosarcoma"
#> 
#> $`DOID:0002116`
#> [1] "pterygium"
#> 
#> $`DOID:0014667`
#> [1] "disease of metabolism"
#> 
#> $`DOID:0040001`
#> [1] "shrimp allergy"
#> 
#> $`DOID:0040002`
#> [1] "aspirin allergy"
#> 
#> $`DOID:0040003`
#> [1] "benzylpenicillin allergy"
```

get alias of `DOID:0001816`

``` r
doalias <- as.list(HDOALIAS)
doalias[['DOID:0001816']]
#> [1] "DOID:267"  "DOID:4508"
```

get synonym of `DOID:0001816`

``` r
dosynonym <- as.list(HDOSYNONYM)
dosynonym[['DOID:0001816']]
#> [1] "\"hemangiosarcoma\" EXACT []"
```

## Fetch the relationship between DO terms

Similar to `DO.db`, we provide four Bimap objects to represent
relationship between DO terms: HDOANCESTOR,HDOPARENTS,HDOOFFSPRING, and
HDOCHILDREN.

### HDOANCESTOR

HDOANCESTOR describes the association between DO terms and their
ancestral terms based on a directed acyclic graph (DAG) defined by the
Disease Ontology. We can use `toTable` function in `AnnotationDbi`
package to get a two-column data.frame: the first column means the DO
term ids, and the second column means their ancestor terms.

``` r
anc_table <- toTable(HDOANCESTOR)
head(anc_table)
#>           doid     ancestor
#> 1 DOID:0001816       DOID:4
#> 2 DOID:0001816   DOID:14566
#> 3 DOID:0001816     DOID:162
#> 4 DOID:0001816 DOID:0050686
#> 5 DOID:0001816     DOID:176
#> 6 DOID:0001816     DOID:175
```

get ancestor of “DOID:0001816”

``` r
anc_list <- AnnotationDbi::as.list(HDOANCESTOR)
anc_list[["DOID:0001816"]]
#> [1] "DOID:4"       "DOID:14566"   "DOID:162"     "DOID:0050686" "DOID:176"    
#> [6] "DOID:175"
```

### HDOPARENTS

HDOPARENTS describes the association between DO terms and their direct
parent terms based on DAG. We can use `toTable` function in
`AnnotationDbi` package to get a two-column data.frame: the first column
means the DO term ids, and the second column means their parent terms.

``` r
parent_table <- toTable(HDOPARENTS)
head(parent_table)
#>           doid       parent
#> 1 DOID:0001816     DOID:175
#> 2 DOID:0002116   DOID:10124
#> 3 DOID:0014667       DOID:4
#> 4 DOID:0040001 DOID:0060524
#> 5 DOID:0040002 DOID:0060500
#> 6 DOID:0040003 DOID:0060519
```

get parent term of “DOID:0001816”

``` r
parent_list <- AnnotationDbi::as.list(HDOPARENTS)
parent_list[["DOID:0001816"]]
#> [1] "DOID:175"
```

### HDOOFFSPRING

HDOPARENTS describes the association between DO terms and their
offspring  
terms based on DAG. it’s the exact opposite of `HDOANCESTOR`, whose
usage is similar to it.

get offspring of “DOID:0001816”

``` r
off_list <- AnnotationDbi::as.list(HDO.db::HDOOFFSPRING)
off_list[["DOID:0001816"]]
#> [1] "DOID:265"  "DOID:268"  "DOID:4505" "DOID:4510" "DOID:4512" "DOID:4513"
#> [7] "DOID:4522" "DOID:4525" "DOID:4527"
```

### HDOCHILDREN

HDOCHILDREN describes the association between DO terms and their direct
children terms based on DAG. it’s the exact opposite of `HDOPARENTS`,
whose usage is similar to it.

get children of “DOID:4”

``` r
child_list <- AnnotationDbi::as.list(HDO.db::HDOCHILDREN)
child_list[["DOID:4"]]
#> [1] "DOID:0014667" "DOID:0050117" "DOID:0080015" "DOID:14566"   "DOID:150"    
#> [6] "DOID:225"     "DOID:630"     "DOID:7"
```

### HDOGENE

HDOGENE describes the association between DO ids and gene ids based on
alliancegenome. get genes of “DOID:0001816”

``` r
HDO_list <- AnnotationDbi::as.list(HDO.db::HDOGENE)
HDO_list[["DOID:0001816"]]
#> [1] "3783" "6774" "7157" "5787" "4609"
```

### HDOGENENCG

HDOGENE describes the association between gene ids and ncg ids based on
NCG. get disease of gene id 60.

``` r
NCG_list <- AnnotationDbi::as.list(HDO.db::HDOGENENCG)
NCG_list[["60"]]
#> [1] "dlblc, follicular_lymphoma"    "pan-cancer_adult"             
#> [3] "diffuse_large_B-cell_lymphoma" "pan-cancer_paediatric"        
#> [5] "bladder_cancer"
```

The HDO.db support the `select()`, `keys()`, `keytypes()`, and `columns`
interface.

``` r
columns(HDO.db)
#>  [1] "alias"     "ancestor"  "children"  "doid"      "gene"      "ncg"      
#>  [7] "offspring" "parent"    "synonym"   "term"
## use doid keys
dokeys <- head(keys(HDO.db))
res <- select(x = HDO.db, keys = dokeys, keytype = "doid", 
    columns = c("offspring", "term", "parent", "gene"))
head(res)
#>           doid offspring         term   parent gene
#> 1 DOID:0001816  DOID:265 angiosarcoma DOID:175 3783
#> 2 DOID:0001816  DOID:265 angiosarcoma DOID:175 4609
#> 3 DOID:0001816  DOID:265 angiosarcoma DOID:175 5787
#> 4 DOID:0001816  DOID:265 angiosarcoma DOID:175 6774
#> 5 DOID:0001816  DOID:265 angiosarcoma DOID:175 7157
#> 6 DOID:0001816  DOID:268 angiosarcoma DOID:175 3783

## use term keys
dokeys <- head(keys(HDO.db, keytype = "term"))
res <- select(x = HDO.db, keys = dokeys, keytype = "term", 
    columns = c("offspring", "doid", "parent", "gene"))   
head(res)
#>           doid         term offspring   parent gene
#> 1 DOID:0001816 angiosarcoma  DOID:265 DOID:175 3783
#> 2 DOID:0001816 angiosarcoma  DOID:265 DOID:175 4609
#> 3 DOID:0001816 angiosarcoma  DOID:265 DOID:175 5787
#> 4 DOID:0001816 angiosarcoma  DOID:265 DOID:175 6774
#> 5 DOID:0001816 angiosarcoma  DOID:265 DOID:175 7157
#> 6 DOID:0001816 angiosarcoma  DOID:268 DOID:175 3783

## use term gene
dokeys <- head(keys(HDO.db, keytype = "gene"))
res <- select(x = HDO.db, keys = dokeys, keytype = "gene", 
    columns = c("doid", "ncg"))   
head(res)
#>           doid  gene                              ncg
#> 1    DOID:3179  7422                             <NA>
#> 2    DOID:8577  7433                             <NA>
#> 3   DOID:10283  7472                     glioblastoma
#> 4 DOID:0060574  7450 pancreatic_ductal_adenocarcinoma
#> 5    DOID:1612 55135                             <NA>
#> 6    DOID:9261  7422                             <NA>
```

## Semantic similarity analysis

Please go to <https://yulab-smu.top/biomedical-knowledge-mining-book/>
for the vignette.

## Disease enrichment analysis

Please go to
<https://yulab-smu.top/biomedical-knowledge-mining-book/dose-enrichment.html>
for the vignette.

``` r
sessionInfo()
#> R version 4.4.1 (2024-06-14 ucrt)
#> Platform: x86_64-w64-mingw32/x64
#> Running under: Windows 11 x64 (build 22631)
#> 
#> Matrix products: default
#> 
#> 
#> locale:
#> [1] LC_COLLATE=Chinese (Simplified)_China.utf8 
#> [2] LC_CTYPE=Chinese (Simplified)_China.utf8   
#> [3] LC_MONETARY=Chinese (Simplified)_China.utf8
#> [4] LC_NUMERIC=C                               
#> [5] LC_TIME=Chinese (Simplified)_China.utf8    
#> 
#> time zone: Asia/Shanghai
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
#> [8] base     
#> 
#> other attached packages:
#> [1] AnnotationDbi_1.66.0 IRanges_2.38.1       S4Vectors_0.42.1    
#> [4] Biobase_2.64.0       BiocGenerics_0.50.0  HDO.db_1.0.0        
#> 
#> loaded via a namespace (and not attached):
#>  [1] crayon_1.5.3            vctrs_0.6.5             httr_1.4.7             
#>  [4] cli_3.6.3               knitr_1.48              rlang_1.1.4            
#>  [7] xfun_0.45               DBI_1.2.3               UCSC.utils_1.0.0       
#> [10] png_0.1-8               jsonlite_1.8.8          bit_4.0.5              
#> [13] Biostrings_2.72.1       htmltools_0.5.8.1       KEGGREST_1.44.1        
#> [16] rmarkdown_2.27          evaluate_0.24.0         fastmap_1.2.0          
#> [19] GenomeInfoDb_1.40.1     yaml_2.3.9              memoise_2.0.1          
#> [22] compiler_4.4.1          RSQLite_2.3.7           blob_1.2.4             
#> [25] pkgconfig_2.0.3         XVector_0.44.0          rstudioapi_0.16.0      
#> [28] digest_0.6.36           R6_2.5.1                GenomeInfoDbData_1.2.12
#> [31] tools_4.4.1             bit64_4.0.5             zlibbioc_1.50.0        
#> [34] cachem_1.1.0
```
