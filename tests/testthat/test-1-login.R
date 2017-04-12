context("Test docuSign login")

test_that("Login doesn't error", {
  expect_silent(login <- docu_login())
})

test_that("An actual account is returned", {
  expect_true(nrow(login)>0)
})
