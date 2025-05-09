#' Extract a group from a multiple group mirt object
#'
#' Extract a single group from an object defined by \code{\link{multipleGroup}},
#' or as a mixture model from \code{\link{mirt}}.
#'
#' @aliases extract.group
#' @param x model object of class \code{'MultipleGroupClass'} or \code{'MixtureClass'}
#' @param group the name of the group to extract
#'
#' @author Phil Chalmers \email{rphilip.chalmers@@gmail.com}
#' @references
#' Chalmers, R., P. (2012). mirt: A Multidimensional Item Response Theory
#' Package for the R Environment. \emph{Journal of Statistical Software, 48}(6), 1-29.
#' \doi{10.18637/jss.v048.i06}
#' @keywords extract
#' @seealso \code{\link{extract.item}}, \code{\link{extract.mirt}}
#' @export extract.group
#' @examples
#'
#' \donttest{
#' set.seed(12345)
#' a <- matrix(abs(rnorm(15,1,.3)), ncol=1)
#' d <- matrix(rnorm(15,0,.7),ncol=1)
#' itemtype <- rep('2PL', nrow(a))
#' N <- 1000
#' dataset1 <- simdata(a, d, N, itemtype)
#' dataset2 <- simdata(a, d, N, itemtype, mu = .1, sigma = matrix(1.5))
#' dat <- rbind(dataset1, dataset2)
#' group <- c(rep('D1', N), rep('D2', N))
#' models <- 'F1 = 1-15'
#'
#' mod_configural <- multipleGroup(dat, models, group = group)
#' group.1 <- extract.group(mod_configural, 'D1') #extract first group
#' summary(group.1)
#' plot(group.1)
#' }
extract.group <- function(x, group){
    if(missing(x)) missingMsg('x')
    if(!is(x, 'MultipleGroupClass') && !is(x, 'MixtureClass'))
        stop('Model was not estimated with multipleGroup()', call.=FALSE)
    if(missing(group)) stop('Must specify group number or name', call.=FALSE)
    stopifnot(length(group) == 1L)
    groupNames <- extract.mirt(x, 'groupNames')
    if(is.character(group)){
        stopifnot(any(group == groupNames))
        group <- which(group == groupNames)
    }
    vals <- mod2values(x)
    vals <- vals[vals$group == groupNames[group], ]
    if(is(x, 'MixtureClass'))
        vals <- vals[-nrow(vals),] # remove PI
    dat <- extract.mirt(x, 'data')
    nfact <- extract.mirt(x, 'nfact')
    K <- extract.mirt(x, 'K')
    groupvec <- extract.mirt(x, 'group')
    groupNames <- extract.mirt(x, 'groupNames')
    itemtype <- extract.mirt(x, 'itemtype')
    mins <- extract.mirt(x, 'mins')
    pick <- if(is(x, 'MultipleGroupClass'))
        groupvec == groupNames[group] else rep(TRUE, length(groupvec))
    sv <- mirt(dat[pick, ], nfact, itemtype=itemtype,
                pars = 'values', technical = list(customK = K))
    sv$value <- vals$value
    sv$est <- vals$est
    constrain <- extract.mirt(x, 'constrain')
    constrain <- lapply(constrain, function(x) x - vals$parnum[1L] - 1L)
    if(length(constrain)){
        parnum <- sv$parnum
        for(i in length(constrain):1L)
            if(!all(constrain[[i]] %in% parnum)) constrain[[i]] <- NULL
    }
    mod <- mirt(dat[pick, ], nfact, itemtype=itemtype,
                pars = sv, technical = list(customK = K, warn=FALSE, mins=mins),
                TOL = NaN, quadpts=1L, constrain=constrain)
    return(mod)
}
