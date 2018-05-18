library(tidyverse)
# ------------------------------------------------------------------------------
# SIERRA LEONE

files <-
  dir("data-raw/05_AS_Files/05_AS_Files/VMS training course WA/Sierra Leone/",
      full.names = TRUE)

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

write_rds(sl, path = "data/old-vms-training_sierra-leone.rds")


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

