library(shiny)
library(ggplot2)
library(DT)
library(readxl)

# Set working directory and read dataset
#setwd('C:\\Users\\bro12\\Desktop\\Desktop\\Data332\\In Class\\Cars')
dataset <- read_excel('CarData .xlsx', .name_repair = 'universal')
dataset <- na.omit(dataset)
column_names <- colnames(dataset)  # Get column names for input selection

# Define a custom theme for ggplot
my_theme <- function() {
  theme_minimal() +
    theme(
      text = element_text(color = "#333333"),  # Set text color
      plot.background = element_rect(fill = "#F5F5F5", color = NA),  # Set plot background color and remove border
      panel.background = element_rect(fill = "#FFFFFF"),  # Set panel background color
      panel.border = element_blank(),  # Remove panel border
      axis.line = element_line(color = "#333333"),  # Set axis line color
      axis.text = element_text(color = "#333333"),  # Set axis text color
      legend.text = element_text(color = "#333333")  # Set legend text color
    )
}

ui2 <- fluidPage(
  titlePanel("Effectiveness of Radar Speed Signs"),
  mainPanel(
    h4("The radar speed sign is formally called a Dynamic Speed Monitoring Display (DSMD) or
Dynamic Speed Feedback Sign (DSFS). There are different types of DSMD, portable chargeable
message signs (PCMS), speed monitoring displays (SMD), and speed display tailers (SDT).
They are either trailer based/portable or are permanent/mounted. A DSMD sign in combination
with a regulatory speed sign provides direct and relevant information to the motorist using the
roadway. It is considered a feedback loop, a very effective way of permitting human beings to
measure performance against a benchmark by displaying performance (Veneziano). The NHTSA
states that DSMD are effective but as soon as they are removed, the speeds rebound quickly.
Therefore, permanent signs are more effective. One concern with these signs is that the excessive
use of signs could lead motorists to disregard the signage in the long term. The cost for a DSMD
is around $10,000 per sign (Dynamic Speed Display/ Feedback Signs). Many studies on DSMD
effectiveness show that they are effective over a long period of time.

     The location we collected data was walking distance from campus. The study from the
University of Southern Illinois Edwardsville is different from others because it focuses on the
radar speed signs near college campuses, making it relevant to the analysis we created. This
study lists 3 factors that make university roads different from others, driver familiarity,
demographics, and prevalence of pedestrians. The driver familiarity is interesting because as a
group we collected the license plate state. There were many Illinois license plates and those were
the cars that were speeding the most. Demographics are different based on the time of day. The
biggest point here is that during the afternoon it is usually not students speeding. It is people who
are in the workforce and driving through or around campus to get to work or home. The
prevalence of pedestrians is not relevant to our study because there was not a pedestrian
walkway, and we did not see any pedestrians when collecting our data at the designated location.
The results of the University of Southern Illinois Edwardsville study show that the radar speed
signs are most effective in the PM. This was the most beneficial finding of the study. I can
believe this as students are leaving classes and nonstudents in the workforce are leaving work
and going home.

     The effectiveness of the radar speed signs is proved by the fact, “85.6% of the drivers that
were exceeding the speed limit reduced their speed when warned of a violation with the radar
speed display sign” (Williamson). When sitting at the data collection location, cars would slow
down when the radar sign blinked at them. Radar speed signs have been consistently shown to
reduce speed. They are most effective when they are permanent, in the PM and along curves,
school zones, parks, and residential areas. The placement of the radar speed sign our class
collected data at is effective because it is in a residential area and by a school. Having one closer
to Augustana’s campus could be helpful. The radar speed sign we collected data at is not
necessarily slowing speed down on campus.



                                       References

Dynamic speed display/feedback signs. NHTSA. (2023).
https://www.nhtsa.gov/book/countermeasures-that-work/speeding-and-speed-
management/countermeasures/other-strategies-behavior-change/dynamic-
speed#:~:text=zones%2C%20and%20curves.-
,Effectiveness%3A,has%20also%20documented%20crash%20reductions.

Veneziano, D. (n.d.). Guidance for Radar Speed Sign Deployments. Guidance for radar speed
sign deployments. https://safety.fhwa.dot.gov/speedmgt/ref_mats/fhwasa1304/1_36.htm

Williamson, M. R., Fries, R. N., & Zhou, H. (2016, April). Long-term effectiveness of radar
speed display signs in a university environment. SPARK.
https://spark.siue.edu/siue_fac/62/"),
    verbatimTextOutput("essay_output")
  )
)

# Define UI for the first page
ui <- fluidPage(
  titlePanel("Car Data Research Paper- Avery, Nico, Waithira"),
    tabPanel("Second Page", ui2)
  )


# Define server logic for both pages
server <- function(input, output, session) {
  
  # Server logic for the first page
  output$plot_01 <- renderPlot({
    ggplot(dataset, aes_string(x = input$X, y = input$Y, colour = input$Splitby)) +
      geom_point() +
      labs(x = input$X, y = input$Y) +  # Set axis labels dynamically
      my_theme()  # Apply custom theme to the plot
  })
  
  output$table_01 <- renderDT({
    dataset[, c(input$X, input$Y, input$Splitby)]
  }, options = list(pageLength = 10))  # Increase page length for better display
  
  # Server logic for the second page remains the same
  
}

# Combine both UIs into a single application
shinyApp(ui = ui, server = server)

