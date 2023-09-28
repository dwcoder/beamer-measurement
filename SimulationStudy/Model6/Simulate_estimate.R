
alpha    <- 20
beta <- 5
sigma <- 1

N = 20

n <- rpois(N,lambda=30 )
male <- rep(c(0,1), length.out=N)


subject_mean =  alpha + beta*male

list_x_all_data <- sapply( split(data.frame(subject_mean,n), 1:N ), function(x) rnorm(x$n, x$subject_mean , sigma) )

x <- sapply(list_x_all_data, function(x){

    n <- length(x)
    my.min <- min(x)
    my.median <- median(x)
    my.max <- max(x)

    my.order.stats <- c(my.min, my.median, my.max, n)
    return(my.order.stats)
}
)

x <- t(x)


library(rstan) # observe startup messages
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
num_chains <- 6

my_dat <- list(N = N, y = x, male=male)

if(exists("fit")){
  fit <- stan(file = 'stanmodel.stan', fit=fit,  data = my_dat,  iter = 10000, chains=num_chains)
} else {
  fit <- stan(file = 'stanmodel.stan', data = my_dat,  iter = 10000, chains=num_chains)
}


summary(fit)
plot(fit)
