% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RRAalpha.R
\name{ct.RRAaPvals}
\alias{ct.RRAaPvals}
\title{gRNA signal aggregation via RRAa}
\usage{
ct.RRAaPvals(p, g.key, permute, permutation.seed = NULL, multi.core = NULL)
}
\arguments{
\item{p}{A single column matrix of ranking scores, with row.names indicating the gRNA labels}

\item{g.key}{An annotation data frame of gRNAs, minimally containing a factorized 'geneSymbol' column indicating the target names. This is typically generated by 
calling the \code{ct.buildKeyFromAnnotation()} function.}

\item{permute}{Number of permutations to be used during empirical p-value estimation.}

\item{permutation.seed}{numeric seed for permutation reproducibility.
Default: \code{NULL} means to not set any seed.}

\item{multi.core}{Deprecated, does nothing}
}
\value{
A named list of target-level empirical P-values.
}
\description{
This is a wrapper function implementing the RRAalpha p-value aggregation algorithm. Takes in a set of gRNA rank scores (formatted as a single-column 
numeric matrix with row.names indicating the guide names) and a list object of gRNA annotations (names are the gene targets, and each element of the list contains 
a vector of the corresponding guide names). The rank scores are converted to gene-level statistics that are thenm transformed into empirical p-values by permutation.
}
\examples{
data('fit')
data('ann')
genePvals <- ct.RRAaPvals(fit$p.value, ann, permute = 100)
}
\author{
Russell Bainer
}
\keyword{internal}
