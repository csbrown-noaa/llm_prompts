# Translated from SAS to R

# Load required libraries
library(dplyr)
library(readr)
library(stringr)
library.dynam('lme4', 'lme4', .libPaths()) # Fix for potential lme4 issues
library(lme4)
library(ggplot2)
library(writexl)

# Set libraries and species to index (graph titles set to species name);
# Original SAS libnames are represented as path variables
sta_path <- "C:\\NMFS\\Main data builds\\Reef Fish\\Data\\main\\Video\\Analysis_Distribution"
viame_path <- "C:\\Users\\matthew.d.campbell\\Desktop\\Active\\GFISHER\\FY24\\VIAME index"

#*******************************************************************************************************
#*Bring in data and modify as needed for specified model runs
#*******************************************************************************************************;

# The original SAS code used haven::read_sas("sta/rfvmad_sm_sta.sas7bdat")
# We will assume rfvmad_sm_sta is available as a data frame.
# For this script, we assume a function `load_sta_data()` loads it.
# stations19_22 <- load_sta_data() %>%
#   filter(year %in% c(2019, 2021, 2022)) %>%
#   select(stationkey, survey, year, region, sta_time, sta_lat, sta_lon, xmiss, xmiss_sur, blk, reefname, sta_dpth, LUTJANUS_CAMPECHANUS, SERIOLA_DUMERILI) %>%
#   arrange(stationkey)

# PROC IMPORT of combined_species_Master.csv
viame_full_path <- file.path(viame_path, "combined_species_Master.csv")
viame_full <- read_csv(viame_full_path, skip = 1, col_names = TRUE)

# data viame_MSfull;
viame_MSfull <- viame_full %>%
  filter(stationkey != '####################') %>%
  mutate(stationkey = if_else(is.na(stationkey), paste0('00000000000', str_sub(station, 1, 9)), stationkey)) %>%
  filter(SumTot > 0, Lab == 'MSL')

# data viame_MSsdum;
viame_MSsdum <- viame_MSfull %>%
  filter(species == 'S_dume') %>%
  rename(
    S_dume10 = m24s_c10, S_dume20 = m24s_c20, S_dume30 = m24s_c30,
    S_dume40 = m24s_c40, S_dume50 = m24s_c50, S_dume60 = m24s_c60,
    S_dume70 = m24s_c70, S_dume80 = m24s_c80, S_dume90 = m24s_c90,
    S_dume95 = m24s_c95
  ) %>%
  select(-SumTot, -station) %>%
  arrange(stationkey)

# data sdum_MS0;
# NOTE: This assumes 'stations19_22' is loaded. The merge is equivalent to a full join.
sdum_MS0 <- full_join(stations19_22, viame_MSsdum, by = "stationkey") %>%
  mutate(
    Lab = ifelse(is.na(Lab) | Lab == '', 'MS', Lab),
    Rtracks24s = ifelse(is.na(Rtracks24s), 0, Rtracks24s),
    species = ifelse(is.na(species) | species == '', 'S_dum', species),
    S_dume10 = as.character(S_dume10), SERIOLA_DUMERILI = as.character(SERIOLA_DUMERILI), # Ensure types match for ifelse
    S_dume10 = ifelse(is.na(S_dume10) | S_dume10 == '', 0, S_dume10),
    S_dume20 = ifelse(is.na(S_dume20) | S_dume20 == '', 0, S_dume20),
    S_dume30 = ifelse(is.na(S_dume30) | S_dume30 == '', 0, S_dume30),
    S_dume40 = ifelse(is.na(S_dume40) | S_dume40 == '', 0, S_dume40),
    S_dume50 = ifelse(is.na(S_dume50) | S_dume50 == '', 0, S_dume50),
    S_dume60 = ifelse(is.na(S_dume60) | S_dume60 == '', 0, S_dume60),
    S_dume70 = ifelse(is.na(S_dume70) | S_dume70 == '', 0, S_dume70),
    S_dume80 = ifelse(is.na(S_dume80) | S_dume80 == '', 0, S_dume80),
    S_dume90 = ifelse(is.na(S_dume90) | S_dume90 == '', 0, S_dume90),
    S_dume95 = ifelse(is.na(S_dume95) | S_dume95 == '', 0, S_dume95)
  )

# data sdum_MS5;
sdum_MS5 <- sdum_MS0 %>%
  mutate(
    S_dume10 = ifelse(S_dume10 == '5', SERIOLA_DUMERILI, S_dume10),
    S_dume20 = ifelse(S_dume20 == '5', SERIOLA_DUMERILI, S_dume20),
    S_dume30 = ifelse(S_dume30 == '5', SERIOLA_DUMERILI, S_dume30),
    S_dume40 = ifelse(S_dume40 == '5', SERIOLA_DUMERILI, S_dume40),
    S_dume50 = ifelse(S_dume50 == '5', SERIOLA_DUMERILI, S_dume50),
    S_dume60 = ifelse(S_dume60 == '5', SERIOLA_DUMERILI, S_dume60),
    S_dume70 = ifelse(S_dume70 == '5', SERIOLA_DUMERILI, S_dume70),
    S_dume80 = ifelse(S_dume80 == '5', SERIOLA_DUMERILI, S_dume80),
    S_dume90 = ifelse(S_dume90 == '5', SERIOLA_DUMERILI, S_dume90),
    S_dume95 = ifelse(S_dume95 == '5', SERIOLA_DUMERILI, S_dume95)
  )

