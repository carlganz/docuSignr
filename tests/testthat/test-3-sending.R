context("Test docuSign envelope and URL for sending")


template_id <- "e86ad42d-f935-4a95-8019-c9e2c902de15"

test_that("Retrieve envelope without error for signing", {
  skip_on_cran()
  login <<- docu_login()
  expect_silent(envelope <<- docu_envelope(
    account_id = login[1, 2],
    base_url = login[1, 3],
    status = "created",
    template_id = template_id,
    template_roles = list(
      email = "carl@cannadatasolutions.com",
      name = "R-Test",
      roleName = "Patient"
    ),
    email_subject = "R-Test",
    email_blurb = "R-Test"
  ))
})

test_that("uri is returned", {
  skip_on_cran()
  expect_true(!is.null(envelope$uri))
})

test_that("Embed doesn't error", {
  skip_on_cran()
  expect_silent(URL <<- docu_embedded_send(
    base_url = login[1, 3],
    return_url = "https://www.google.com",
    uri = envelope$uri,
    signer_name = "R-Test",
    signer_email = "carl@cannadatasolutions.com",
    client_user_id = "1"
  ))
})

test_that("URL is legit", {
  skip_on_cran()
  expect_true(!httr::http_error(URL))
})