
# mk8dx

<!-- badges: start -->
<!-- badges: end -->

The mk8dx package converts lss files for MK8DX speedruns into usable
table data.

## Installation

You can install the development version of mk8dx from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("sj-io/mk8dx")
```

Load the package to your library to use it.

``` r
library(mk8dx)
```

## Package Contents

### `mk_lss()`: Convert lss data to a table format

`mk_lss` is a function that converts .lss file data into a table.

``` r
library(dplyr)

filepath <- "inst/extdata/bell-cup.lss"

bell_cup <- mk_lss(filepath)

glimpse(bell_cup)
```

    ## Rows: 8
    ## Columns: 14
    ## $ category          <chr> "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cup…
    ## $ attempt_count     <dbl> 2, 2, 2, 2, 2, 2, 2, 2
    ## $ individual_cup    <chr> "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bel…
    ## $ cc                <chr> "150cc", "150cc", "150cc", "150cc", "150cc", "150cc"…
    ## $ items             <chr> "No Items", "No Items", "No Items", "No Items", "No …
    ## $ version           <chr> "Digital", "Digital", "Digital", "Digital", "Digital…
    ## $ attempt_id        <dbl> 1, 1, 1, 1, 2, 2, 2, 2
    ## $ attempt_started   <dttm> 2023-03-26 21:25:31, 2023-03-26 21:25:31, 2023-03-26…
    ## $ attempt_ended     <dttm> 2023-03-26 21:35:05, 2023-03-26 21:35:05, 2023-03-26…
    ## $ attempt_time      <dbl> 573.779, 573.779, 573.779, 573.779, 550.774, 550.77…
    ## $ segment_id        <int> 1, 2, 3, 4, 1, 2, 3, 4
    ## $ segment_time      <dbl> 153.480, 156.099, 144.452, 119.748, 141.554, 143.80…
    ## $ segment_name      <chr> "dNBC", "dRiR", "dSBS", "dBB", "dNBC", "dRiR", "dSBS…
    ## $ best_segment_time <dbl> 141.554, 143.809, 142.057, 119.748, 141.554, 143.809…

The `mk_lss()` function reads the file as xml data using `xml2`. It then
pulls the data with these functions:

- `mk_variables()`: Gets the category name, number of attempts, and
  metadata variables, if any exist.
- `mk_attempts()`: Gets the attempt id, when the run began and ended,
  and how long the run lasted (will be NA if run was not completed).
- `mk_segments()`: Gets the segment/track id for the run, track name,
  and your personal best time for that track.
- `mk_segment_times()`: Gets the split time for the track. All times are
  given in seconds.

If `mk_lss()` is not working for you, running the file though these
functions can help identify the problem.

### `tracks` dataset

The `tracks` dataset is a list of every track in MK8DX (as of wave 4).
It can be used as a reference or to standardize/correct track names for
use in tables or graphs. The dataset contains the track name, in both
full (`track`) and abbreviated (`trk`) forms. The original system tag
(`og_system`) is in a separate column to allow unique styling,
i.e. “(DS) Peach Gardens”, “Peach Gardens DS”.

``` r
tracks[13:20, ]
```

    ## # A tibble: 8 × 9
    ##   trkID trk   track       og_system cup_ID cup   trks16_ID trks16_name trks48_ID
    ##   <dbl> <chr> <chr>       <chr>      <int> <chr>     <int> <chr>           <dbl>
    ## 1    13 CC    Cloudtop C… <NA>           1 Spec…        13 Nitro Trac…        13
    ## 2    14 BDD   Bone-Dry D… <NA>           2 Spec…        14 Nitro Trac…        14
    ## 3    15 BC    Bowser's C… <NA>           3 Spec…        15 Nitro Trac…        15
    ## 4    16 RR    Rainbow Ro… <NA>           4 Spec…        16 Nitro Trac…        16
    ## 5    17 rMMM  Moo Moo Me… Wii            1 Shel…         1 Retro Trac…        17
    ## 6    18 rMC   Mario Circ… GBA            2 Shel…         2 Retro Trac…        18
    ## 7    19 rCCB  Cheep Chee… DS             3 Shel…         3 Retro Trac…        19
    ## 8    20 rTT   Toad's Tur… N64            4 Shel…         4 Retro Trac…        20

#### Join by track abbreviation

If you use standard track abbreviations[^1] as your `segment_name`, you
can join `segment_name` with `tracks$trk` to create new names.

``` r
bell_cup %>%
  left_join(tracks, by = c("segment_name" = "trk")) %>%
  mutate(new_segment_name = if_else(!is.na(og_system),
                                paste0(track, " [", og_system, "]"),
                                track)) %>%
  select(attempt_id, segment_name, new_segment_name, segment_time)
