##' @title Run a (limited) Pathway Enrichment Analysis on the results of a Crispr experiment.
##' @description This function enables some limited geneset enrichment-type analysis of data derived from a pooled Crispr
##' screen using the PANTHER pathway database. Specifically, it identifies the set of targets significantly enriched or
##' depleted in a \code{summaryDF} object returned from \code{ct.generateResults} and compares that set to the remaining
##' targets in the screening library using a hypergeometric test.
##'
##' Note that many Crispr gRNA libraries specifically target biased sets of genes, often focusing on genes involved
##' in a particular pathway or encoding proteins with a shared biological property. Consequently, the enrichment results
##' returned by this function represent the pathways containing genes disproportionately targeted *within the context
##' of the screen*, and may or may not be informative of the underlying biology in question. This means that
##' pathways not targeted by a Crispr library will obviously never be enriched within the positive target set regardless of
##' their biological relevance, and pathways enriched within a focused library screen are similarly expected to partially
##' reflect the composition of the library and other confounding issues (e.g., number of targets within a pathway).
##' Analysts should therefore use this function with care. For example, it might be unsurprising to detect pathways related
##' to histone modification within a screen employing a crispr library targeting epigenetic regulators.
##'
##' @param summaryDF A dataframe summarizing the results of the screen, returned by the function \code{\link{ct.generateResults}}.
##' @param pvalue.cutoff A gene-level p-value cutoff defining targets of interest within the screen. Note that this is a
##' nominal p-value cutoff to preserve end-user flexibility.
##' @param enrich Logical indicating whether to consider guides that are enriched (default) or depleted within the screen.
##' @param organism The species of the cell line used in the screen; currently only 'human' or 'mouse' are supported.
##' @param db.cut Minimum number of genes annotated to a given to a pathway within the screen in order to consider it in the enrichment test.
##' @return A dataframe of enriched pathways.
##' @author Russell Bainer, Steve Lianoglou
##' @keywords internal
#ct.PantherPathwayEnrichment <- function(summaryDF, pvalue.cutoff = 0.01, enrich = TRUE, organism = 'human', db.cut = 10){
#  .Deprecated(msg = 'This function is on its way out in favor of the new functionality using sparrow. See ct.seas() and the gCrisprTools vignettes.')
#  
#  if (!requireNamespace("PANTHER.db")) {
#    stop("The PANTHER.db bioconductor package is required")
#  }
#  if (!requireNamespace("AnnotationDbi")) {
#    stop("The AnnotationDbi bioconductor package is required")
#  }
#
#  #Check the input:
#    organism <- match.arg(organism, c('human', 'mouse'))
#
#    if(!(enrich %in% c(TRUE, FALSE))){
#      stop('enrich must be either TRUE or FALSE.')
#    }
#
#    if(!ct.resultCheck(summaryDF)){
#      stop("Execution halted.")
#    }
#
#    if(!(pvalue.cutoff <= 1 & pvalue.cutoff >= 0 & is.numeric(pvalue.cutoff))){
#      stop("pvalue.cutoff must be a numeric value between 0 and 1.")
#    }
#
#    if(!(is.numeric(db.cut))){
#      stop("db.cut must be a numeric value.")
#    }
#
#
#    message("WARNING: The interpretation of gene set enrichment analyses in Crispr screens is tricky. See the man page for further details.")
#
#    #Condense the summary frame to gene-level estimates and isolate the ones that we are testing
#    summaryDF <- summaryDF[!duplicated(summaryDF$geneID),]
#    summaryDF <- summaryDF[!is.na(summaryDF$geneID),]
#    summaryDF <- summaryDF[!grepl('^[A-Za-z]+$', summaryDF$geneID),]
#    universe <- summaryDF$geneID
#    #Pull out the significant hits
#    selected <- summaryDF$geneID[summaryDF[,"Target-level Enrichment P"] <= pvalue.cutoff]#

#    if(enrich == FALSE){
#      selected <- summaryDF$geneID[summaryDF[,"Target-level Depletion P"] <= pvalue.cutoff]
#    }

    #make the database and conform it to the provided resultDF:
#    pdb <- suppressMessages(ct.getPanther(organism))
#    pathways <- names(pdb)
#    pdb.cut <- lapply(pdb, function(x){x[x %in% universe]})
#    genesInCats <- vapply(pdb.cut, length, numeric(1))
#    pdb.cut <- pdb.cut[genesInCats > db.cut]
#    genesInCats <- genesInCats[genesInCats > db.cut]

#    message(paste('Omitting PANTHER pathways containing fewer than', db.cut, 'genes.'))

#    if(length(pdb.cut) == 0){
#      stop(paste('No acceptable gene sets found; consider reducing db.cut? \nExiting.'))
#    }

#    message(paste('Performing Hypergeometric tests with', length(pdb.cut), 'gene sets...'))

