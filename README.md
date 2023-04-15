
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mk8dx

<!-- badges: start -->
<!-- badges: end -->

The goal of mk8dx is to convert speedrun data for MK8DX into usable
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

`mk_lss` is a function that converts a folder of .lss files into a table
of your speedrun data.

``` r
mk_lss("../mario-kart/data")
```

    # A tibble: 24 × 11
       fileID category     cup      speed items    version runID attempts trackID trk   split_time        
        <int> <chr>        <chr>    <chr> <chr>    <chr>   <int>    <dbl>   <int> <chr> <chr>             
     1      1 Bonus Cups   Bell Cup 150cc No Items Digital     1        2       1 dNBC  00:02:33.480000000
     2      1 Bonus Cups   Bell Cup 150cc No Items Digital     1        2       2 dRiR  00:02:36.098999999
     3      1 Bonus Cups   Bell Cup 150cc No Items Digital     1        2       3 dSBS  00:02:24.452000000
     4      1 Bonus Cups   Bell Cup 150cc No Items Digital     1        2       4 dBB   00:01:59.748000001
     5      1 Bonus Cups   Bell Cup 150cc No Items Digital     2        2       1 dNBC  00:02:21.553999999
     6      1 Bonus Cups   Bell Cup 150cc No Items Digital     2        2       2 dRiR  00:02:23.809000000
     7      1 Bonus Cups   Bell Cup 150cc No Items Digital     2        2       3 dSBS  00:02:22.057000000
     8      1 Bonus Cups   Bell Cup 150cc No Items Digital     2        2       4 dBB   00:02:03.354000000
     9      2 Nitro Tracks NA       150cc No Items Digital     1        1       1 MKS   00:02:06.882000000
    10      2 Nitro Tracks NA       150cc No Items Digital     1        1       2 WP    00:02:12.391000000
    # ℹ 14 more rows
    # ℹ Use `print(n = ...)` to see more rows

The resulting data set will contain the following variables:

- `fileID`: The specific .lss file for the runs.
- `category`, `cup`, `speed`, `items`, `version`, and `patch` are your
  settings set for the splits data. They are based on the MK8DX
  variables on <https://one.livesplit.org/>. If you do not have one of
  these variables in your splits data, it will not appear in the
  dataset.
- `runID`: The run attempt in the lss file.
- `attempts`: Total number of run attempts. If you restarted a run in
  the first split, total attempts will be higher than the max run
  number.
- `trackID` and `trk`: The track/split in the run.
- `split_time`: The real time for the specific split. The dataset only
  contains split times for completed splits.

### Convert split time data

The `split_time` was intentionally left in character format because
sometimes saving in a different format can lead to errors.

To change to a time period format in R, I recommend the `lubridate`
package.

``` r
# install.package("lubridate")
library(lubridate)

mk <- mk_lss("../mario-kart/data")

# convert to hours minutes seconds
mk_hms <- mk %>% 
  mutate(split_time = hms(split_time))
head(mk_hms)
```

    # A tibble: 6 × 11
      fileID category   cup      speed items    version runID attempts trackID trk   split_time      
       <int> <chr>      <chr>    <chr> <chr>    <chr>   <int>    <dbl>   <int> <chr> <Period>        
    1      1 Bonus Cups Bell Cup 150cc No Items Digital     1        2       1 dNBC  2M 33.48S       
    2      1 Bonus Cups Bell Cup 150cc No Items Digital     1        2       2 dRiR  2M 36.098999999S
    3      1 Bonus Cups Bell Cup 150cc No Items Digital     1        2       3 dSBS  2M 24.452S      
    4      1 Bonus Cups Bell Cup 150cc No Items Digital     1        2       4 dBB   1M 59.748000001S
    5      1 Bonus Cups Bell Cup 150cc No Items Digital     2        2       1 dNBC  2M 21.553999999S
    6      1 Bonus Cups Bell Cup 150cc No Items Digital     2        2       2 dRiR  2M 23.809S    

This table shows split times in period format.

However, you’ll want to convert to seconds to calculate with the data.

``` r
# convert to seconds (required for mathing times)
mk_sec <- mk %>% 
  mutate(split_time = period_to_seconds(hms(split_time)))
glimpse(mk_sec)
```

    Rows: 24
    Columns: 11
    $ fileID     <int> 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    $ category   <chr> "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus Cups", "Bonus …
    $ cup        <chr> "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bell Cup", "Bell C…
    $ speed      <chr> "150cc", "150cc", "150cc", "150cc", "150cc", "150cc", "150cc", "150cc", "150cc", "150cc", "…
    $ items      <chr> "No Items", "No Items", "No Items", "No Items", "No Items", "No Items", "No Items", "No Ite…
    $ version    <chr> "Digital", "Digital", "Digital", "Digital", "Digital", "Digital", "Digital", "Digital", "Di…
    $ runID      <int> 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    $ attempts   <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    $ trackID    <int> 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
    $ trk        <chr> "dNBC", "dRiR", "dSBS", "dBB", "dNBC", "dRiR", "dSBS", "dBB", "MKS", "WP", "SSC", "TR", "MC…
    $ split_time <dbl> 153.480, 156.099, 144.452, 119.748, 141.554, 143.809, 142.057, 123.354, 126.882, 132.391, 1…

This table changes the split time column to a numeric format.
