library(shiny)

paramNames <- c("start_capital", "annual_mean_return", "annual_ret_std_dev",
                "annual_inflation", "annual_inf_std_dev", "monthly_withdrawals", "n_obs",
                "n_sim")

# Define server logic required to generate and plot a random distribution
#
# Idea and original code by Pierre Chretien
# Small updates by Michael Kapler
#
shinyServer(function(input, output, session) {
  
  getParams <- function(prefix) {
    
    input[[paste0(prefix, "_recalc")]]
    
    params <- lapply(paramNames, function(p) {
      input[[paste0(prefix, "_", p)]]
    })
    names(params) <- paramNames
    params
  }
  
  # Function that generates scenarios and computes NAV. The expression
  # is wrapped in a call to reactive to indicate that:
  #
  # 1) It is "reactive" and therefore should be automatically
  # re-executed when inputs change
  #
  getNav <- function(prefix) {
    
    params <- getParams(prefix)
    #-------------------------------------
    # Inputs
    #-------------------------------------
    
    # Initial capital
    start.capital = params$start_capital
    
    # Investment
    annual.mean.return = params$annual_mean_return / 100
    annual.ret.std.dev = params$annual_ret_std_dev / 100
    
    # Inflation
    annual.inflation = params$annual_inflation / 100
    annual.inf.std.dev = params$annual_inf_std_dev / 100
    
    # Withdrawals
    monthly.withdrawals = params$monthly_withdrawals
    
    # Number of observations (in Years)
    n.obs = params$n_obs
    
    # Number of simulations
    n.sim = params$n_sim
    
    #-------------------------------------
    # Simulation
    #-------------------------------------
    
    # number of months to simulate
    n.obs = 12 * n.obs
    
    
    # monthly Investment and Inflation assumptions
    monthly.mean.return = annual.mean.return / 12
    monthly.ret.std.dev = annual.ret.std.dev / sqrt(12)
    
    monthly.inflation = annual.inflation / 12
    monthly.inf.std.dev = annual.inf.std.dev / sqrt(12)
    
    
    # simulate Returns
    monthly.invest.returns = matrix(0, n.obs, n.sim)
    monthly.inflation.returns = matrix(0, n.obs, n.sim)
    
    monthly.invest.returns[] = rnorm(n.obs * n.sim, mean = monthly.mean.return, sd = monthly.ret.std.dev)
    monthly.inflation.returns[] = rnorm(n.obs * n.sim, mean = monthly.inflation, sd = monthly.inf.std.dev)
    
    # simulate Withdrawals
    nav = matrix(start.capital, n.obs + 1, n.sim)
    for (j in 1:n.obs) {
      nav[j + 1, ] = nav[j, ] * (1 + monthly.invest.returns[j, ] - monthly.inflation.returns[j, ]) - monthly.withdrawals
    }  
    
    # once nav is below 0 => run out of money
    # nav[ nav < 0 ] = NA
    
    # convert to millions
    nav = nav / 1000000
    
    return(nav)
  }
  
  # Expression that plot NAV paths. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  # 1) It is "reactive" and therefore should be automatically
  # re-executed when inputs change
  # 2) Its output type is a plot
  #
  doRender <- function(nav) {
    
    layout(matrix(c(1,2,1,3),2,2))
    
    # plot all scenarios
    matplot(nav, type = 'l', las = 1, xlab = 'Months', ylab = 'Millions',
            main = 'Acumulated profit')
    
    
    # plot % of scenarios that are still paying
    p.alive = 1 - rowSums(is.na(nav)) / ncol(nav)
    
    plot(100 * p.alive, las = 1, xlab = 'Months', ylab = 'Percentage Positive profit',
         main = 'Percentage of positive benefits Scenarios', ylim=c(0,100))
    grid()	
    
    
    last.period = nrow(nav)
    
    # plot distribution of final wealth
    final.nav = nav[last.period, ]
    final.nav = final.nav[!is.na(final.nav)]
    
    if(length(final.nav) == 0) return()	
    
    plot(density(final.nav/(1.02)^nav, from=0, to=max(final.nav/(1.02)^nav)), las = 1, xlab = 'Net present Value',
         main = paste('Distribution of Net present Value (r=2% over capital cost),', 100 * p.alive[last.period], '% periods are positive'))
    grid()	
  }
  
  navA <- reactive(getNav("a"))
  # navB <- reactive(getNav("b"))
  
  output$a_distPlot <- renderPlot({
    doRender(navA())
  })
  # output$b_distPlot <- renderPlot({
  #   doRender(navB())
  # })
  
})