#' Topline Performance Chart
#'
#' @param sirs301_obj a sirs301 object
#' @param studentids students you want to plot
#' @param subject c('ELA', 'Math')
#' @param years
#'
#' @return ggplot2 object
#' @export

topline_performance_chart <- function(
  sirs301_obj,
  studentids,
  subject,
  years,
  by = c('test_subject')
) {

  df <- topline_performance_stats(sirs301_obj, studentids, subject, years, by)

  ggplot(
    data = df,
    aes_string(
      x = by,
      y = 'percent_proficient'
    )
  ) +
  geom_bar(stat = 'identity') +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, .1),
    labels = scales::percent
  )

}
