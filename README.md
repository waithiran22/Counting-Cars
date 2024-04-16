# Counting Cars🚗

## This repository presents the data analysis and findings from the Counting Cars project, where speeds of 150 vehicles were recorded. Conducted collaboratively by Waithira Ng'ang'a, Nicolas Navarro, and Avery Frick, the project offers insights into vehicle speed behavior in the area.
---
## Data Dictionary📖
The data for this project was collected individually from the speed rador on 30th St and 24th Avenue in Rock Island, IL.

Key Columns:

-Date: Date of the recorded observation.

-Temperature: Ambient temperature at the time of observation.

-Weather: Description of the prevailing weather conditions.

-Time: Timestamp of the observation.

-Speed: Vehicle speed captured by the radar.

-Color: Color of the vehicle.

-License Plate State: State of registration indicated by the license plate.

---

## Data Cleaning 🧹
The data cleaning process includes ensuring proper date, time and temperature formats, and preparing the data for analysis.

---
## Graphs
### speed - temperature
<img src="CarGraphs/speedVStemperature1.png" height = 250, width = 400>

```
#Scatter plot with a trend line for SPEED-TEMPERATURE
ggplot(car_data, aes(x = Temperature, y = Speed)) +
  geom_point(alpha = 0.5) + # Alpha for transparency on points
  geom_smooth(method = lm, color = "blue", se = FALSE) + 
  labs(
    title = "Speed vs. Temperature",
    x = "Temperature (°F)",
    y = "Speed (mph)"
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank(), 
    panel.grid.major.x = element_blank()
  )
```

### speed - state license plate
<img src="CarGraphs/speedVSlicenseplate1.png" height = 250, width = 400>

```
#Categorizing the speeds into ranges
car_data$SpeedRange <- cut(car_data$Speed, breaks = seq(from = min(car_data$Speed), 
                                                        to = max(car_data$Speed), 
                                                        by = 5), 
                           include.lowest = TRUE)

#Creating a bar chart with these ranges
ggplot(car_data, aes(x = SpeedRange, fill = License_plate_state)) +
  geom_bar(position = "dodge") + 
  labs(title = "Count of Speed Ranges by License Plate State",
       x = "Speed Range (mph)",
       y = "Count") +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 65, vjust = 0.6))
```

### speed - time of the day
<img src="CarGraphs/speedVStimeday1.png" height = 300, width = 450>

```
#Categorizing the times into sections of the day
car_data <- car_data %>%
  mutate(
    TimeOfDay = case_when(
      Hour >= 5 & Hour < 10 ~ "Early Morning",
      Hour >= 10 & Hour < 12 ~ "Mid Morning",
      Hour >= 12 & Hour < 14 ~ "Early Afternoon",
      Hour >= 14 & Hour < 17 ~ "Mid Afternoon",
      Hour >= 17 & Hour < 20 ~ "Evening",
      TRUE ~ "Night"
    )
  )

#To specify the order of the levels
car_data$TimeOfDay <- factor(
  car_data$TimeOfDay, 
  levels = c("Early Morning", "Mid Morning", "Early Afternoon", "Mid Afternoon", "Evening", "Night")
)
  
#Scatter plot of Speed vs. Time of Day
ggplot(car_data, aes(x = TimeOfDay, y = Speed)) +
  geom_point(aes(color = TimeOfDay)) +
  scale_color_brewer(palette = "Set1") +  
  labs(title = "Car Speed During Different Times of Day",
       x = "Time of Day",
       y = "Speed (mph)") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)  #to center the plot title
  ) +
  scale_x_discrete(limits = c("Early Morning", "Mid Morning", "Early Afternoon", "Mid Afternoon", "Evening", "Night"))
```
