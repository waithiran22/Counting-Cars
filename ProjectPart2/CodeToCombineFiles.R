library(readxl)
library(data.table)
library(purrr)
library(openxlsx)
library(dplyr)

setwd('~/Documents/Senior Year /DATA 332/CarDataCombining')

## import all data
Car_Data_Excel <- read_excel('Car Data Excel.xlsx')
Car_Data <- read_excel('Car_Data.xlsx')
Car <- read_excel('Car.xlsx')
counting_cars <- read_excel('counting_cars.xlsx')
IRL_Car_Data <- read_excel('IRL.xlsx')
mergedCarData <- read_excel("mergedCarData.xlsx")
speed_analyst_332_Car_Data <- read_excel('Speed analyst 332 Car Data.xlsx')
UpdatedCarTracking<- read_xlsx('Updated.xlsx')

## change column names
setnames(UpdatedCarTracking, old = 'Time of Day', new = 'Time')
setnames(UpdatedCarTracking, old = 'Speed (mph)', new = 'Speed')
setnames(UpdatedCarTracking, old = 'Type of Car', new = 'Type')
setnames(UpdatedCarTracking, old = 'Car Number', new = 'CN')
setnames(UpdatedCarTracking, old = 'Weather', new = 'Temperature')
UpdatedCarTracking<- subset(UpdatedCarTracking, select = -CN)

setnames(speed_analyst_332_Car_Data, old = 'MPH', new = 'Speed')
setnames(speed_analyst_332_Car_Data, old = 'Time of Day', new = 'Time')
setnames(speed_analyst_332_Car_Data, old = 'Type of se', new = 'Type')
setnames(speed_analyst_332_Car_Data, old = 'Orange Light', new = 'OL')
setnames(speed_analyst_332_Car_Data, old = 'Student', new = 'Name')
speed_analyst_332_Car_Data<- subset(speed_analyst_332_Car_Data, select = -OL)


colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "MPH"] <- "Speed"
colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "Time.of.Day"] <- "Time"
colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "Wheater"] <- "Weather"
colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "Collector"] <- "Name"
colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "Time of Day"] <- "Time"
colnames(IRL_Car_Data)[colnames(IRL_Car_Data) == "Week Day"] <- "Day"

setnames(counting_cars, old = 'Temp', new = 'Temperature')
setnames(counting_cars, old = 'MPH', new = 'Speed')
counting_cars<- subset(counting_cars, select = -...6)
counting_cars<- subset(counting_cars, select = -...7)
counting_cars<- subset(counting_cars, select = -...8)
counting_cars<- subset(counting_cars, select = -...9)
counting_cars<- subset(counting_cars, select = -...10)
counting_cars<- subset(counting_cars, select = -...11)

setnames(Car, old = 'Speed MPH', new = 'Speed')
setnames(Car, old = 'Vehicle Color', new = 'Color')
setnames(Car, old = 'Vehicle Type', new = 'Type')
setnames(Car, old = 'Collector Name', new = 'Name')
setnames(Car, old = 'Flashing Light', new = 'FlashingLight')
Car <- subset(Car, select = -Manufacturer)
Car <- subset(Car, select = -FlashingLight)

setnames(Car_Data_Excel, old = 'License plate state', new = 'LPS')
Car_Data_Excel <- subset(Car_Data_Excel, select = -LPS)

setnames(mergedCarData, old = 'Orange Light', new = 'OL')
mergedCarData<- subset(mergedCarData, select = -OL)
mergedCarData<- subset(mergedCarData, select = -State)

combined_data <- bind_rows(Car, Car_Data, Car_Data_Excel, counting_cars, IRL_Car_Data, mergedCarData, speed_analyst_332_Car_Data, UpdatedCarTracking)

write.xlsx(combined_data, "combinedDataOutput.xlsx")
