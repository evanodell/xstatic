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

  expect_s3_class(something, "tbl_df")
  expect_equal(names(something), c("lsoa11cd",  "lsoa11nm",
                                   "data_date" ,"universal"))
  expect_true("E01014091" %in% something$lsoa11cd)
  expect_true(all(grepl("Herefordshire", something$lsoa11nm)))

})
