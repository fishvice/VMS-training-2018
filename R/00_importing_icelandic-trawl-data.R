library(mar)
con <- connect_mar()
VID <-
  afli_stofn(con) %>%
  filter(ar %in% 2017,
         veidarf == 6) %>%
  collect(n = Inf) %>%
  pull(skipnr) %>%
  unique()
VID <- as.character(VID)
tbl_mar(con, "stk.stk_vms_v") %>%
  mutate(year = to_number(to_char(posdate, 'YYYY')),
         lon = poslon * 45 / atan(1),
         lat = poslat * 45 / atan(1),
         heading = heading * 45 / atan(1),
         speed = speed * 1.852) %>%
  filter(year %in% c(2017),
         between(lon, -28, -18),
         between(lat, 65.5, 67.5),
         skip_nr %in% VID) %>%
  select(vid = skip_nr, time = posdate, lon, lat,
         speed, heading, port = harborid) %>%
  collect(n = Inf) %>%
  mutate(vid = as.integer(vid)) %>%
  write_rds(path = "data/iceland_vms-trawl-data.rds")
