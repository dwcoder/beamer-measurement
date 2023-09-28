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
   sigma[i]  = sqrt( log( 1+ (sd_base^2) / ( mean_person[i]^2 ) ) );
   mu[i]    = log( mean_person[i] ) - ((0.5)*sigma[i]^2);
  }
    y ~ lognormal(mu, sigma);


  mean_base ~ lognormal(0,100);
  sd_base ~ lognormal(0,100);
  beta ~ normal(0, 1000);

}
