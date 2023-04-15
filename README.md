
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
       fileID runID trackID category     cup      speed items    version trk   attempts split_time        
        <int> <int>   <int> <chr>        <chr>    <chr> <chr>    <chr>   <chr> <chr>    <chr>             
     1      1     1       1 Bonus Cups   Bell Cup 150cc No Items Digital dNBC  2        00:02:33.480000000
     2      1     1       2 Bonus Cups   Bell Cup 150cc No Items Digital dRiR  2        00:02:36.098999999
     3      1     1       3 Bonus Cups   Bell Cup 150cc No Items Digital dSBS  2        00:02:24.452000000
     4      1     1       4 Bonus Cups   Bell Cup 150cc No Items Digital dBB   2        00:01:59.748000001
     5      1     2       1 Bonus Cups   Bell Cup 150cc No Items Digital dNBC  2        00:02:21.553999999
     6      1     2       2 Bonus Cups   Bell Cup 150cc No Items Digital dRiR  2        00:02:23.809000000
     7      1     2       3 Bonus Cups   Bell Cup 150cc No Items Digital dSBS  2        00:02:22.057000000
     8      1     2       4 Bonus Cups   Bell Cup 150cc No Items Digital dBB   2        00:02:03.354000000
     9      2     1       1 Nitro Tracks NA       150cc No Items Digital MKS   1        00:02:06.882000000
    10      2     1       2 Nitro Tracks NA       150cc No Items Digital WP    1        00:02:12.391000000
    # ℹ 14 more rows
    # ℹ Use `print(n = ...)` to see more rows

The resulting data set will contain the following variables:

- `fileID`: The specific .lss file for the runs.
- `runID`: The run number in the lss file.
- `trackID` and `trk`: The track/split in the run.
- `category`, `cup`, `speed`, `items`, `version`, and `patch` are your
  settings set for the splits data. They are based on the MK8DX
  variables on <https://one.livesplit.org/>. If you do not have one of
  these variables in your splits data, it will not appear in the
  dataset.
- `attempts`: Total number of run attempts. If you restarted a run in
  the first split, total attempts will be higher than the max run
  number.
- `split_time`: The real time for the specific split. The dataset only
  contains split times for completed splits.

### Convert split time data

The split_time was intentionally left in character format because
sometimes saving in a different format can lead to errors.

To change to a period format in R, I recommend the `lubridate` package.

``` r
# install.package("lubridate")
library(lubridate)

mk_data <- mk_lss("../mario-kart/data") %>% 
  mutate(split_time = hms(split_time))
```

    # A tibble: 24 × 11
       fileID runID trackID category     cup      speed items    version trk   attempts split_time      
        <int> <int>   <int> <chr>        <chr>    <chr> <chr>    <chr>   <chr> <chr>    <Period>        
     1      1     1       1 Bonus Cups   Bell Cup 150cc No Items Digital dNBC  2        2M 33.48S       
     2      1     1       2 Bonus Cups   Bell Cup 150cc No Items Digital dRiR  2        2M 36.098999999S
     3      1     1       3 Bonus Cups   Bell Cup 150cc No Items Digital dSBS  2        2M 24.452S      
     4      1     1       4 Bonus Cups   Bell Cup 150cc No Items Digital dBB   2        1M 59.748000001S
     5      1     2       1 Bonus Cups   Bell Cup 150cc No Items Digital dNBC  2        2M 21.553999999S
     6      1     2       2 Bonus Cups   Bell Cup 150cc No Items Digital dRiR  2        2M 23.809S      
     7      1     2       3 Bonus Cups   Bell Cup 150cc No Items Digital dSBS  2        2M 22.057S      
     8      1     2       4 Bonus Cups   Bell Cup 150cc No Items Digital dBB   2        2M 3.354S       
     9      2     1       1 Nitro Tracks NA       150cc No Items Digital MKS   1        2M 6.882S       
    10      2     1       2 Nitro Tracks NA       150cc No Items Digital WP    1        2M 12.391S      
    # ℹ 14 more rows
    # ℹ Use `print(n = ...)` to see more rows

The resulting table shows split times in period format.
