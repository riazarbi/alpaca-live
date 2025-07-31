# Load libraries ----
library(rblncr)

# Set parameters from ENV variables ----
trading_mode = "live"
alpaca_live_key <- Sys.getenv("ALPACA_LIVE_KEY")
alpaca_live_secret <- Sys.getenv("ALPACA_LIVE_SECRET")

# Create backend connections -----
t_conn <- alpaca_connect(trading_mode,
                         alpaca_live_key,
                         alpaca_live_secret)
d_conn <- alpaca_connect("data",
                         alpaca_live_key,
                         alpaca_live_secret)

# Read in portfolio model and rebalancing history ----
portfolio_model <- read_portfolio_model("model.yaml")
rebalance_dates_file <- "last_rebalance"

# Extract last_rebalance timestamp ----
if(file.exists(rebalance_dates_file)) {
  rebalance_dates <- readLines(rebalance_dates_file) |>
    lubridate::as_datetime()
  last_rebalance <-max(rebalance_dates)
} else {
  last_rebalance <- NULL
}

# Check cooldown period ----
still_cooldown <- !(cooldown_elapsed(last_rebalance, portfolio_model$cooldown$days))

# Submit trades (if cooldown elapsed) ----
if(still_cooldown) {
  message("Cooldown period still in force.")
} else {

# Get current portfolio 
  get_portfolio_current(t_conn) |>
# Load targets
    load_portfolio_targets(portfolio_model) |>
# Price it
    price_portfolio(connection = d_conn, price_type = 'close') |>
# Solve
    solve_portfolio() |>
# Constrain to just a small amount
# We are following a dollar cost averaging strategy
    constrain_orders(
      connection = d_conn,
      min_order_size = 100,
      max_order_size = 1000,
      buy_only = TRUE) |>  
# Trade on the constrained orders
    trader(trader_life = 300,
           resubmit_interval = 30,
           trading_connection = t_conn,
           pricing_connection = d_conn,
           pricing_spread_tolerance = 0.01,
           exit_if_market_closed = TRUE,
           verbose = TRUE)
  
  # Record rebalance date for cooldown tracking
  current_timestamp <- lubridate::now()
  nowtext <-  strftime(current_timestamp,"%Y-%m-%d %H:%M:%S")
  write(nowtext, rebalance_dates_file, append = TRUE)
}
