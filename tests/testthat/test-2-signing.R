context("Test docuSign envelope and URL for signing")

test_that("Retrieve envelope without error for signing", {
  skip_on_cran()
  login <<- docu_login(demo = TRUE)
  template_id <<- docu_templates(base_url = login[1, 3])$templateId
  expect_silent(envelope <<- docu_envelope(
    account_id = login[1, 2],
    base_url = login[1, 3],
    template_id = template_id,
    template_roles = list(
      email = "carl@cannadatasolutions.com",
      name = "R-Test",
      roleName = "Patient",
      clientUserId = "1"
    ),
    email_subject = "R-Test",
    email_blurb = "R-Test"
  ))
})

test_that("envelopId is returned", {
  skip_on_cran()
  expect_true(!is.null(envelope$envelopeId))
})

test_that("Embed doesn't error", {
  skip_on_cran()
  expect_silent(URL <<- docu_embedded_sign(
    base_url = login[1, 3],
    return_url = "https://www.google.com",
    envelope_id = envelope$envelopeId,
    signer_name = "R-Test",
    signer_email = "carl@cannadatasolutions.com",
    client_user_id = "1"
  ))
})

test_that("URL is legit", {
  skip_on_cran()
  expect_true(!httr::http_error(URL))
})

