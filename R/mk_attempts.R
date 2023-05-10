#' Run attempt history
#'
#' @param lss An lss file read into R.
#'
#' @return A tibble of your run attempts for the lss file.
#'
#' @import xml2
#' @import tidyr
mk_attempts <- function(lss) {

  attempt_nodes <- xml_find_all(lss, "//Attempt")

  tibble(
    attempt_id = as.numeric(xml_attr(attempt_nodes, "id")),
    attempt_started = xml_attr(attempt_nodes, "started"),
    attempt_ended = xml_attr(attempt_nodes, "ended"),
    attempt_time = xml_text(xml_child(attempt_nodes, "RealTime"))
  )

}
