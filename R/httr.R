#' Authenticate DocuSign
#'
#' Login to DocuSign and get baseURL and accountId
#'
#' @export
#' @import httr jsonlite
#' @importFrom magrittr %>%
#' @param username docuSign username
#' @param password docuSign password
#' @param integrator_key docusign integratorKey
#' @examples 
#' \dontrun{
#' # assuming env variables are properly set up
#' (login <- docu_login())
#' }

docu_login <-
  function(username = Sys.getenv("docuSign_username"),
           password = Sys.getenv("docuSign_password"),
           integrator_key = Sys.getenv("docuSign_integrator_key")) {
    # XML for authentication
    auth <- docu_auth(username, password, integrator_key)
    
    url <- 'https://demo.docusign.net/restapi/v2/login_information'
    
    header <- docu_header(auth)
    
    # send login info
    # need back baseUrl and accountId info
    resp <- httr::GET(url, header)
    
    parsed <- parse_response(resp)
    
    parsed$loginAccounts
  }

#' Create document for particular instance to be signed
#'
#' Does envelope stuff
#'
#' @export
#' @inheritParams docu_login
#' @param account_id docuSign accountId
#' @param status envelope status
#' @param base_url docuSign baseURL
#' @param template_id docuSign templateId
#' @param template_roles list of parameters passed to template
#' @param email_subject docuSign emailSubject
#' @param email_blurb docuSign emailBlurb
#' @examples 
#' \dontrun{
#' # assuming env variables are properly set up
#' login <- docu_login()
#' (env <- docu_envelope(username = Sys.getenv("docuSign_username"),
#'  password = Sys.getenv("docuSign_password"),
#'  integrator_key = Sys.getenv("docuSign_integrator_key"),
#'  account_id = login[1, "accountId"], base_url = login[1, "baseUrl"], 
#'  template_id = "e86ad42d-f935-4a95-8019-c9e2c902de15",
#'  template_roles = list(name = "Name", email = "email@example.com",
#'                       roleName = "Role", clientUserId = "1"),
#'  email_subject = "Subject", email_blurb = "Body"
#'  ))
#'  }

docu_envelope <-
  function(username = Sys.getenv("docuSign_username"),
           password = Sys.getenv("docuSign_password"),
           integrator_key = Sys.getenv("docuSign_integrator_key"),
           account_id,
           status = "sent",
           base_url,
           template_id,
           template_roles,
           email_subject,
           email_blurb) {
    # XML for authentication
    auth <- docu_auth(username, password, integrator_key)
    
    # request body
    if (!is.null(template_roles$clientUserId)) {
      body <- 
        sprintf(
          '{"accountId": "%s",
        "status" : "%s",
        "emailSubject" : "%s",
        "emailBlurb": "%s",
        "templateId": "%s",
        "templateRoles": [{
          "email" : "%s",
          "name": "%s",
          "roleName": "%s",
          "clientUserId": "%s" }] }',
          account_id,
          status,
          email_subject,
          email_blurb,
          template_id,
          template_roles$email,
          template_roles$name,
          template_roles$roleName,
          template_roles$clientUserId
        )
    } else {
      body <- 
        sprintf(
          '{"accountId": "%s",
        "status" : "%s",
        "emailSubject" : "%s",
        "emailBlurb": "%s",
        "templateId": "%s",
        "templateRoles": [{
          "email" : "%s",
          "name": "%s",
          "roleName": "%s" }] }',
          account_id,
          status,
          email_subject,
          email_blurb,
          template_id,
          template_roles$email,
          template_roles$name,
          template_roles$roleName
        )
    }
    
    url <- paste0(base_url, "/envelopes")
    
    header <- docu_header(auth)
    
    resp <- httr::POST(url, header, body = body)

    parsed <- parse_response(resp)
    
    parsed
    
  }

#' Embedded docuSign
#'
#' Get URL for embedded docuSign
#'
#' @export
#' @inheritParams docu_login
#' @param base_url docuSign baseURL
#' @param return_url URL to return to after signing
#' @param envelope_id ID for envelope returned from \code{docu_envelope}
#' @param signer_name Name of person signing document
#' @param signer_email Email of person signing document
#' @param client_user_id ID for signer
#' @param authentication_method Method application uses to authenticate user. Defaults to "None".
#' @examples 
#' \dontrun{
#' # assuming env variables are properly set up
#' login <- docu_login()
#' env <- docu_envelope(
#'  account_id = login[1, "accountId"], base_url = login[1, "baseUrl"], 
#'  template_id = "e86ad42d-f935-4a95-8019-c9e2c902de15",
#'  template_roles = list(name = "Name", email = "email@example.com",
#'                       roleName = "Patient", clientUserId = "1"),
#'  email_subject = "Subject", email_blurb = "Body"
#' )
#' URL <- docu_embed(
#'  base_url = login[1, "baseUrl"], return_url = "www.google.com",
#'  signer_name = "Name", signer_email = "email@example.com", 
#'  client_user_id = "1", 
#'  envelope_id = env$envelopeId
#' )
#' }


