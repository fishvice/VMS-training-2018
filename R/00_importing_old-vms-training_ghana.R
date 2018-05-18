library(rio)
library(tidyverse)
library(lubridate)

# ------------------------------------------------------------------------------
# GHANA
gh.folders <- dir("data-raw/05_AS_Files/05_AS_Files/VMS training course WA/Ghana",
                  full.names = TRUE, pattern = "batch")

res <- list()
counter <- 0
for(i in 1:length(gh.folders)) {
  files <- paste0(gh.folders[i], "/", dir(gh.folders[i]))
  k <- str_detect(files, "empty")
  files <- files[!k]
  for(j in 1:length(files)) {
    counter <- counter + 1
      res[[counter]] <-
        import(files[j]) %>%
        mutate(file = files[j])
  }
}

gh <-
  bind_rows(res) %>%
  select(mobile = Mobile,
         time = Date,
         lat = Latitude,
         lon = Longitude,
         eez1 = EEZ1,
         speed = Speed,
         port = Port,
         call = `Radio Call Sign`,
         mmsi = MMSI,
         ref = `Beacon ref`,
         area = FishingArea,
         file = file) %>%
  mutate(time = dmy_hms(time)) %>%
  as_tibble()
write_rds(gh, path = "data/old-vms-training_ghana.rds")

# note that there are a lot of duplicates
gh <-
  gh %>%
  select(-file) %>%
  distinct()
summary(gh)
