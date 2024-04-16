rm(list=ls())
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)
library(explore)

#set up working directory and read data
car_data<- read_excel("C:/Users/HP/OneDrive/Documents/DATA 332/car_data.xlsx")
