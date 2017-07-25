context("topline stats tests")

test_that("topline_performance_stats should return a tibble", {

  ex <- topline_performance_stats(
    sirs301_obj = demo_301,
    studentids = gr6,
    subject = 'Math',
    years = 2016
  )

  expect_is(ex, 'tbl_df')
})
