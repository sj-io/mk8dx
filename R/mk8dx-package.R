#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end

ignore_unused_imports <- function() {
  readr::read_csv()
  purrr::map()
}

utils::globalVariables(c("segment_name_path",
                         "segment_time_path",
                         "segment_id"))

