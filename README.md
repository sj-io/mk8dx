
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

## `mk_lss`

### Convert lss data to a table format

Enter a filepath into `mk_lss()` to convert .lss data into a table.

``` r
library(dplyr)

filepath <- "inst/extdata/bell-cup.lss"

bell_cup <- mk_lss(filepath)

head(bell_cup, 4)
```

    ## # A tibble: 4 × 14
    ##   category   attempt_count individual_cup cc    items    version attempt_id
    ##   <chr>              <dbl> <chr>          <chr> <chr>    <chr>        <dbl>
    ## 1 Bonus Cups             2 Bell Cup       150cc No Items Digital          1
    ## 2 Bonus Cups             2 Bell Cup       150cc No Items Digital          1
    ## 3 Bonus Cups             2 Bell Cup       150cc No Items Digital          1
    ## 4 Bonus Cups             2 Bell Cup       150cc No Items Digital          1
    ## # ℹ 7 more variables: attempt_started <dttm>, attempt_ended <dttm>,
    ## #   attempt_time <dbl>, segment_id <int>, segment_time <dbl>,
    ## #   segment_name <chr>, best_segment_time <dbl>

The `mk_lss()` function reads the file as xml data using `xml2`. It then
gets your file’s metadata variables, attempts, and split data.

Note: All split/run times are given in seconds. If runs are not
completed, the attempt time will be NA. If you reset on the first track,
there will be more NA variables.

To convert a folder of lss files into one table, use `mk_lss_folder()`.

``` r
folderpath <- "inst/extdata"

all_runs <- mk_lss_folder(folderpath)

all_runs[7:14, ]
```

    ## # A tibble: 8 × 14
    ##   category      attempt_count individual_cup cc    items    version   attempt_id
    ##   <chr>                 <dbl> <chr>          <chr> <chr>    <chr>          <dbl>
    ## 1 Bonus Cups                2 Bell Cup       150cc No Items Digital            2
    ## 2 Bonus Cups                2 Bell Cup       150cc No Items Digital            2
    ## 3 DLC Cups                  0 Boomerang Cup  150cc No Items Digital           NA
    ## 4 DLC Cups                  0 Boomerang Cup  150cc No Items Digital           NA
    ## 5 DLC Cups                  0 Boomerang Cup  150cc No Items Digital           NA
    ## 6 DLC Cups                  0 Boomerang Cup  150cc No Items Digital           NA
    ## 7 Lightning Cup             5 <NA>           150cc <NA>     Cartridge          1
    ## 8 Lightning Cup             5 <NA>           150cc <NA>     Cartridge          1
    ## # ℹ 7 more variables: attempt_started <dttm>, attempt_ended <dttm>,
    ## #   attempt_time <dbl>, segment_id <int>, segment_time <dbl>,
    ## #   segment_name <chr>, best_segment_time <dbl>

## `mk_repair`

### Repair incorrectly entered data

This is an experimental function to repair some columns that might have
issues if your splits were entered incorrectly, or if you have old,
outdated duplicate files in the same folder as more recent data.

``` r
repaired_runs <- mk_repair(all_runs)

repaired_runs[29:32, ]
```

    ## # A tibble: 4 × 14
    ##   category   attempt_count individual_cup cc    items version   attempt_id
    ##   <chr>              <dbl> <chr>          <chr> <chr> <chr>          <dbl>
    ## 1 Retro Cups             5 Lightning Cup  150cc <NA>  Cartridge          1
    ## 2 Retro Cups             5 Lightning Cup  150cc <NA>  Cartridge          1
    ## 3 Retro Cups             5 Lightning Cup  150cc <NA>  Cartridge          1
    ## 4 Retro Cups             5 Lightning Cup  150cc <NA>  Cartridge          1
    ## # ℹ 7 more variables: attempt_started <dttm>, attempt_ended <dttm>,
    ## #   attempt_time <dbl>, segment_id <int>, segment_time <dbl>,
    ## #   segment_name <chr>, best_segment_time <dbl>

Current features:

- Move/correct `individual_cup` names entered into the `category` field
- Trim whitespace of characters
- Round all attempt/split times to the hundredths place.
- Fill in missing metadata variables (only for matching category/cup)
- Update outdated split data for matching run categories/variables.

## `mk_track_names`

### Rename track names to a uniform format

Joins with the `tracks` dataset by `category`, `individual_cup`, and
`segment_id`.

``` r
mk_track_names(repaired_runs, style = "full") %>% 
  select(category, individual_cup, segment_id, contains("segment_name")) %>% 
  distinct()
```

    ## # A tibble: 29 × 5
    ##    category     individual_cup segment_id og_segment_name segment_name          
    ##    <chr>        <chr>               <dbl> <chr>           <chr>                 
    ##  1 Bonus Cups   Bell Cup                1 dNBC            Neo Bowser City [3DS] 
    ##  2 Bonus Cups   Bell Cup                2 dRiR            Ribbon Road [GBA]     
    ##  3 Bonus Cups   Bell Cup                3 dSBS            Super Bell Subway     
    ##  4 Bonus Cups   Bell Cup                4 dBB             Big Blue              
    ##  5 DLC Cups     Boomerang Cup           1 bBR             Bangkok Rush [Tour]   
    ##  6 DLC Cups     Boomerang Cup           2 bMC             Mario Circuit [DS]    
    ##  7 DLC Cups     Boomerang Cup           3 bWS             Waluigi Stadium [GCN] 
    ##  8 DLC Cups     Boomerang Cup           4 bSSY            Singapore Speedway [T…
    ##  9 Nitro Tracks <NA>                    1 MKS             Mario Kart Stadium    
    ## 10 Nitro Tracks <NA>                    2 WP              Water Park            
    ## # ℹ 19 more rows

## `tracks` dataset

The `tracks` dataset is a list of every track in MK8DX (as of wave 4).
It can be used as a reference or to standardize/correct track names for
use in tables or graphs. The dataset contains the track name, in both
full (`track`) and abbreviated (`trk`) forms. The original console tag
(`console`) is in a separate column to allow unique styling, i.e. “(DS)
Peach Gardens”, “Peach Gardens DS”.

``` r
tracks[13:20, ]
```

    ## # A tibble: 8 × 9
    ##   trk_ID trk   track        console cup_ID cup   trks16_ID trks16_name trks48_ID
    ##    <dbl> <chr> <chr>        <chr>    <int> <chr>     <int> <chr>           <dbl>
    ## 1     13 CC    Cloudtop Cr… <NA>         1 Spec…        13 Nitro Trac…        13
    ## 2     14 BDD   Bone-Dry Du… <NA>         2 Spec…        14 Nitro Trac…        14
    ## 3     15 BC    Bowser's Ca… <NA>         3 Spec…        15 Nitro Trac…        15
    ## 4     16 RR    Rainbow Road <NA>         4 Spec…        16 Nitro Trac…        16
    ## 5     17 rMMM  Moo Moo Mea… Wii          1 Shel…         1 Retro Trac…        17
    ## 6     18 rMC   Mario Circu… GBA          2 Shel…         2 Retro Trac…        18
    ## 7     19 rCCB  Cheep Cheep… DS           3 Shel…         3 Retro Trac…        19
    ## 8     20 rTT   Toad's Turn… N64          4 Shel…         4 Retro Trac…        20

## Credits

This package is based on [Chipdelmal’s MK8D
package](https://github.com/Chipdelmal/MK8D), which uses python to
convert lss files to a dataframe.
