context("Test docuSign login")

test_that("Environmental vars exist", {
  expect_true(Sys.getenv("docuSign_username")!="")
  expect_true(Sys.getenv("docuSign_password")!="")
  expect_true(Sys.getenv("docuSign_integrator_key")!="")
})

test_that("Login works doesn't error", {
  expect_silent(login <<- docu_login())
})

test_that("An actual account is returned", {
  expect_true(nrow(login)>0)
})
