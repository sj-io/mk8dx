#' Get all lss files in a folder
#'
#' @param folderpath A folder containing lss files
#'
#' @return A vector of lss filepaths
#' @export
#'
#' @examples
#' folder <- "extdata/"
#' mk_lss_folder(folder)
mk_lss_folder <- function(folderpath) {

  d <- folderpath
  paste0(d, list.files(d, pattern = ".lss"))

}
