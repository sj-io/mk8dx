#' Repair MK8DX columns
#'
#' @param df A table of MK8DX speedrunning data
#'
#' @return Repaired table
#' @export
#'
#' @import dplyr
#' @import stringr
mk_repair <- function(df) {

  df <- df %>%
    mutate(
      # remove extra white space
      across(where(is.character), ~ str_trim(.x)),
      # round times to thousandth place
      across(ends_with("_time"), ~ round(.x, 3))
      )

  # find incorrectly categorized cups
  c <- str_detect(df$category, "Cup$") %>% unique()

  if (TRUE %in% c) {

    bad_cups <- df %>% filter(str_detect(category, "Cup$"))
    good_cups <- mk_repair_cup_cats(bad_cups)

    df <- df %>%
      filter(!str_detect(category, "Cup$")) %>%
      bind_rows(good_cups)

  }

  df %>%
    # fill empty metadata variables
    mk_repair_fill_vars() %>%
    # repair outdated columns
    mk_repair_outdated()

}

#' Repair MK8DX cups in category column
#'
#' @param df A table of MK8DX speedrunning data.
#' @param category The category with incorrect data
#' @param individual_cup The column for cup names
#'
#' @return Table with corrected cups and categories columns.
#'
#' @import purrr
mk_repair_cup_cats <- function(df, category, individual_cup) {

  tracks <- tracks
  cup_cats <- set_names(tracks$trks16_name, tracks$cup)

  df %>%
    mutate(individual_cup = category,
           category = recode(category, !!!cup_cats),
           category = str_replace(category, "Tracks", "Cups"))

}


#' Repair missing variables based on categories
#'
#' @param df table of MK8DX speedrunning data.
#' @param category The categories to group by.
#' @param individual_cup The cups to group by.
#'
#' @return table with filled in values
#'
mk_repair_fill_vars <- function(df, category, individual_cup) {

  df %>%
    group_by(category, individual_cup) %>%
    fill(-c("category", "individual_cup", contains("attempt"), contains("segment")),
         .direction = "downup") %>%
    ungroup()

}


#' Repair outdated data
#'
#' @param df table of MK8DX speedrunning data.
#' @param attempt_count column to correct
#' @param best_segment_time column to correct
#'
#' @return table with corrected columns
#'
mk_repair_outdated <- function(df, attempt_count, best_segment_time) {

  df %>%
    mutate(attempt_count = max(attempt_count),
           best_segment_time = min(best_segment_time),
           .by = c("category":"attempt_id", -contains("attempt"), "segment_id"))

}
