rm(list=ls())
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)
library(explore)

#set up working directory and read data
car_data<- read_excel("C:/Users/HP/OneDrive/Documents/DATA 332/car_data.xlsx")

# Plotting a histogram of vehicle speeds
ggplot(car_data, aes(x = Speed)) +
  geom_histogram(bins = 30, fill = "purple", color = "black") +
  ggtitle("Distribution of Vehicle Speeds") +
  xlab("Speed (mph)") +
  ylab("Frequency") +
  theme_minimal()

# Define custom colors for the two weather conditions
weather_colors <- c("Sunny" = "yellow", "Cloudy" = "purple")

# Boxplot of speed by weather condition
ggplot(car_data, aes(x = Weather, y = Speed, fill = Weather)) +
  geom_boxplot() +
  scale_fill_manual(values = weather_colors) +
  ggtitle("Speed Distribution by Weather Condition") +
  xlab("Weather") +
  ylab("Speed (mph)") +
  theme_light() +
  scale_fill_viridis_d()

#Renaming the 'License plate state' column to 'License_plate_state'
car_data <- car_data %>%
  rename(License_plate_state = `License plate state`)
#Histogram for SPEED-LICENSE PLATE STATE
ggplot(car_data, aes(x = Speed, fill = License_plate_state)) +
  geom_histogram(bins = 30, position = "identity", alpha = 0.6) +
  facet_wrap(~ License_plate_state) +
  labs(title = "Distribution of Speeds by License Plate State",
       x = "Speed (mph)",
       y = "Count") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Calculate the top 5 most frequent colors
top_colors <- car_data %>%
  count(Color, sort = TRUE) %>%
  top_n(5, n)

# Filter the data to include only the top 5 colors
filtered_data <- car_data %>%
  filter(Color %in% top_colors$Color)


# Plotting speed versus vehicle color for the top 5 colors
ggplot(filtered_data, aes(x = as.factor(Color), y = Speed)) +
  geom_jitter(aes(color = Color), width = 0.2) +  # Using jitter to prevent overplotting
  scale_color_manual(values = c("black" = "black", "blue" = "blue", "grey" = "grey", "red" = "red", "white" = "beige")) +
  ggtitle("Vehicle Speed by Top 5 Car Colors") +
  xlab("Car Color") +
  ylab("Speed (mph)") +
  theme_bw()
