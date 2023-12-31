% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compareContrasts.R
\name{ct.upSet}
\alias{ct.upSet}
\title{Consolidate shared signals across many contrasts in an UpSet Plot}
\usage{
ct.upSet(dflist, add.stats = TRUE, nperm = 10000, ...)
}
\arguments{
\item{dflist}{a named list of (possibly simplified) `resultsDf`s.}

\item{add.stats}{Logical indicating whether the significance of set overlaps should be included in the visualization.}

\item{nperm}{Number of permutations for P-value generation. Ignored if `add.stats` is `FALSE`.}

\item{...}{Other named arguments to `ComplexHeatmap::UpSet()`, `ct.compareContrasts`, or `ct.simpleResult()`.}
}
\value{
An UpSet plot on the current device. Silently, a combination matrix appropriate for plotting that plot, 
containing useful information about the observed intersections.
}
\description{
This function takes in a named list of `results` dataframes produced by `ct.generateResults()` or similar, 
harmonizes them, and identifies overlaps between them using the logic implemented in `ct.compareContrasts()`. It then uses the
overlaps of these sets to compose an UpSet plot summarizing shared overlaps of the provided contrasts. These overlaps can be 
specified with some detail via arguments passed to the `ct.compareContrasts()` function; see documentation for more details.

Note that the UpSet plot is constructed to respect signal directionality, and by default constructs overlaps conditionally, 
but in a *bidirectional* manner. That is, a signal is considered observed in two (or more) contrasts regardless of the 
contrast from which the stringent signal is observed, so a signal replicated in three contrasts is interpreted as a target 
for which the evidence crosses the stringent threshold in one or more of the contrasts and passes the lax contrast in the others. 

Note that multiple important parameters are passed directly to `ct.compareContrasts()` if not specified in the command. Users 
are advised to study the corresponding manual page to better understand their options regarding contrast thresholding, 
orientation, etc.
}
\examples{
data('resultsDF')
sets <- ct.upSet(list('first' = resultsDF, 'second' = resultsDF[1:5000,]))
}
\author{
Russell Bainer
}
