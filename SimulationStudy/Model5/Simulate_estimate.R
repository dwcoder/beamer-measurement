
mu    <- 20
sigma <- 1

N = 1

n <- rep(30, N)

x <- rnorm(n, mu, sigma)

my.min <- min(x)
my.median <- median(x)
my.max <- max(x)

my.order.stats <- c(my.min, my.median, my.max, n)

my.order.stats <- matrix(my.order.stats, N, 4)


library(rstan) # observe startup messages
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
num_chains <- 6

my_dat <- list(N = 1, y = my.order.stats)

if(exists("fit")){
  fit <- stan(file = 'stanmodel.stan', fit=fit,  data = my_dat,  iter = 10000, chains=num_chains)
} else {
  fit <- stan(file = 'stanmodel.stan', data = my_dat,  iter = 10000, chains=num_chains)
}

summary(fit)
plot(fit)
