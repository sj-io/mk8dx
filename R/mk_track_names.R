#' Rename MK8DX track names
#'
#' @param df working df
#' @param style The track name as "full", "abbr", or "both"
#' @param tag_position Either "before" or "after" track name
#' @param tag_surrounds Either "parenthesis", "brackets", or "NA"
#'
#' @return A dataframe with renamed track names
#' @export
#'
mk_track_names <- function(df,
                           style = "both",
                           tag_position = "after",
                           tag_surrounds = "brackets") {

  tracks <- tracks
  tracks_long <- tracks %>%
    pivot_longer(cols = c(ends_with("_ID") & !"trk_ID"),
                 names_pattern = "(.*)_ID",
                 names_to = "category",
                 values_to = "segment_id") %>%
    mutate(
      individual_cup = if_else(category == "cup", cup, NA_character_),
      category = case_when(
        category == "cup" & trk_ID > 48 ~ "DLC Cups",
        category == "cup" ~ str_replace(trks16_name, "Tracks", "Cups"),
        category == "trks16" ~ trks16_name,
        category == "trks48" & trk_ID > 48 ~ "DLC 48 Tracks",
        category == "trks48" ~ "48 Tracks",
        .default = category
      )) %>%
    select(-c(trks16_name, cup, trk_ID))

  # tag surrounds
  if (tag_surrounds == "parenthesis") {
    tracks_long$console <- if_else(!is.na(tracks_long$console),
                              paste0("(", tracks_long$console, ")"),
                              tracks_long$console)
  } else if (tag_surrounds == "brackets") {
    tracks_long$console <- if_else(!is.na(tracks_long$console),
                              paste0("[", tracks_long$console, "]"),
                              tracks_long$console)
  } else {
    tracks_long$console
  }

  # tag position
  if (tag_position == "before") {
    tracks_long$track <- if_else(!is.na(tracks_long$console),
                            paste(tracks_long$console, tracks_long$track),
                            tracks_long$track)
  } else {
    tracks_long$track <- if_else(!is.na(tracks_long$console),
                            paste(tracks_long$track, tracks_long$console),
                            tracks_long$track)
  }

  df <- df %>%
    left_join(tracks_long %>% select(-console),
              by = c("category", "individual_cup", "segment_id")) %>%
    rename(og_segment_name = segment_name)

  if (style == "full") {
    df %>%
      rename(segment_name = track) %>%
      select(-trk)
  } else if (style == "abbr") {
    df %>%
      rename(segment_name = trk) %>%
      select(-track)
  } else {
    df %>%
      rename(segment_name = track,
             segment_name_abbr = trk)
  }

}
