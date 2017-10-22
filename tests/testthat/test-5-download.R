context("Test docu_download")

test_that("Retrieve document without error", {
  skip_on_cran()
  skip_if_not(nchar(Sys.getenv("docuSign_integrator_key")) > 0)
  login <- docu_login(demo = TRUE)
  envelopes <- docu_list_envelopes(base_url = login$baseUrl[1], from_date = "2017/1/1")
  envelope_id <- envelopes[envelopes$status == "completed","envelopeId"][1]
  file <- tempfile()
  expect_silent(document <<- docu_download(file, 
                            base_url = login[1, 3], 
                            envelope_id = envelope_id))
})

test_that("Document exists", {
  skip_on_cran()
  skip_if_not(nchar(Sys.getenv("docuSign_integrator_key")) > 0)
  expect_true(file.exists(document))
})
