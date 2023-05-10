
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

    ##     category attempt_count individual_cup    cc    items version attempt_id
    ## 1 Bonus Cups             2       Bell Cup 150cc No Items Digital          1
    ## 2 Bonus Cups             2       Bell Cup 150cc No Items Digital          1
    ## 3 Bonus Cups             2       Bell Cup 150cc No Items Digital          1
    ## 4 Bonus Cups             2       Bell Cup 150cc No Items Digital          1
    ##       attempt_started       attempt_ended attempt_time segment_id segment_time
    ## 1 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779          1      153.480
    ## 2 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779          2      156.099
    ## 3 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779          3      144.452
    ## 4 2023-03-26 21:25:31 2023-03-26 21:35:05      573.779          4      119.748
    ##   segment_name best_segment_time
    ## 1         dNBC           141.554
    ## 2         dRiR           143.809
    ## 3         dSBS           142.057
    ## 4          dBB           119.748

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

    ##         category attempt_count individual_cup    cc    items   version
    ## 7     Bonus Cups             2       Bell Cup 150cc No Items   Digital
    ## 8     Bonus Cups             2       Bell Cup 150cc No Items   Digital
    ## 9       DLC Cups             0  Boomerang Cup 150cc No Items   Digital
    ## 10      DLC Cups             0  Boomerang Cup 150cc No Items   Digital
    ## 11      DLC Cups             0  Boomerang Cup 150cc No Items   Digital
    ## 12      DLC Cups             0  Boomerang Cup 150cc No Items   Digital
    ## 13 Lightning Cup             5           <NA> 150cc     <NA> Cartridge
    ## 14 Lightning Cup             5           <NA> 150cc     <NA> Cartridge
    ##    attempt_id     attempt_started       attempt_ended attempt_time segment_id
    ## 7           2 2023-03-26 21:35:48 2023-03-26 21:44:59     550.7740          3
    ## 8           2 2023-03-26 21:35:48 2023-03-26 21:44:59     550.7740          4
    ## 9          NA                <NA>                <NA>           NA          1
    ## 10         NA                <NA>                <NA>           NA          2
    ## 11         NA                <NA>                <NA>           NA          3
    ## 12         NA                <NA>                <NA>           NA          4
    ## 13          1 2022-05-28 04:37:50 2022-05-28 04:47:21     571.7477          1
    ## 14          1 2022-05-28 04:37:50 2022-05-28 04:47:21     571.7477          2
    ##    segment_time segment_name best_segment_time
    ## 7      142.0570         dSBS          142.0570
    ## 8      123.3540          dBB          119.7480
    ## 9            NA          bBR                NA
    ## 10           NA          bMC                NA
    ## 11           NA          bWS                NA
    ## 12           NA         bSSY                NA
    ## 13     143.7547         rTTC          138.8561
    ## 14     161.6055         rPPS          158.0864

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

### Join by track abbreviation

If you use standard track abbreviations[^1] as your `segment_name`, you
can join `segment_name` with `tracks$trk` to create new names.

``` r
bell_cup %>%
  left_join(tracks, by = c("segment_name" = "trk")) %>%
  mutate(new_segment_name = if_else(!is.na(console),
                                paste0(track, " [", console, "]"),
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

### Join by position

If your `segment_name` cannot easily be matched, you can also join by
the track’s position in the category. For instance, you can join by the
`tracks$cup` and its corresponding position (`tracks$cup_ID`).

``` r
bell_cup %>% 
  left_join(tracks, by = c("individual_cup" = "cup",
                           "segment_id" = "cup_ID")) %>% 
  mutate(new_segment_name = if_else(!is.na(console),
                                paste0(track, " [", console, "]"),
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

## Credits

This package is based on [Chipdelmal’s MK8D
package](https://github.com/Chipdelmal/MK8D), which uses python to
convert lss files to a dataframe.

[^1]: Abbreviated names were copied from [the MK8DX Speedrunning
    discord](https://discord.com/channels/199214365860298752/199214365860298752/998310385545384138).
