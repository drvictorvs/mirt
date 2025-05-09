#' Convert ordered Likert-scale responses (character or factors) to integers
#'
#' Given a matrix or data.frame object consisting of Likert responses return an
#' object of the same dimensions with integer values.
#'
#' @param x a matrix of character values or data.frame of character/factor vectors
#'
#' @param levels a named character vector indicating which integer values
#'   should be assigned to which elements. If omitted, the order of the elements
#'   will be determined after converting each column in \code{x} to a factor
#'   variable
#'
#' @author Phil Chalmers \email{rphilip.chalmers@@gmail.com}
#' @references
#' Chalmers, R., P. (2012). mirt: A Multidimensional Item Response Theory
#' Package for the R Environment. \emph{Journal of Statistical Software, 48}(6), 1-29.
#' \doi{10.18637/jss.v048.i06}
#'
#' @seealso \code{\link{key2binary}}, \code{\link{poly2dich}}
#' @keywords data conversion
#' @export
#' @examples
#' \donttest{
#'
#' # simulate data
#'
#' dat1 <- matrix(sample(c('Disagree', 'Strongly Disagree', 'Agree',
#'                         'Neutral', 'Strongly Agree'), 1000*5, replace=TRUE),
#'                nrow=1000, ncol=5)
#' dat1[2,2] <- dat1[3,3] <- dat1[1,3] <- NA # NAs added for flavour
#' dat2 <- matrix(sample(c('D', 'SD', 'A', 'N', 'SA'), 1000*5, replace=TRUE),
#'                nrow=1000, ncol=5)
#' dat <- cbind(dat1, dat2)
#'
#' # separately
#' intdat1 <- likert2int(dat1)
#' head(dat1)
#' head(intdat1)
#'
#' # more useful with explicit levels
#' lvl1 <- c('Strongly Disagree'=1, 'Disagree'=2, 'Neutral'=3, 'Agree'=4,
#'           'Strongly Agree'=5)
#' intdat1 <- likert2int(dat1, levels = lvl1)
#' head(dat1)
#' head(intdat1)
#'
#' # second data
#' lvl2 <- c('SD'=1, 'D'=2, 'N'=3, 'A'=4, 'SA'=5)
#' intdat2 <- likert2int(dat2, levels = lvl2)
#' head(dat2)
#' head(intdat2)
#'
#' # full dataset (using both mapping schemes)
#' intdat <- likert2int(dat, levels = c(lvl1, lvl2))
#' head(dat)
#' head(intdat)
#'
#'
#' #####
#' # data.frame as input with ordered factors
#'
#' dat1 <- data.frame(dat1)
#' dat2 <- data.frame(dat2)
#' dat.old <- cbind(dat1, dat2)
#' colnames(dat.old) <- paste0('Item_', 1:10)
#' str(dat.old) # factors are leveled alphabetically by default
#'
#' # create explicit ordering in factor variables
#' for(i in 1:ncol(dat1))
#'    levels(dat1[[i]]) <- c('Strongly Disagree', 'Disagree', 'Neutral', 'Agree',
#'                           'Strongly Agree')
#'
#' for(i in 1:ncol(dat2))
#'    levels(dat2[[i]]) <- c('SD', 'D', 'N', 'A', 'SA')
#'
#' dat <- cbind(dat1, dat2)
#' colnames(dat) <- colnames(dat.old)
#' str(dat) # note ordering
#'
#' intdat <- likert2int(dat)
#' head(dat)
#' head(intdat)
#'
#' }
likert2int <- function(x, levels = NULL){
    x <- as.data.frame(x)
    ret <- lapply(1:ncol(x), function(ind, x, levels){
        if(is.null(levels)){
            lvl_nms <- levels(x[[ind]])
            lvl <- 1:length(lvl_nms)
            names(lvl) <- lvl_nms
        } else lvl <- levels
        out <- lvl[as.character(x[[ind]])]
        out
    }, x=x, levels=levels)
    ret <- data.frame(do.call(cbind, ret), row.names=rownames(x))
    colnames(ret) <- colnames(x)
    ret
}
