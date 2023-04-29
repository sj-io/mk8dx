#' Get segment names/id from an lss file.
#'
#' @param lss An lss file read into R.
#'
#' @return A tibble of tracks in the lss file.
#' @export
#'
#' @import xml2
#' @import dplyr
#' @import stringr
mk_segments <- function(lss) {
  segment_names <- xml_find_all(lss, "//Segment/Name")
  best_segment_nodes <- xml_find_all(lss, "//Segment/BestSegmentTime/RealTime")

  tibble(
    segment_name = xml_text(segment_names),
    segment_name_path = xml_path(segment_names),
    segment_id = str_extract(segment_name_path, "(?<=Segment.)\\d"),
    best_segment_time = xml_text(best_segment_nodes)
  ) %>%
    select("segment_id", "segment_name", "best_segment_time")

}
