test_that("slurping works", {
  library(xstatic)

  something <- xstatic_slurp(
    dataset_name = "^Universal",
    areas_list = "",
    filter_level = "upper",
    filter_area = "Herefordshire",
    return_level = "LSOA",
    periods_tail = 2,
    batch_size = 1000,
    use_aliases = TRUE,
    chatty = TRUE
  )

})
