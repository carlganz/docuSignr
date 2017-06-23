context("Test docuSign login")

test_that("Environmental vars exist", {
  skip_on_cran()
  expect_true(Sys.getenv("docuSign_username")!="")
  expect_true(Sys.getenv("docuSign_password")!="")
  expect_true(Sys.getenv("docuSign_integrator_key")!="")
})

test_that("Login works doesn't error", {
  skip_on_cran()
  expect_silent(login <<- docu_login(demo = TRUE))
})

test_that("An actual account is returned", {
  skip_on_cran()
  expect_true(nrow(login)>0)
})
