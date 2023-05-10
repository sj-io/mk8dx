# test_that("function works", {
#
#   # files <- mk_lss_folder("inst/extdata/")
#   # all_runs <- map(files, mk_lss) |> list_rbind()
#   # bad_cup_cat <- all_runs %>% filter(str_detect(category, "Cup$"))
#
#   mk_repair(bad_cup_cat)
#
#   # mess_1 <- mk_lss_folder("../../data/splits/")
#   # mess_2 <- mk_lss_folder("../../data/splits/archive/")
#   # mess_3 <- mk_lss_folder("../../data/splits/archive/archive-2/")
#   # mess <- c(mess_1, mess_2, mess_3)
#
#   messy <- map(mess, mk_lss) %>% list_rbind()
#
#   # messy_cups <- messy %>% filter(!str_ends(category, "Tracks"))
#   # tidy_cups <- messy_cups %>% mk_repair()
#
#   tidy <- mk_repair(messy) %>% distinct()
#
#   fix_these <- tidy %>%
#     count(attempt_started, segment_id) %>%
#     filter(n > 1) %>%
#     arrange(desc(n)) %>% left_join(test)
#
#
# })
