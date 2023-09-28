
source("Lognormal_utilityfunctions_old.R")

mean_base <- 10
sd_base <- 1
b_male <- 0.3

n <- 100
male <- c(rep(0, 50) , rep(1,50))


mean_person <- mean_base*exp(b_male*male)

sigma <- sqrt( log( 1+ ( sd_base^2)/( mean_person^2 )   )   )
mu    <- log( mean_person ) - (1/2)*sigma^2

y <- sapply(split(data.frame(mu=mu, sigma=sigma),1:n) , function(x) rlnorm(1, x$mu, x$sigma) )


library(rstan) # observe startup messages
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

my_inits <- list(list(mean_base=mean_base, sd_base=sd_base, beta=0) )
my_dat <- list(N = n, y = y, male=male)

fit <- stan(file = 'stanmodel.stan', data = my_dat, init=my_inits, iter = 10000, chains=1)


plot(fit)
summary(fit)



