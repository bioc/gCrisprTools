% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ViewControls.R
\name{ct.viewControls}
\alias{ct.viewControls}
\title{View nontargeting guides within an experiment}
\usage{
ct.viewControls(
  eset,
  annotation,
  sampleKey,
  geneSymb = NULL,
  normalize = TRUE,
  lib.size = NULL
)
}
\arguments{
\item{eset}{An ExpressionSet  object containing, at minimum, a matrix of gRNA abundances extractable with the \code{exprs} function.}

\item{annotation}{An annotation data.frame for the experiment. gRNAs are annotated by
row, and must minimally contain columns \code{geneSymbol} and \code{geneID}.}

\item{sampleKey}{A sample key, supplied as an ordered factor linking the samples to experimental
variables. The \code{names} attribute should exactly match those present in \code{eset}, and the control condition is assumed to be
the first \code{level}.}

\item{geneSymb}{The \code{geneSymbol} identifier in \code{annotation} that corresponds to nontargeting gRNAs. If absent, \code{ct.ViewControls} will
attempt to infer nontargeting guides by searching for \code{'no_gid'} or \code{NA} in the appropriate columns.}

\item{normalize}{Logical indicating whether to attempt to normalize the data in the \code{eset} by DESeq size factors present in the metadata. If \code{TRUE},
then the metadata must contain a column containing these factors, named \code{sizeFactor.crispr-gRNA}.}

\item{lib.size}{An optional vector of voom-appropriate library size adjustment factors, usually calculated with \code{\link[edgeR]{calcNormFactors}} 
and transformed to reflect the appropriate library size. These adjustment factors are interpreted as the total library sizes for each sample, 
and if absent will be extrapolated from the columnwise count sums of the \code{exprs} slot of the \code{eset}.}
}
\value{
An image of nontargeting control gRNA abundances on the default device.
}
\description{
This function tries to identify, and then plot the abundance of, the full set of non-targeting controls from an ExpressionSet
object. Ideally, the user will supply a geneSymbol present in the appropriate annotation file that uniquely identifies the nontargeting gRNAs.
Absent this, the the function will search for common identifier used by nontargeting controls (geneID 'no_gid', or geneSymbol NA).
}
\examples{
data('es')
data('ann')

#Build the sample key
library(Biobase)
sk <- ordered(relevel(as.factor(pData(es)$TREATMENT_NAME), 'ControlReference'))
names(sk) <- row.names(pData(es))

ct.viewControls(es, ann, sk, geneSymb = NULL, normalize = FALSE)
ct.viewControls(es, ann, sk, geneSymb = NULL, normalize = TRUE)
}
\author{
Russell Bainer
}
