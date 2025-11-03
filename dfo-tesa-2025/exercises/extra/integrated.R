d <- readRDS("~/src/gfsynopsis-2024/report/data-cache-2025-03/north-pacific-spiny-dogfish.rds")
library(dplyr)
library(ggplot2)
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

ggplot(dat, aes(longitude, latitude, size = catch_count, colour = survey)) +
  geom_point(alpha = 0.2, pch = 21) +
  facet_wrap(~year)

library(sdmTMB)

dat2 <- add_utm_columns(dat, c("longitude", "latitude"), utm_crs = 32609) |>
  as.data.frame()

mesh <- make_mesh(dat2, c("X", "Y"), cutoff = 15)
plot(mesh)

dat2$survey <- factor(dat2$survey, levels = c("HBLL", "IPHC"))

fit <- sdmTMB(catch_count ~ factor(year) + factor(survey), family = nbinom2(), data = dat2, mesh = mesh, time = "year", spatial = "on", spatiotemporal = "iid", silent = FALSE, anisotropy = TRUE, offset = log(dat2$hook_count))


sanity(fit)
print(fit)
tidy(fit)
tidy(fit, "ran_pars")

plot_anisotropy(fit)
summary(fit)

grid <- gfplot::hbll_s_grid$grid |>
  rename(longitude = X, latitude = Y)
grid <- sdmTMB::replicate_df(grid, "year", sort(unique(dat2$year)))
grid <- add_utm_columns(grid, c("longitude", "latitude"), utm_crs = 32609)
grid$survey <- factor("HBLL", levels = c("HBLL", "IPHC"))

pred <- predict(fit, newdata = grid, return_tmb_object = TRUE)

ind <- get_index(pred, area = 4, bias_correct = TRUE)

ggplot(ind, aes(year, est, ymin = lwr, ymax = upr)) +
  geom_ribbon(fill = "grey70", colour = NA) +
  geom_line()
