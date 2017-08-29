context("topline performance chart tests")

test_that("topline_performance_chart should return ggplot object", {

  ex <- topline_performance_chart(
    sirs301_obj = demo_301,
    studentids = gr6,
    subject = 'Math',
    years = 2016
  )

  expect_is(ex, 'ggplot')
})
