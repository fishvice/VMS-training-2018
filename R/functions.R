grade <- function(x, dx) {
  brks <- seq(floor(min(x)), ceiling(max(x)),dx)
  ints <- findInterval(x, brks, all.inside = TRUE)
  x <- (brks[ints] + brks[ints + 1]) / 2
  return(x)
}

plot_speed <- function(d) {
  d %>%
    ggplot(aes(speed)) +
    geom_histogram()
}