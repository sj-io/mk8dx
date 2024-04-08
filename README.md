
# mk8dx

<!-- badges: start -->
<!-- badges: end -->

The mk8dx package converts lss files for MK8DX speedruns into usable
table data. It also has tools to help clean up the data.

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

## `mk_lss()`: Create a table from lss data

Provide a folder or file path to `mk_lss()` to create a table from lss
data.

``` r
library(dplyr)

bell_cup <- mk_lss("inst/extdata/bell-cup.lss")

head(bell_cup, 4)
```

    ## # A tibble: 4 × 16
    ##   category   total_attempts individual_cup cc    items    version attempt_id
    ##   <chr>               <dbl> <chr>          <chr> <chr>    <chr>        <dbl>
    ## 1 Bonus Cups              2 Bell Cup       150cc No Items Digital          1
    ## 2 Bonus Cups              2 Bell Cup       150cc No Items Digital          1
    ## 3 Bonus Cups              2 Bell Cup       150cc No Items Digital          1
    ## 4 Bonus Cups              2 Bell Cup       150cc No Items Digital          1
    ## # ℹ 9 more variables: attempt_started <dttm>, attempt_ended <dttm>,
    ## #   attempt_real_time <dbl>, attempt_game_time <dbl>, segment_id <dbl>,
    ## #   segment_real_time <dbl>, segment_game_time <dbl>, segment_name <chr>,
    ## #   best_segment_real_time <dbl>

The `mk_lss()` function reads the data using `xml2`. It gets the file’s
variables, attempts, and split data.

Note: All split/run times are given in seconds. If runs are not
completed, the attempt time will be NA.

You can also provide a folder path to create one table from all lss
files in the folder.

``` r
path <- "inst/extdata"

all_runs <- mk_lss(path)

all_runs[7:14, ]
```

    ## # A tibble: 8 × 16
    ##   category      total_attempts individual_cup cc    items    version  attempt_id
    ##   <chr>                  <dbl> <chr>          <chr> <chr>    <chr>         <dbl>
    ## 1 Bonus Cups                 2 Bell Cup       150cc No Items Digital           2
    ## 2 Bonus Cups                 2 Bell Cup       150cc No Items Digital           2
    ## 3 DLC Cups                   0 Boomerang Cup  150cc No Items Digital          NA
    ## 4 DLC Cups                   0 Boomerang Cup  150cc No Items Digital          NA
    ## 5 DLC Cups                   0 Boomerang Cup  150cc No Items Digital          NA
    ## 6 DLC Cups                   0 Boomerang Cup  150cc No Items Digital          NA
    ## 7 Lightning Cup              5 <NA>           150cc <NA>     Cartrid…          1
    ## 8 Lightning Cup              5 <NA>           150cc <NA>     Cartrid…          1
    ## # ℹ 9 more variables: attempt_started <dttm>, attempt_ended <dttm>,
    ## #   attempt_real_time <dbl>, attempt_game_time <dbl>, segment_id <dbl>,
    ## #   segment_real_time <dbl>, segment_game_time <dbl>, segment_name <chr>,
    ## #   best_segment_real_time <dbl>

## `tracks` dataset

The `tracks` dataset contains every track in MK8DX (96 tracks). It can
be used as a reference or to standardize/correct track names.

Included is:

- the track name, both long (`track`) and abbreviated (`trk`)
- the original console the track appeared (`console`)
- some `id` columns to help sort/match tracks

``` r
tracks[c(15:18, 79:82), ]
```

    ## # A tibble: 8 × 9
    ##   trk_ID trk   track        console cup_ID cup   trks16_ID trks16_name trks48_ID
    ##    <dbl> <chr> <chr>        <chr>    <int> <chr>     <int> <chr>           <dbl>
    ## 1     15 BC    Bowser's Ca… <NA>         3 Spec…        15 Nitro Trac…        15
    ## 2     16 RR    Rainbow Road <NA>         4 Spec…        16 Nitro Trac…        16
    ## 3     17 rMMM  Moo Moo Mea… Wii          1 Shel…         1 Retro Trac…        17
    ## 4     18 rMC   Mario Circu… GBA          2 Shel…         2 Retro Trac…        18
    ## 5     79 bWS   Waluigi Sta… GCN          3 Boom…        15 Wave 3 + 4…        31
    ## 6     80 bSSy  Singapore S… Tour         4 Boom…        16 Wave 3 + 4…        32
    ## 7     81 bAtD  Athens Dash  Tour         1 Feat…         1 Wave 5 + 6…        33
    ## 8     82 bDC   Daisy Cruis… GCN          2 Feat…         2 Wave 5 + 6…        34

## Credits

This package is based on [Chipdelmal’s MK8D
package](https://github.com/Chipdelmal/MK8D), which uses python to
convert lss files to a dataframe.
