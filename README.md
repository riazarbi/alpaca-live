# rblncr-demo

## Setup

To set up on a fresh machine:

```
sudo apt -y install r-base cmake libcurl4-openssl-dev libssl-dev
sudo Rscript -e "install.packages('renv')"
```

```R
renv::init()
quit()
```

```R
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
options(repos="https://packagemanager.rstudio.com/all/__linux__/noble/latest")
source("https://docs.posit.co/rspm/admin/check-user-agent.R")
Sys.setenv("NOT_CRAN" = TRUE)

packages <- c("arrow",
              "tidyr",
              "readr",
              "shiny",
              "remotes")

renv::install(packages)

renv::install("riazarbi/rblncr@*release")
```

## Using github action

The github action should work fine. Just make suure you've enabels actions in the repo and added the required secrets. 

These are:

- ALPACA_LIVE_KEY
- ALPACA_LIVE_SECRET
- GH_PAT (for R package installer to work correctly)