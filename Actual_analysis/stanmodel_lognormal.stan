functions {

real[] mean_cov_to_mu_sigma(real mmean, real cov_variation){

      real mu;
      real sigma;
      real ssd;
      real return_vec[2];

      ssd = cov_variation*mmean;

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return_vec[1] = mu;
      return_vec[2] = sigma;

      return return_vec;
}

    /* reparametrise the lognormal) */
    real my_lognormal_lpdf(real y, real mmean, real cov_variation){

      real mu;
      real sigma;
      real ssd;

      ssd = cov_variation*mmean;

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return lognormal_lpdf(y | mu, sigma );
    }

    real myF(real y, vector theta){

      real mmean;
      real ssd;
      real mu;
      real sigma;
      real cov_variation;

      mmean = theta[1];
      cov_variation = theta[2];
      ssd = cov_variation*mmean;

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return lognormal_cdf( y , mu, sigma );
    }

    real my_logf(real y, vector theta){

      real mmean;
      real ssd;
      real mu;
      real sigma;
      real cov_variation;

      mmean = theta[1];
      cov_variation = theta[2];
      ssd = cov_variation*mmean;

      sigma = sqrt( log( 1+ ( ssd^2)/( mmean^2 )   )   );
      mu = log( mmean ) - (0.5)*sigma^2;

      return lognormal_lpdf(y | mu, sigma );
    }

    real order_statistic_dist_lpdf(vector y, vector theta ){

        real N;
        real k;

        real F_min;
        real F_median;
        real F_max;

        real log_f_min;
        real log_f_median;
        real log_f_max;

        N = round(y[4]); // We could do this better by splitting the int and real
        k = ceil(N/2);

        F_min    = myF(y[1], theta);
        F_median = myF(y[2], theta);
        F_max    = myF(y[3], theta);

        log_f_min    = my_logf(y[1], theta);
        log_f_median = my_logf(y[2], theta);
        log_f_max    = my_logf(y[3], theta);

        return
                (k - 2 ) *log( F_median  - F_min )
            + (N - k - 1 )*log( F_max - F_median )
            + log_f_min
            + log_f_median
            + log_f_max ;

    }



}

data {
  int<lower=0> N;
  vector<lower=0>[4] y[N];
  int<lower=0> n_groups;
  int<lower=0> n_years;
  int<lower=0> groupnum[N];

  int<lower=0> yearnum[N];

  int<lower=0> N_special;
  real<lower=0> y_special[N_special];
  int<lower=0> groupnum_special[N_special];
  int<lower=0> yearnum_special[N_special];
}
parameters {
real par_group[n_groups-1];
real par_year[n_years-1];
real par_intercept;
real<lower=0> cov_variation;
}

model {
  vector[2] theta;
  real par_group_with_dummy[n_groups];
  real par_year_with_dummy[n_years];

  // Make a dummy variables
  // The last one is the dummy
  par_group_with_dummy[n_groups] = 0;
  for (i in 1:(n_groups-1)) par_group_with_dummy[i] = par_group[i];

  par_year_with_dummy[n_years] = 0;
  for (i in 1:(n_years-1)) par_year_with_dummy[i] = par_year[i];

  theta[2]  = cov_variation;

  for(i in 1:N){
    theta[1] = exp(par_intercept
                   + par_group_with_dummy[groupnum[i]]
                   + par_year_with_dummy[yearnum[i]]
                   ); // mean
    y[i] ~ order_statistic_dist(theta);
  }

  for(i in 1:N_special){
    theta[1] = exp(par_intercept
                   + par_group_with_dummy[groupnum_special[i]]
                   + par_year_with_dummy[yearnum_special[i]]
                   ); // mean
    y_special[i] ~ my_lognormal(theta[1], theta[2]);
  }

  par_group~ normal(0, 10);
  par_intercept~ normal(0, 100);
  cov_variation ~ lognormal(0, 2);


}
generated quantities{

real the_mean[n_groups];
real the_mu[n_groups];
real the_sigma[n_groups];

real musigma[2];

// Generate the mean claim for the dummy/baseline case, only for the final year

    for( i in 1:(n_groups-1)){

        the_mean[i] = exp(par_intercept
                        + par_group[i]
                        // + par_year[i] //final year value is 0
                        );

        musigma = mean_cov_to_mu_sigma(the_mean[i], cov_variation);

        the_mu[i] = musigma[1];
        the_sigma[i] = musigma[2];

    }

// For the base case:

the_mean[n_groups] = exp(par_intercept );

musigma = mean_cov_to_mu_sigma(the_mean[n_groups], cov_variation);

the_mu[n_groups] = musigma[1];
the_sigma[n_groups] = musigma[2];

}

