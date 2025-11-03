f_ans <- readLines("dfo-tesa-2025/exercises/05-exercise-troubleshooting-answers.qmd")

f <- f_ans[!grepl("# answer$", f_ans)]

for (i in seq_along(f)) {
  if (grepl(" # exercise$", f[i])) {
    f[i] <- gsub("^# ", "  ", f[i])
    f[i] <- gsub("^#([a-zA-Z\\#]+)", "\\1", f[i])
  }
}

writeLines(f, "dfo-tesa-2025/exercises/05-exercise-troubleshooting.qmd")
