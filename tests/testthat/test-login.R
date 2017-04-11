context("Test docuSign login")

test_that("Login doesn't error", {
  expect_success(login <- docu_login())
})

test_that("An actual account is returned", {
  expect_true(nrow(login)>0)
})