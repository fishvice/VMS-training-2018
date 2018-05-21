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
  select(vid = Mobile,
         time = Date,
         lon = Longitude,
         lat = Latitude,
         speed = Speed,
         port = Port,
         eez1 = EEZ1,
         call = `Radio Call Sign`,
         mmsi = MMSI,
         ref = `Beacon ref`,
         area = FishingArea,
         file = file) %>%
  mutate(time = dmy_hms(time)) %>%
  as_tibble() %>%
  select(-file) %>%
  # get rid of duplicates
  distinct() %>%
  write_rds(path = "data/old-vms-training_ghana.rds")

