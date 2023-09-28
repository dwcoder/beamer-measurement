library(actuar)


alpha <- log(5)/log(4) # 80/20 law


N = 80

n <- rpois(N,lambda=50 )
male <- rep(c(0,1), length.out=N)

par_intercept <- 1.3
par_male <- 0.5


subject_mean =  exp(par_intercept + par_male*male)

subject_beta = subject_mean*(alpha-1) # using the mean of the pareto to solve for alpha


list_x_all_data <- sapply( split(data.frame(subject_beta,n), 1:N ), function(x) rpareto(x$n, alpha, x$subject_beta ) )

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


plot(fit)
summary(fit)
