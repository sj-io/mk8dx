#' MK8DX tracks
#'
#' Tracks, cups, categories in MK8DX.
#'
#' @source Nintendo MK8DX track selection screen.
#' Abbreviated names from MK8DX Speedrunning discord, Meester Tweester#7342 pinned comment on general-chat. <https://discord.com/channels/199214365860298752/199214365860298752/998310385545384138>
#'
#' @format Data fram with columns
#' \describe{
#' \item{trkID}{key. unique ID for the track}
#' \item{trk}{track abbreviation}
#' \item{track}{base name for the track}
#' \item{og_system}{the original gaming system for the track}
#' \item{cup_ID}{track's split position in a 4-track cup run}
#' \item{cup}{track's cup}
#' \item{trks16_ID}{track's split position in a 16-track run}
#' \item{trks16_name}{track's 16 track category}
#' \item{trks48_ID}{track's split position in a 48-track run}
#' }
"tracks"
