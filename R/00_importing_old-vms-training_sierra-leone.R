library(tidyverse)
library(rio)
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
sl <-
  sl %>%
  select(vid = publicdeviceid,
         time,
         lon,
         lat,
         speed,
         heading,
         messageid,
         channel,
         name,
         speed_cms,
         type,
         recievetime,
         gpsquality) %>%
  filter(between(lon, -18, 2.5),
         between(lat, 1, 11))

write_rds(sl, path = "data/old-vms-training_sierra-leone.rds")

