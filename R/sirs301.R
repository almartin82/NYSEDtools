#' @title Create a sirs301 object
#' @import ggplot2 magrittr
#'
#' @description
#' \code{sirs301} creates a sirs301 object, enabling analysis and reporting.
#'
#' @param csvs data frame of sirs 301 exports from New York's L2RPT - eg output of
#' sirs301_import_csvs
#' @param cohort_kind should we name cohorts by their college entry
#' or college graduation year?
#' @param roster data frame, with additional student demographic information.
#' if NA (default), this is ignored.
#' @param verbose should sirs301 print status updates?  default is FALSE.
#' @param ... additional arguments to pass to constructor functions
#'
#' @export

sirs301 <- function(
  csvs,
  cohort_kind,
  roster,
  verbose,
  ...
) UseMethod("sirs301")

#' @export
sirs301.default <- function(
  csvs,
  cohort_kind = 'college_entry',
  roster = NULL,
  verbose = FALSE,
  ...) {

  #clean up df names
  df <- janitor::clean_names(csvs)

  #clean up data
  if (verbose) cat('cleaning up raw csvs')
  df <- df %>%
    dplyr::mutate(
      curr_grade_lvl = ifelse(curr_grade_lvl == 'KF', 0, curr_grade_lvl),
      curr_grade_lvl = as.integer(curr_grade_lvl)
    )

  #get academic year
  df <- df %>%
    tidyr::separate(
      col = report_school_year,
      into = c('start_year', 'test_year'),
      sep = '-',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::mutate(
      test_year = 2000 + test_year
    )

  #get cohort
  df <- df %>%
    dplyr::mutate(
      cohort_numeric = calculate_cohort(curr_grade_lvl, start_year, cohort_kind)
    )

  #grab NYSESLAT
  nyseslat <- df %>%
    dplyr::filter(
      grepl('NYSESLAT', assessment_description, fixed = TRUE)
    ) %>%
    #break out assessment_description
    tidyr::separate(
      col = assessment_description,
      into = c('test_subject', 'test_grade', 'discard1', 'discard2'),
      sep = ' ',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::select(
      -discard1, -discard2
    ) %>%
    dplyr::mutate(
      test_subject = gsub(':', '', test_subject, fixed = TRUE),
      perf_level_numeric = NA
    )

  ela_math_sci <- df %>%
    dplyr::filter(grepl('ELA|Math|Sci', assessment_description)) %>%
    tidyr::separate(
      col = standard_achieved,
      into = c('discard', 'performance_level_numeric'),
      sep = ' ',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::select(
      -discard
    ) %>%
    dplyr::rename(
      scale_score = numeric_score,
      performance_level = standard_achieved
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      scale_score = ifelse(scale_score == '', NA, as.numeric(scale_score)),
      performance_level_numeric = ifelse(
        performance_level_numeric == 'tested', NA, as.numeric(performance_level_numeric)),
      is_l1 = performance_level_numeric == 1,
      is_l2 = performance_level_numeric == 2,
      is_l3 = performance_level_numeric == 3,
      is_l4 = performance_level_numeric == 4,
      is_l2_or_higher = performance_level_numeric >= 2,
      is_proficient = performance_level_numeric >= 3
    ) %>%
    dplyr::ungroup()

  #grab science
  sci <- ela_math_sci %>%
    dplyr::filter(grepl('Sci', assessment_description, fixed = TRUE)) %>%
    #break out assessment_description
    tidyr::separate(
      col = assessment_description,
      into = c('discard1', 'test_grade', 'test_subject', 'discard2'),
      sep = ' ',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::select(
      -discard1, -discard2
    ) %>%
    dplyr::mutate(
      test_subject = gsub(':', '', test_subject, fixed = TRUE)
    )

  #grab ela / math
  ela_math <- ela_math_sci %>%
    dplyr::filter(grepl('ELA|Math', assessment_description)) %>%
    #break out assessment_description
    tidyr::separate(
      col = assessment_description,
      into = c('discard', 'test_grade', 'test_subject'),
      sep = ' ',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::select(
      -discard
    )

  #give the data objects classes
  class(ela_math) <- c("sirs301_ela_math", class(ela_math))
  class(sci) <- c("sirs301_sci", class(sci))
  class(nyseslat) <- c("sirs301_nyseslat", class(nyseslat))

  ##GROWTH
  growth <- sirs301_ela_math_growth(ela_math)

  out <- list(
    'ela_math' = ela_math,
    'sci' = sci,
    'nyseslat' = nyseslat,
    'growth' = growth
  )

  if (!is.null(roster)) {
    out[['roster']] <- roster
  }

  #make the object class 'sirs301'
  class(out) <- c("sirs301", class(out))

  out
}



#' @title print method for \code{sirs301} class
#'
#' @description prints to console
#'
#' @details Prints a summary of the a \code{sirs301} object.
#'
#' @param x a \code{sirs301} object
#' @param ... additional arguments
#'
#' @return some details about the object to the console.
#' @rdname print
#' @export

print.sirs301 <- function(x, ...) {

  #gather some summary stats
  n_df <- length(x)
  n_sy <- length(unique(x$ela_math$report_school_year))
  n_students <- length(unique(x$ela_math$student_id))
  n_schools <- length(unique(x$ela_math$location_name))

  cat("A sirs301 object repesenting:\n- ")
  cat(paste(n_sy))
  cat(" school years")
  cat("\n- ")
  cat(paste(n_students))
  cat(" students from ")
  cat(paste(n_schools))
  cat(" schools\n\n")

  #about the object
  cat("The sirs301 object has ")
  cat(n_df)
  cat(" dataframes, named:\n")
  cat(paste(names(x), collapse = ', '))
}
