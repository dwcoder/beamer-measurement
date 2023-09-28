data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
real<lower=0> theta;

}
model {

  y ~ exponential(theta);
  theta ~ lognormal(0, 1000);

}
