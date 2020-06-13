#' xstatic: Builds Queries And Retrieves Data From DWP Stat-Xplore
#'
#' @import httr
#' @importFrom assertthat assert_that
#' @importFrom dplyr bind_cols bind_rows ensym filter mutate mutate_at pull select slice tibble
#' @importFrom dwpstat dwp_schema
#' @importFrom here here
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map map_chr map2_chr map_dfc pluck reduce
#' @importFrom readr read_csv
#' @importFrom rlang .data :=
#' @importFrom snakecase to_snake_case
#' @importFrom stringr str_c str_detect str_glue str_replace str_subset
#' @importFrom usethis ui_info ui_stop use_data
#' @importFrom utils head tail
#' @docType package
#' @name xstatic
#' @aliases NULL xstatic-package
NULL

