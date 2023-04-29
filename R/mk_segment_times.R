#' Get track times from an lss file
#'
#' @param lss An lss file read into R.
#'
#' @return A tibble of track times.
#' @export
#'
#' @import xml2
#' @import dplyr
#' @import stringr
mk_segment_times <- function(lss) {

  segment_time_nodes <- xml_find_all(lss, "//SegmentHistory/Time/RealTime")

  segment_times <- tibble(
    segment_time_path = xml_path(segment_time_nodes),
    segment_id = str_extract(segment_time_path, "(?<=Segment.)\\d"),
    attempt_id = xml_attr(xml_parent(segment_time_nodes), "id"),
    segment_time = xml_text(segment_time_nodes)
  ) %>% select("segment_id", "attempt_id", "segment_time")

  bad_segment_id <- count(segment_times, segment_id)

  if (nrow(bad_segment_id) >= 1) {
    segment_times %>% mutate(segment_id = row_number(), .by = "attempt_id")
  } else {
    segment_times
  }

}
