

#' A function to make the APPR performance vs 2+ year performance table.
#'
#' @param sirs301 a valid sirs301 object
#' @param subject c('ELA', 'Math')
#' @param end_year integer, year that you want to generate the table for
#' @param location_name name of the location to report on.
#'
#' @return
#' @export

appr_performance_by_year_table <- function(
  sirs301,
  subject,
  end_year,
  location_name
) {
  #NSE problems
  location_name_in <- location_name
  end_year_in <- end_year

  #limit the data to matching rows based on the arguments above
  df <- sirs301$ela_math %>%
    dplyr::filter(
      test_subject == subject,
      test_year == end_year,
      location_name == location_name_in
    )

  #reproducible pipe
  proficient_pipe <- . %>%
    dplyr::mutate(
      dummy_tested = ifelse(test_status == 'TEST', TRUE, NA),
      dummy_tested = ifelse(test_status == 'NTEST', FALSE, dummy_tested),
      dummy_proficient = ifelse(performance_level_numeric %in% c(3, 4), TRUE, NA),
      dummy_proficient = ifelse(performance_level_numeric %in% c(1, 2), FALSE, dummy_proficient)
    ) %>%
    dplyr::summarize(
      `Percent Proficient` = mean(dummy_proficient),
      `Number Tested` = sum(dummy_tested)
    )

  #calculate for all students, per grade
  all_stu_per_grade <- df %>%
    dplyr::group_by(test_subject, test_grade) %>%
    proficient_pipe()

  #calculate for all students, all grades
  all_stu_all_grades <- df %>%
    dplyr::group_by(test_subject) %>%
    proficient_pipe

  #put the years enrolled on the df for the next step
  roster <- sirs301$roster %>%
    dplyr::filter(end_year == end_year_in)

  df_years <- df %>%
    dplyr::inner_join(roster, by = c('student_id' = 'studentid', 'test_year' = 'end_year'))

  #what happens if there are kids IN the sirs file but NOT in the roster?
  missing_mask <- !unique(df$student_id) %in% df_years$student_id

  if (sum(missing_mask) > 0) {
    warning(
      sprintf("there are %s unmatched students in your roster file!\n", sum(missing_mask))
      #todo: list them here
    )
  }

  #calculate for all students in 2nd year or more, per grade
  second_yr_stu_per_grade <- df_years %>%
    dplyr::filter(years_enrolled >= 2) %>%
    dplyr::group_by(test_subject, test_grade) %>%
    proficient_pipe

  #calculate for all students in 2nd year or more, all; grade
  second_yr_stu_all_grades <- df_years %>%
    dplyr::filter(years_enrolled >= 2) %>%
    dplyr::group_by(test_subject) %>%
    proficient_pipe

  #put rows together
  all_stu <- dplyr::bind_rows(all_stu_per_grade, all_stu_all_grades)
  all_stu$test_grade <- ifelse(is.na(all_stu$test_grade), 'All', all_stu$test_grade)

  second_yr <- dplyr::bind_rows(second_yr_stu_per_grade, second_yr_stu_all_grades)
  second_yr$test_grade <- ifelse(is.na(second_yr$test_grade, 'All', second_yr$test_grade))

  #we could make it fancy, but let's just return the data
  list(
    'All Students' = all_stu,
    'Second Year' = second_yr
  )

}