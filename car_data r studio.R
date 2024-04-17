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

#Renaming the 'License plate state' column to 'License_plate_state'
car_data <- car_data %>%
  rename(License_plate_state = `License plate state`)


# violin plot to show distribution of speeds by state
ggplot(car_data, aes(x = License_plate_state, y = Speed, fill = License_plate_state)) +
  geom_violin(trim = FALSE, alpha = 0.7) + 
  geom_point(position = position_jitter(width = 0.1), alpha = 0.5, color = "black", size = 1.5) +  
  stat_summary(fun = median, geom = "line", aes(group = License_plate_state), color = "white", size = 1.5) + 
  scale_fill_brewer(palette = "Set3") +  
  labs(title = "Vehicle Speed Distribution by State",
       x = "State",
       y = "Speed (mph)") +
  theme_light() + 
  theme(legend.position = "none",  
        plot.title = element_text(hjust = 0.5),  
        axis.text.x = element_text(angle = 45, hjust = 1))  
# Color vs State

# Calculate the top 5 most frequent colors
top_colors <- car_data %>%
  count(Color, sort = TRUE) %>%
  top_n(5, n)

# Filter the data to include only the top 5 colors
filtered_data <- car_data %>%
  filter(Color %in% top_colors$Color)


# Plotting top 5 colors for each state
color_counts <- filtered_data %>%
  group_by(License_plate_state, Color) %>%
  summarise(Count = n(), .groups = 'drop') %>%
  mutate(Color = fct_reorder(Color, Count))

ggplot(color_counts, aes(x = License_plate_state, y = Count, fill = Color)) +
  geom_bar(stat = "identity", position = position_dodge()) +  
  scale_fill_manual(values = c("black" = "black", "blue" = "blue", "grey" = "grey", "red" = "red", "white" = "beige")) +
  labs(title = "Top 5 Car Colors in Each State",
       x = "State",
       y = "Count of Cars") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom") 

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
