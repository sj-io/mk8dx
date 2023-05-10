#' Get all lss files in a folder
#'
#' @param folderpath A folder containing lss files
#'
#' @return A table of all lss data in the folder
#' @export
#'
#' @import purrr
mk_lss_folder <- function(folderpath) {

  d <- folderpath

  if (!str_ends(d, "/")) {
    d <- paste0(d, "/")
  }

  files <- paste0(d, list.files(d, pattern = ".lss"))
  map(files, mk_lss) |> list_rbind()

}
