library(dplyr)
library(ggplot2)

d <- readRDS("~/src/gfsynopsis-2024/report/data-cache-2025-03/north-pacific-spiny-dogfish.rds")
d1 <- d$survey_sets
d2 <- filter(d1, survey_abbrev == "HBLL OUT S")
d3 <- gfdata::load_iphc_dat() |> filter(year >= min(d2$year)) |>
  filter(species_common_name == "north pacific spiny dogfish") |>
  filter(latitude < max(d2$latitude))

ggplot(d3, aes(longitude, latitude, size = number_observed)) +
  geom_point() +
  facet_wrap(~year) +
  geom_point(data = d2, colour = "red", pch = 21, mapping = aes(size = catch_count))

dat <- bind_rows(
  transmute(d2, year, longitude, latitude, catch_count, hook_count, survey = "HBLL"),
  transmute(d3, year, longitude, latitude, catch_count = number_observed, hook_count = hooks_observed, survey = "IPHC")
)
grid <- gfplot::hbll_s_grid$grid |>
  rename(longitude = X, latitude = Y) |>
  as_tibble()

saveRDS(dat, file = "data/dogfish-hbll-iphc.rds")
saveRDS(grid, file = "data/hbll-s-grid.rds")
