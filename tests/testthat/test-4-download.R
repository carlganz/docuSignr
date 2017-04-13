context("Test docu_download")

envelope_id <- "ba9af7f9-8504-4bd8-8e95-1991833833fc"

test_that("Retrieve document without error", {
  skip_on_cran()
  login <- docu_login()
  file <- tempfile()
  expect_silent(document <<- docu_download(file, 
                            base_url = login[1, 3], 
                            envelope_id = envelope_id))
})

test_that("Document exists", {
  skip_on_cran()
  expect_true(file.exists(document))
})
