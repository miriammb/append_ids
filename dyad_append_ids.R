############################################
############################################
##    More efficient append_ids function for bilateral data      
##    Miriam Barnum
##    Updated 4/30/2019
############################################
############################################

dyad_append_ids <- function(df,breaks=T) {
  
  #Load in the country IDs file
  load("MasterGWNO.RDATA")
  
  # prevents false positives for "notfound"
  ids$minyear2 <- ifelse(ids$minyear2 == -9999, 9999, ids$minyear2)
  
  ############################################
  ## Format Data                            ##  
  ## (based on original append IDS function) #
  ############################################
  
  yrexists = 0
  ctryexists1 = 0
  ctryexists2 = 0
  for (i in 1:length(names(df))) {
    #Find the first country variable and name it repcountry
    if (names(df)[i]=="Country1" | names(df)[i]=="country1" | 
        names(df)[i]=="CountryName1" | names(df)[i]=="countryname1" | 
        names(df)[i]=="Countryname1" | names(df)[i]=="Country 1" | 
        names(df)[i]=="country 1" | names(df)[i]=="CountryName 1" | 
        names(df)[i]=="countryname 1" | names(df)[i]=="Countryname 1"| 
        names(df)[i]=="repcountry") {
      names(df)[i]="repcountry"
      df$repcountry = as.character(df$repcountry)
      ctryexists1=1
    }
    
    #Find the second country variable and name it parcountry
    if (names(df)[i]=="Country2" | names(df)[i]=="country2" | 
        names(df)[i]=="CountryName2" | names(df)[i]=="countryname2" | 
        names(df)[i]=="Countryname2" | names(df)[i]=="Country 2" | 
        names(df)[i]=="country 2" | names(df)[i]=="CountryName 2" | 
        names(df)[i]=="countryname 2" | names(df)[i]=="Countryname 2" |
        names(df)[i]=="parcountry") {
      names(df)[i]="parcountry"
      df$parcountry = as.character(df$parcountry)
      ctryexists2=1
    }
    
    #Check to see if the year variable exists
    if (names(df)[i]=="Year" | names(df)[i]=="year" | names(df)[i]=="YEAR") {
      names(df)[i] = "year"
      df$year <- as.numeric(df$year)
      yrexists = 1
    }
    
    #Check to see if gwno codes already exist
    if (names(df)[i] == "GWNo1" | names(df)[i]=="gwno1" | 
        names(df)[i]=="GWNO1" | names(df)[i] == "GWNo 1" 
        | names(df)[i]=="gwno 1" | names(df)[i]=="GWNO 1") {
      names(df)[i]="repgwno_raw"
    }
    
    if (names(df)[i] == "GWNo2" | names(df)[i]=="gwno2" | 
        names(df)[i]=="GWNO2" | names(df)[i] == "GWNo 2" 
        | names(df)[i]=="gwno 2" | names(df)[i]=="GWNO 2") {
      names(df)[i]="pargwno_raw"
    }
    
    #Check to see if cow codes already exist
    if (names(df)[i]=="COW1" | names(df)[i]=="cow1" | 
        names(df)[i]=="ccode1" | names(df)[i]=="cowcode1" |
        names(df)[i]=="COW 1" | names(df)[i]=="cow 1" | 
        names(df)[i]=="ccode 1" | names(df)[i]=="cowcode 1") {
      names(df)[i] = "repccode_raw"
    }
    
    if (names(df)[i]=="COW2" | names(df)[i]=="cow2" | 
        names(df)[i]=="ccode2" | names(df)[i]=="cowcode2") {
      names(df)[i] = "parccode_raw"
    }
  }
  
  if(ctryexists1 == 0 |ctryexists2 == 0 ) {
    stop("The data must have variables containing both country names 
         before the append ids function is called")
  }
  
  if (yrexists == 0) {
    # We're going to pretend that the year of every observation is 2015
    df$year = rep(2015,nrow(df))
  }
  
  #############################
  ## Preprocess Country Names #
  #############################
  
  df$repcountryname_raw <- df$repcountry
  df$repcountry <- tolower(df$repcountry)
  df$repcountry <- gsub('[[:punct:]]', '', df$repcountry)
  df$repcountry <- gsub('\\s', '', df$repcountry) 
  
  df$parcountryname_raw <- df$parcountry
  df$parcountry <- tolower(df$parcountry)
  df$parcountry <- gsub('[[:punct:]]', '', df$parcountry)
  df$parcountry <- gsub('\\s', '', df$parcountry) 
  
  ########################
  ## Append Country IDs #
  ########################
  
  # keep track of countries without gwnos
  df$repnotfound <- NA
  df$parnotfound <- NA
  
  # merge in ids for repcountry
  df <- merge(df, ids, by.x = "repcountry", by.y = "country", all.x = T)
  
  # note country names not found, or outside of min/max years
  df$repnotfound <- ifelse(!is.na(df$gwno),
                           !((df$minyear1<=df$year & df$maxyear1>=df$year) | (df$minyear2<=df$year & df$maxyear2>=df$year)),TRUE)
  notfound <- df$repcountryname_raw[df$repnotfound]
  df <- df[!(df$repnotfound),]
  
  #print(df)
  
  df[,c("minyear1", "maxyear1", "minyear2", "maxyear2","repnotfound")] <- NULL
  
  names(df)[names(df)=="gwno"] <- "repgwno"
  names(df)[names(df)=="ccode"] <- "repccode"
  names(df)[names(df)=="ifscode"] <- "repifscode"
  names(df)[names(df)=="ifs"] <- "repifs"
  names(df)[names(df)=="gwabbrev"] <- "repgwabbrev"
  names(df)[names(df)=="gwname"] <- "repcountry.stand"
  
  # merge in ids for parcountry
  df <- merge(df, ids, by.x = "parcountry", by.y = "country", all.x = T)
  
  # note country names not found, or outside of min/max years
  df$parnotfound <- ifelse(!is.na(df$gwno),
                           !((df$minyear1<=df$year & df$maxyear1>=df$year) | (df$minyear2<=df$year & df$maxyear2>=df$year)), TRUE)
  notfound <- c(df$parcountryname_raw[df$parnotfound], notfound)
  df <- df[!(df$parnotfound),]
  
  #print(df)
  
  df[,c("minyear1", "maxyear1", "minyear2", "maxyear2", "parnotfound")] <- NULL
  
  names(df)[names(df)=="gwno"] <- "pargwno"
  names(df)[names(df)=="ccode"] <- "parccode"
  names(df)[names(df)=="ifscode"] <- "parifscode"
  names(df)[names(df)=="ifs"] <- "parifs"
  names(df)[names(df)=="gwabbrev"] <- "pargwabbrev"
  names(df)[names(df)=="gwname"] <- "parcountry.stand"
  
  
  #############################
  # Display and check countries
  #  that did not get a gwno
  #############################
  notfound <- unique(notfound)
  notfound <- notfound[!(notfound %in% df$repcountryname_raw | notfound %in% df$parcountryname_raw)]
  
  print("The following countries were not given gwno codes: ")
  for (i in 1:length(notfound)) {
    print(notfound[i])
  }
  
  if(breaks) {
    print("**Check missing GWNO values, then type 'c' when done**")
    browser()
  }
  
  ###############################
  # Clean up and return dataframe
  ###############################
  
  # make gwno name be the country name
  df$repcountry <- NULL
  df$parcountry <- NULL
  names(df)[names(df)=="repcountry.stand"] = "repcountry"
  names(df)[names(df)=="parcountry.stand"] = "parcountry"
  
  # put the id variables first
  nonids <- names(df)[!(names(df) %in% c('repcountry','repgwno','parcountry','pargwno','year','repccode','parccode','repifs','parifs',
                                         'repifscode','parifscode','repgwabbrev','pargwabbrev'))]
  df <- df[,c('repcountry','repgwno','parcountry','pargwno','year','repccode','parccode','repifs','parifs',
              'repifscode','parifscode','repgwabbrev','pargwabbrev',nonids)]
  
  # Sort the data by gwno and year
  df = df[order(df$repgwno,df$pargwno,df$year),]
  
  
  #If the year variable was created and not originally part of the data, drop it here
  if (yrexists==0) {
    #Find theyear variable
    yrloc = -1
    for (q in 1:length(names(df))) {
      if (names(df)[q]=="year") {
        yrloc = q
        break
      }
    }
    df = df[,-yrloc]
  }
  
  #return the data frame
  return(df)
}

#############################################
# Function to Add a New Country Name/Spelling
#############################################

# This function requires two inputs -- the new country name and the existing one
# e.g. add_name("IR of Afghanistan", "Afghanistan")

add_name <- function(newName, existingName){
  load("MasterGWNO.RDATA")
  #load("/Volumes/GoogleDrive/My Drive/Master IPE Data/raw-data v5/MasterGWNO.RDATA")
  
  if (!is.character(newName) | !is.character(existingName)) {
    stop("Names must be provided as character strings.")
  }
  
  # preprocess names
  new <- tolower(newName)
  new <- gsub('[[:punct:]]', '', new)
  new <- gsub('\\s', '', new) 
  
  ex <- tolower(existingName)
  ex <- gsub('[[:punct:]]', '', ex)
  ex <- gsub('\\s', '', ex) 
  
  if (new %in% ids$country) {
    stop(paste(newName,"already exists in the MasterGWNO.RDATA file."))
  }
  
  if (!ex %in% ids$country) {
    stop(paste(existingName,"does not exist in the IDs file. Please provide a version of the country name that currently exists in the MasterGWNO.RDATA file."))
  }
  
  # duplicate old record, add new name
  tmp <- ids[ids$country == ex,]
  tmp$country <- new
  ids <- rbind(ids, tmp)
  
  save(ids,file = "MasterGWNO.RDATA")
  #save(ids,file="/Volumes/GoogleDrive/My Drive/Master IPE Data/MasterGWNO.RDATA")
  
  rm(ids)
}

###############################
# Function to Append Suffixes
###############################

dyad_append_suffix <- function(df,suffix) {
  ids.names = c("repcountry","parcountry","year","repgwno","repccode","repifscode","repifs","repgwabbrev",
                "pargwno","parccode","parifscode","parifs","pargwabbrev")
  for (i in 1:length(names(df))) {
    if ((names(df)[i] %in% ids.names)==F) {
      names(df)[i] = paste(names(df)[i],suffix,sep="_")
    }
  }
  return(df)
}

