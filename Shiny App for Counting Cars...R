rm(list=ls())
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(lubridate)
library(explore)
library(DT)
library(bslib)

# Define the user interface
ui <- fluidPage(
  
  theme = bs_theme(version = 5, bootswatch = "solar"),
  # Custom CSS to make the title fixed and add padding to content
  tags$head(
    tags$style(HTML("
            #fixed-title {
                position: fixed;
                top: 0;
                width: 100%;
                z-index: 9999;  /* Make sure it's sufficiently high */
                background-color: transparent;  /* Make it transparent to inherit from theme */
                color: inherit;  /* Ensure text color inherits from theme */
                padding: 10px 0;
                border-bottom: 1px solid #ddd;
            }
            body > .container-fluid, body > .container {
                padding-top: 150px;  /* Adjust this value to ensure enough space under the fixed title */
            }
        "))
  ),
  
  
  # Use div to create a fixed title panel
  div(class = "fixed-title", id = "fixed-title",
      h1("Vehicle Speed Analysis", style = "margin-left: 20px;")  # You can adjust the margin as needed
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("summaryInput", "Select Summary Variable", 
                  choices = c("Speed", "Temperature", "Color", "Weather", "State"), selected = "Speed", 
                  multiple = FALSE),
      selectInput("colorInput", "Select Car Color",
                  choices = c("Black", "Red", "White", "Blue", "Grey", "All"), selected = "All", multiple = TRUE),
      selectInput("weatherInput", "Select Weather Condition",
                  choices = c("Sunny", "Cloudy", "All"), selected = "All", multiple = TRUE),
      selectInput("stateInput", "Select License Plate State", 
                  choices = c("IL", "IA", "MI", "All"), selected = "All", multiple = TRUE),
      actionButton("updateButton", "Update Graphs"),
      style = "position: fixed; overflow: visible;"
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Project Summary", 
                 textOutput("projectSummary"),
                 DTOutput("dataTable")  # This will display the table
        ),
        tabPanel("Data Summary",
                 verbatimTextOutput("dataSummary"),
                 plotOutput("summaryPlot")),
        tabPanel("Graphs",
                 plotOutput("histSpeed"),
                 plotOutput("boxWeather"),
                 plotOutput("speedState"),
                 plotOutput("colorState"),
                 plotOutput("speedTime")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive data based on input actions
  reactive_data <- eventReactive(input$updateButton, {
    df <- read_excel("C:/Users/HP/OneDrive/Documents/DATA 332/car_data.xlsx")
    
    # Verify DateTime column and extract Hour, if missing halt with an error
    if("Time" %in% names(df)) {
      df <- df %>% 
        mutate(Hour = hour(hms(substring(Time, 12, 19))))
    } else {
      stop("DateTime column is missing or incorrect format")
    }
    
    df = df %>% 
      mutate(
      TimeOfDay = case_when(
        Hour >= 12 & Hour < 14 ~ "Early Afternoon",
        Hour >= 14 & Hour < 17 ~ "Mid Afternoon",
        Hour >= 17 & Hour < 20 ~ "Evening",
        TRUE                   ~ "Night"
      ),
      
      TimeOfDay = factor(TimeOfDay, levels = c("Early Afternoon", "Mid Afternoon", "Evening", "Night"))
    )
    
    df = df %>%
      rename(State = `License plate state`)
    
    
    #Summarized tables
    weather_colors <- c("Sunny" = "yellow", "Cloudy" = "purple")
    
    # Calculate the top 5 most frequent colors
    top_colors <- df %>%
      count(Color, sort = TRUE) %>%
      top_n(5, n)
    
    # Filter the data to include only the top 5 colors
    filtered_data <- df %>%
      filter(Color %in% top_colors$Color)
    
    
    # Plotting top 5 colors for each state
    color_counts <- filtered_data %>%
      group_by(State, Color) %>%
      summarise(Count = n(), .groups = 'drop') %>%
      mutate(Color = fct_reorder(Color, Count))
    
    # Convert 'DateTime' to just the time component
    df$Time <- format(as.POSIXct(df$Time), format = "%H:%M:%S")
    
    # Categorize into "Morning" and "Afternoon"
    df$TimeCategory <- ifelse(df$Time < 14, "Afternon", "Evening")
    
    # Aggregate to get average speed by exact time
    speed_by_timeHM <- df %>%
      group_by(Time) %>%
      summarise(AvgSpeed = mean(Speed, na.rm = TRUE)) %>%
      mutate(Time = as.POSIXct(Time, format = "%H:%M"))
    
    
    list(
      full_data = df,
      color_counts = color_counts,
      speed_by_time = speed_by_timeHM,
      weather_colors = weather_colors
    )
    
  }, ignoreNULL = FALSE)
  
  
  
  
  ##### Output objects below #####################
  ############################################################################
  ############################################################################
  
  ### output for Project summary Tab
  output$projectSummary <- renderText({
    "This project analyzes vehicle speeds from a dataset, focusing on how various factors such as color, weather, and time of day influence speed. 
    The analysis includes summary statistics for the data and various plots to visualize the relationships between variables.
    This Shiny app combines all the analyses into an interactive dashboard."
  })
  
  # Render a sample data table
  output$dataTable <- renderDataTable({
    data <- req(reactive_data())$full_data  # Make sure this accesses the correct reactive data structure
    datatable(data[1:10, ], options = list(pageLength = 10, autoWidth = TRUE))  # Show the first 10 rows as a sample
  })
  
  
  ### Data Summary Output objects
  
  output$dataSummary <- renderPrint({
    data <- req(reactive_data())$full_data
    summary(data)
  })
  
  # Summary Plot based on the selected variable
  
  
  output$summaryPlot <- renderPlot({
    data <- req(reactive_data())$full_data
    
    
    var_to_plot <- input$summaryInput
    
    filtered_data <- req(reactive_data())$full_data
    
    if (input$colorInput != "All") {
      filtered_data <- filtered_data[filtered_data$Color %in% input$colorInput, ]
    }
    if (input$weatherInput != "All") {
      filtered_data <- filtered_data[filtered_data$Weather %in% input$weatherInput, ]
    }
    if (input$stateInput != "All") {
      filtered_data <- filtered_data[filtered_data$State %in% input$stateInput, ]
    }
    
    # Depending on the selected variable, create a different type of plot
    if(var_to_plot %in% c("Speed")) {
      ggplot(data, aes_string(x = var_to_plot)) +
        geom_histogram(binwidth = 5, fill = "blue") +
        labs(title = paste("Distribution of", var_to_plot),
             x = var_to_plot, y = "Frequency") +
        theme_minimal()+
        theme(
          panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
          plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
          panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
          panel.grid.minor = element_blank(),
          plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
          axis.title = element_text(color = "white"),
          axis.text = element_text(color = "white")
        )
      
      
    } else if(var_to_plot %in% c("Color", "Weather")) {
      ggplot(data, aes_string(x = var_to_plot, fill = var_to_plot)) +
        geom_bar() +
        labs(title = paste("Count of", var_to_plot),
             x = var_to_plot, y = "Count") +
        theme_minimal()+
        theme(
          panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
          plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
          panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
          panel.grid.minor = element_blank(),
          plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
          axis.title = element_text(color = "white"),
          axis.text = element_text(color = "white")
        )
      }else if(var_to_plot %in% c("Temperature")){
        ggplot(data, aes_string(x = var_to_plot)) +
          geom_histogram(binwidth = 5, fill = "Purple") +
          labs(title = paste("Distribution of", var_to_plot),
               x = var_to_plot, y = "Frequency") +
          theme_minimal()+
          theme(
            panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
            plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
            panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
            panel.grid.minor = element_blank(),
            plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
            axis.title = element_text(color = "white"),
            axis.text = element_text(color = "white")
          )
        }else if(var_to_plot %in% c("State")){
          
          ggplot(data, aes_string(x = var_to_plot, fill = var_to_plot)) +
            geom_bar() +
            labs(title = paste("Count of", var_to_plot),
                 x = var_to_plot, y = "Count") +
            theme_minimal()+
            theme(
              panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
              plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
              panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
              panel.grid.minor = element_blank(),
              plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
              axis.title = element_text(color = "white"),
              axis.text = element_text(color = "white")
            )
    } else {
      plot.new()
      text(0.5, 0.5, "No plot available for the selected variable", cex = 1.5)
    }
  }, bg = "transparent")
  
  
  #### Outputs for plots
  
  output$histSpeed <- renderPlot({
    data <- req(reactive_data())
    ggplot(data$full_data, aes(x = Speed)) +
      geom_histogram(binwidth = 5, fill = "#8A2BE2", color = "black") +  # Using a hex code for a shade of purple
      geom_vline(aes(xintercept = mean(Speed)), color = "red", linetype = "dashed", size = 1) +
      ggtitle("Distribution of Vehicle Speeds") +
      xlab("Speed (mph)") +
      ylab("Frequency") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))+
      theme(
        panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
        plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
        panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white")
      )
  }, bg = "transparent")
  
  
  output$boxWeather <- renderPlot({
    data <- req(reactive_data())
    ggplot(data$full_data, aes(x = Weather, y = Speed, fill = Weather)) +
      geom_boxplot() +
      scale_fill_manual(values = data$weather_colors) +
      ggtitle("Speed Distribution by Weather Condition") +
      xlab("Weather") +
      ylab("Speed (mph)") +
      theme_light() +
      scale_fill_viridis_d()+
      theme(
        panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
        plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
        panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white")
      )
  }, bg = "transparent")
  
  
  output$speedState <- renderPlot({
    data <- req(reactive_data())
    ggplot(data$full_data, aes(x = State, y = Speed, fill = State)) +
      geom_violin(trim = FALSE, alpha = 0.7) +  # Semi-transparent violins
      geom_point(position = position_jitter(width = 0.1), alpha = 0.5, color = "black", size = 1.5) +  # Add jittered points for individual data
      stat_summary(fun = median, geom = "line", aes(group = State), color = "white", size = 1.5) +  # Median line
      scale_fill_brewer(palette = "Set3") +  # Change color palette to something more diverse
      labs(title = "Vehicle Speed Distribution by State",
           x = "State",
           y = "Speed (mph)") +
      theme_light() +  # Use a lighter theme for a cleaner look
      theme(legend.position = "none",  # Hide the legend
            plot.title = element_text(hjust = 0.5),  # Center the title
            axis.text.x = element_text(angle = 45, hjust = 1))+
      theme(
        panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
        plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
        panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white")
      )
  }, bg = "transparent")
  
  
  output$colorState <- renderPlot({
    data <- req(reactive_data())
    ggplot(data$color_counts, aes(x = State, y = Count, fill = Color)) +
      geom_bar(stat = "identity", position = position_dodge()) +  # Use dodge position for grouped bars
      scale_fill_manual(values = c("black" = "black", "blue" = "blue", "grey" = "grey", "red" = "red", "white" = "beige")) +
      labs(title = "Top 5 Car Colors in Each State",
           x = "State",
           y = "Count of Cars") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5),
            legend.position = "bottom") +
      theme(
        panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
        plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
        panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white")
      )
  }, bg = "transparent")
  
  output$speedTime <- renderPlot({
    data <- req(reactive_data())
    ggplot(data$speed_by_time, aes(x = Time, y = AvgSpeed)) +
      geom_line(color = "#00BFA8") +  # Choose a nice color for the line
      geom_point(color = "#F8766D", size = 2) +  # Choose a color for the points and make them larger
      scale_x_datetime(date_labels = "%H:%M", date_breaks = "1 hour", 
                       limits = as.POSIXct(c('13:00', '19:00'), format = "%H:%M")) +
      labs(title = "Average Vehicle Speed by Exact Time of Day",
           x = "Time of Day (13:00 - 19:00)",
           y = "Average Speed (mph)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5),  # Rotate x-axis labels for readability
            plot.title = element_text(hjust = 0.5),  # Center the plot title
            legend.position = "none")+
      theme(
        panel.background = element_rect(fill = "transparent", color = NA),  # Transparent panel background
        plot.background = element_rect(fill = "transparent", color = NA),  # Transparent plot background
        panel.grid.major = element_blank(),  # Optionally remove grid lines for a cleaner look
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "white"),  # Ensure text color is visible against your theme
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white")
      )
  }, bg = "transparent")
  
}

