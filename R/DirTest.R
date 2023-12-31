##' @title Compute Directional P-values from eBayes Output
##' @description This function produces two sets of one-sided P-values derived from the moderated t-statistics produced by eBayes.  
##' @param fit An object of class MArrayLM containing, at minimum, a \code{df.residual} slot containing the appropriate degres of freedom for each test, and a \code{t} slot containing t statistics. 
##' @return A matrix object with two numeric columns, indicating the p-values quantifying the evidence for enrichment and depletion of each feature in the relevant model contrast.   
##' @param contrast.term If a fit object with multiple coefficients is passed in, a string indiating the coefficient of interest.   
##' @author Russell Bainer
##' @examples data('fit')
##' ct.DirectionalTests(fit)
##' @export
ct.DirectionalTests <- function(fit, contrast.term = NULL) {

    if (ncol(fit$coefficients) > 1) {
        if (is.null(contrast.term)) {
            stop("The fit object contains multiple coefficients. Please specify a contrast.term.")
        }
        fit <- ct.preprocessFit(fit, contrast.term)
    }

    if (!methods::is(fit, "MArrayLM")) {
        stop(deparse(substitute(fit)), " is not an MArrayLM object.")
    }
    if (!("t" %in% names(fit))) {
        stop("No t statistics are present in the specified object.")
    }
    if (!("df.total" %in% names(fit))) {
        stop("Cannot find the appropriate degrees of freedom (df.total) in the specified object.")
    }

    out <- cbind(pt(fit$t, df = fit$df.total[1], lower.tail = TRUE), pt(fit$t, df = fit$df.total[1], lower.tail = FALSE))
    colnames(out) <- c("Depletion.P", "Enrichment.P")
    row.names(out) <- row.names(fit$t)
    return(out)
}