```

    ##   attempt_id segment_name      new_segment_name segment_time
    ## 1          1         dNBC Neo Bowser City [3DS]      153.480
    ## 2          1         dRiR     Ribbon Road [GBA]      156.099
    ## 3          1         dSBS     Super Bell Subway      144.452
    ## 4          1          dBB              Big Blue      119.748
    ## 5          2         dNBC Neo Bowser City [3DS]      141.554
    ## 6          2         dRiR     Ribbon Road [GBA]      143.809
    ## 7          2         dSBS     Super Bell Subway      142.057
    ## 8          2          dBB              Big Blue      123.354

#### Join by position

If your `segment_name` cannot easily be matched, you can also join by
the track’s position in the category. For instance, you can join by the
`tracks$cup` and its corresponding position (`tracks$cup_ID`).

``` r
bell_cup %>% 
  left_join(tracks, by = c("individual_cup" = "cup",
                           "segment_id" = "cup_ID")) %>% 
  mutate(new_segment_name = if_else(!is.na(og_system),
                                paste0(track, " [", og_system, "]"),
                                track)) %>%
  select(category, individual_cup, segment_id, segment_name, new_segment_name)
```

    ##     category individual_cup segment_id segment_name      new_segment_name
    ## 1 Bonus Cups       Bell Cup          1         dNBC Neo Bowser City [3DS]
    ## 2 Bonus Cups       Bell Cup          2         dRiR     Ribbon Road [GBA]
    ## 3 Bonus Cups       Bell Cup          3         dSBS     Super Bell Subway
    ## 4 Bonus Cups       Bell Cup          4          dBB              Big Blue
    ## 5 Bonus Cups       Bell Cup          1         dNBC Neo Bowser City [3DS]
    ## 6 Bonus Cups       Bell Cup          2         dRiR     Ribbon Road [GBA]
    ## 7 Bonus Cups       Bell Cup          3         dSBS     Super Bell Subway
    ## 8 Bonus Cups       Bell Cup          4          dBB              Big Blue

For other categories, you can use the 16-track name (`trks16_name`) and
position (`trks16_ID`); the 48-track position (`trks48_ID`); or the
unique ID of the track, `trkID`, which also functions as the eventual
96-track position.

## Further Usage

### Convert a folder of lss files to a table

To get data from all lss files in a folder, use the `purrr::map()`
function.

``` r
library(purrr)

# list all files in a folder path
f <- "inst/extdata/"
files <- paste0(f, list.files(f, pattern = ".lss"))

# get the lss data for each file and bind together
all_runs <- map(files, mk_lss) |> list_rbind()

glimpse(all_runs)
```

    ## Rows: 28
    ## Columns: 14
    ## $ category          <chr> "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cup…
    ## $ attempt_count     <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1…
    ## $ individual_cup    <chr> "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bel…
    ## $ cc                <chr> "150cc", "150cc", "150cc", "150cc", "150cc", "150cc"…
    ## $ items             <chr> "No Items", "No Items", "No Items", "No Items", "No …
    ## $ version           <chr> "Digital", "Digital", "Digital", "Digital", "Digital…
    ## $ attempt_id        <dbl> 1, 1, 1, 1, 2, 2, 2, 2, NA, NA, NA, NA, 1, 1, 1, 1, …
    ## $ attempt_started   <dttm> 2023-03-26 21:25:31, 2023-03-26 21:25:31, 2023-03-2…
    ## $ attempt_ended     <dttm> 2023-03-26 21:35:05, 2023-03-26 21:35:05, 2023-03-2…
    ## $ attempt_time      <dbl> 573.779, 573.779, 573.779, 573.779, 550.774, 550.774…
    ## $ segment_id        <int> 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 5, 6…
    ## $ segment_time      <dbl> 153.480, 156.099, 144.452, 119.748, 141.554, 143.809…
    ## $ segment_name      <chr> "dNBC", "dRiR", "dSBS", "dBB", "dNBC", "dRiR", "dSBS…
    ## $ best_segment_time <dbl> 141.554, 143.809, 142.057, 119.748, 141.554, 143.809…

## Credits

This package is based on [Chipdelmal’s MK8D
package](https://github.com/Chipdelmal/MK8D), which uses python to
convert lss files to a dataframe.

[^1]: Abbreviated names were copied from [the MK8DX Speedrunning
    discord](https://discord.com/channels/199214365860298752/199214365860298752/998310385545384138).
