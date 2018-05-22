grade <- function(x, dx) {
  brks <- seq(floor(min(x)), ceiling(max(x)),dx)
  ints <- findInterval(x, brks, all.inside = TRUE)
  x <- (brks[ints] + brks[ints + 1]) / 2
  return(x)
}

plot_speed <- function(d, bindwidth = 0.5, speed.min = 0, speed.max = 15) {
  d %>%
    dplyr::select(speed) %>%
    tidyr::drop_na() %>%
    dplyr::filter(dplyr::between(speed, speed.min, speed.max)) %>%
    dplyr::mutate(speed = grade(speed, bindwidth)) %>%
    dplyr::group_by(speed) %>%
    dplyr::count() %>%
    ggplot2::ggplot(ggplot2::aes(speed, n)) +
    ggplot2::geom_col()
}

vms_filter_data <- function(d,
                            lon.min = -179, lon.max = 179,
                            lat.min = -89,  lat.max = 89,
                            speed.min = 2.5, speed.max = 4.5) {

  d %>%
    dplyr::select(lon, lat, speed) %>%
    tidyr::drop_na() %>%
    dplyr::filter(dplyr::between(lon, lon.min, lon.max),
                  dplyr::between(lat, lat.min, lat.max),
                  dplyr::between(speed, speed.min, speed.max))

}

vms_grid_data <- function(d, dx, dy) {

  if(missing(dx)) stop("You need to provide the longitudinal resolution")

  if(missing(dy)) dy <- dx

  d %>%
    dplyr::select(lon, lat) %>%
    tidyr::drop_na() %>%
    dplyr::mutate(lon = grade(lon, dx),
                  lat = grade(lat, dy)) %>%
    dplyr::group_by(lon, lat) %>%
    dplyr::count() %>%
    dplyr::ungroup()

}

vms_plot_data <- function(d, limit.upper = 0.99) {

  require(mapdata)
  m <-
    ggplot2::map_data("worldHires",
                      xlim = range(d$lon),
                      ylim = range(d$lat))

  d %>%
    dplyr::mutate(n = ifelse(n > quantile(n, limit.upper),
                             quantile(n, limit.upper),
                             n)) %>%
    ggplot2::ggplot() +
    ggplot2::geom_polygon(data = m, aes(long, lat, group = group), fill = "grey") +
    ggplot2::geom_raster(ggplot2::aes(lon, lat, fill = n)) +
    ggplot2::coord_quickmap(xlim = range(d$lon), ylim = range(d$lat)) +
    viridis::scale_fill_viridis(option = "B", direction = -1) +
    ggplot2::scale_x_continuous(name = NULL) +
    ggplot2::scale_y_continuous(name = NULL)

}
