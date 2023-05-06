
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

After installing the package, load it to use it.

``` r
library(mk8dx)
```

## Convert lss data to a table format

`mk_lss` is a function that converts .lss file data into a table.

``` r
library(dplyr)

file <- "inst/extdata/bell-cup.lss"

bell_cup <- mk_lss(file)

glimpse(bell_cup)
```

    ## Rows: 8
    ## Columns: 14
    ## $ category          <chr> "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cup…
    ## $ attempt_count     <chr> "2", "2", "2", "2", "2", "2", "2", "2"
    ## $ individual_cup    <chr> "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bel…
    ## $ cc                <chr> "150cc", "150cc", "150cc", "150cc", "150cc", "150cc"…
    ## $ items             <chr> "No Items", "No Items", "No Items", "No Items", "No …
    ## $ version           <chr> "Digital", "Digital", "Digital", "Digital", "Digital…
    ## $ attempt_id        <chr> "1", "1", "1", "1", "2", "2", "2", "2"
    ## $ attempt_started   <chr> "03/26/2023 21:25:31", "03/26/2023 21:25:31", "03/26…
    ## $ attempt_ended     <chr> "03/26/2023 21:35:05", "03/26/2023 21:35:05", "03/26…
    ## $ attempt_time      <chr> "00:09:33.779000000", "00:09:33.779000000", "00:09:3…
    ## $ segment_id        <int> 1, 2, 3, 4, 1, 2, 3, 4
    ## $ segment_time      <chr> "00:02:33.480000000", "00:02:36.098999999", "00:02:2…
    ## $ segment_name      <chr> "dNBC", "dRiR", "dSBS", "dBB", "dNBC", "dRiR", "dSBS…
    ## $ best_segment_time <chr> "00:02:21.553999999", "00:02:23.809000000", "00:02:2…

The `mk_lss()` function reads the file as xml data using `xml2`. It then
pulls the data with these functions:

- `mk_variables()`: Gets the category name, number of attempts, and
  metadata variables, if any exist.
- `mk_attempts()`: Gets the attempt id, when the run began and ended,
  and how long the run lasted (will be NA if run was not completed).
- `mk_segments()`: Gets the segment/track id for the run, track name,
  and your personal best time for that track.
- `mk_segment_times()`: Gets the split time for the track.

### Map a folder of lss files

To get data from all lss files in a folder, use the `purrr::map()`
function.

``` r
library(purrr)

f <- "inst/extdata/"     # folder path
files <- paste0(f, list.files(f, pattern = ".lss"))

all_runs <- map(files, mk_lss) |> list_rbind()

glimpse(all_runs)
```

    ## Rows: 24
    ## Columns: 14
    ## $ category          <chr> "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cup…
    ## $ attempt_count     <chr> "2", "2", "2", "2", "2", "2", "2", "2", "1", "1", "1…
    ## $ individual_cup    <chr> "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bel…
    ## $ cc                <chr> "150cc", "150cc", "150cc", "150cc", "150cc", "150cc"…
    ## $ items             <chr> "No Items", "No Items", "No Items", "No Items", "No …
    ## $ version           <chr> "Digital", "Digital", "Digital", "Digital", "Digital…
    ## $ attempt_id        <chr> "1", "1", "1", "1", "2", "2", "2", "2", "1", "1", "1…
    ## $ attempt_started   <chr> "03/26/2023 21:25:31", "03/26/2023 21:25:31", "03/26…
    ## $ attempt_ended     <chr> "03/26/2023 21:35:05", "03/26/2023 21:35:05", "03/26…
    ## $ attempt_time      <chr> "00:09:33.779000000", "00:09:33.779000000", "00:09:3…
    ## $ segment_id        <int> 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1…
    ## $ segment_time      <chr> "00:02:33.480000000", "00:02:36.098999999", "00:02:2…
    ## $ segment_name      <chr> "dNBC", "dRiR", "dSBS", "dBB", "dNBC", "dRiR", "dSBS…
    ## $ best_segment_time <chr> "00:02:21.553999999", "00:02:23.809000000", "00:02:2…

### Convert split time data

Date-times and run/split times are currently saved as character data. To
convert these, use the `lubridate` package.

``` r
library(lubridate)

# format dates; convert times to seconds
all_runs_with_periods <- all_runs %>% 
  mutate(
    across(c(attempt_started, attempt_ended), ~ mdy_hms(.x)),
    across(ends_with("_time"), ~ period_to_seconds(hms(.x))),
    .keep = "used"
    ) %>% rename(PB_time = best_segment_time)
# last two lines make table legible in readme

head(all_runs_with_periods)
```

    ##       attempt_started       attempt_ended attempt_time segment_time PB_time
    ## 1 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779      153.480 141.554
    ## 2 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779      156.099 143.809
    ## 3 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779      144.452 142.057
    ## 4 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779      119.748 119.748
    ## 5 2023-03-26 21:35:48 2023-03-26 21:44:59      550.774      141.554 141.554
    ## 6 2023-03-26 21:35:48 2023-03-26 21:44:59      550.774      143.809 143.809

## Credit

This package is based on [Chipdelmal’s MK8D
package](https://github.com/Chipdelmal/MK8D), which uses python to
convert lss files to a dataframe.
