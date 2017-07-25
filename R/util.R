#' caclculate cohort
#'
#' @param grade student's grade level
#' @param start_year start of the year in question.  eg, 2015-2016 would be 2015.
#' @param kind c('college_entry', 'college_grad').  should the cohort be tagged by
#' the year the student *enters* college, or the year the student will
#' *graduate* college?
#'
#' @return numeric vector with student's cohort name
#' @export

calculate_cohort <- function(grade, start_year, kind = 'college_entry') {

  kind %>% ensurer::ensure_that(
    . %in% c('college_entry', 'college_grad') ~
      paste0("valid values for kind are: 'college_entry', 'college_grad'")
  )

  if (kind == 'college_entry') {
    out <- start_year + 13 - grade
  } else if (kind == 'college_grad') {
    out <- start_year + 17 - grade
  }

  out
}


kipp_4col <- c(
  rgb(207, 204, 193, max = 255),
  rgb(230, 230, 230, max = 255),
  rgb(254, 188, 17, max = 255),
  rgb(247, 148, 30, max = 255)
)



ensure_ela_math <- ensurer::ensures_that(. %in% c('ELA', 'Math') ~ paste0("valid values for subjects are: 'ELA', 'Math'"))
ensure_subjects <- ensurer::ensures_that(. %in% c('ELA', 'Math', 'Sci') ~ paste0("valid values for subjects are: 'ELA', 'Math', 'Sci'"))

#' utility function to filter a sirs301 object
#'
#' @param data sirs301$ela_math data object
#' @param studentids students you want to include in the performance stats
#' @param subjects c('ELA', 'Math')
#' @param year test year (ending academic year)
#'
#' @return tbl_df with matching data
#' @export

limit_ela_math <- function(data, studentids, subjects, years) {

  #expects sirs301_ela_math objects
  data %>% ensurer::ensure_that(
    inherits(., 'sirs301_ela_math') ~ 'data must be a sirs301_ela_math object'
  )

  #be defensive about bad arguments to subjects
  subjects %>% ensure_ela_math

  data %>%
    dplyr::filter(student_id %in% studentids) %>%
    dplyr::filter(test_subject %in% subjects) %>%
    dplyr::filter(test_year %in% years)
}
