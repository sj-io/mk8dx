# test_that("mk_segments runs with empty file", {
#   lss <- read_xml("../../inst/extdata/boomerang-cup.lss")
#
#   segments <- mk_segments(lss)
#
#   expect_equal(ncol(segments), 2)
# })
#
# test_that("mk_segments runs with non-empty file", {
#   lss <- read_xml("../../inst/extdata/bell-cup.lss")
#
#   segments <- mk_segments(lss)
#
#   expect_equal(ncol(segments), 3)
# })
