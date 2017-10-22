context("Test that we can get info about envelopes")


test_that("We can list envelopes without error", {
  skip_on_cran()
  login <<- docu_login(demo = TRUE)
  expect_silent(envelopes <<- docu_list_envelopes(base_url = login$baseUrl[1], from_date = "2017/1/1"))
})

test_that("Envelopes actually exist", {
  skip_on_cran()
  expect_true(nrow(envelopes)>0)
  expect_true("envelopeId" %in% names(envelopes))
})

test_that("Get status of individual envelope", {
  skip_on_cran()
  expect_silent(status <<- docu_envelope_status(base_url = login$baseUrl[1], envelope_id = envelopes$envelopeId[1]))
  expect_true(length(status) == 1)
})