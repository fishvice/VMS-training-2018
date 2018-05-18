library(tidyverse)
files <-
  data_frame(path = dir("data-raw/global-fishing-watch/fishing_effort/daily_csvs",
                        full.names = TRUE),
             year = dir("data-raw/global-fishing-watch/fishing_effort/daily_csvs") %>%
               str_sub(1,4))

years <- unique(files$year)

for(y in 1:length(years)) {
  print(years[y])
  files.tmp <-
    files %>%
    filter(year == years[y]) %>%
    pull(path)
  res <- list()
  for(i in 1:length(files.tmp)) {
    res[[i]] <-
      read_csv(files.tmp[i]) %>%
      rename(lon = lon_bin,
             lat = lat_bin) %>%
      mutate(lon = lon / 100,
             lat = lat / 100)
  }
  bind_rows(res) %>%
  write_rds(path = paste0("data/global-fishing-watch_", years[y], ".rds"))
}
