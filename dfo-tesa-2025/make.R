future::plan(future::multisession)
options(future.rng.onMisuse = "ignore")

PARALLEL <- F
BUILD_RMD <- F
BUILD_QMD <- T

folder <- "dfo-tesa-2025"
files <- list.files(folder, pattern = "\\.Rmd$")
files <- gsub("\\.Rmd$", "", files)

files <- files[!grepl("^99", files)]
files

# Add .qmd files from exercises/ folder that start with "0"
qmd_files <- list.files(file.path(folder, "exercises"), pattern = "^0.*\\.qmd$")
qmd_files <- gsub("\\.qmd$", "", qmd_files)
qmd_files <- file.path("exercises", qmd_files)
qmd_files <- qmd_files[!grepl("04-exercise$", qmd_files)]
qmd_files

rm <- function(x) if (file.exists(x)) file.remove(x)
rm_folder <- function(x) if (file.exists(x)) unlink(x, recursive = TRUE)

# Clean .Rmd files
if (BUILD_RMD) {
  purrr::walk(files, function(.x) {
    cat(.x, "\n")
    f <- paste0(here::here(folder, .x), ".html")
    rm(f)
    f <- paste0(here::here(folder, .x), "_cache")
    rm_folder(f)
    f <- paste0(here::here(folder, .x), "_files")
    rm_folder(f)
  })
}

# Clean .qmd files
if (BUILD_QMD) {
  purrr::walk(qmd_files, function(.x) {
    cat(.x, "\n")
    f <- paste0(here::here(folder, .x), ".html")
    rm(f)
    f <- paste0(here::here(folder, .x), "_cache")
    rm_folder(f)
    f <- paste0(here::here(folder, .x), "_files")
    rm_folder(f)
  })
}

# https://github.com/rstudio/rmarkdown/issues/1673
render_separately <- function(...) callr::r(
  function(...) rmarkdown::render(..., envir = globalenv()),
  args = list(...), show = TRUE)

render_qmd_separately <- function(...) callr::r(
  function(...) quarto::quarto_render(...),
  args = list(...), show = TRUE)

if (!PARALLEL) {
  if (BUILD_RMD) {
    purrr::walk(files, function(.x) {
      cat(.x, "\n")
      render_separately(paste0(here::here(folder, .x), ".Rmd"))
    })
  }
  if (BUILD_QMD) {
    purrr::walk(qmd_files, function(.x) {
      cat(.x, "\n")
      render_qmd_separately(paste0(here::here(folder, .x), ".qmd"))
    })
  }
} else {
  if (BUILD_RMD) {
    furrr::future_walk(rev(files), function(.x) {
      render_separately(paste0(here::here(folder, .x), ".Rmd"))
    })
  }
  if (BUILD_QMD) {
    furrr::future_walk(rev(qmd_files), function(.x) {
      render_qmd_separately(paste0(here::here(folder, .x), ".qmd"))
    })
  }
}

# Remove .rmarkdown files from exercises folder
rmarkdown_files <- list.files(
  file.path(here::here(folder, "exercises")),
  pattern = "\\.rmarkdown$",
  full.names = TRUE
)
purrr::walk(rmarkdown_files, function(.x) {
  cat("Removing:", .x, "\n")
  rm(.x)
})
