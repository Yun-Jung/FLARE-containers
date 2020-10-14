library(rNOMADS)
library(RCurl)
library(stringr)
library(yaml)

config_file = "/root/flare/shared/flare-download-noaa-dev/flare-config.yml"
directory = "/root/flare/shared/flare-download-noaa-dev/"

#Read Config File
config = yaml.load_file(config_file)

site_name = config$container$site$name

#User defined location of interest and directory
lake_lat_n_list = c(config$container$site$latitude)
lake_lon_w_list = c(config$container$site$longitude)
#Degrees west (does not currently work for sites in eastern hemisphere)

lake_name_list = c(config$container$site$name)

if(!file.exists(directory)) {
  dir.create(file.path(directory))
}

for(subdir in lake_name_list) {
  if(!file.exists(file.path(directory, subdir))) {
    dir.create(file.path(directory, subdir))
  }
}

#####

time <- c(0, 64) #6 hour prediction for 16 days
lon.dom <- seq(0, 359, by = 0.5) #domain of longitudes in model (1 degree resolution)
lat.dom <- seq(-90, 90, by = 0.5) #domain of latitudes in model (1 degree resolution)

for(lake_index in 1:length(lake_name_list)){

  lon <- which.min(abs(lon.dom  - (360 - lake_lon_w_list[lake_index]))) - 1 #NOMADS indexes start at 0
  lat <- which.min(abs(lat.dom - lake_lat_n_list[lake_index])) - 1 #NOMADS indexes start at 0

  #Get yesterdays 6 am GMT, 12 pm GMT, 6 pm GMT, and todays 12 an GMT runs
  urls.out <- GetDODSDates(abbrev = "gens_bc")

  for(i in 1:length(urls.out$url)){

    urls.out$model <- "gefs"
    urls.out$date <- urls.out$date[which(lubridate::as_date(urls.out$date) > lubridate::as_date("2020-09-25"))]
    urls.out$url <- paste0("https://nomads.ncep.noaa.gov:443/dods/gefs/gefs",urls.out$date)



    model.url <- urls.out$url[i]
    #model.url <- str_replace(model.url,"gens_bc","gens")
    run_date <- urls.out$date[i]
    model_list <- c("gefs_pgrb2ap5_all_00z", "gefs_pgrb2ap5_all_06z", "gefs_pgrb2ap5_all_12z", "gefs_pgrb2ap5_all_18z")

    model_list_old <- c("gep_all_00z", "gep_all_06z", "gep_all_12z", "gep_all_18z")

    for(m in 1:length(model_list)){

      file_present_local <- file.exists(paste0(directory, lake_name_list[lake_index], '/', lake_name_list[lake_index], '_', run_date, '_', model_list[m], '.csv'))
      file_present_local_old <- file.exists(paste0(directory, lake_name_list[lake_index], '/', lake_name_list[lake_index], '_', run_date, '_', model_list_old[m], '.csv'))

      print(paste0(directory, lake_name_list[lake_index], '/', lake_name_list[lake_index], '_', run_date, '_', model_list_old[m], '.csv is already downloaded: ', file_present_local_old))

      #Check if already downloaded
      if(!file_present_local_old){

        model.runs <- tryCatch(GetDODSModelRuns(model.url),
                               error = function(e){
                                 warning(paste(e$message, "skipping", paste0(directory, lake_name_list[lake_index], '/', lake_name_list[lake_index], '_', run_date, '_', model_list_old[m], '.csv')),
                                         call. = FALSE)
                                 return(NA)
                               },
                               finally = NULL)

        if(!is.na(model.runs)){

          #check if avialable at NOAA
          if(model_list[m] %in% model.runs$model.run){

            model.run <- model.runs$model.run[which(model.runs$model.run == model_list[m])]
            #Get variables of interest for GLM

            #tmp2m #temp at 2 m

            #dlwrfsfc #surface downward long-wave rad. flux [w/m^2]

            #dswrfsfc #surface downward short-wave rad. flux [w/m^2]

            #pratesfc #surface precipitation rate [kg/m^2/s]

            #rh2m #2 m above ground relative humidity [%]

            #vgrd10m  #10 m above ground v-component of wind [m/s]

            #ugrd10m #10 m above ground u-component of wind [m/s]

            #spfh2m #2 m above specific humidity  [kg/kg]

            #pressfc #Surface pressure [pa]

            #tcdcclm #entire atmosphere total cloud cover [%]

            tmp2m <- DODSGrab(model.url, model.run, "tmp2m", time = time, lon = c(lon,lon),
                              lat = c(lat,lat),ensembles=c(0,30))

            dlwrfsfc <- DODSGrab(model.url, model.run, "dlwrfsfc", time = time, lon = c(lon,lon),
                                 lat = c(lat,lat),ensembles=c(0,30))

            dswrfsfc <- DODSGrab(model.url, model.run, "dswrfsfc", time = time, lon = c(lon,lon),
                                 lat = c(lat,lat),ensembles=c(0,30))

            apcpsfc <- DODSGrab(model.url, model.run, "apcpsfc", time = time, lon = c(lon,lon),
                                lat = c(lat,lat),ensembles=c(0,30))

            apcpsfc$value <- apcpsfc$value / (60 * 60 * 6)

            rh2m <- DODSGrab(model.url, model.run, "rh2m", time = time, lon = c(lon,lon),
                             lat = c(lat,lat),ensembles=c(0,30))

            vgrd10m <- DODSGrab(model.url, model.run, "vgrd10m", time = time, lon = c(lon,lon),
                                lat = c(lat,lat),ensembles=c(0,30))

            ugrd10m <- DODSGrab(model.url, model.run, "ugrd10m", time = time, lon = c(lon,lon),
                                lat = c(lat,lat),ensembles=c(0,30))

            #spfh2m <- DODSGrab(model.url, model.run, "spfh2m", time = time, lon = c(lon,lon),
            #                   lat = c(lat,lat),ensembles=c(0,30))

            pressfc <- DODSGrab(model.url, model.run, "pressfc", time = time, lon = c(lon,lon),
                                lat = c(lat,lat),ensembles=c(0,30))

            tcdcclm <- DODSGrab(model.url, model.run, "tcdcclm", time = time, lon = c(lon,lon),
                                lat = c(lat,lat),ensembles=c(0,30))

            forecast.time <- strftime(tmp2m$forecast.date, format="%Y-%m-%d %H:%M:%S",tz = 'GMT')

            forecast_noaa <- data.frame(forecast.date = forecast.time,
                                        ensembles = tmp2m$ensembles,
                                        tmp2m = tmp2m$value,
                                        dlwrfsfc= dlwrfsfc$value,
                                        dswrfsfc = dswrfsfc$value,
                                        pratesfc = apcpsfc$value,
                                        rh2m = rh2m$value,
                                        vgrd10m = vgrd10m$value,
                                        ugrd10m = ugrd10m$value,
                                        #spfh2m = spfh2m$value,
                                        pressfc = pressfc$value,
                                        tcdcclm = tcdcclm$value)

            write.csv(forecast_noaa, paste0(directory, lake_name_list[lake_index], "/", lake_name_list[lake_index], "_", run_date, "_", model_list_old[m], '.csv'), row.names = FALSE)
          }
        }
      }
    }
  }
}