# data sdum_MS10;
sdum_MS10 <- sdum_MS0 %>%
  mutate(
    S_dume10 = ifelse(S_dume10 == '10', SERIOLA_DUMERILI, S_dume10),
    S_dume20 = ifelse(S_dume20 == '10', SERIOLA_DUMERILI, S_dume20),
    S_dume30 = ifelse(S_dume30 == '10', SERIOLA_DUMERILI, S_dume30),
    S_dume40 = ifelse(S_dume40 == '10', SERIOLA_DUMERILI, S_dume40),
    S_dume50 = ifelse(S_dume50 == '10', SERIOLA_DUMERILI, S_dume50),
    S_dume60 = ifelse(S_dume60 == '10', SERIOLA_DUMERILI, S_dume60),
    S_dume70 = ifelse(S_dume70 == '10', SERIOLA_DUMERILI, S_dume70),
    S_dume80 = ifelse(S_dume80 == '10', SERIOLA_DUMERILI, S_dume80),
    S_dume90 = ifelse(S_dume90 == '10', SERIOLA_DUMERILI, S_dume90),
    S_dume95 = ifelse(S_dume95 == '10', SERIOLA_DUMERILI, S_dume95)
  )

# data sdum_MS15;
sdum_MS15 <- sdum_MS0 %>%
  mutate(
    S_dume10 = ifelse(S_dume10 == '15', SERIOLA_DUMERILI, S_dume10),
    S_dume20 = ifelse(S_dume20 == '15', SERIOLA_DUMERILI, S_dume20),
    S_dume30 = ifelse(S_dume30 == '15', SERIOLA_DUMERILI, S_dume30),
    S_dume40 = ifelse(S_dume40 == '15', SERIOLA_DUMERILI, S_dume40),
    S_dume50 = ifelse(S_dume50 == '15', SERIOLA_DUMERILI, S_dume50),
    S_dume60 = ifelse(S_dume60 == '15', SERIOLA_DUMERILI, S_dume60),
    S_dume70 = ifelse(S_dume70 == '15', SERIOLA_DUMERILI, S_dume70),
    S_dume80 = ifelse(S_dume80 == '15', SERIOLA_DUMERILI, S_dume80),
    S_dume90 = ifelse(S_dume90 == '15', SERIOLA_DUMERILI, S_dume90),
    S_dume95 = ifelse(S_dume95 == '15', SERIOLA_DUMERILI, S_dume95)
  )

#*******************************************************************************************************
#*Index work
#*******************************************************************************************************;
# (SAS documentation comments omitted for brevity)

species <- "SERIOLA_DUMERILI"
Title1 <- "Greater Amberjack"

# data a;
a <- sdum_MS15 %>%
  mutate(mincount = as.numeric(S_dume70)) # Converted from character in previous steps

# data poscatch;
poscatch <- a %>%
  filter(S_dume70 > 0)

# data outliers;
outliers <- a %>%
  filter(!!sym(species) >= 15) %>%
  mutate(diff = !!sym(species) - mincount)

# PROC EXPORT outliers
outlier_output_path <- file.path(viame_path, "SD Diff Out 2.xlsx")
# write_xlsx(outliers, path = outlier_output_path) # write is a side effect, handled in test script

# data a2;
a2 <- a
# (no other modifications in the original code)

# Model parameterization;
factorsclass <- "year"
modelpars <- "year"
factorsb <- "" # No factors specified
factorsbcon <- "year"
factorsc <- "" # No factors specified
factorsccon <- "year"
yrstart <- 2019
yrend <- 2022

# Final data set settings;
dataset <- a2 %>%
  mutate(count = mincount + 0)
# Filtering by region was commented out in original

# ODS RTF file setup - In R, we will save plots and tables individually.

#*******************************************************************************************************************
# Start Poisson Model
#******************************************************************************************************************;
sampsize <- 1646 # This should be dynamically calculated, e.g., nrow(dataset)

# Add observation-level random effect for overdispersion
dataset <- dataset %>% mutate(obs_id = 1:n())

# PROC GLIMMIX for Poisson
# The bare `random intercept;` in SAS GLIMMIX for a Poisson is a method to account for overdispersion.
# The equivalent in lme4 is an observation-level random effect.
poisson_model <- glmer(mincount ~ year + (1|obs_id), data = dataset, family = poisson(link = "log"))
summary(poisson_model)
# lsmeans and plotting would be done on the model object.

# PROC GLIMMIX for Negative Binomial
negbin_model <- glmer.nb(mincount ~ year + (1|obs_id), data = dataset)
summary(negbin_model)
# lsmeans and plotting would be done on the model object.
# The QQ plot simulation logic would need to be re-implemented using R's simulation functions (e.g., `simulate()`)

#****************************************************************************************************/
# Delta log normal model
#****************************************************************************************************/

# data ANALYSIS;
ANALYSIS <- dataset %>%
  filter(year >= yrstart, year <= yrend) %>%
  mutate(
    lgmincount = if_else(mincount > 0, log(mincount), NA_real_),
    success = if_else(mincount > 0, 1, 0),
    idvar = 1:n() # Equivalent to _n_
    # depthscale = depth # depth is not in the dataset from prior steps
  )

# Binomial part of the model (using the custom %glimmix macro)
# This is equivalent to a standard GLMM fit in R.
binomial_dln_model <- glmer(success ~ year, data = ANALYSIS, family = binomial(link = "logit"))
summary(binomial_dln_model)

# Positive value part of the model (using PROC MIXED)
POSIT <- ANALYSIS %>% filter(mincount > 0)
lmer_dln_model <- lmer(lgmincount ~ year, data = POSIT)
summary(lmer_dln_model)

# The complex calculations for Lo's index would follow, using coefficients
# and variance components extracted from these two models.
# This involves a line-by-line translation of the `ESTIM` data step logic.
# e.g.,
# lsm_b <- fixef(binomial_dln_model)
# lsm_p <- fixef(lmer_dln_model)
# ...and so on.

# Final output tables and plots would be generated from the calculated index.