docu_embedded_sign <- function(username = Sys.getenv("docuSign_username"),
                       password = Sys.getenv("docuSign_password"),
                       integrator_key = Sys.getenv("docuSign_integrator_key"),
                       base_url,
                       return_url,
                       envelope_id, 
                       signer_name,
                       signer_email,
                       client_user_id,
                       authentication_method = "None") {
  # XML for authentication
  auth <- docu_auth(username, password, integrator_key)
  
  # request body
  body <- list(
    authenticationMethod = authentication_method,
    email = signer_email,
    returnUrl = return_url,
    userName = signer_name,
    clientUserId = client_user_id
  )
  
  header <- docu_header(auth)
  
  url <- paste0(base_url, "/envelopes/", envelope_id, "/views/recipient")
  
  res <- httr::POST(url, header, body = body, encode = "json")
  
  parsed <- parse_response(res)
  
  parsed$url
  
}

#' @rdname docu_embedded_sign
#' @inheritParams docu_embedded_sign
#' @param uri uri path
#' @export

docu_embedded_send <- function(username = Sys.getenv("docuSign_username"),
                               password = Sys.getenv("docuSign_password"),
                               integrator_key = Sys.getenv("docuSign_integrator_key"),
                               base_url,
                               return_url,
                               uri, 
                               signer_name,
                               signer_email,
                               client_user_id,
                               authentication_method = "None") {
  # XML for authentication
  auth <- docu_auth(username, password, integrator_key)
  
  # request body
  body <- list(
    authenticationMethod = authentication_method,
    email = signer_email,
    returnUrl = return_url,
    userName = signer_name,
    clientUserId = client_user_id
  )
  
  header <- docu_header(auth)
  
  url <- paste0(base_url, uri, "/views/sender")
  
  res <- httr::POST(url, header, body = body, encode = "json")
  
  parsed <- parse_response(res)
  
  parsed$url
  
}

#' Download Document from DocuSign
#' 
#' @export
#' @inheritParams docu_login
#' @param file a character string naming a file
#' @param base_url base_url
#' @param envelope_id id of envelope
#' 

docu_download <- function(file, username = Sys.getenv("docuSign_username"),
                          password = Sys.getenv("docuSign_password"),
                          integrator_key = Sys.getenv("docuSign_integrator_key"),
                          base_url,
                          envelope_id) {
  # XML for authentication
  auth <- docu_auth(username, password, integrator_key)
  
  url <- paste0(base_url, 
                "/envelopes/", 
                envelope_id, 
                "/documents/combined")
  
  header <- docu_header(auth)
  
  document <- httr::GET(url, header)
  
  writeBin(httr::content(document, as = "raw"), 
           con = file)
  
  file
  
}

#' Process results from POST or GET
#'
#' @param response Result of POST or GET

parse_response <- function(response) {
  parsed <- response %>%
    httr::content(type = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  
  # parse errors
  if (http_error(response)) {
    stop(
      sprintf(
        "DocuSign API request failed [%s]\n%s\n<%s>",
        status_code(response),
        parsed$message,
        parsed$errorCode
      ),
      call. = FALSE
    )
  } else {
    return(parsed)
  }
}

#' Create XML authentication string
#'
#' @inheritParams docu_login

docu_auth <- function(username = Sys.getenv("docuSign_username"),
                      password = Sys.getenv("docuSign_password"),
                      integrator_key = Sys.getenv("docuSign_integrator_key")) {
  sprintf(
    "<DocuSignCredential>
    <Username>%s</Username>
    <Password>%s</Password>
    <IntegratorKey>%s</IntegratorKey>
    </DocuSignCredential>",
    username,
    password,
    integrator_key
  )
}

#' Create header for docuSign
#'
#' Create header for authentication with docuSign
#' @param auth XML object with authentication info

docu_header <- function(auth) {
  httr::add_headers('X-DocuSign-Authentication' = auth,
                    'Accept' = 'application/json')
}
