library(shiny)

renderInputs <- function(prefix) {
  wellPanel(
    fluidRow(
      column(6,
             sliderInput(paste0(prefix, "_", "n_obs"), "Project (in Years):", min = 0, max = 40, value = 20),
             sliderInput(paste0(prefix, "_", "start_capital"), "Initial capital invested :", min = 0, max = 1000000000, value = 456000000, step = 100000, format="$#,##0", locale="us"),
             sliderInput(paste0(prefix, "_", "annual_mean_return"), "Annual profit  (in % over capita):", min = 0.0, max = 10.0, value = 1.5, step = 0.5),
             sliderInput(paste0(prefix, "_", "annual_ret_std_dev"), "Annual profit volatility (in %):", min = 0.0, max = 25.0, value = 3.0, step = 0.1)
      ),
      column(6,
             sliderInput(paste0(prefix, "_", "annual_inflation"), "Annual effective tariff red (in %):", min = 0, max = 20, value = 2.5, step = 0.1),
             sliderInput(paste0(prefix, "_", "annual_inf_std_dev"), "Annual tariff red volatility. (in %):", min = 0.0, max = 5.0, value = 1.5, step = 0.05),
             sliderInput(paste0(prefix, "_", "monthly_withdrawals"), "Monthly financial fees:", min = 1000, max = 5000000, value = 1858000, step = 1000, format="$#,##0", locale="us",),
             sliderInput(paste0(prefix, "_", "n_sim"), "Number of simulations:", min = 0, max = 2000, value = 200)
      )
    ),
    p(actionButton(paste0(prefix, "_", "recalc"),
                   "Re-run simulation", icon("random")
    ))
  )
}

# Define UI for application that plots random distributions
shinyUI(fluidPage(theme="simplex.min.css",
                  tags$style(type="text/css", "label {font-size: 12px;}"),
                  
                  # Application title
                  tags$h1("Profit analysis for a windmill farm. Random production with known financial costs "), 
                  tags$h2("Financial Uncertainty: simulating net wealth with random returns"), 
                  tags$h3("Tariff eff. reduction and monthly recovery capital considered"),
                  tags$h3("Benefits are capitalized, no dividends are payed"),
                  tags$h3("Adapted from shiny library examples"),
                  # p("An adaptation of the",
                  #  tags$a(href="http://glimmer.rstudio.com/systematicin/retirement.withdrawal/", "retirement app"),
                  # "from",
                  #  tags$a(href="http://systematicinvestor.wordpress.com/", "Systematic Investor"),
                  #  "to demonstrate the use of Shiny's new grid options."),
                  hr(),
                  
                  fluidRow(
                    column(10, tags$h3("Parameters for Scenario "))
                  # column(6, tags$h3("Scenario B"))
                  ),
                  fluidRow(
                    column(10, renderInputs("a"))
                  #  column(6, renderInputs("b"))
                  ),
                  fluidRow(
                    column(10,
                           plotOutput("a_distPlot", height = "600px")
                    )
                  # column(6,
                  #         plotOutput("b_distPlot", height = "600px")
                  #  )
                  )
))