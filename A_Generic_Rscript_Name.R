#The first data set gives political leanings for thousands of surveyed individuals across the US. The second gives crime and population 
#statistics for every state in the US. The third gives the governors for each state with their political affiliations. I wish to 
#investigate a relationship between statewide political learnings, a governor's political affilication and crime rates.

###Part A: Finding/reading the data###

#loading required packages
library(tidyverse) 
library(lmtest)
library(stringr)
library(nortest)
library(foreign)

#reading in the three datasets
pol = read.spss("~/home/joshz/Typology-17/Typology 17 public.sav", to.data.frame = T)
crime = read_csv("~/home/joshz/Crime.csv")
governors = read_csv("~/home/joshz/Governors.csv")




###Part B: Wrangling the data###

#Removing useless variable labels for political dataset and turning into tibble (to make data manipulation easier)
attributes(pol)$variable.labels = NULL
pol = as.tibble(pol)

#counting the number of Democrats, Republicans and independents surveyed for each state (for the political dataset)
pol = pol %>% 
  group_by(state) %>%
  summarise(surveyCount=n(), 
            Democrats=sum(party=="Democrat"), 
            Republicans=sum(party=="Republican"), 
            independents=sum(party=="Independent"), 
            other=sum(!(party %in% c("Republican", "Democrat", "Independent")))) 

#keeping only state and the political party in control (for the governor dataset)
governors = governors %>%
  select(State, Party) %>%
  rename(state=State, governorParty=Party)
head(governors)

#tidying up the crime dataset
crime = crime %>% 
  rename(state='Table 5', population=X4, crimes=X5) %>%         #making column names clearer
  fill(state) %>%                                               #filling in missing state values with the last non-missing state value
  filter(X2 == "State Total") %>%                               #Removing everything except statewide crime statistics (eg metropolitan crime stats)
  dplyr::select(state, population, crimes) %>%                  #only keeping variables of interest - violent crime, population and state name
  transform(population=str_replace_all(population, ',', ''),    #removing commas from the numbers
            crimes=str_replace(crimes, ',', '')) %>% 
  transform(population = as.numeric(population), crimes = as.numeric(crimes)) #making column types numberic for the columns that have numbers
head(crime)




###Part C: Joining tables###

#Re-formating datasets so that they can be joined by the 'state' variable
pol = transform(pol, state=str_to_upper(state)) 
crime = transform(crime, state=ifelse(state=="NORTH CAROLINA4", "NORTH CAROLINA", state))
governors = transform(governors, state=str_to_upper(state))

#joining datasets
pooledData = full_join(pol, governors, by = "state") 
pooledData = full_join(pooledData, crime, by = "state")
head(pooledData)

#computing the variables that will be used for creating relevant plots and drawing inferences
pooledData  = pooledData %>% 
  mutate(percDem = Democrats/surveyCount,              #percentage of surveyed individuals that were Democrat
         percRep = Republicans/surveyCount,            #percent that were Republican
         percInd = independents/surveyCount,           #percent that were independent
         percOth = other/surveyCount,                  #percent that identified as none of the three above
         crimeRate = crimes/(population/100000))       #violent crimes per 100,000 people
head(pooledData)
#NOTE: The first three variables created will serve as an estimate for the proportion of individuals in a given state that are Democrat, Republican and independent

#No crime numbers are reported for 'DISTRICT OF COLUMBIA', and thus we are removing it
pooledData = filter(pooledData, state!="DISTRICT OF COLUMBIA")

#Saving the final, joined, processed dataset
write.csv(pooledData, file="~/Desktop/pooledData.csv")











