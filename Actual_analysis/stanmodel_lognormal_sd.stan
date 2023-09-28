functions {

    real myF(real y, vector theta){

      real mmean;
      real ssd;
      real mu;
      real sigma;

      mmean = theta[1];
      ssd = theta[2];

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return lognormal_cdf( y , mu, sigma );
    }

    real my_logf(real y, vector theta){

      real mmean;
      real ssd;
      real mu;
      real sigma;

      mmean = theta[1];
      ssd = theta[2];

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return lognormal_lpdf(y | mu, sigma );
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

        N = round(y[4]); # We could do this better by splitting the int and real
        k = ceil(N/2);

        F_x_min    = myF(y[1], theta);
        F_x_median = myF(y[2], theta);
        F_x_max    = myF(y[3], theta);

        log_f_x_min    = my_logf(y[1], theta);
        log_f_x_median = my_logf(y[2], theta);
        log_f_x_max    = my_logf(y[3], theta);

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
  int<lower=0> n_years;
  int<lower=0> groupnum[N];

  int<lower=0> yearnum[N];
}
parameters {
real par_group[n_groups-1];
real par_year[n_years-1];
real par_intercept;
real<lower=0> ssd;
}

model {
  vector[2] theta;
  real par_group_with_dummy[n_groups];
  real par_year_with_dummy[n_years];

  # Make a dummy variables
  # The last one is the dummy
  par_group_with_dummy[n_groups] = 0;
  for (i in 1:(n_groups-1)) par_group_with_dummy[i] = par_group[i];

  par_year_with_dummy[n_years] = 0;
  for (i in 1:(n_years-1)) par_year_with_dummy[i] = par_year[i];

  theta[2]  = ssd;

  for(i in 1:N){
    theta[1] = exp(par_intercept
                   + par_group_with_dummy[groupnum[i]]
                   + par_year_with_dummy[yearnum[i]]
                   ); # mean
    y[i] ~ ordered_stats_dist(theta);
  }

  par_group~ normal(0, 1000);
  par_intercept~ normal(0, 1000);
  ssd ~ cauchy(0, 5);


}

generated quantities{
real the_mean;

the_mean = exp(par_intercept
                   + par_group[1]
                   + par_year[1]
                   );

}

