#source files and set paths on container
#these directories won't change on container
print(paste("Running NOAA scripts starting at:", as.character(Sys.time())))

 <- "/root/flare/shared"
configuration_yaml <- "/root/flare/shared/flare-config.yml"

#Read configuration file
config_file <- yaml::read_yaml(configuration_yaml)
output_directory <- config_file$output_directory

#Read list of latitude and longitudes
neon_sites <- readr::read_csv(file.path("/root/flare/", config_file$site_file))
site_list <- neon_sites$site_id
lat_list <- neon_sites$latitude
lon_list <- neon_sites$longitude

print(paste0("Site file: ", config_file$site_file))

noaaGEFSpoint::noaa_gefs_download_downscale(site_list,
                                            lat_list,
                                            lon_list,
                                            output_directory,
                                            forecast_time = config_file$forecast_time,
                                            forecast_date = config_file$forecast_date,
                                            downscale = config_file$downscale,
                                            run_parallel = config_file$run_parallel,
                                            num_cores = config_file$num_cores,
                                            method = "grid",
                                            overwrite = config_file$overwrite)