# Run the Shiny application
shinyApp(ui = ui, server = server)
# req(input$colorInput, input$weatherInput, input$stateInput, input$summaryInput)
# # Apply filters
# if (input$colorInput != "All") {
#   data <- data %>% filter(Color == input$colorInput)
# }
# if (input$weatherInput != "All") {
#   data <- data %>% filter(Weather == input$weatherInput)
# }
# if (input$stateInput != "All") {
#   data <- data %>% filter(State == input$stateInput)
# }
# 
# # Plot based on the selected variable
# var_to_plot <- input$summaryInput
# 
# # Depending on the selected variable, create a different type of plot
# if(var_to_plot %in% c("Speed", "Temp")) {
#   ggplot(data, aes_string(x = var_to_plot)) +
#     geom_histogram(binwidth = 5, fill = "blue") +
#     labs(title = paste("Distribution of", var_to_plot),
#          x = var_to_plot, y = "Frequency") +
#     theme_minimal()
# } else if(var_to_plot %in% c("Color", "Weather", "State")) {
#   ggplot(data, aes_string(x = var_to_plot, fill = var_to_plot)) +
#     geom_bar() +
#     labs(title = paste("Count of", var_to_plot),
#          x = var_to_plot, y = "Count") +
#     theme_minimal()
# } else {
#   plot.new()
#   text(0.5, 0.5, "No plot available for the selected variable", cex = 1.5)
# }