#    #Set up the output and run the tests
#    out <- data.frame('PATHWAY' = names(pdb.cut),
#                      'nGenes' = genesInCats,
#                      'sigGenes' = vapply(pdb.cut, function(x){sum(x %in% selected, na.rm = TRUE)}, numeric(1)),
#                      stringsAsFactors = FALSE)
#    testResults <- t(mapply(.doHyperGInternal,
#                         'numW' = out$nGenes,
#                         'numB' = rep(length(universe), nrow(out)),
#                         'numDrawn' = rep(length(selected), nrow(out)),
#                         'numWdrawn' = out$sigGenes,
#                         'over' = rep(TRUE, nrow(out)),
#                         SIMPLIFY =TRUE))
#    out <- cbind(out, testResults[,3:1])
#    out[,'FDR'] <- p.adjust(out$p, 'BH')
#    out[,2:7] <- apply(out[,2:7], 2, as.numeric)
#    out <- out[order(out$p, decreasing = FALSE),]
#    row.names(out) <- 1:nrow(out)

#    return(out)
#    }

##' @title  Extract a Named List of Entrez IDs Annotated to Each Pathway in \code{PANTHER.db}
##' @description This is a function that invokes the \link[PANTHER.db]{PANTHER.db} Bioconductor library to extract a list of pathway mappings
##' to be used in gene set enrichment tests. Specifically, the function returns a named list of pathways, where each element contains
##' Entrez IDs. Users should not generally call this function directly as it is invoked internally by the higher-level
##' \code{ct.PantherPathwayEnrichment()} function.
##' @param species The species of the cells used in the screen. Currently only 'human' or 'mouse' are supported.
##' @return A named list of pathways from \code{PANTHER.db}.
##' @author Russell Bainer, Steve Lianoglou.
##' @keywords internal
#ct.getPanther <- function (species = c("human", "mouse")){
#  .Deprecated(msg = 'This function is on its way out in favor of the new functionality using sparrow. See ct.seas() and the gCrisprTools vignettes.')
#  species <- match.arg(species, c("human", "mouse"))
#
#  if (!requireNamespace("PANTHER.db")) {
#    stop("The PANTHER.db bioconductor package is required")
#  }
#  if (!requireNamespace("AnnotationDbi")) {
#    stop("The AnnotationDbi bioconductor package is required")
#  }
#  if (species == "human") {
#    org.pkg <- "org.Hs.eg.db"
#    xorg <- "Homo_sapiens"
#  }
#  else {
#    org.pkg <- "org.Mm.eg.db"
#    xorg <- "Mus_musculus"
#  }
#  if (!requireNamespace(org.pkg)) {
#    stop(org.pkg, " bioconductor package required for this species query")
#  }
#
#  p.db <- PANTHER.db
#
#  #This is a prefiltering step that appears to be unnecessary now
#  #but potentially breaks if the user doesn't have proper database permissions.
#  #pthOrganisms(p.db) <- toupper(species)

#  org.db <- getFromNamespace(org.pkg, org.pkg)

#  p.all <- select(p.db, keys(p.db, keytype="PATHWAY_ID"),
#                    columns=c("PATHWAY_ID", "PATHWAY_TERM", "UNIPROT"),
#                    'PATHWAY_ID')
#  # Map uniprot to entrez
#  umap <- suppressMessages(select(org.db, p.all$UNIPROT, c('UNIPROT', 'ENTREZID'), 'UNIPROT'))
#  m <- merge(p.all, umap, by='UNIPROT')
#  m <- subset(m, !is.na(m$ENTREZID))

#  paths <- split(m[,3:4], as.factor(m$PATHWAY_TERM))
#  lapply(paths, function(x){unique(x$ENTREZID)})
#}

