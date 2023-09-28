functions {

    real myF(real y, vector theta){
      return normal_cdf(y, theta[1], theta[2] );
    }

    real my_lpdff(real y, vector theta){
     return normal_lpdf(y | theta[1], theta[2] );
    }

    real ordered_stats_dist_lpdf(vector y, vector theta ){

        real N;
        real k;

        real F_x_min;
        real F_x_median;
        real F_x_max;

        real log_f_x_min;
        real log_f_x_median;
        real log_f_x_max;

        N = round(y[4]); // We could do this better by splitting the int and real
        k = ceil(N/2);

        F_x_min    = myF(y[1], theta);
        F_x_median = myF(y[2], theta);
        F_x_max    = myF(y[3], theta);

        log_f_x_min    = my_lpdff(y[1], theta);
        log_f_x_median = my_lpdff(y[2], theta);
        log_f_x_max    = my_lpdff(y[3], theta);

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
  vector[4] y[N];
}
parameters {
real mu;
real<lower=0> sigma;
}
model {
vector[2] theta;

  theta[1] = mu;
  theta[2] = sigma;

  for(i in 1:N){
    y[i] ~ ordered_stats_dist( theta );
  }

  mu ~ normal(0, 1000);
  sigma ~ lognormal(0, 1000);


}
