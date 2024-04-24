rm(list=ls())
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)
library(explore)

#set up working directory and read data
car_data<- read_excel("/Users/averyfrick/Documents/Senior Year /DATA 332/CarDataCombining/combinedDataOutput.xlsx")

# Plotting a histogram of vehicle speeds

ggplot(car_data, aes(x = Speed)) +
  geom_histogram(binwidth = 5, fill = "#8A2BE2", color = "black") + 
  geom_vline(aes(xintercept = mean(Speed)), color = "red", linetype = "dashed", size = 1) +
  ggtitle("Distribution of Vehicle Speeds") +
  xlab("Speed (mph)") +
  ylab("Frequency") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))  

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


#Plot for speed by time of the day
# Convert 'DateTime' to just the time component
car_data$Time <- format(as.POSIXct(car_data$Time), format = "%H:%M:%S")

# Categorize into "Morning" and "Afternoon"
car_data$TimeCategory <- ifelse(car_data$Time < 14, "Afternon", "Evening")

# Aggregate to get average speed by exact time
speed_by_timeHM <- car_data %>%
  group_by(Time) %>%
  summarise(AvgSpeed = mean(Speed, na.rm = TRUE)) %>%
  mutate(Time = as.POSIXct(Time, format = "%H:%M"))

# Create a line chart
ggplot(speed_by_timeHM, aes(x = Time, y = AvgSpeed)) +
  geom_line(color = "#00BFA8") + 
  geom_point(color = "#F8766D", size = 2) +  
  scale_x_datetime(date_labels = "%H:%M", date_breaks = "1 hour", 
                   limits = as.POSIXct(c('13:00', '19:00'), format = "%H:%M")) +
  labs(title = "Average Vehicle Speed by Exact Time of Day",
       x = "Time of Day (13:00 - 19:00)",
       y = "Average Speed (mph)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  
        plot.title = element_text(hjust = 0.5), 
        legend.position = "none")  