# NYSEDtools
Tools for working with educational data from New York State's Level 2 Reporting System (L2RPT)

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

## Why NYSEDtools?
All New York State school districts receive data from the state in a common data format.  `NYSEDtools` attempts to make a data analyst's life easier by providing an expressive vocabulary of data cleaning functions, analysis, calculations, and visualizations that show the progress of schools, grade levels, and students.

## Quickstart!

### Getting the data from L2RPT
NYS test data is released through the <a href="https://reports.nycenet.edu/statel2rptreports/">'State Level 2 Reports' (L2RPT)</a> system, which is an IBM Cognos platform.  You can <a href="http://www.p12.nysed.gov/irs/level2reports/home.html">read more</a> about L2RPT on the NYSED website.
`NYSEDtools` uses the 'SIRS-301 Tested/Not Tested Confirmation Report', which can be found at `L2RPT - SEDDAS` > `Tested / Not Tested,
` > `SIRS-301 Tested/Not Tested Confirmation Report`.
Choose the most general options possible (you will need to run ELA, Math and Science exports separately).
Click on the `All Students` row and `Tested` column to get a table of individual student records, then `View in Excel Options` > `View in Excel 2007 Format`.  This package consumes those export files - save them to your computer.  You will likely need to generate several export files to cover all the years of data housed in L2RPT.

### Loading data exports from L2RPT
This quickstart uses the dummy data in `inst/raw-data`.  **All data in those files is procedurally generated**, not merely anonymized, meaning that while it simulates the look and feel of a L2RPT file, it is not derived from personally identifiable student data in any way.

```{r}

raw_301 <- NYSEDtools::sirs301_import_csvs(path = file.path('inst', 'raw-data'))

head(raw_301)

```

produces:

```
# A tibble: 6 x 26
  DISTRICT_NAME DISTRICT_KEY LOCATION_NAME LOCATION_KEY_RSP_SCH     STUDENT_NAME
          <chr>        <chr>         <chr>                <chr>            <chr>
1 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 1
2 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 2
3 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 3
4 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 4
5 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 5
6 DEMO DISTRICT     80099999   DEMO SCHOOL                 9999 Sample Student 6
# ... with 21 more variables: STUDENT_ID <chr>, STUDENT_ID_ALT <chr>,
#   STUDENT_GENDER <chr>, CURR_GRADE_LVL <chr>, ITEM_KEY <chr>, `Assessment
#   Description` <chr>, CHALLENGE_TYPE <chr>, ETHNIC_DESC <chr>, LEP_DURATION <chr>,
#   LEP_ELIGIBILITY <chr>, POVERTY <chr>, NUMERIC_SCORE <chr>, STANDARD_ACHIEVED <chr>,
#   STD_ACHIEVED_CODE <chr>, TEST_STATUS <chr>, NYSESLAT_ELIGIBLE <chr>,
#   NYSAA_ELIGIBLE <chr>, FORMER_LEP <chr>, FORMER_SWD <chr>, REPORT_SCHOOL_YEAR <chr>,
#   MODIFIED_DATE <chr>
```

`sirs301_import_csvs` will look recursively through any sub-directory that you give it, so it's fine to organize the raw data exports by year, school, subject - whatever.

### Creating the sirs301 object

This package processes the raw sirs 301 data and creates a custom data object, class `sirs301`.  That custom object has cleaned up data frames (ie, numeric performance levels) and calculated fields, like growth.  Having this cleaned-up object powers the analysis and visualization functions included in the package.

```{r}

demo_301 <- NYSEDtools::sirs301(csvs = raw_301)

```
Produces:

```
> demo_301 <- sirs301(csvs = raw_301)
> demo_301
A sirs301 object repesenting:
- 1 school years
- 372 students from 1 schools

The sirs301 object has 4 dataframes, named:
ela_math, sci, nyseslat, growth
```

### The payoff - easy visualizations, analysis, and insight!

Now that you have a `sirs301` object you can hand it off to the visualization and analysis functions in this package. 

The general recipe for a visualization or analysis function is:

1. a `sirs301` object
2. a vector of studentids

Most of the time school data analysts are interested in grade levels of students.  That's easy to do in this framework - simply create a vector of studentids that, for instance, corresponds to '6th grade students at Demo School' and pass that to the visualization or analysis function.

First let's save the studentids of the 6th graders to a vector:
```{r}
gr6 <- demo_301$ela_math %>% 
  dplyr::filter(location_name == 'DEMO SCHOOL' & test_grade == 6 & test_year == 2016) %>%
  dplyr::select(student_id) %>%
  unlist() %>% unname() %>% unique()

gr6
```

Now we'll generate `cohort_performance_bins` for these students by passing that vector to `studentids`:

```{r}
gr6_math_bins <- cohort_performance_bins(
  sirs301_obj = demo_301,
  studentids = gr6,
  subject = 'Math'
)

gr6_math_bins
```

<img src="https://raw.githubusercontent.com/almartin82/NYSEDtools/master/inst/images/gr6_math_bins.png" /> 

## Contributing to NYSEDtools
Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
