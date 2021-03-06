#' xstatic_slurp
#' @name xstatic_slurp
#'
#' @param dataset_name name of the dataset on Stat-Xplore (partial/regex works)
#' @param areas_list provide a list of area codes for the query
#' @param filter_level return data within an area at this level
#' @param filter_area return data within this area. defaults to ".*"
#' @param return_level return data at this level
#' @param area_code_lookup use this source to lookup area codes at
#' data_level within filter_location
#' @param use_aliases TRUE by default. Set to FALSE to turn off aliases for
#' location_level and data_level
#' @param batch_size If data for more than 1000 area codes are requested then
#' they will be batched into queries of this size. Default is 1000.
#' @param chatty TRUE by default. Provides verbose commentary on the query
#' process.
#' @param ... space to pass parameters to the helper function `get_dwp_codes`,
#' mainly to do with the number of recent periods (months or quarters) to
#' retrieve data for: provide `periods_tail = n` (uses 1 (just return most
#' recent period) by default); see also `periods_head`; you can also tweak
#' the query away from the default of Census geographies to Westminster
#' constituencies, for example, where available, by providing a different
#' value for `geo_type`; you can also change the subset of data from the
#' default by providing a different value for `ds`.
#'
#' @return A data frame
#' @export
#'
#' @examples
#' xstatic_slurp(
#'   dataset_name = "^Carers",
#'   areas_list = "",
#'   filter_level = "lad",
#'   filter_area = "City of London",
#'   return_level = "msoa",
#'   periods_tail = 2,
#'   periods_head = 1,
#'   use_aliases = TRUE,
#'   chatty = FALSE
#' )
utils::globalVariables(c("."))

xstatic_slurp <- function(dataset_name, areas_list = "", filter_level = "",
                          filter_area = ".*", return_level,
                          area_code_lookup = "", use_aliases = TRUE,
                          batch_size = 1000, chatty = TRUE, ...) {

  # source(here("R/slurp_helpers.R"))

  if (areas_list == "") {
    if (chatty) {
      ui_info("No list of area codes provided. Using a lookup instead.")
    }
    # source(here("R/get_area_codes.R"))

    # make sure we've got a vector of area codes to work with -----------------
    area_codes <- get_area_codes(filter_level, filter_area, return_level,
      lookup = area_code_lookup,
      use_aliases = use_aliases, chatty = chatty
    )
    areas_list <- make_batched_list(area_codes, batch_size = batch_size)

    # not sure I am doing this right
    assert_that(is.list(areas_list))
    assert_that(length(areas_list) > 0)

    if (chatty) {
      ui_info(paste(
        length(area_codes),
        "area codes retrieved and batched into a list of",
        length(areas_list), "batches, of max batch size",
        batch_size
      ))
    }
  }


  # get build codes/ids etc
  # source(here("R/get_dwp_codes.R"))

  data_level <- process_aliases(return_level)
  geo_level <- geo_levels %>%
    filter(returns == data_level) %>%
    pull(geo_level)

  build_list <- get_dwp_codes(dataset_name, geo_level = geo_level, chatty = chatty, ...)

  assert_that(is.list(build_list))
  assert_that(length(build_list) == 6)

  dates <- str_replace(build_list[["periods"]], "(.*:)([:digit:]*$)", "\\2")

  # create geo_codes_list
  geo_codes_list <- areas_list %>%
    map(~ list(
      convert_geo_ids(build_list[["geo_level_id"]], .),
      build_list[["periods"]]
    ))


  # map along each chunk of geo_codes_list to create a query for each chunk

  # shamelessly borrowing this
  # source(here("R/evanodell_sx_get_data_util.R"))

  data_out_list <- geo_codes_list %>%
    map(~ build_query(
      build_list = build_list,
      geo_codes_chunk = .
    ) %>%
      sx_get_data_util(table_endpoint, .) %>%
      pull_sx_data(., dates = dates))


  data_out <- reduce(data_out_list, bind_rows)
  assert_that(nrow(data_out) == length(dates) * length(area_codes))
  ui_info(paste(nrow(data_out), "rows of data at", data_level, "level retrieved."))

  # ui_info(paste("Data level:", data_level))
  data_level_code <- paste0(data_level, "cd")
  data_level_name <- paste0(data_level, "nm")
  tidy_ben_name <- snakecase::to_snake_case(dataset_name)
  # ui_info(paste("Data level code:", data_level_code))
  # ui_info(paste("Data level name:", data_level_name))

  tibble(data_date = rep(dates, each = length(area_codes))) %>%
    bind_cols(data_out) %>%
    select(
      {{ data_level_code }} := uris,
      {{ data_level_name }} := labels,
      data_date,
      {{ tidy_ben_name }} := values
    )
}
