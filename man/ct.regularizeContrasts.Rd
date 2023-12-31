% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fileutilities.R
\name{ct.regularizeContrasts}
\alias{ct.regularizeContrasts}
\title{Regularize Two Screening Results Objects}
\usage{
ct.regularizeContrasts(dflist, collapse = c("geneSymbol", "geneID"))
}
\arguments{
\item{dflist}{A list of results dataframes. Names will be preserved.}

\item{collapse}{Column of the provided resultsDFs on which to collapse values; should be `geneSymbol` or `geneID`.}
}
\value{
A list of the in-register `simpleResult` objects, with length and names identical to `dflist`.
}
\description{
This function prepares multiple `gCrisprTools` results dataframes for comparison. Specifically, 
it checks that all provided data frames are valid result objects, converts each to the target-wise `simpleResult` format, 
removes signals that are not shared by all objects, places their rows in identical order, and then returns the simplified dataframes as a list. 

This function is largely meant to be used by other gCrisprtools functions, although there are occasions when an analyst may want to call it directly. 
Often, it is useful to pass the `collapse` argument to `ct.simpleresult()` in cases where libraries and technologies differ between screens.
}
\examples{
data('resultsDF')
lapply(ct.regularizeContrasts(list('df1' = resultsDF[1:300,], 'df2' = resultsDF[200:400,])), nrow)
}
