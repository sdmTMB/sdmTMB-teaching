d <- readRDS("~/src/gfsynopsis-2024/report/data-cache-2025-03/quillback-rockfish.rds")
# d <- readRDS("~/src/gfsynopsis-2024/report/data-cache-2025-03/north-pacific-spiny-dogfish.rds")
# d <- readRDS("~/src/gfsynopsis-2024/report/data-cache-2025-03/lingcod.rds")
d <- d$survey_sets
# Filter to the two HBLL inside surveys
# d <- dplyr::filter(d, survey_abbrev %in% c("HBLL OUT N", "HBLL OUT S"))
d <- dplyr::filter(d, survey_abbrev %in% c("HBLL INS N", "HBLL INS S"))

d <- dplyr::select(d, year, survey_abbrev, longitude, latitude, density_ppkm2, catch_count)
saveRDS(d, "dfo-tesa-2025/data/quillback-hbll-inside.rds")

library(dplyr)
grid_one_n <- gfplot::hbll_inside_n_grid$grid |>
  rename(longitude = X, latitude = Y) |>
  mutate(survey_abbrev = "HBLL INS N")
grid_one_s <- gfplot::hbll_inside_s_grid$grid |>
  rename(longitude = X, latitude = Y) |>
  mutate(survey_abbrev = "HBLL INS S")
grid_one <- bind_rows(grid_one_n, grid_one_s)
grid_one <- as.data.frame(grid_one) |> as_tibble()
row.names(grid_one) <- NULL

saveRDS(grid_one, "dfo-tesa-2025/data/hbll-inside-grid.rds")
