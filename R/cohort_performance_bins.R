#' Cohort Performance Bins
#'
#' @param sirs301_obj a sirs301 object
#' @param studentids students you want to plot
#' @param subject c('ELA', 'Math', 'Sci')
#'
#' @return ggplot2 object
#' @export

cohort_performance_bins <- function(
  sirs301_obj,
  studentids,
  subject
) {

  #be defensive against bad `subject` parameters
  valid_subjects <- c('ELA', 'Math', 'Sci')
  subject %>% ensurer::ensure_that(
    . %in% valid_subjects ~
      paste0("valid values for subject are: ",
              paste(valid_subjects, collapse = ', ')
      )
  )

  #extract subject
  if (subject %in% c('ELA', 'Math')) {
    df <- sirs301_obj$ela_math
  } else if (subject == 'Sci') {
    df <- sirs301_obj$sci
  }

  #subset to these students
  df <- df %>% dplyr::filter(student_id %in% studentids & test_subject == subject)

  term_totals <- df %>%
    dplyr::select(
      test_subject, test_grade, performance_level, performance_level_numeric
    ) %>%
    #first group by term
    dplyr::group_by(
      test_subject, test_grade
    ) %>%
    dplyr::summarize(
      n_total = n()
    ) %>%
    as.data.frame()


  perf_level_totals <- df %>%
    #then group by perf_level
    dplyr::group_by(
      test_subject, test_grade, performance_level_numeric
    ) %>%
    dplyr::summarize(
      n_level = n()
    ) %>%
    #include at grade level flag
    dplyr::mutate(
      proficient_dummy = ifelse(performance_level_numeric %in% c(3, 4), 'Yes', 'No'),
      order = perf_level_order(as.numeric(performance_level_numeric))
    )


  prepped <- perf_level_totals %>%
    dplyr::left_join(
      term_totals[, c(2,3)],
      by = "test_grade"
  ) %>%
    dplyr::mutate(
      pct = n_level /  n_total * 100
    )

  #TRANSFORMATION - TWO dfs FOR CHART
  #super helpful advice from: http://stackoverflow.com/a/13734448/561698
  perf_above <- prepped %>% dplyr::filter(proficient_dummy == 'Yes')
  perf_below <- prepped %>% dplyr::filter(proficient_dummy == 'No')

  #flip the sign
  perf_below$pct <- perf_below$pct * -1

  #midpoints for labels
  perf_above <- perf_above %>%
    dplyr::group_by(test_grade) %>%
    dplyr::mutate(
      cumsum = dplyr::with_order(order_by = order, fun = cumsum, x = pct),
      midpoint = cumsum - (0.5 * pct)
    )

  perf_below <- perf_below %>%
    dplyr::group_by(test_grade) %>%
    dplyr::arrange(order) %>%
    dplyr::mutate(
      cumsum = dplyr::with_order(order_by = order, fun = cumsum, x = pct),
      midpoint = cumsum - (0.5 * pct)
    )

  x_breaks <- sort(unique(prepped$test_grade))
  x_labels <- paste0('Gr. ', x_breaks)

  #MAKE THE PLOT
  p <- ggplot() +
    #top half of NPR plots
    geom_bar(
      data = perf_above,
      aes(
        x = test_grade,
        y = pct,
        fill = factor(performance_level_numeric)
      ),
      stat = "identity"
    ) +
    #bottom half of NPR plots
    geom_bar(
      data = perf_below,
      aes(
        x = test_grade,
        y = pct,
        fill = factor(performance_level_numeric)
      ),
      stat = "identity"
    )

  #labels above
  p <- p +
    geom_text(
      data = perf_above,
      aes(
        x = test_grade,
        y = midpoint,
        label = round(pct,0)
      ),
      size = 4
    ) +
    #labels below
    geom_text(
      data = perf_below,
      aes(
        x = test_grade,
        y = midpoint,
        label = abs(round(pct, 0))
      ),
      size = 4
    ) +
    #axis labels
    labs(
      x = 'Grade Level',
      y = 'Percentage of Cohort'
    ) +
    theme_bw() +
    #zero out cetain formatting
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title.x = element_text(size = rel(0.9)),
      plot.margin = rep(grid::unit(0,"null"),4)
    ) +
    scale_x_continuous(
      breaks = x_breaks,
      labels = x_labels
    )

  legend_labels = c('Level 1', 'Level 2', 'Level 3', 'Level 4')

  p <- p + scale_fill_manual(
    values = kipp_4col, labels = legend_labels, name = 'Perf. Levels',
    guide = guide_legend(reverse = TRUE)
  )

  p
}



#' @title perf_level_order
#'
#' @description helper function used by cohort_performance_bins to put performance levels in correct order
#'
#' @param x a performance level (1-4)

perf_level_order <- function(x) {
  ifelse(x == 2, 1,
         ifelse(x == 1, 2, x)
  )
}
