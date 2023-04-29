#' Get run variables from lss data.
#'
#' @param lss An lss file read into R.
#'
#' @return A tibble of the metadata variables for the lss file.
#' @export
#'
#' @import xml2
#' @import tidyr
#' @importFrom janitor clean_names
mk_variables <- function(lss) {

  variable_nodes <- xml_find_all(lss, "//Variable")

  if (length(variable_nodes) == 0) {
    tibble(
      category = xml_text(xml_child(lss, "CategoryName")),
      attempt_count = xml_text(xml_child(lss, "AttemptCount"))
    )
  } else {
    tibble(
      category = xml_text(xml_child(lss, "CategoryName")),
      attempt_count = xml_text(xml_child(lss, "AttemptCount")),
      name = xml_attr(variable_nodes, "name"),
      value = xml_text(variable_nodes)
    ) %>%
      pivot_wider() %>% janitor::clean_names()
  }
}
