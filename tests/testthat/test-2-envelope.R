context("Test docuSign envelope")

template_id <- "e86ad42d-f935-4a95-8019-c9e2c902de15"

login <- docu_login()

test_that("Retrieve envelope without error", {
  expect_silent(envelope <- docu_envelope(
    account_id = login[1, 2],
    base_url = login[1, 3],
    template_id = template_id,
    template_roles = list(
      email = "carl@cannadatasolutions.com",
      name = "Carl",
      roleName = "Patient"
    ),
    email_subject = "blah",
    email_blurb = "blah"
  ))
})

test_that("URI is returned", {
  expect_true(!is.null(envelope$uri))
})