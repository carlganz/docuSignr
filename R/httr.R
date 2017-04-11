#' Authenticate DocuSign
#'
#' Login to DocuSign and get baseURL and accountId
#'
#' @export
#' @import httr jsonlite XML
#' @importFrom magrittr %>%
#' @param username docuSign username
#' @param password docuSign password
#' @param integrator_key docusign integratorKey

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
    
    parsed
  }

#' Create document for particular instance to be signed
#'
#' Does envelope stuff
#'
#' @export
#' @inheritParams docu_login
#' @param account_id docuSign accountId
#' @param base_url docuSign baseURL
#' @param template_id docuSign templateId
#' @param template_roles list of parameters passed to template
#' @param email_subject docuSign emailSubject
#' @param email_blurb docuSign emailBlurb

docu_envelope <-
  function(username = Sys.getenv("docuSign_username"),
           password = Sys.getenv("docuSign_password"),
           integrator_key = Sys.getenv("docuSign_integrator_key"),
           account_id,
           base_url,
           template_id,
           template_roles,
           email_subject,
           email_blurb) {
    # XML for authentication
    auth <- docu_auth(username, password, integrator_key)
    
    # request body
    body <- 
      sprintf(
        '{"accountId": "%s",
        "status" : "created",
        "emailSubject" : "%s",
        "emailBlurb": "%s",
        "templateId": "%s",
        "templateRoles": [{
          "email" : "%s",
          "name": "%s",
          "roleName": "%s" }] }',
        account_id,
        email_subject,
        email_blurb,
        template_id,
        template_roles$email,
        template_roles$name,
        template_roles$roleName
      )
    
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
#' @param signer_name Name of person signing document
#' @param client_user_id ID for signer
#' @param uri docuSign uri
#'

docu_embed <- function(username = Sys.getenv("docuSign_username"),
                       password = Sys.getenv("docuSign_password"),
                       integrator_key = Sys.getenv("docuSign_integrator_key"),
                       base_url,
                       return_url,
                       signer_name,
                       client_user_id,
                       uri) {
  # XML for authentication
  auth <- docu_auth(username, password, integrator_key)
  
  # request body
  body <- list(
    authenticationMethod = "email",
    email = username,
    returnUrl = return_url,
    userName = signer_name,
    clietUserId = client_user_id
  )
  
  header <- docu_header(auth)
  
  url <- paste0(base_url, uri, "/views/sender")
  
  res <- httr::POST(url, header, body = body, encode = "json")
  
  parsed <- parse_response(res)
  
  parsed$url
  
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
        parsed$documentation_url
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
