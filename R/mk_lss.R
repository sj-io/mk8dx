#' @import purrr
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import xml2

mk_lss <- function(folder) {
  s <- folder
  f <- list.files(s, pattern = ".lss")
  fileList <- paste0(s, "/", f)

  lsstocsv <- fileList |>
    map(read_xml) |>
    map(as_list) |>
    tibble() |>
    rename(value = 1) |>
    unnest(value) |>
    unnest_wider(value) |>
    mutate(fileID = row_number(), .before = 1) |>
    unnest(Metadata) |>
    unnest(Metadata) |>
    filter(map_vec(Metadata, ~ !str_detect(., "^Switch$"))) |>
    # filter(!str_detect(Metadata, "^Switch$")) |>
    unnest(Metadata) |>
    mutate(md = case_when(
      str_detect(Metadata, "Cup") ~ "v-cup",
      str_detect(Metadata, "\\d{2}cc") ~ "v-speed",
      str_detect(Metadata, "Items$") ~ "v-items",
      str_detect(Metadata, "^(Digital|Cartridge)$") ~ "v-version"
    )) |>
    unnest(Metadata) |>
    pivot_wider(names_from = "md", values_from = "Metadata", values_fill = NA_character_) |>
    unnest(AttemptHistory) |>
    group_by(fileID) |>
    mutate(runID = row_number(), .after = "fileID") |>
    unnest_wider(AttemptHistory) |>
    unnest_longer(Segments, keep_empty = TRUE) |>
    group_by(fileID, runID) |>
    mutate(trackID = row_number(), .after = "runID") |>
    ungroup() |>
    unnest_wider(Segments) |>
    unnest(c(SplitTimes, SegmentHistory)) |>
    unnest(cols = c(SplitTimes, BestSegmentTime, SegmentHistory)) |>
    unnest(everything()) |>
    unnest(everything()) |>
    group_by(fileID, runID, trackID) |>
    mutate(segmentID = row_number(), .after = "trackID") |>
    ungroup() |>
    filter(runID == segmentID) |>
    select(fileID:trackID,
           category = CategoryName,
           starts_with("v-"),
           trk = Name,
           total_attempts = AttemptCount,
           split_time = SegmentHistory,
           split_PB = BestSegmentTime,
           run_PB = SplitTimes) |>
    rename_with(~ str_remove(.x, "v-"), starts_with("v-"))

  lsstocsv
}
