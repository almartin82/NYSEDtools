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
