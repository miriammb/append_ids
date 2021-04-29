# single wrapper for the two existing append ids functions
source("dyad_append_ids.R")
source("cy_append_ids.R")

append_ids <- function(df, dyad = FALSE, breaks = TRUE){
  if(dyad){
    print("Adding ID variables to dyadic data...")
    dat <- dyad_append_ids(df, breaks)
    return(dat)
  }else{
    print("Adding ID variables to country-year data... Don't forget to set dyad = TRUE if you are working with dyadic data.")
    dat <- cy_append_ids(df, breaks)
    return(dat)
  }
}

append_suffix <- function(df, suffix){
  if(dyad){
    print("Adding variable suffixes to dyadic data...")
    dat <- dyad_append_suffix(df, suffix)
    return(dat)
  }else{
    print("Adding variable suffixes to country-year data... Don't forget to set dyad = TRUE if you are working with dyadic data.")
    dat <- cy_append_suffix(df, suffix)
    return(dat)
  }
}