#' Convert a folder of lss files into a table.
#'
#' @param folder A folder path to your MK8DX lss files.
#'
#' @return A tibble of your speedrun data.
#' @export
#'
#' @import purrr
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import xml2

mk_lss <- function(folder) {
  s <- folder
  f <- list.files(s, pattern = ".lss")
  fileList <- paste0(s, "/", f)

  attemptdates <- fileList |>
    map(read_xml) |>
    map(xml_find_all, "AttemptHistory") |>
    map(xml_children) |>
    map(xml_attrs) |>
    enframe(name = "fileID") |>
    unnest_longer(col = "value") |>
    unnest_wider(col = "value") |>
    mutate(id = as.integer(id)) |>
    select(fileID, runID = id, run_started = started, run_ended = ended)

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
    unnest(Metadata) |>
    mutate(md = case_when(
      str_detect(Metadata, "Cup") ~ "v-cup",
      str_detect(Metadata, "\\d{2}cc") ~ "v-speed",
      str_detect(Metadata, "Items$") ~ "v-items",
      str_detect(Metadata, "^(Digital|Cartridge)$") ~ "v-version",
      str_detect(Metadata, "2.3.0") ~ "v-patch"
    )) |>
    unnest(Metadata) |>
    pivot_wider(names_from = "md", values_from = "Metadata", values_fill = NA_character_) |>
    unnest(AttemptHistory) |>
    mutate(runID = row_number(), .by = "fileID", .after = "fileID") |>
    unnest_wider(AttemptHistory) |>
    unnest_longer(Segments, keep_empty = TRUE) |>
    mutate(trackID = row_number(), .by = c("fileID", "runID"), .after = "runID") |>
    unnest_wider(Segments) |>
    unnest(c(SplitTimes, SegmentHistory)) |>
    unnest(cols = c(SplitTimes, BestSegmentTime, SegmentHistory)) |>
    unnest(everything()) |>
    unnest(everything()) |>
    mutate(segmentID = row_number(), .by = c("fileID", "runID", "trackID"), .after = "trackID",
           AttemptCount = as.numeric(AttemptCount)) |>
    filter(runID == segmentID) |>
    left_join(attemptdates, by = c("fileID", "runID")) |>
    select(fileID,
           category = CategoryName,
           starts_with("v-"),
           attempts = AttemptCount,
           runID,
           starts_with("run_"),
           trackID,
           trk = Name,
           split_time = SegmentHistory,
           # split_PB = BestSegmentTime,
           # run_PB = SplitTimes
    ) |>
    rename_with(~ str_remove(.x, "v-"), starts_with("v-"))

  lsstocsv
}
