#!/usr/bin/env Rscript

library(yaml)

args = commandArgs(trailingOnly=TRUE)

data_location = file.path("/root/flare/shared", args[1])
config_file = file.path(data_location, "flare-config.yml")

#Read Config File
config <- yaml::read_yaml(config_file)
print(config)

if(!file.exists(file.path(data_location, config$realtime_insitu_location))){
  stop("Missing temperature data GitHub repo")
}
if(!file.exists(file.path(data_location, config$realtime_met_station_location))){
  stop("Missing met station data GitHub repo")
}
if(!file.exists(file.path(data_location, config$noaa_location))){
  stop("Missing NOAA forecast GitHub repo")
}
if(!file.exists(file.path(data_location, config$manual_data_location))){
  stop("Missing Manual data GitHub repo")
}

if(!file.exists(file.path(data_location, config$realtime_inflow_data_location))){
  stop("Missing Inflow data GitHub repo")
}

setwd(file.path(data_location, config$realtime_insitu_location))
system(paste0("git pull"))

setwd(file.path(data_location, config$realtime_met_station_location))
system(paste0("git pull"))

setwd(file.path(data_location, config$noaa_location))
system(paste0("git pull"))

setwd(file.path(data_location, config$manual_data_location))
system(paste0("git pull"))

setwd(file.path(data_location, config$realtime_inflow_data_location))
system(paste0("git pull"))
