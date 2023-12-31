% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Crispr_Enrichment_test.R
\name{ct.targetSetEnrichment}
\alias{ct.targetSetEnrichment}
\title{Run a (limited) Pathway Enrichment Analysis on the results of a Crispr experiment.}
\usage{
ct.targetSetEnrichment(
  summaryDF,
  targets,
  enrich = TRUE,
  ignore = "NoTarget",
  ...
)
}
\arguments{
\item{summaryDF}{A dataframe summarizing the results of the screen, returned by the function \code{\link{ct.generateResults}}. 
Internally coerced via `ct.simpleResult()`.}

\item{targets}{A character vector containing the names of the targets to be tested; by default these are assumed to be `geneID`s, 
but specifying `collapse=geneSymbol` enables setting on `geneSymbol` by passing that value through to `ct.simpleResult`.}

\item{enrich}{Logical indicating whether to consider guides that are enriched (default) or depleted within the screen.}

\item{ignore}{Optionally, a character vector containing elements of the \code{summaryDF} that should be ignored in the analysis 
(e.g., unassignable or nonfunctional targets, such as nontargeting controls). By default, this function omits targets with 
\code{geneSymbol} 'NoTarget'.}

\item{...}{Additional parameters to pass to `ct.simpleResult`.}

\item{pvalue.cutoff}{A gene-level p-value cutoff defining targets of interest within the screen. Note that this is a
nominal p-value cutoff to preserve end-user flexibility.}

\item{organism}{The species of the cell line used in the screen; currently only 'human' or 'mouse' are supported.}

\item{db.cut}{Minimum number of genes annotated to a given to a pathway within the screen in order to consider it in the enrichment test.}

\item{species}{The species of the cells used in the screen. Currently only 'human' or 'mouse' are supported.}
}
\value{
A dataframe of enriched pathways.

A named list of pathways from \code{PANTHER.db}.

A named list containing the tested target set and tables detailing the hypergeometric test results using various P-value and
Q-value thresholds.
}
\description{
This function enables some limited geneset enrichment-type analysis of data derived from a pooled Crispr
screen using the PANTHER pathway database. Specifically, it identifies the set of targets significantly enriched or
depleted in a \code{summaryDF} object returned from \code{ct.generateResults} and compares that set to the remaining
targets in the screening library using a hypergeometric test.

Note that many Crispr gRNA libraries specifically target biased sets of genes, often focusing on genes involved
in a particular pathway or encoding proteins with a shared biological property. Consequently, the enrichment results
returned by this function represent the pathways containing genes disproportionately targeted *within the context
of the screen*, and may or may not be informative of the underlying biology in question. This means that
pathways not targeted by a Crispr library will obviously never be enriched within the positive target set regardless of
their biological relevance, and pathways enriched within a focused library screen are similarly expected to partially
reflect the composition of the library and other confounding issues (e.g., number of targets within a pathway).
Analysts should therefore use this function with care. For example, it might be unsurprising to detect pathways related
to histone modification within a screen employing a crispr library targeting epigenetic regulators.

This is a function that invokes the \link[PANTHER.db]{PANTHER.db} Bioconductor library to extract a list of pathway mappings
to be used in gene set enrichment tests. Specifically, the function returns a named list of pathways, where each element contains
Entrez IDs. Users should not generally call this function directly as it is invoked internally by the higher-level
\code{ct.PantherPathwayEnrichment()} function.

This function takes in a \code{resultsDF} and a vector of \code{targets} (contained in the \code{geneID} column of
\code{resultsDF}) and determines whether the specified targets are enriched within the set of all significantly altered targets.
It does this by iteratively testing whether \code{targets} are more likely to be among the set of enriched or depleted targets
at various significance thresholds using a hypergeometric test. Note that the returned Hypergeometric P-values are not corrected
for multiple testing.

Returns a list detailing the \code{targets} used in the tests, and tables indicating the results of the hypergeometric test
at various significance thresholds.
}
\examples{
data(resultsDF)
tar <-  sample(unique(resultsDF$geneSymbol), 20)
res <- ct.targetSetEnrichment(resultsDF, tar)
}
\author{
Russell Bainer, Steve Lianoglou

Russell Bainer, Steve Lianoglou.

Russell Bainer
}
\keyword{internal}
