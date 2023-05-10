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
#' @import lubridate
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
  if (nrow(attempts != 0)) {
    cbind(run_variables, attempts) %>%
      left_join(segment_times, "attempt_id") %>%
      left_join(run_segments, "segment_id") %>%
      mutate(across(c("attempt_started", "attempt_ended"),
                    ~ lubridate::mdy_hms(.x)),
             across(ends_with("_time"),
                    ~ lubridate::period_to_seconds(lubridate::hms(.x)))) %>%
      suppressWarnings()
  } else {
    cbind(run_variables, run_segments)
  }

}

#' Get run variables from lss data.
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of the metadata variables for the lss file.
#'
#' @importFrom janitor clean_names
mk_variables <- function(lss) {

  variable_nodes <- xml_find_all(lss, "//Variable")

  if (length(variable_nodes) != 0) {
    tibble(
      category = xml_text(xml_child(lss, "CategoryName")),
      attempt_count = as.numeric(xml_text(xml_child(lss, "AttemptCount"))),
      name = xml_attr(variable_nodes, "name"),
      value = xml_text(variable_nodes)
    ) %>%
      pivot_wider() %>% janitor::clean_names()
  } else {
    tibble(
      category = xml_text(xml_child(lss, "CategoryName")),
      attempt_count = as.numeric(xml_text(xml_child(lss, "AttemptCount")))
    )
  }
}

#' Run attempt history
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of your run attempts for the lss file.
mk_attempts <- function(lss) {

  attempt_nodes <- xml_find_all(lss, "//Attempt")

  tibble(
    attempt_id = as.numeric(xml_attr(attempt_nodes, "id")),
    attempt_started = xml_attr(attempt_nodes, "started"),
    attempt_ended = xml_attr(attempt_nodes, "ended"),
    attempt_time = xml_text(xml_child(attempt_nodes, "RealTime"))
  )

}


#' Get segment names/id from an lss file.
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of tracks in the lss file.
#'
#' @import stringr
mk_segments <- function(lss) {
  segment_names <- xml_find_all(lss, "//Segment/Name")
  best_segment_nodes <- xml_find_all(lss, "//Segment/BestSegmentTime/RealTime")

  segments <- tibble(
    segment_name = xml_text(segment_names),
    segment_name_path = xml_path(segment_names),
    segment_id = as.numeric(str_extract(segment_name_path, "(?<=Segment.)\\d"))
  ) %>%
    select("segment_id", "segment_name")

  if (length(best_segment_nodes) >= 1) {
    segments <- segments %>%
      mutate(best_segment_time = xml_text(best_segment_nodes))
  }

  bad_segment_id <- count(segments, segment_id)

  if (nrow(bad_segment_id) >= 1) {
    segments %>% mutate(segment_id = row_number())
  } else {
    segments
  }

}

#' Get track times from an lss file
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of track times.
mk_segment_times <- function(lss) {

  segment_time_nodes <- xml_find_all(lss, "//SegmentHistory/Time/RealTime")

  segment_times <- tibble(
    segment_time_path = xml_path(segment_time_nodes),
    segment_id = as.numeric(str_extract(segment_time_path, "(?<=Segment.)\\d")),
    attempt_id = as.numeric(xml_attr(xml_parent(segment_time_nodes), "id")),
    segment_time = xml_text(segment_time_nodes)
  ) %>% select("segment_id", "attempt_id", "segment_time")

  bad_segment_id <- count(segment_times, segment_id)

  if (nrow(bad_segment_id) >= 1) {
    segment_times %>% mutate(segment_id = row_number(), .by = "attempt_id")
  } else {
    segment_times
  }

}
