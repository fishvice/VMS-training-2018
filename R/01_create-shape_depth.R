library(marmap)
library(sp)
library(raster)
library(tidyverse)
cp <-
  getNOAA.bathy(lon1=-20, lon2=5, lat1=2, lat2=15,
                resolution=1, keep = T) %>%
  as.SpatialGridDataFrame() %>%
  raster() %>%
  rasterToContour(levels = c(-25, -50, -100, -200, -500, -1000))
names(cp@data) <- "depth"
cp %>%
  ggplot() +
  geom_path(aes(long, lat, group = group)) +
  coord_quickmap(xlim = c(-20, -10),
                 ylim = c(5, 12))
rgdal::writeOGR(cp, "data-raw/shapes", "depth-contours", driver = "ESRI Shapefile")
