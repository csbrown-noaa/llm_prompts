setwd("../example_input")

station_info <- read.csv("./data/station_info.csv")
catchData = read.csv("./data/catch_data.csv", header = F)

colnames(catchData) = c("station_id", "species_name", "catch_count")


total.data <- merge(station_info, catchData, by="station_id")

total.data$density_per_km2 = total.data$catch_count / total.data$area_swept_km2

total.data = total.data[is.finite(total.data$density_per_km2), ]

conversion_factor_km2_to_mi2 = 0.62
total.data$density_per_sq_mi <- total.data$density_per_km2 / conversion_factor_km2_to_mi2

red_snapper_data <- total.data[total.data$species_name == 'Lutjanus campechanus',]

rs_model <- glm(catch_count ~ bottom_temp_c, data = red_snapper_data, family = poisson)
print("--- Red Snapper Model Summary ---")
summary(rs_model)

new_temps = data.frame(bottom_temp_c = seq(min(red_snapper_data$bottom_temp_c), max(red_snapper_data$bottom_temp_c), length.out = 100))

rs_preds <- predict(rs_model, newdata = new_temps, type = "response")
rs_predictions_df = data.frame(species = 'Lutjanus campechanus', temperature = new_temps$bottom_temp_c, predicted_count = rs_preds)


gag_grouper_data <- total.data[total.data$species_name == 'Mycteroperca microlepis',]

gg_model = glm(catch_count ~ bottom_temp_c, data = gag_grouper_data, family = poisson)
print("--- Gag Grouper Model Summary ---")
summary(gg_model)

new_temps_gg = data.frame(bottom_temp_c = seq(min(gag_grouper_data$bottom_temp_c), max(gag_grouper_data$bottom_temp_c), length.out = 100))

gg_preds <- predict(gg_model, newdata = new_temps_gg, type = "response")
gg_predictions_df = data.frame(species = 'Mycteroperca microlepis', temperature = new_temps_gg$bottom_temp_c, predicted_count = gg_preds)


final_predictions = rbind(rs_predictions_df, gg_predictions_df)

if (!dir.exists("./outputs")) {
  dir.create("./outputs")
}

write.csv(final_predictions, "./outputs/model_predictions.csv", row.names=F)

png("./outputs/abundance_plot.png", width=800, height=600, res=100)
plot(total.data$bottom_temp_c, total.data$catch_count,
     pch = 19, col = as.factor(total.data$species_name),
     xlab = "Bottom Temperature (°C)", ylab = "Catch Count",
     main = "Fish Abundance vs. Bottom Temperature")

lines(rs_predictions_df$temperature, rs_predictions_df$predicted_count, col = "black", lwd = 2)
lines(gg_predictions_df$temperature, gg_predictions_df$predicted_count, col = "red", lwd = 2)

legend(22.5, 20,
       legend = c("Red Snapper", "Gag Grouper", "RS Model Fit", "GG Model Fit"),
       col = c("black", "red", "black", "red"),
       pch = c(19, 19, NA, NA),
       lty = c(NA, NA, 1, 1),
       lwd = 2)
dev.off()

print("Analysis complete. Outputs are in the './outputs' directory.")
