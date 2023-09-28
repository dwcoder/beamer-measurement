functions {

real make_sigma(real mean, real sd);
real make_mu(real mean, real sd);


    real make_sigma(real my_mean, real my_sd){
      return sqrt( log( 1+ (my_sd^2) / ( my_mean^2 ) ) );
    }

    real make_mu(real my_mean, real my_sigma){
      return log( my_mean ) - ((0.5)*my_sigma^2);
    }

}

data {
  int<lower=0> N;
  vector[N] y;
  vector[N] male;
}
parameters {
real<lower=0> mean_base;
real<lower=0> sd_base;
real beta;

}
model {
vector[N] mean_person;
vector[N] sigma;
vector[N] mu;


  for(i in 1:N){
   mean_person[i] = mean_base*exp(beta*male[i]);
   sigma[i] = make_sigma(mean_person[i], sd_base);
   mu[i] = make_mu(mean_person[i], sigma[i]);
  }
    y ~ lognormal(mu, sigma);


  mean_base ~ lognormal(0,100);
  sd_base ~ lognormal(0,100);
  beta ~ normal(0, 1000);

}
