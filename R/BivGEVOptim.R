


################################################################################################
##################################   BivGEVOptim    ############################################
################################################################################################

BivGEVOptim <- function (start.v, VC, respvec)
{
epsilon <- 1e-07
max.p <- 0.9999999
d.n1 <- der2p.dereta1 <- NULL
d.n2 <- der2p.dereta2 <- NULL
tau.eq1 <- VC$tau.eq1
tau.eq2 <- VC$tau.eq2
eta1 <- VC$X1 %*% start.v[1:VC$X1.d2]
eta2 <- VC$X2 %*% start.v[(VC$X1.d2 + 1):(VC$X1.d2 + VC$X2.d2)]
etad <- NULL
p1 <- exp(-(1 + tau.eq1 * (eta1))^(-1/tau.eq1))
p1 <- ifelse(p1 < epsilon, epsilon, p1)
p1 <- ifelse(p1 > max.p, max.p, p1)
cp1 <- 1 - p1

.e11 <- 1 + eta1 * tau.eq1
.e21 <- 1/tau.eq1
d.n1 <- exp(-(.e11)^-(.e21))/(.e11)^(1 + .e21)
d.n1 <- ifelse(d.n1 < epsilon, epsilon, d.n1)

p2 <- exp(-(1 + tau.eq2 * (eta2))^(-1/tau.eq2))
p2 <- ifelse(p2 < epsilon, epsilon, p2)
p2 <- ifelse(p2 > max.p, max.p, p2)
cp2 <- 1 - p2

.e12 <- 1 + eta2 * tau.eq2
.e22 <- 1/tau.eq2
d.n2 <- exp(-(.e12)^-(.e22))/(.e12)^(1 + .e22)
d.n2 <- ifelse(d.n2 < epsilon, epsilon, d.n2)

.e1 <- 1/tau.eq1
.e2 <- 1 + .e1
.e3 <- 1 + eta1 * tau.eq1
.e4 <- 2 * .e2
der2p.dereta1 <- (1/.e3^.e4 - tau.eq1 * .e2 * .e3^(.e1 - .e4)) * exp(-.e3^-.e1)

.e5 <- 1/tau.eq2
.e6 <- 1 + .e5
.e7 <- 1 + eta2 * tau.eq2
.e8 <- 2 * .e6
der2p.dereta2 <- (1/.e7^.e8 - tau.eq2 * .e6 * .e7^(.e5 - .e8)) * exp(-.e7^-.e5)


der2p1.dereta12 <- der2p.dereta1
der2p2.dereta22 <- der2p.dereta2

teta.st <- etad <- start.v[(VC$X1.d2 + VC$X2.d2 + 1)]
resT <- teta.tr(VC, teta.st)
teta.st <- resT$teta.st
teta <- resT$teta

p11 <- BiCDF(p1, p2, VC$nC, teta) #, VC$dof)
p10 <- pmax(p1 - p11, epsilon)
p01 <- pmax(p2 - p11, epsilon)
p00 <- pmax(1 - p11 - p10 - p01, epsilon)
l.par <- VC$weights * (respvec$y1.y2 * log(p11) + respvec$y1.cy2 *
        log(p10) + respvec$cy1.y2 * log(p01) + respvec$cy1.cy2 *
        log(p00))
dH <- copgHs(p1, p2, eta1 = NULL, eta2 = NULL, teta, teta.st,
      VC$BivD) #, VC$dof)
    c.copula.be1 <- dH$c.copula.be1
    c.copula.be2 <- dH$c.copula.be2
    c.copula.theta <- dH$c.copula.theta
    c.copula2.be1 <- dH$c.copula2.be1
    c.copula2.be2 <- dH$c.copula2.be2
    bit1.b1b1 <- c.copula2.be1 * d.n1^2 + c.copula.be1 * der2p1.dereta12
    bit2.b1b1 <- -c.copula2.be1 * d.n1^2 + (1 - c.copula.be1) *
        der2p1.dereta12
    bit3.b1b1 <- -bit1.b1b1
    bit4.b1b1 <- -bit2.b1b1
    bit1.b2b2 <- c.copula2.be2 * d.n2^2 + c.copula.be2 * der2p2.dereta22
    bit2.b2b2 <- -bit1.b2b2
    bit3.b2b2 <- -c.copula2.be2 * d.n2^2 + (1 - c.copula.be2) *
        der2p2.dereta22
    bit4.b2b2 <- -bit3.b2b2
    c.copula2.be1be2 <- dH$c.copula2.be1be2
    bit1.b1b2 <- c.copula2.be1be2 * d.n1 * d.n2
    bit2.b1b2 <- -bit1.b1b2
    bit3.b1b2 <- -bit1.b1b2
    bit4.b1b2 <- bit1.b1b2
    c.copula2.be1th <- dH$c.copula2.be1th
    bit1.b1th <- c.copula2.be1th * d.n1
    bit2.b1th <- -bit1.b1th
    bit3.b1th <- -bit1.b1th
    bit4.b1th <- bit1.b1th
    c.copula2.be2th <- dH$c.copula2.be2th
    bit1.b2th <- c.copula2.be2th * d.n2
    bit2.b2th <- -bit1.b2th
    bit3.b2th <- -bit1.b2th
    bit4.b2th <- bit1.b2th
 
    
    bit1.th2 <- dH$bit1.th2
    bit2.th2 <- -bit1.th2
    bit3.th2 <- -bit1.th2
    bit4.th2 <- bit1.th2
    
    dl.dbe1 <- VC$weights * d.n1 * ((respvec$y1.y2 * c.copula.be1/p11) +
        (respvec$y1.cy2 * (1 - c.copula.be1)/p10) + (respvec$cy1.y2 *
        c.copula.be1/(-p01)) + (respvec$cy1.cy2 * (c.copula.be1 -
        1)/p00))
    dl.dbe2 <- VC$weights * d.n2 * ((respvec$y1.y2 * c.copula.be2/p11) +
        (respvec$y1.cy2 * c.copula.be2/(-p10)) + (respvec$cy1.y2 *
        (1 - c.copula.be2)/(p01)) + (respvec$cy1.cy2 * (c.copula.be2 -
        1)/p00))
    dl.drho <- VC$weights * (respvec$y1.y2 * c.copula.theta/p11 +
        respvec$y1.cy2 * (-c.copula.theta)/p10 + respvec$cy1.y2 *
        (-c.copula.theta)/p01 + respvec$cy1.cy2 * c.copula.theta/p00)
    add.b <- 1

    ###########################
        d2l.be1.be1 <- -VC$weights * (respvec$y1.y2 * (bit1.b1b1 *
            p11 - (c.copula.be1 * d.n1)^2)/p11^2 + respvec$y1.cy2 *
            (bit2.b1b1 * p10 - ((1 - c.copula.be1) * d.n1)^2)/p10^2 +
            respvec$cy1.y2 * (bit3.b1b1 * p01 - (-c.copula.be1 *
                d.n1)^2)/p01^2 + respvec$cy1.cy2 * (bit4.b1b1 *
            p00 - ((c.copula.be1 - 1) * d.n1)^2)/p00^2)
        d2l.be2.be2 <- -VC$weights * (respvec$y1.y2 * (bit1.b2b2 *
            p11 - (c.copula.be2 * d.n2)^2)/p11^2 + respvec$y1.cy2 *
            (bit2.b2b2 * p10 - (-c.copula.be2 * d.n2)^2)/p10^2 +
            respvec$cy1.y2 * (bit3.b2b2 * p01 - ((1 - c.copula.be2) *
                d.n2)^2)/p01^2 + respvec$cy1.cy2 * (bit4.b2b2 *
            p00 - ((c.copula.be2 - 1) * d.n2)^2)/p00^2)
        d2l.be1.be2 <- -VC$weights * (respvec$y1.y2 * (bit1.b1b2 *
            p11 - (c.copula.be1 * d.n1 * c.copula.be2 * d.n2))/p11^2 +
            respvec$y1.cy2 * (bit2.b1b2 * p10 - ((1 - c.copula.be1) *
                d.n1) * (-c.copula.be2 * d.n2))/p10^2 + respvec$cy1.y2 *
            (bit3.b1b2 * p01 - (-c.copula.be1 * d.n1 * (1 - c.copula.be2) *
                d.n2))/p01^2 + respvec$cy1.cy2 * (bit4.b1b2 *
            p00 - ((c.copula.be1 - 1) * d.n1 * ((c.copula.be2 -
            1) * d.n2)))/p00^2)
        d2l.be1.rho <- -VC$weights * (respvec$y1.y2 * (bit1.b1th *
            p11 - (c.copula.be1 * d.n1 * c.copula.theta))/p11^2 +
            respvec$y1.cy2 * (bit2.b1th * p10 - ((1 - c.copula.be1) *
                d.n1) * (-c.copula.theta))/p10^2 + respvec$cy1.y2 *
            (bit3.b1th * p01 - (-c.copula.be1 * d.n1) * (-c.copula.theta))/p01^2 +
            respvec$cy1.cy2 * (bit4.b1th * p00 - ((c.copula.be1 -
                1) * d.n1) * c.copula.theta)/p00^2)/add.b
        d2l.be2.rho <- -VC$weights * (respvec$y1.y2 * (bit1.b2th *
            p11 - (c.copula.be2 * d.n2 * c.copula.theta))/p11^2 +
            respvec$y1.cy2 * (bit2.b2th * p10 - (-c.copula.be2 *
                d.n2) * (-c.copula.theta))/p10^2 + respvec$cy1.y2 *
            (bit3.b2th * p01 - ((1 - c.copula.be2) * d.n2) *
                (-c.copula.theta))/p01^2 + respvec$cy1.cy2 *
            (bit4.b2th * p00 - ((c.copula.be2 - 1) * d.n2) *
                c.copula.theta)/p00^2)/add.b
        d2l.rho.rho <- (-VC$weights * (respvec$y1.y2 * (bit1.th2 *
            p11 - (c.copula.theta/add.b)^2)/p11^2 + respvec$y1.cy2 *
            (bit2.th2 * p10 - (-c.copula.theta/add.b)^2)/p10^2 +
            respvec$cy1.y2 * (bit3.th2 * p01 - (-c.copula.theta/add.b)^2)/p01^2 +
            respvec$cy1.cy2 * (bit4.th2 * p00 - (c.copula.theta/add.b)^2)/p00^2))

        #################################
   
        if(0){
        criteria <- c(NaN, NA, Inf, -Inf)
        no.good <- apply(apply(cbind(l.par, dl.dbe1, dl.dbe2, dl.drho,
        d2l.be1.be1,d2l.be2.be2, d2l.be1.be2,d2l.be1.rho,d2l.be2.rho,d2l.rho.rho),
        c(1, 2), `%in%`, criteria), 1, any)
        good <- no.good == FALSE
        l.par <- l.par[good]
        dl.dbe1 <- dl.dbe1[good]
        dl.dbe2 <- dl.dbe2[good]
        dl.drho <- dl.drho[good]
        d2l.be1.be1 <- d2l.be1.be1[good]
        d2l.be2.be2 <- d2l.be2.be2[good]
        d2l.be1.be2 <- d2l.be1.be2[good]
        d2l.be1.rho <- d2l.be1.rho[good]
        d2l.be2.rho <- d2l.be2.rho[good]
        d2l.rho.rho <- d2l.rho.rho[good]
        VC$X1 <- as.matrix(VC$X1)
        VC$X2 <- as.matrix(VC$X2)}


        be1.be1 <- crossprod(VC$X1 * c(d2l.be1.be1), VC$X1)
        be2.be2 <- crossprod(VC$X2 * c(d2l.be2.be2), VC$X2)
        be1.be2 <- crossprod(VC$X1 * c(d2l.be1.be2), VC$X2)
        be1.rho <- t(t(rowSums(t(VC$X1 * c(d2l.be1.rho)))))
        be2.rho <- t(t(rowSums(t(VC$X2 * c(d2l.be2.rho)))))

        H <- rbind(cbind(be1.be1, be1.be2, be1.rho), cbind(t(be1.be2),
            be2.be2, be2.rho), cbind(t(be1.rho), t(be2.rho),
            sum(d2l.rho.rho)))
        G <- -c(colSums(c(dl.dbe1) * VC$X1), colSums(c(dl.dbe2) *
            VC$X2), sum(dl.drho))

     res <- -sum(l.par)

     S.h <- S.h1 <- S.h2 <- 0

    S.res <- res
    res <- S.res + S.h1
    G <- G + S.h2
    H <- H + S.h


    list(value = res, gradient = G, hessian = H, S.h = S.h, S.h1 = S.h1, S.h2 = S.h2,
        l = S.res, l.par = l.par, p11 = p11, p10 = p10,
        p01 = p01, p00 = p00, eta1 = eta1, eta2 = eta2, etad = etad,
        dl.dbe1 = dl.dbe1, dl.dbe2 = dl.dbe2, dl.drho = dl.drho, 
        BivD = VC$BivD, p1 = p1, p2 = p2, theta.star = teta.st, tau.eq1 = tau.eq1, tau.eq2 = tau.eq2)

}

