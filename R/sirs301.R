#' @title Create a sirs301 object
#'
#' @description
#' \code{sirs301} creates a sirs301 object, enabling analysis and reporting.
#'
#' @param csvs data frame of sirs 301 exports - eg output of
#' sirs301_import_csvs
#' @param verbose should sirs301 print status updates?  default is FALSE.
#' @param ... additional arguments to pass to constructor functions
#' @export

sirs301 <- function(
  csvs, cohort_kind = 'college_entry', verbose = FALSE, ...
) UseMethod("sirs301")

#' @export
sirs301.default <- function(csvs, cohort_kind, verbose = FALSE, ...) {

  #clean up df names
  df <- janitor::clean_names(csvs)

  #clean up types
  df <- df %>%
    dplyr::mutate(
      curr_grade_lvl = ifelse(curr_grade_lvl == 'KF', 0, curr_grade_lvl),
      curr_grade_lvl = as.integer(curr_grade_lvl)
    )

  #get academic year
  df <- df %>%
    tidyr::separate(
      col = report_school_year,
      into = c('start_year', 'end_year'),
      sep = '-',
      remove = FALSE,
      convert = TRUE
    ) %>%
    dplyr::mutate(
      end_year = 2000 + end_year
    )

  #get cohort
  df <- df %>%
    dplyr::mutate(
      cohort_numeric = calculate_cohort(curr_grade_lvl, start_year, cohort_kind)
    )

  #grab NYSESLAT
  nyseslat <- df %>%
    dplyr::filter(
      grepl('NYSESLAT', df$assessment_description, fixed = TRUE)
    )

  #grab science
  sci <- df %>%
    dplyr::filter(
      grepl('Sci: Scale', df$assessment_description, fixed = TRUE)
    )

  #grab ela / math
  ela_math <- df %>%
    dplyr::filter(
      grepl(' ELA', df$assessment_description, fixed = TRUE) |
      grepl(' Math', df$assessment_description, fixed = TRUE)
    )

  out <- list(
    'ela_math' = ela_math,
    'sci' = sci,
    'nyseslat' = nyseslat
  )

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
  cat(" schools")
}
