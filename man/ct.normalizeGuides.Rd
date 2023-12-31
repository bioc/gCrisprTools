% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Normalization.R
\name{ct.normalizeGuides}
\alias{ct.normalizeGuides}
\title{Normalize an ExpressionSet Containing a Crispr Screen}
\usage{
ct.normalizeGuides(
  eset,
  method = c("scale", "FQ", "slope", "controlScale", "controlSpline"),
  annotation = NULL,
  sampleKey = NULL,
  lib.size = NULL,
  plot.it = FALSE,
  ...
)
}
\arguments{
\item{eset}{An ExpressionSet object with integer count data extractable with \code{exprs()}.}

\item{method}{The normalization method to use.}

\item{annotation}{The annotation object for the library, required for the methods employing nontargeting controls.}

\item{sampleKey}{An (optional) sample key, supplied as an ordered factor linking the samples to experimental
variables. The \code{names} attribute should exactly match those present in \code{eset}, and the control set is assumed to be
the first \code{level}. If `method` = `FQ`, the sampleKey is taken as the `sets` argument (and its format requirements are similarly 
relaxed; see `?ct.normalizeFC`).}

\item{lib.size}{An optional vector of voom-appropriate library size adjustment factors, usually calculated with \code{\link[edgeR]{calcNormFactors}} 
and transformed to reflect the appropriate library size. These adjustment factors are interpreted as the total library sizes for each sample, 
and if absent will be extrapolated from the columnwise count sums of the \code{exprs} slot of the \code{eset}.}

\item{plot.it}{Logical indicating whether to plot the ranked log2 gRNA count distributions before and after normalization.}

\item{...}{Other parameters to be passed to the individual normalization methods.}
}
\value{
A renormalized ExpressionSet. If specified, the sample level counts will be scaled so as to maintain the validity 
of the specified \code{lib.size} values.
}
\description{
This function normalizes Crispr gRNA abundance estimates contained in an \code{ExpressionSet} object.
Currently four normalization methods are implemented: median scaling (via \code{normalizeMedianValues}), slope-based
normalization (via \code{ct.normalizeBySlope()}), scaling to the median of the nontargeting control values (via 
\code{ct.normalizeNTC()}), factored quantile normalization (via \code{ct.normalizeFQ()}), and spline fitting to the distribution of 
selected gRNAs (via \code{ct.normalizeSpline()}). Because of the peculiarities of pooled Crispr screening data, these 
implementations may be more stable than the endogenous methods used downstream by \link[limma]{voom}. See the respective 
man pages for further details about specific normalization approaches.
}
\examples{
data('es')
data('ann')

#Build the sample key as needed
library(Biobase)
sk <- ordered(relevel(as.factor(pData(es)$TREATMENT_NAME), 'ControlReference'))
names(sk) <- row.names(pData(es))

es.norm <- ct.normalizeGuides(es, 'scale', annotation = ann, sampleKey = sk, plot.it = TRUE)
es.norm <- ct.normalizeGuides(es, 'slope', annotation = ann, sampleKey = sk, plot.it = TRUE)
es.norm <- ct.normalizeGuides(es, 'controlScale', annotation = ann, sampleKey = sk, plot.it = TRUE, geneSymb = 'NoTarget')
es.norm <- ct.normalizeGuides(es, 'controlSpline', annotation = ann, sampleKey = sk, plot.it = TRUE, geneSymb = 'NoTarget')
}
\seealso{
\code{\link{ct.normalizeMedians}}, \code{\link{ct.normalizeBySlope}}, \code{\link{ct.normalizeNTC}}, \code{\link{ct.normalizeSpline}}
}
\author{
Russell Bainer
}
