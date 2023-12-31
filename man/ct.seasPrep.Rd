% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sparrow_integration.R
\name{ct.seasPrep}
\alias{ct.seasPrep}
\title{Prepare one or more resultsDF objects for analysis via Sparrow.}
\usage{
ct.seasPrep(
  dflist,
  collapse.on = c("geneID", "geneSymbol"),
  cutoff = 0.1,
  statistic = c("best.q", "best.p"),
  regularize = FALSE,
  gdb = NULL,
  active = "replicated"
)
}
\arguments{
\item{dflist}{A list of gCrisprTools results `data.frames` to be formatted.}

\item{collapse.on}{Should targets be annotated as `geneSymbol`s or `geneID`s (default)?}

\item{cutoff}{Numeric maximum value of `statistic` to define significance.}

\item{statistic}{Should cutoffs be calculated based on FDR (`best.q`) or P-value (`best.p`)?}

\item{regularize}{Logical indicating whether to regularize the result objects in `dflist` (e.g., use intersection set of 
all targets), or keep as-is.}

\item{gdb}{Optionally, a `GeneSetDb` object to enable proper registration of the output. If provided, the 
collapsing features in the provided `simpleDF`s must be present in the `gsd@db$feature_id` slot. Note that a GREAT-style `GeneSetDb` that 
has been conformed via `ct.GREATdb()` will use `geneID`s as the `feature_id`.}

\item{active}{Optionally, the name of a logical column present in the provided result that will be used to define significant signals. 
This is set to `replicated` by default to If a valid column name is provided, this overrides the specification of `cutoff` and `statistic`.}
}
\value{
A list of `data.frames` formatted for evaluation with `sparrow::seas()`.
}
\description{
Take in a list of results objects and return an equivalently-named list of input `data.frames` appropriate for `sparrow::seas()`. 
By construction, the relevant target unit is extracted from the `geneSymbol` column of the provided results objects, which may. Note that the 
genewise `@logFC` slot in the returned object will contain the appropriately-signed Z transformation of the P-value 
assigned to the target. In most applications this is arguably more interpretable than e.g., the median gRNA log2 fold change.
}
\examples{
data(resultsDF)
ct.seasPrep(list('longer' = resultsDF, 'shorter' = resultsDF[1:10000,]), collapse.on = 'geneSymbol')
}
