#The goal is to clean the UNICEF Data Warehouse export
# Input:  data/raw/UNICEF_DW.csv
# Output: data/clean/unicef_clean.csv


library(tidyverse)

 
##########################STEP 1: Load the raw file############################################

raw <- read_csv("data/raw/UNICEF_DW.csv", show_col_types = FALSE)

# Always look at the data first
dim(raw)       #how many rows and columns?  27893 and  39
names(raw)     #what are all the column names?
head(raw)      #what does the data look like?

#######################################STEP 2: Dropping columns that add no analytical value####################################
#These are metadata/system columns that UNICEF includes in every export but contain the same value in every row,or are just code versions of columns we already have as labels

unicef_clean <- raw %>%
  select(
    #KEEP: geographic info
    country_code  = REF_AREA,
    country       = REF_AREA_LABEL,
    
    #KEEP: indicator info
    indicator_code = INDICATOR,
    indicator      = INDICATOR_LABEL,
    
    #KEEP: disaggregation dimensions
    sex            = SEX_LABEL,
    age_group      = AGE_LABEL,
    urbanisation   = URBANISATION_LABEL,
    
    #KEEP: the actual data
    year           = TIME_PERIOD,
    value          = OBS_VALUE,
    unit           = UNIT_MEASURE_LABEL,
    unit_type      = UNIT_TYPE_LABEL,
    
    #KEEP: data quality flag (important for analysis)
    obs_status     = OBS_STATUS_LABEL,
    
    #KEEP: source info (buried in comment text)
    comment_obs    = COMMENT_OBS,
    comment_ts     = COMMENT_TS
    
    #DROPPED (not keeping):
    #STRUCTURE, STRUCTURE_ID, ACTION         — system metadata, is the same in every row
    #FREQ, FREQ_LABEL                        — is "Annual"
    #SEX, AGE, URBANISATION                  — code versions, we have the labels
    #UNIT_MEASURE, UNIT_MULT, UNIT_MULT_LABEL — redundant with unit_type
    #TIME_FORMAT, TIME_FORMAT_LABEL          — is the same
    #DATABASE_ID, DATABASE_ID_LABEL          — it is  "UNICEF Data Warehouse"
    #OBS_CONF, OBS_CONF_LABEL                — it is "Public"
    #COMP_BREAKDOWN_1/2/3 and their labels   — all "Not Applicable" in this export
    #OBS_STATUS                              — kept the label version instead
  )
unicef_clean


#################################STEP 3: Extract data source from the comment_obs column########################################
#The comment looks like: "Observation Footnote: Children with disabilities - Data Source: MICS_2022_23" We want to pull out just the data source part

unicef_clean <- unicef_clean %>%
  mutate(
    #str_extract pulls text matching a pattern
    #"(?<=Data Source:  )\\S+" means: grab non-space characters after "Data Source:  "
    data_source = str_extract(comment_obs, "(?<=Data Source:  )\\S+")
  )

#Check it worked
unicef_clean %>%
  select(comment_obs, data_source) %>%
  head(5)



############################STEP 4: Clean up text values#######################################################

unicef_clean <- unicef_clean %>%
  mutate(
    #Replace "Total" urbanisation with something cleaner
    urbanisation = if_else(urbanisation == "Total", "All areas", urbanisation),
    
    #Trim any accidental whitespace from text columns
    country    = str_trim(country),
    indicator  = str_trim(indicator),
    sex        = str_trim(sex),
    age_group  = str_trim(age_group),
    
    #Make obs_status NA where it is missing
    obs_status = na_if(obs_status, "NA")
  )
unicef_clean

###################################STEP 5: Check for problems########################################################

#Any missing values in the key columns? only one column 
unicef_clean %>%
  summarise(
    missing_country   = sum(is.na(country)),
    missing_indicator = sum(is.na(indicator)),
    missing_year      = sum(is.na(year)),
    missing_value     = sum(is.na(value)),
    missing_status    = sum(is.na(obs_status))
  )

#What are the unique indicators? there are 16 indicators in total. 
#Body mass index (BMI) is a value derived from the mass and height of a person.
unicef_clean %>%
  count(indicator_code, indicator) %>%
  print(n = 30)

#What years are covered? years: 1970-2023
range(unicef_clean$year, na.rm = TRUE)

#How many countries? 200 countries
n_distinct(unicef_clean$country)

#How many records flagged as "Low reliability"? 5 
unicef_clean %>%
  count(obs_status, sort = TRUE)

#Which countries have low reliability data? Georgia (n=2); Kyrgyz Republic(n=2); Turkmenistan (n=1)  
unicef_clean %>%
  filter(obs_status == "Low reliability") %>%
  count(country, sort = TRUE)


# How many NAs in obs_status, and are their values still present?
unicef_clean %>%
  filter(is.na(obs_status)) %>%
  summarise(
    n_rows        = n(),
    missing_value = sum(is.na(value)),
    year_range    = paste(min(year), "-", max(year)),
    countries     = n_distinct(country)
  )

# Which indicators have the most NAs in obs_status?
unicef_clean %>%
  filter(is.na(obs_status)) %>%
  count(indicator, sort = TRUE)

##################################STEP 6: Optional — flag low reliability records##################################
#I want to exclude these from analysis or keep them but mark them clearly
#only flag low reliability (treat NA status as acceptable)

unicef_clean <- unicef_clean %>%
  mutate(
    reliable = case_when(
      obs_status == "Low reliability" ~ FALSE,
      TRUE                            ~ TRUE
    )
  )

#How many reliable vs unreliable? reliable: reliable: 27888; unreliable: 5
unicef_clean %>% count(reliable)



########################STEP 7: Drop the raw comment columns now that we extracted#####################################
#what we need from them

unicef_clean <- unicef_clean %>%
  select(-comment_obs, -comment_ts)


####################################STEP 8: Final check — look at the clean data############################################

dim(unicef_clean)     #should be 27893 rows, ~12 columns
names(unicef_clean)   #clean column names
head(unicef_clean)    #looks good?
glimpse(unicef_clean) #data types correct?

#Quick summary of the key columns
unicef_clean %>%
  select(country, indicator, sex, year, value, obs_status, reliable) %>%
  summary()


#######################STEP 9: Save the clean file#################################

write_csv(unicef_clean, "data/clean/unicef_clean.csv")

message("Done! Clean data saved to data/clean/unicef_clean.csv")
message(paste("Rows:", nrow(unicef_clean)))
message(paste("Columns:", ncol(unicef_clean)))
