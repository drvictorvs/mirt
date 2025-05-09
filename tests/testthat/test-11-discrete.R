expect_class <- function(x, class) expect_true(inherits(x, class))

test_that('discrete', {

    #----------
    # dichotomous LCA
    dat <- expand.table(LSAT6)
    mod <- mdirt(dat, 2, verbose=FALSE, SE=TRUE, SE.type = 'Richardson')
    so <- summary(mod)
    expect_equal(extract.mirt(mod, 'condnum'), 153.6806, tolerance = 1e-4)
    expect_equal(extract.mirt(mod, 'logLik'), -2467.408, tolerance = 1e-4)
    expect_equal(extract.mirt(mod, 'df'), 20)
    expect_equal(as.numeric(sort(so$Class.Probability[,'prob'])[1L]), 0.3317701, tolerance = 1e-2)
    expect_equal(as.numeric(sort(so$Item_1)), c(0.03705052,0.1555339,0.8444661,0.9629495),
                 tolerance = 1e-4)

    M <- M2(mod)
    expect_equal(M$M2, 4.603509, tolerance = 1e-4)
    fs <- fscores(mod, full.scores=FALSE)
    pick <- apply(fs[1:5, c('Class_1', 'Class_2')], 1, max)
    expect_equal(pick, c(0.9885338, 0.9614451, 0.9598363, 0.8736180, 0.9415842),
                 tolerance = 1e-2)

    resid <- residuals(mod, type = 'exp')
    expect_equal(resid$std.res[1:3], c(1.0380029, 0.1373462, -0.3478477), tolerance = 1e-2)
    residLD <- residuals(mod, type = 'LD')
    expect_equal(as.numeric(residLD[2:4, 1]), c(0.1092414, 0.4115837, 0.1316043), tolerance=1e-2)
    ifit <- itemfit(mod)
    expect_equal(ifit$S_X2, c(0.4345528,1.6995487,0.7470039,0.1830134,0.1429708), tolerance=1e-2)

    W <- wald(mod, L = matrix(c(1,numeric(9), 0), nrow=1))
    expect_equal(W$W, 25.58544, tolerance=1e-4)

    # covdata
    set.seed(4)
    covdata <- data.frame(X = rowSums(dat))
    modb <- mdirt(dat, 2, covdata=covdata, formula = ~X,
                  verbose=FALSE, GenRandomPars = TRUE)
    expect_equal(logLik(modb), -2390.676, tolerance = 1)

    #----------
    # polytomous LCA
    vals <- c(1.65,6.9,3.74,9.13,1.89,9.13,1.05,1.62,1.51,3.74,-1.17,3.4,1.64,
            -2.56,2.5,6.54,0.29,7.2,1.5,2.2,1.97,3.71,0.22,3.75,0.85)
    sv <- mdirt(Science, 2, verbose=FALSE, pars='values')
    sv$value <- vals
    mod2 <- mdirt(Science, 2, verbose=FALSE, pars=sv)
    so <- summary(mod2)
    expect_equal(extract.mirt(mod2, 'logLik'), -1622.466, tolerance = 1e-4)
    expect_equal(extract.mirt(mod2, 'df'), 230)
    expect_equal(as.numeric(sort(so$Class.Probability[,'prob'])), c(0.2995343, 0.7004657), tolerance = 1e-2)
    expect_equal(as.numeric(sort(so$Comfort)), c(5.137347e-05,0.01823445,0.0511375,0.09465902,0.1209914,0.4738024,0.4750087,0.7661152),
                 tolerance = 1e-2)

    #----------
    # GOM
    if(FALSE){
        rm(list=ls())
        set.seed(8765)
        I <- 10
        prob.class1 <- runif( I , 0 , .35 )
        prob.class2 <- runif( I , .70 , .95 )
        prob.class3 <- .5*prob.class1+.5*prob.class2 # probabilities for fuzzy class
        probs <- cbind( prob.class1 , prob.class2 , prob.class3)

        # define classes
        N <- 1000
        latent.class <- c( rep(1,round(1/3*N)),rep(2,round(1/2*N)),rep(3,round(1/6*N)))

        # simulate item responses
        dat <- matrix( NA , nrow=N , ncol=I )
        for (ii in 1:I){
            dat[,ii] <- probs[ ii , latent.class ]
            dat[,ii] <- 1 * ( runif(N) < dat[,ii] )
        }
        colnames(dat) <- paste0( "I" , 1:I)
        save(dat, file = 'tests/tests/testdata/discrete1.rds')
    }
    load('testdata/discrete1.rds')

    Theta <- matrix(c(1, 0, .5, .5, 0, 1), nrow=3 , ncol=2,byrow=TRUE)
    mod_gom <- mdirt(dat, 2, customTheta = Theta, verbose=FALSE)
    so <- summary(mod_gom)
    expect_equal(extract.mirt(mod_gom, 'logLik'), -5541.09, tolerance = 1e-4)
    expect_equal(extract.mirt(mod_gom, 'df'), 1001)
    expect_equal(as.numeric(sort(so$Class.Probability[,'prob'])), c(0.1744980, 0.3188351, 0.5066669), tolerance = 1e-2)
    expect_equal(as.numeric(sort(so[[1]])), c(0.1045606,0.1184876,0.4824176,0.5175824,0.8815124,0.8954394),
                 tolerance = 1e-2)

    #-----------------
    #multidim discrete

    dat <- key2binary(SAT12,
                      key = c(1,4,5,2,3,1,2,1,3,1,2,4,2,1,5,3,4,4,1,4,3,3,4,1,3,5,1,3,1,5,4,5))

    # define Theta grid for three latent classes
    Theta <- matrix(c(0,0,0, 1,0,0, 0,1,0, 0,0,1, 1,1,0, 1,0,1, 0,1,1, 1,1,1),
                     ncol=3, byrow=TRUE)
    mod_discrete <- mdirt(dat, 3, customTheta = Theta, TOL = 1e-2, verbose=FALSE)
    expect_equal(extract.mirt(mod_discrete, 'logLik'), -9432.635, tolerance = 1e-4)
    so <- summary(mod_discrete)
    expect_equal(as.numeric(sort(so$Class.Probability[,'prob'])), c(0.0004940534,0.003972187,0.04249068,0.05372494,0.08291352,0.2009768,0.2657006,0.3497273), tolerance = 1e-2)

    #-----------------

    # multiple group test with constrained group probabilities
    group <- rep(c('G1', 'G2'), each = nrow(SAT12)/2)
    Theta <- diag(2)
    model <- mirt.model('A1 = 1-32
                         A2 = 1-32
                         CONSTRAINB = (33, c1)')
    mod <- mdirt(dat, model, group = group, customTheta = Theta,
                 verbose = FALSE)
    expect_equal(logLik(mod), -9598.103, tolerance = 1e-4)
    expect_equal(as.numeric(coef(mod)[[1]][[33]]), .4165249, tolerance=1e-2)
    expect_equal(M2(mod)$M2, 1239.17, tolerance = 1)

#
#     data(data.read, package = 'sirt')
#     dat <- data.read
#
#     # define discrete theta distribution with 3 dimensions
#     Theta <- matrix(c(0,0,0, 1,0,0, 0,1,0, 0,0,1, 1,1,0, 1,0,1, 0,1,1, 1,1,1), ncol=3, byrow=TRUE)
#
#     # define mirt model
#     I <- ncol(dat) # I = 12
#     mirtmodel <- mirt.model("F1 = 1-4
#                             F2 = 5-8
#                             F3 = 9-12")
#
#     # get parameters
#     mod.pars <- mdirt(dat, model=mirtmodel, itemtype = '2PL', pars = "values")
#
#     # starting values d parameters (transformed guessing parameters)
#     ind <- which( mod.pars$name == "d" )
#     mod.pars[ind,"value"] <- qlogis(.2)
#
#     # starting values transformed slipping parameters
#     ind <- which( ( mod.pars$name %in% paste0("a",1:3) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- qlogis(.8) - qlogis(.2)
#
#     mod_mdiscrete <- mdirt(dat, mirtmodel, pars=mod.pars, itemtype = '2PL',
#                            technical = list(customTheta=Theta), verbose=FALSE)
#     so <- summary(mod_mdiscrete)
#     expect_equal(mod_mdiscrete@logLik, -1923.518, tolerance = 1e-4)
#     expect_equal(as.numeric(sort(so$Class.Proportions)),
#                  c(0.007497902, 0.008688461, 0.009559938, 0.010802275, 0.040517211,
#                    0.041186267, 0.415900556, 0.465847391), tolerance = 1e-4)
#     expect_equal(sd(as.numeric(sort(so[[1]]))), 0.3891998, tolerance = 1e-4)

#     #-----------------
#     #located latent class model
#     data(data.read, package = 'sirt')
#     dat <- data.read
#
#     items <- colnames(dat)
#
#     # use 10th item as the reference item
#     ref.item <- 10
#
#     # define mirt model
#     I <- ncol(dat) # I = 12
#     mirtmodel <- mirt::mirt.model("
#                                   C1 = 1-12
#                                   C2 = 1-12
#                                   C3 = 1-12
#                                   CONSTRAIN = (1-12,a1),(1-12,a2),(1-12,a3)
#                                   ")
#
#     # get parameters
#     mod.pars <- mdirt(dat, model=mirtmodel, itemtype = '2PL', pars = "values")
#
#     # set starting values for class specific item probabilities
#     mod.pars[ mod.pars$name == "d" ,"value" ] <- qlogis( colMeans(dat,na.rm=TRUE) )
#
#     # set item difficulty of reference item to zero
#     ind <- which( ( paste(mod.pars$item) == items[ref.item] ) &
#     ( ( paste(mod.pars$name) == "d" ) ) )
#     mod.pars[ ind ,"value" ] <- 0
#     mod.pars[ ind ,"est" ] <- FALSE
#
#     mod_llca <- mdirt(dat, mirtmodel, itemtype='2PL', pars=mod.pars, verbose=FALSE)
#     so <- summary(mod_llca)
#     expect_equal(mod_llca@logLik, -1967.22, tolerance = 1e-4)
#     expect_equal(as.numeric(sort(so$Class.Proportions)),
#                  c(0.02909875, 0.46250363, 0.50839762), tolerance = 1e-2)
#     expect_equal(as.numeric(sort(so[[1]])),
#                  c(0.0472525,0.2285291,0.3232925,0.6767075,0.7714709,0.9527475),
#                  tolerance = 1e-3)

})

#     #----------
#     #-- define Theta design matrix for 5 classes
#     set.seed(979)
#     I <- 9
#     N <- 5000
#     b <- seq( - 1.5, 1.5 , len=I)
#     b <- rep(b,3)
#
#     # define class locations
#     theta.k <- c(-3.0, -4.1, -2.8 , 1.7 , 2.3 , 1.8 ,
#                  0.2 , 0.4 , -0.1 ,
#                  2.6 , 0.1, -0.9, -1.1 ,-0.7 , 0.9 )
#     Nclasses <- 5
#     theta.k0 <- theta.k <- matrix( theta.k , Nclasses , 3 , byrow=TRUE )
#     pi.k <- c(.20,.25,.25,.10,.20)
#     theta <- theta.k[ rep( 1:Nclasses , round(N*pi.k) ) , ]
#     dimensions <- rep( 1:3 , each=I)
#
#     # simulate item responses
#     dat <- matrix( NA , nrow=N , ncol=I*3)
#     for (ii in 1:(3*I) ){
#         dat[,ii] <- 1 * ( runif(N) < plogis( theta[, dimensions[ii] ] - b[ ii] ) )
#     }
#
#     Theta <- diag(5)
#     Theta <- cbind( Theta , Theta , Theta )
#     r1 <- rownames(Theta) <- paste0("C",1:5)
#     colnames(Theta) <- c( paste0(r1 , "D1") , paste0(r1 , "D2") , paste0(r1 , "D3") )
#
#     I <- ncol(dat) # I = 27
#     mirtmodel <- mirt::mirt.model("C1D1 = 1-9
#                                   C2D1 = 1-9
#                                   C3D1 = 1-9
#                                   C4D1 = 1-9
#                                   C5D1 = 1-9
#                                   C1D2 = 10-18
#                                   C2D2 = 10-18
#                                   C3D2 = 10-18
#                                   C4D2 = 10-18
#                                   C5D2 = 10-18
#                                   C1D3 = 19-27
#                                   C2D3 = 19-27
#                                   C3D3 = 19-27
#                                   C4D3 = 19-27
#                                   C5D3 = 19-27
#                                   CONSTRAIN = (1-9,a1),(1-9,a2),(1-9,a3),(1-9,a4),(1-9,a5), (10-18,a6),(10-18,a7),(10-18,a8),(10-18,a9),(10-18,a10), (19-27,a11),(19-27,a12),(19-27,a13),(19-27,a14),(19-27,a15)
#                                   ")
#
#     #-- get initial parameter values
#     mod.pars <- mdirt(dat, model=mirtmodel, itemtype = '2PL', pars = "values")
#
#     #-- redefine initial parameter values
#     # set all d parameters initially to zero
#     ind <- which( ( mod.pars$name == "d" ) )
#     mod.pars[ ind ,"value" ] <- 0
#
#     # fix item difficulties of reference items to zero
#     mod.pars[ ind[ c(5,14,23) ] , "est"] <- FALSE
#
#     # initial item parameters of cluster locations (a1,...,a15)
#     ind <- which( ( mod.pars$name %in% paste0("a", c(1,6,11) ) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- -2
#     ind <- which( ( mod.pars$name %in% paste0("a", c(1,6,11)+1 ) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- -1
#     ind <- which( ( mod.pars$name %in% paste0("a", c(1,6,11)+2 ) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- 0
#     ind <- which( ( mod.pars$name %in% paste0("a", c(1,6,11)+3 ) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- 1
#     ind <- which( ( mod.pars$name %in% paste0("a", c(1,6,11)+4 ) ) & ( mod.pars$est ) )
#     mod.pars[ind,"value"] <- 0
#
#     mod_multidim <- mdirt(dat, mirtmodel, itemtype = '2PL', technical = list(customTheta=Theta))

