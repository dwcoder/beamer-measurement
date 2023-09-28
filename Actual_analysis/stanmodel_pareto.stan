functions {

    real myF(real y, vector theta){
      # pareto(0 , scale, shape)
      return pareto_type_2_cdf(y, 0, theta[1], theta[2] );
    }

    real my_logf(real y, vector theta){
      return pareto_type_2_log(y, 0, theta[1], theta[2] );
    }

    real ordered_stats_dist_log(vector y, vector theta ){

        real N;
        real k;

        real F_x_min;
        real F_x_median;
        real F_x_max;

        real log_f_x_min;
        real log_f_x_median;
        real log_f_x_max;

        N <- round(y[4]); # We could do this better by splitting the int and real
        k <- ceil(N/2);

        F_x_min    <- myF(y[1], theta);
        F_x_median <- myF(y[2], theta);
        F_x_max    <- myF(y[3], theta);

        log_f_x_min    <- my_logf(y[1], theta);
        log_f_x_median <- my_logf(y[2], theta);
        log_f_x_max    <- my_logf(y[3], theta);

        return
                (k - 2 ) *log( F_x_median  - F_x_min )
            + (N - k - 1 )*log( F_x_max - F_x_median )
            + log_f_x_min
            + log_f_x_median
            + log_f_x_max ;

    }



}

data {
  int<lower=0> N;
  vector<lower=0>[4] y[N];
  int<lower=0> n_groups;
  int<lower=0> groupnum[N];
}
parameters {
real par_group[n_groups-1];
real par_intercept;
real<lower=0> alpha;
}

model {
  # Theta holds the pareto parameters: [1] is scale, [2] is shape
  vector[2] theta;
  real par_group_with_dummy[n_groups];

  # Make a dummy variable
  # The last one is the dummy
  par_group_with_dummy[n_groups] <- 0;
  for (i in 1:(n_groups-1)) par_group_with_dummy[i] <- par_group[i];

  #theta[2] <- log(5)/log(4); # 80/20 principle
  theta[2] <- alpha; #scale parameter

  for(i in 1:N){
    theta[1] <- exp(par_intercept + par_group_with_dummy[groupnum[i]] )*theta[2] ;
    y[i] ~ ordered_stats_dist( theta );
  }

  par_group~ normal(0, 1000);
  par_intercept~ normal(0, 1000);
  alpha ~ lognormal(0, 1000);


}
