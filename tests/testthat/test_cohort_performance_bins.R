context("cohort performance bins tests")

test_that("cohort_performance_bins should return ggplot object", {
  gr6_math_bins <- cohort_performance_bins(
    sirs301_obj = demo_301,
    studentids = gr6,
    subject = 'Math'
  )

  expect_is(gr6_math_bins, 'ggplot')
})

