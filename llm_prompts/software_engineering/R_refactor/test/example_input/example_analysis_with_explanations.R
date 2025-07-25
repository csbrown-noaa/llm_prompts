# SCRIPT: analyze_gulf_survey.R
# AUTHOR: A. Scientist
# DATE: July 7, 2025
# PURPOSE: Analyze fish abundance from the 2023-2024 Gulf of Mexico survey
# and model it against bottom temperature.

# A common but bad practice.
setwd("../example_input")

# -- 1. LOAD DATA --
# Load station metadata and survey catch data from the 'data' subdirectory.
station_info <- read.csv("./data/station_info.csv")
catchData = read.csv("./data/catch_data.csv", header = F)

# The catch data file has no header, so we have to name the columns manually.
colnames(catchData) = c("station_id", "species_name", "catch_count")


# -- 2. MERGE AND PREPARE DATA --
# Combine the two datasets into a single data frame
total.data <- merge(station_info, catchData, by="station_id")

# Calculate density (count per area). Note: this is a potential source of errors.
total.data$density_per_km2 = total.data$catch_count / total.data$area_swept_km2

# Remove non-finite values that result from division by zero, but don't log it.
# This silently drops station GOM-005 from the analysis!
total.data = total.data[is.finite(total.data$density_per_km2), ]

# --- NEW SECTION WITH IN-CODE LOGIC ERROR ---
# Convert density to square miles for comparison with US domestic surveys.
conversion_factor_km2_to_mi2 = 0.62 # ERROR: This is the linear factor for km -> mi, not the area factor!
total.data$density_per_sq_mi <- total.data$density_per_km2 / conversion_factor_km2_to_mi2
# The correct factor for km^2 to mi^2 is ~0.3861.
# --- END NEW SECTION ---


# -- 3. ANALYSIS - RED SNAPPER (Lutjanus campechanus) --
# Isolate the data for Red Snapper
red_snapper_data <- total.data[total.data$species_name == 'Lutjanus campechanus',]

# Fit a simple Poisson Generalised Linear Model
# We assume the count of fish is related to the bottom temperature
rs_model <- glm(catch_count ~ bottom_temp_c, data = red_snapper_data, family = poisson)
print("--- Red Snapper Model Summary ---")
summary(rs_model)

# Create a sequence of temperatures for prediction
new_temps = data.frame(bottom_temp_c = seq(min(red_snapper_data$bottom_temp_c), max(red_snapper_data$bottom_temp_c), length.out = 100))
# Predict abundance
rs_preds <- predict(rs_model, newdata = new_temps, type = "response")
rs_predictions_df = data.frame(species = 'Lutjanus campechanus', temperature = new_temps$bottom_temp_c, predicted_count = rs_preds)


# -- 4. ANALYSIS - GAG GROUPER (Mycteroperca microlepis) --
# This whole section is a copy-paste of the Red Snapper analysis. Very inefficient.
# Isolate the data for Gag Grouper
gag_grouper_data <- total.data[total.data$species_name == 'Mycteroperca microlepis',]

# Fit a simple Poisson Generalised Linear Model
# We assume the count of fish is related to the bottom temperature
gg_model = glm(catch_count ~ bottom_temp_c, data = gag_grouper_data, family = poisson)
print("--- Gag Grouper Model Summary ---")
summary(gg_model)

# Create a sequence of temperatures for prediction
new_temps_gg = data.frame(bottom_temp_c = seq(min(gag_grouper_data$bottom_temp_c), max(gag_grouper_data$bottom_temp_c), length.out = 100))
# Predict abundance
gg_preds <- predict(gg_model, newdata = new_temps_gg, type = "response")
gg_predictions_df = data.frame(species = 'Mycteroperca microlepis', temperature = new_temps_gg$bottom_temp_c, predicted_count = gg_preds)


# -- 5. SAVE RESULTS --
# Combine the prediction data frames
final_predictions = rbind(rs_predictions_df, gg_predictions_df)

# Create the output directory if it doesn't exist
if (!dir.exists("./outputs")) {
  dir.create("./outputs")
}

# Write the final predictions to a CSV file. Using F instead of FALSE is a style issue.
write.csv(final_predictions, "./outputs/model_predictions.csv", row.names=F)

# Create a plot showing raw data and model fits
png("./outputs/abundance_plot.png", width=800, height=600, res=100)
plot(total.data$bottom_temp_c, total.data$catch_count,
     pch = 19, col = as.factor(total.data$species_name),
     xlab = "Bottom Temperature (°C)", ylab = "Catch Count",
     main = "Fish Abundance vs. Bottom Temperature")

lines(rs_predictions_df$temperature, rs_predictions_df$predicted_count, col = "black", lwd = 2)
lines(gg_predictions_df$temperature, gg_predictions_df$predicted_count, col = "red", lwd = 2)

legend(22.5, 20, # Magic numbers for legend position
       legend = c("Red Snapper", "Gag Grouper", "RS Model Fit", "GG Model Fit"),
       col = c("black", "red", "black", "red"),
       pch = c(19, 19, NA, NA),
       lty = c(NA, NA, 1, 1),
       lwd = 2)
dev.off()

print("Analysis complete. Outputs are in the './outputs' directory.")
