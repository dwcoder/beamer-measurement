

theta <- 0.1
n <- 1000


y <- rexp(n, theta)


library(rstan) # observe startup messages
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
num_chains <- 6

my_dat <- list(N = n, y = y)

fit <- stan(file = 'stanmodel.stan', data = my_dat,  iter = 10000, chains=num_chains)

summary(fit)
plot(fit)