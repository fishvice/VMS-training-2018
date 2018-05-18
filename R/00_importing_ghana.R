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
gh <-
  gh %>%
  select(-file) %>%
  distinct()
summary(gh)

# ------------------------------------------------------------------------------
# SIERRA LEONE

files <-
  dir("data-raw/05_AS_Files/05_AS_Files/VMS training course WA/Sierra Leone/",
      full.names = TRUE)

res <- list()
counter <- 0
for(j in 1:length(files)) {
    res[[j]] <-
      import(files[j]) %>%
      mutate(file = files[j],
             PublicDeviceID = as.character(PublicDeviceID))
}

sl <-
  bind_rows(res)

tmp1 <- import(files[1])
names(tmp1) <- c("messageid", "date", "time", "channel",
                 "publicdeviceid", "name", "speed_cms",
                 "heading", "lon", "lat", "type", "speed")
tmp1 <-
  tmp1 %>%
  unite(date, time, col = "time", sep = " ")
tmp2 <- import(files[2])
names(tmp2) <- c("recievetime","time","lat", "lon", "speed_cms",
                 "speed", "gpsquality","publicdeviceid", "type")
tmp3 <- import(files[3])
names(tmp3) <- c("recievetime","time","lat", "lon", "speed_cms",
                 "speed", "gpsquality","publicdeviceid", "type")
tmp3 <-
  tmp3 %>%
  mutate(speed_cms = ifelse(speed_cms == "NULL", NA_character_,
                            speed_cms),
         speed_cms = as.numeric(speed_cms))

sl <-
  tmp1 %>%
  mutate(publicdeviceid = as.character(publicdeviceid)) %>%
  bind_rows(tmp2 %>%
              mutate(publicdeviceid = as.character(publicdeviceid))) %>%
  bind_rows(tmp3) %>%
  as_tibble() %>%
  mutate(recievetime = dmy_hms(recievetime),
         time = dmy_hms(time))

summary(sl)
sl %>%
  filter(speed < 15) %>%
  ggplot(aes(speed)) +
  geom_histogram()

# ------------------------------------------------------------------------------
# Sierra Leone 2
sl2 <- read_csv("data-raw/20171128-SL_data_dump.csv", na = c("NULL", "#VALUE!"))
names(sl2) <- c("recievetime", "time", "lat", "lon", "speed_cms",
                "speed", "gpsquality", "publicdeviceid", "type")
sl2 <-
  sl2 %>%
  mutate(recievetime = ymd_hms(recievetime),
         time = ymd_hms(time))

# ------------------------------------------------------------------------------
# Sierra Leone 3
sl3 <- read_csv2("data-raw/sierraLeone_dump.csv", na = c("NULL", "#VALUE!"))
names(sl3) <- c("recievetime", "time", "lat", "lon", "speed_cms",
                "gpsquality", "publicdeviceid", "type")
sl3 <-
  sl3 %>%
  mutate(recievetime = ymd_hms(recievetime),
         time = ymd_hms(time))

d <-
  sl %>%
  mutate(file = 1) %>%
  bind_rows(sl2 %>%
              mutate(file = 2,
                     publicdeviceid = as.character(publicdeviceid))) %>%
  bind_rows(sl3 %>%
              mutate(file = 3,
                     publicdeviceid = as.character(publicdeviceid)))

d <-
  d %>%
  # overwrite derived speed
  mutate(speed = 0.0194384 * speed_cms)
d %>%
  filter(between(speed, 1, 15)) %>%
  sample_n(1e5) %>%
  ggplot() +
  geom_histogram(aes(speed))
d %>%
  mutate(year = year(time),
         month = month(time)) %>%
  group_by(file) %>%
  summarise(n = n(),
            y.min = min(year, na.rm = TRUE),
            y.max = max(year, na.rm = TRUE))
