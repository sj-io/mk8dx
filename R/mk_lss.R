#' Convert lss data into a table
#'
#' @param filepath A path to an lss file.
#'
#' @return A tibble of the data for the lss file.
#' @export
#'
#' @import xml2
#' @import dplyr
#' @import tidyr
mk_lss <- function(filepath) {
  lss <- read_xml(filepath)

  # run variables
  run_variables <- mk_variables(lss)

  # attempts
  attempts <- mk_attempts(lss)

  # segments/tracks
  run_segments <- mk_segments(lss)

  # segment times
  segment_times <- mk_segment_times(lss)

  # put it all together
  cbind(run_variables, attempts) %>%
    left_join(segment_times, "attempt_id") %>%
    left_join(run_segments, "segment_id")
}
