#' Convert lss data into a table
#'
#' @param path A path to an lss file.
#'
#' @return A tibble of the data for the lss file.
#' @export
#'
#' @import xml2 dplyr tidyr lubridate stringr purrr
mk_lss <- function(path) {

  if (str_ends(path, ".lss")) {
    mk_lss_file(path)

  } else if (dir.exists(path)) {

    if (!str_ends(path, "/")) {
      path <- paste0(path, "/")
    }

    files <- paste0(path, list.files(path, pattern = ".lss"))
    map(files, mk_lss_file) |> list_rbind()

  } else {
    stop("Not an .lss file or folder containing .lss files.")
  }

}

mk_lss_file <- function(path) {
  lss <- read_xml(path)

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
      suppressWarnings() %>%
      as_tibble()
  } else {
    cbind(run_variables, run_segments) %>% as_tibble()
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
      total_attempts = as.numeric(xml_text(xml_child(lss, "AttemptCount"))),
      name = xml_attr(variable_nodes, "name"),
      value = xml_text(variable_nodes)
    ) %>%
      pivot_wider() %>% janitor::clean_names()
  } else {
    tibble(
      category = xml_text(xml_child(lss, "CategoryName")),
      total_attempts = as.numeric(xml_text(xml_child(lss, "AttemptCount")))
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
    attempt_real_time = xml_text(xml_child(attempt_nodes, "RealTime")),
    attempt_game_time = xml_text(xml_child(attempt_nodes, "GameTime"))
  )

}


#' Get segment names/id from an lss file.
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of tracks in the lss file.
mk_segments <- function(lss) {
  segment_names <- xml_find_all(lss, "//Segment/Name")
  best_segment_nodes_real <- xml_find_all(lss, "//Segment/BestSegmentTime/RealTime")
  best_segment_nodes_game <- xml_find_all(lss, "//Segment/BestSegmentTime/GameTime")

  segments <- tibble(
    segment_name = xml_text(segment_names),
    segment_name_path = xml_path(segment_names),
    segment_id = as.numeric(str_extract(segment_name_path, "(?<=Segment.)\\d"))
  ) %>%
    select("segment_id", "segment_name")

  bad_segment_id <- count(segments, segment_id)
  bad_segment_id <- bad_segment_id |> filter(n > 1)

  if (nrow(bad_segment_id) >= 1) {
    segments <- segments %>% mutate(segment_id = row_number())
  }

  if (length(best_segment_nodes_real) >= 1) {
    segments <- segments %>%
      mutate(best_segment_real_time = xml_text(best_segment_nodes_real))
  }

  if (length(best_segment_nodes_game) >= 1) {
    segments <- segments %>%
      mutate(best_segment_game_time = xml_text(best_segment_nodes_game))
  }

  segments

}

#' Get track times from an lss file
#'
#' @param lss MK8DX XML data
#'
#' @return A tibble of track times.
mk_segment_times <- function(lss) {

  segment_real_time_nodes <- xml_find_all(lss, "//SegmentHistory/Time/RealTime")
  segment_game_time_nodes <- xml_find_all(lss, "//SegmentHistory/Time/GameTime")

  segment_real_times <- tibble(
    segment_time_path = xml_path(segment_real_time_nodes),
    segment_id = as.numeric(str_extract(segment_time_path, "(?<=Segment.)\\d")),
    attempt_id = as.numeric(xml_attr(xml_parent(segment_real_time_nodes), "id")),
    segment_real_time = xml_text(segment_real_time_nodes)
  ) %>% select("segment_id", "attempt_id", "segment_real_time")

  bad_segment_id <- count(segment_real_times, segment_id)
  bad_segment_id <- bad_segment_id |> filter(n > 1)

  if (nrow(bad_segment_id) >= 1) {
    segment_real_times <- segment_real_times %>% mutate(segment_id = row_number(), .by = "attempt_id")
  }

  segment_game_times <- tibble(
    segment_time_path = xml_path(segment_game_time_nodes),
    segment_id = as.numeric(str_extract(segment_time_path, "(?<=Segment.)\\d")),
    attempt_id = as.numeric(xml_attr(xml_parent(segment_game_time_nodes), "id")),
    segment_game_time = xml_text(segment_game_time_nodes)
  ) %>% select("segment_id", "attempt_id", "segment_game_time")

  if (nrow(bad_segment_id) >= 1) {
    segment_game_times <- segment_game_times %>% mutate(segment_id = row_number(), .by = "attempt_id")
  }

  segment_times <- segment_real_times |> left_join(segment_game_times, by = c("segment_id", "attempt_id"))

}
