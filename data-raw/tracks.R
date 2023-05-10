## code to prepare `tracks` dataset

library(readr)

tracks_raw <- read_csv("data-raw/tracks.csv")

# tracks <- read_csv("data-raw/tracks.csv") %>%
#   mutate(cup = paste(cup, "Cup"),
#          cup_trackID = row_number(), .by = "cup") %>%
#   mutate(trk_trackID = row_number(), .by = "category") %>%
#   mutate(trk48_trackID = ifelse(trkID < 49, trkID, NA)) %>%
#   rename(cat_partial = category) %>%
#   pivot_longer(cols = c(ends_with("_trackID")),
#                names_to = "cat",
#                values_to = "trackID",
#                names_pattern = "(.*)(?=_trackID)",
#                values_drop_na = TRUE) %>%
#   mutate(
#     category = case_when(
#       cat == "cup" & trkID > 48 ~ "DLC Cups",
#       cat == "cup" ~ paste(cat_partial, "Cups"),
#       cat == "trk" ~ paste(cat_partial, "Tracks"),
#       cat == "trk48" ~ "48 Tracks",
#       .default = "other"
#     ),
#     cup = if_else(
#       str_detect(category, "Tracks"),
#       NA_character_,
#       cup)
#   ) %>%
#   select(cat, category, cup, trackID, trkID:og_system)

tracks <- tracks_raw %>%
  select(trk_ID = trkID, trk, track,
         console = og_system, cup,
         cat = category,
         everything()) %>%
  mutate(cup = paste(cup, "Cup"),
         cup_ID = row_number(), .by = "cup",
         ) %>%
  mutate(wave = as.numeric(str_extract(cat, "\\d")),
         trks16_name = case_when(
           str_detect(cat, "[1357]") ~ paste(cat, "+", wave + 1),
           str_detect(cat, "[2468]") ~ paste("Wave", wave - 1, "+", wave),
           !str_detect(cat, "\\d") ~ cat
         ),
         trks16_name = paste(trks16_name, "Tracks")
         # cups_name = case_when(
         #   str_detect(cat, "\\d") ~ paste(cat, "Cups")
         # )
         ) %>%
  select(-c(wave, cat)) %>%
  mutate(trks16_ID = row_number(), .by = "trks16_name", .before = "trks16_name") %>%
  select(trk_ID:console,
         cup_ID, cup,
         everything()) %>%
  mutate(trks48_ID = ifelse(trk_ID > 48,
                            trk_ID - 48,
                            trk_ID))

save(tracks, file = "data/tracks.rda")

usethis::use_data(tracks, overwrite = TRUE)
