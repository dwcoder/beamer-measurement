functions {


    real my_exp_lpdf(real y, real theta){
      return (log(theta) - theta*y);
    }

    real my_exp_vec_lpdf(vector y, real theta){
      return sum(log(theta) - theta*y);
    }

}

data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
real<lower=0> theta;

}
model {

  y ~ my_exp_vec(theta);
  theta ~ lognormal(0, 1000);

}