##' @title Test Whether a Specified Target Set is Enriched Within a Pooled Screen
##' @description This function takes in a \code{resultsDF} and a vector of \code{targets} (contained in the \code{geneID} column of
##' \code{resultsDF}) and determines whether the specified targets are enriched within the set of all significantly altered targets.
##' It does this by iteratively testing whether \code{targets} are more likely to be among the set of enriched or depleted targets
##' at various significance thresholds using a hypergeometric test. Note that the returned Hypergeometric P-values are not corrected
##' for multiple testing.
##'
##' Returns a list detailing the \code{targets} used in the tests, and tables indicating the results of the hypergeometric test
##' at various significance thresholds.
##' @param summaryDF A dataframe summarizing the results of the screen, returned by the function \code{\link{ct.generateResults}}. 
##' Internally coerced via `ct.simpleResult()`.
##' @param targets A character vector containing the names of the targets to be tested; by default these are assumed to be `geneID`s, 
##' but specifying `collapse=geneSymbol` enables setting on `geneSymbol` by passing that value through to `ct.simpleResult`.
##' @param enrich Logical indicating whether to consider guides that are enriched (default) or depleted within the screen.
##' @param ignore Optionally, a character vector containing elements of the \code{summaryDF} that should be ignored in the analysis 
##' (e.g., unassignable or nonfunctional targets, such as nontargeting controls). By default, this function omits targets with 
##' \code{geneSymbol} 'NoTarget'.
##' @param ... Additional parameters to pass to `ct.simpleResult`.
##' @return A named list containing the tested target set and tables detailing the hypergeometric test results using various P-value and
##' Q-value thresholds.
##' @examples data(resultsDF)
##' tar <-  sample(unique(resultsDF$geneSymbol), 20)
##' res <- ct.targetSetEnrichment(resultsDF, tar)
##' @author Russell Bainer
##' @export
ct.targetSetEnrichment <- function(summaryDF, targets, enrich = TRUE, ignore = 'NoTarget', ...){

  #input checks
  stopifnot(is(enrich, 'logical'), is(ignore, 'character'))
  
  if(!is.character(targets)){
    warning("Supplied targets are not a character vector. Coercing.")
    targets <- as.character(targets)
  }
  
  #Infer whether Gsdb is ID or feature centric
  gids <- sum(targets %in% summaryDF$geneID)
  gsids <- sum(targets %in% summaryDF$geneSymbol)
  
  if(all(c(gsids, gids) == 0)){
    stop('None of the targets are present in either the geneID or geneSymbol slots of the first provided result.')
  }
  
  collapse <- ifelse(gids > gsids, 'geneID', 'geneSymbol')
  summaryDF <- ct.simpleResult(summaryDF, collapse)

  valid <- intersect(targets, row.names(summaryDF))

  if(length(setdiff(targets, valid)) != 0){
    warning('Not all of the supplied targets are present in the summary dataframe. Proceeding with ',
            length(valid), ' targets.')
  }

  #Condense the summary frame to gene-level estimates and isolate the ones that we are testing
  summaryDF <- summaryDF[setdiff(row.names(summaryDF), ignore),]  #Remove NoTarget Genes rather than constraining to Entrez

  #Pull out the P-values
  selected <- summaryDF[,c("best.p", "best.q")]
  
  if(enrich){
    selected[(summaryDF$direction %in% 'deplete'), ] <- c(1,1)
  } else {
    selected[(summaryDF$direction %in% 'enrich'), ] <- c(1,1)
  }

  #Set the cutoffs
  cuts <- c(0,1/(10^(5:1)), 0.5, 1)

  out <- list('targets' = valid)
  out$P.values <- cbind(cuts,
                        vapply(cuts, function(x){sum(selected[valid,1] <= x)}, numeric(1)),
                        vapply(cuts, function(x){
                                            .doHyperGInternal(length(valid),
                                                nrow(selected),
                                                sum(selected[,1] <= x),
                                                sum(selected[valid,1] <= x),
                                                TRUE)$p},
                                      numeric(1))

                          )
  out$Q.values <- cbind(cuts,
                        vapply(cuts, function(x){sum(selected[valid,2] <= x)}, numeric(1)),
                        vapply(cuts, function(x){
                          .doHyperGInternal(length(valid),
                                            nrow(selected),
                                            sum(selected[,2] <= x),
                                            sum(selected[valid,2] <= x),
                                            TRUE)$p},
                          numeric(1))
                        )


  colnames(out$P.values) <- colnames(out$Q.values) <- c('Cutoff', 'Sig', 'Hypergeometric_P')
  return(out)
}






## -----------------------------------------------------------------------------
## These were copied from the Bioconductor collection package

##' We envision the test as follows:
##'
##' The urn contains genes from the gene universe.  Genes annotated at a
##' given collection term are white and the rest black.
##'
##' The number drawn is the size of the selected gene list.  The
##' number of white drawn is the size of the intersection of the
##' selected list and the genes annotated at the collection.
##' Here's a diagram based on using GO as the collection:
##'
##'          inGO    notGO
##'          White   Black
##' selected  n11     n12
##' not       n21     n22
##'
##' numW: number of genes in GO category
##' numB: size of universe
##' numDrawn: number of differentially expressed genes
##' numWdrawn: the number of genes differentially expressed in category
##' @keywords internal
##' @noRd

.doHyperGInternal <- function(numW, numB, numDrawn, numWdrawn, over = TRUE) {
  n21 <- numW - numWdrawn
  n12 <- numDrawn - numWdrawn
  n22 <- numB - n12

  odds_ratio <-  (numWdrawn * n22) / (n12 * n21)

  expected <- (numWdrawn + n12) * (numWdrawn + n21)
  expected <- expected / (numWdrawn + n12 + n21 + n22)

  if (over) {
    ## take the -1 because we want evidence for as extreme or more
    pvals <- phyper(numWdrawn - 1L, numW, numB,
                    numDrawn, lower.tail=FALSE)
  } else {
    pvals <- phyper(numWdrawn, numW, numB,
                    numDrawn, lower.tail=TRUE)
  }

  list(p=pvals, odds=odds_ratio, expected=expected)
}
