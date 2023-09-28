# Stan sandbox

The purpose of these tests is to get rid of any syntax errors.
The end goal is to add my own functions and distributions to Stan, using their `functions` block.

But first I need to make sure the model without fancy functions and distributions work.
That will act as a testbed for more complicated ones.
From there on out we can add complexity.
Having a base of simple, working models to build on means a lot less debugging when errors pop up, as we know the code to be correct to a certain point.

## Model 1
A lognormal model, where I want to do a link function on the mean, rather than the mu.

Lessons learned: In the Stan for loop, order matters. You have to assign a value to the mu and sigma before you can use them in the lognormal sampling statement. This was not the case in JAGS


## Model 2
The same as model 1, but I add a function to make the work easier.

Lessons learned: Functions are surprisingly easy, but you sometimes have to declare and define them.
It probably doesn't do damage to always do both.
Defining them also declares them, according to the manual.

## Model 3
This is a simple exponential model. Will be a result against which to check model 4.

## Model 4
Implemented model 3 using my own sampling statement functions.

Lessons learned: There is an error in the stan manual, it looks like they are not allowing user [function overloading anymore](https://github.com/stan-dev/stan/issues/1547).


## Model 5
Here I will try to implement the ordered-statistic distribution
For now, I will use just one observation row.
That is, I will input just one vector of `c(min, med, max, n)` from which to estimate parameters.


## Model 6
Here I will use the ordered-statistic distribution from model 5 into a working regression (it will imitate a GLM).
Currently using the normal distribution
Next, I can try different distributions, like the pareto, so that I can fit it to the claims data.

## Model 7
This is the regression from model 6, but with a Pareto distribution rather than a normal distribution.
Working pareto regression, using only summary statistics.
It still uses simulated data, but a live version of this model used in the Cyber analysis of the NetDilligence data.
