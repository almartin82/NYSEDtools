#' Generate student-level growth scores from the SIRS301 tested report
#'
#' @param sirs301_ela_math dataframe of ela and math scores.  eg $ela_math slot on sirs301 object.
#' @param headline logical, return the headline stats.  If FALSE, will return less frequently used
#' columns like start_lep_duration and end_lep_duration.  default is TRUE
#'
#' @return dataframe, class sirs301_ela_math_growth
#' @export

sirs301_ela_math_growth <- function(
  sirs301_ela_math, headline = TRUE
) {

  #first make the empty student scaffold
  scaffold <- sirs301_empty_scaffold(sirs301_ela_math)

  #now build out the scaffold with data
  complete_scaffold <- sirs301_fill_scaffold(sirs301_ela_math, scaffold, headline)

  #growth stats
  final <- sirs301_growth_calcs(complete_scaffold)

  class(final) <- c("sirs301_ela_math_growth", class(final))

  final
}


#' Crate empty scaffold for
#'
#' @description helper function for `sirs301_ela_math_growth`
#' @inheritParams sirs301_ela_math_growth
#'
#' @return dataframe with all possible growth windows per student/subject

sirs301_empty_scaffold <- function(
  sirs301_ela_math
) {

  #get unique student/year pairs
  unique_pairs <- sirs301_ela_math %>%
    dplyr::select(student_id, test_year) %>%
    unique()

  #minus one year
  pairs_minus <- unique_pairs %>%
    dplyr::mutate(
      start_test_year = test_year - 1
    ) %>%
    dplyr::rename(
    end_test_year = test_year
    ) %>%
    dplyr::select(
      student_id, start_test_year, end_test_year
    )

  #plus the year
  pairs_plus <- unique_pairs %>%
    dplyr::mutate(
      end_test_year = test_year + 1
    ) %>%
    dplyr::rename(
      start_test_year = test_year
    ) %>%
    dplyr::select(
      student_id, start_test_year, end_test_year
    )

  #bind_rows, take the uniques
  all_pairs <- dplyr::bind_rows(pairs_minus, pairs_plus) %>%
    unique()

  #identify windows
  pairs_with_id <- all_pairs %>%
    dplyr::mutate(growth_window = paste0(start_test_year, ' to ', end_test_year))

  pairs_with_id
}


#' Fill in the growth scaffold with data
#'
#' @description helper function for `sirs301_ela_math_growth`
#' @inheritParams sirs301_ela_math_growth
#' @param scaffold output of `sirs301_empty_scaffold`
#'
#' @return dataframe with matching student data for all possible combinations.

sirs301_fill_scaffold <- function(sirs301_ela_math, scaffold, headline = TRUE) {

  subj_scaffold <- data.frame(test_subject = c('ELA', 'Math'), stringsAsFactors = FALSE)
  scaffold <- merge(scaffold, subj_scaffold, all = TRUE)

  #add invariant demographics
  stu_demog <- sirs301_ela_math %>%
    dplyr::select(student_id, student_gender, ethnic_desc, test_year) %>%
    dplyr::group_by(student_id) %>%
    dplyr::mutate(most_recent = rank(-test_year, ties.method = 'first')) %>%
    dplyr::filter(most_recent == 1) %>%
    dplyr::select(-test_year, -most_recent)

  scaffold <- scaffold %>%
    dplyr::left_join(stu_demog, by = 'student_id')


  #identifies the student/assessment pair
  core_cols <- c("student_id", "test_subject")

  headline_variable_cols <- c(
    #identifies the assessment
    "test_grade", "item_key", "test_year",

    #identifies the student's enrollment
    "district_name", "district_key",
    "location_name", "location_key_rsp_sch",
    "cohort_numeric",

    #details about the score
    "test_status", "scale_score", "performance_level", "performance_level_numeric"
  )

  full_variable_cols <- c(
    #identifies the assessment
    "assessment_description", "test_grade", "item_key",
    "report_school_year", "start_year", "test_year",

    #identifies the student's enrollment
    "district_name", "district_key",
    "location_name", "location_key_rsp_sch",
    "curr_grade_lvl", "cohort_numeric",

    #characteristics of the student at test time
    "challenge_type", "poverty", "lep_eligibility", "lep_duration",
    "nyseslat_eligible", "nysaa_eligible",
    "former_lep", "former_swd",

    #details about the score
    "test_status", "scale_score",
    "performance_level", "performance_level_numeric", "std_achieved_code"
  )


  #slim results df
  if (headline) {
    variable_cols <- headline_variable_cols
    desired_cols <- c(core_cols, variable_cols)

    slim_ela_math <- sirs301_ela_math %>%
      dplyr::select(dplyr::one_of(desired_cols))

  } else if (!headline) {
    variable_cols <- full_variable_cols
    desired_cols <- c(core_cols, variable_cols)

    slim_ela_math <- sirs301_ela_math %>%
      dplyr::select(dplyr::one_of(desired_cols))
  }

  #match and rename start
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = slim_ela_math,
      by = c(
        'start_test_year' = 'test_year',
        'student_id' = 'student_id',
        'test_subject' = 'test_subject'
      )
    )

  mask <- names(scaffold) %in% variable_cols
  names(scaffold)[mask] <- paste0('start_', names(scaffold)[mask])

  #match and rename end
  scaffold <- scaffold %>%
    dplyr::left_join(
      y = slim_ela_math,
      by = c(
        'end_test_year' = 'test_year',
        'student_id' = 'student_id',
        'test_subject' = 'test_subject'
      )
    )

  mask <- names(scaffold) %in% variable_cols
  names(scaffold)[mask] <- paste0('end_', names(scaffold)[mask])

  scaffold
}


#' Do growth calculations on a completed scaffold
#'
#' @param complete_scaffold dataframe, output of sirs301_fill_scaffold
#'
#' @return dataframe with growth calculations

sirs301_growth_calcs <- function(complete_scaffold) {

  out <- complete_scaffold %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      complete_obsv = ifelse(!is.na(start_scale_score) & !is.na(end_scale_score), TRUE, FALSE),
      scale_score_change = end_scale_score - start_scale_score,
      perf_level_change = end_performance_level_numeric - start_performance_level_numeric
    )

  out
}
