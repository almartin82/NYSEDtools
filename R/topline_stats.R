#' Topline Performance Stats
#'
#' @param sirs301_obj a sirs301 object
#' @param studentids students you want to include in the performance stats
#' @param subjects c('ELA', 'Math')
#' @param year test year (ending academic year)
#'
#' @return ggplot2 object
#' @export

topline_performance_stats <- function(
  sirs301_obj,
  studentids,
  subjects = c('ELA', 'Math'),
  years = c(2017),
  by = c('district_name', 'test_subject')
) {

  limit_ela_math(sirs301_obj$ela_math, studentids, subjects, years) %>%
  dplyr::group_by_at(by) %>%
  dplyr::summarize(
    percent_proficient = mean(is_proficient),
    `L1%` = round(mean(is_l1) * 100, 0),
    `L2%` = round(mean(is_l2) * 100, 0),
    `L3%` = round(mean(is_l3) * 100, 0),
    `L4%` = round(mean(is_l4) * 100, 0),
    `L2+%` = round(mean(is_l2_or_higher)  * 100, 0),
    `L1%_raw` = mean(is_l1),
    `L2%_raw` = mean(is_l2),
    `L3%_raw` = mean(is_l3),
    `L4%_raw` = mean(is_l4),
    `L2+%_raw` = mean(is_l2_or_higher),
    `L1` = sum(is_l1),
    `L2` = sum(is_l2),
    `L3` = sum(is_l3),
    `L4` = sum(is_l4)
  )
}
