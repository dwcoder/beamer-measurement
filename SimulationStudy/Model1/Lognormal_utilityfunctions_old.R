library(magrittr)



LognormalParamsToMoments <- function( mu , sigma=NULL ){
  if( length(mu)==2 & is.null(sigma) )
  {
    return(LognormalParamsToMoments( mu[1] , mu[2] ) )
  }
  mean <- exp( mu + 0.5*sigma^2 )
  var <- (exp( sigma^2 ) - 1) *mean^2

  return(c(mean=mean, sd=sqrt(var) ) )
}

LognormalMomentsToParams <- function(mean , sd=NULL){
  if( length(mean)==2 & is.null(sd) )
  {
    return(LognormalMomentsToParams( mean[1] , mean[2] ) )
  }

  sigma  <-  sqrt( log( 1+ ( sd^2)/( mean^2 )   )   )
  mu    <- log( mean ) - (1/2)*sigma^2

  c(mu=mu, sigma=sigma)
}


Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}



# Takes three quantiles and fits a lognormal
FitLognorm <- function(myvector , plot=FALSE)
{
myqdist <- qlnorm

q <-  myvector


ofn <- function(x , q) sum( abs( q - myqdist( c( 0.025 , 0.5 , 0.975 )  , x[1] , x[2] ) )^2 )
osol <- optim(c(1,1),ofn , q=q)

if(plot)
{
 x11()
 myddist <- dlnorm
 plot( x <-seq(0 , q[3] , by=0.1)   , myddist( x , osol$par[1] , osol$par[2] ) , type="l" )
 points( q , myddist( q , osol$par[1] , osol$par[2] )  )
}
 
return( osol$par ) 


}
 
 

# This function takes the mode and the variance, and then sloves the mu and sigma
ModeAndVarToLognormal <- function( mode , variance=NULL)
{
   if( length(mode)==2 & is.null(variance) )
   { 
      return( modeandvar_to_lognormal( mode[1] , mode[2] ) )
   } 


  ofn <- function( x , mode, variance)
  {
   mu <- x[1]
   sigma <- x[2]
   
   # two error terms
   term1 <-  exp( mu - sigma^2 ) -  mode
   term2 <-  (exp(sigma^2) -1 )*(exp( 2*mu + sigma^2 ) ) - variance 
   
   return( sum( abs(c( term1 , term2) )^2  ) )
  }
  
  startsigma <- sqrt( log( 1 + variance/mode^2 )  ) 
  startmu <- log(mode) - 0.5*startsigma
  
  osol <- optim( c( startmu, startsigma ) , ofn , mode=mode , variance=variance ) 

  return(c( mu= osol$par[1] , sigma=osol$par[2]  ) )
  
}



InspectLognorm <- function( mu , sigma=NULL , quantile_points = c(  0.025 , 0.5 , 0.975 )  )
{
   if( length(mu)==2 & is.null(sigma) )
   { 
      return( InspectLognorm( mu[1] , mu[2] ) )
   } 
 
  ddist <- dlnorm
  qdist <- qlnorm
  
  xlims <- c(0 , qlnorm( 0.99 , mu , sigma ) )

  q <- qdist( quantile_points  , mu , sigma )
  
  plot( x <-seq(xlims[1] ,  xlims[2] , length.out=1000)  , ddist( x , mu , sigma) , type="l" )
  points( q , ddist( q ,  mu , sigma )  )

}


