library(lubridate)
library(tidyverse)
d <-
  read_csv2("data-raw/sierraLeone_dump.csv", na = c("NULL", "#VALUE!"))
names(d) <- c("recievetime", "time", "lat", "lon", "speed_cms",
                "gpsquality", "publicdeviceid", "type")
d <-
  d %>%
  mutate(recievetime = ymd_hms(recievetime),
         time = ymd_hms(time),
         speed = 0.0194384 * speed_cms) %>%
  select(vid = publicdeviceid,
         time,
         lon,
         lat,
         speed,
         speed_cms,
         gpsquality,
         type) %>%
  filter(between(lon, -18, 2.5),
         between(lat, 1, 11))
write_rds(d, path = "data/sierra-leone_mail-from-stephen_2015-05-14.rds")

write_csv(d, path = "data-raw/sierra-leone_mail-from-stephen_2015-05-14.csv")
