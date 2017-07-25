context("util tests")

test_that("limit_ela_math should fail with bad parameters", {

  expect_error(
    limit_ela_math(data = demo_301, studentids = gr6, subject = 'Math', years = 2016),
    'data must be a sirs301_ela_math object'
  )

  expect_error(
    limit_ela_math(data = demo_301$ela_math, studentids = gr6, subject = 'Art', years = 2016),
    "valid values for subjects are: 'ELA', 'Math'"
  )

})
