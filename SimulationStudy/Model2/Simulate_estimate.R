
source("Lognormal_utilityfunctions_old.R")

mean_base <- 10
sd_base <- 2
b_male <- 0.03

n <- 1000
male <- rep(c(0,1), length.out=n)


mean_person <- mean_base*exp(b_male*male)

sigma <- sqrt( log( 1+ ( sd_base^2)/( mean_person^2 ) ) )
mu    <- log( mean_person ) - (1/2)*sigma^2

y <- sapply(split(data.frame(mu=mu, sigma=sigma),1:n) , function(x) rlnorm(1, x$mu, x$sigma) )


library(rstan) # observe startup messages
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
num_chains <- 6

my_inits <- rep(list(list(mean_base=mean_base, sd_base=sd_base, beta=0) ), num_chains)
my_dat <- list(N = n, y = y, male=male)

fit <- stan(file = 'stanmodel.stan', data = my_dat, init=my_inits, iter = 10000, chains=num_chains)

plot(fit)
summary(fit)

