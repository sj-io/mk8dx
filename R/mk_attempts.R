#' Run attempt history
#'
#' @param filepath A filepath to an lss file.
#'
#' @return A tibble of your run attempt history for the lss file.
#' @export
#'
#' @import xml2
#' @import purrr
#' @import dplyr
mk_attempts <- function(filepath) {

  attempts <- filepath %>%
    read_xml() %>%
    xml_find_all("AttemptHistory") %>%
    xml_children() %>%
    xml_attrs() %>%
    map_dfr(enframe, .id = "attempt") %>%
    pivot_wider() %>%
    select(-1)

}
