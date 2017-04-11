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
  function(username = Sys.getenv(),
           password = Sys.getenv(),
           integrator_key = Sys.getenv()) {
    # XML for authentication
    auth <- XML::newXMLNode("DocuSignCredentials")
    XML::newXMLNode("Username", username, parent = auth)
    XML::newXMLNode("Password", password, parent = auth)
    XML::newXMLNode("IntegratorKey", integrator_key, parent = auth)
    
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
  function(username = Sys.getenv(),
           password = Sys.getenv(),
           integrator_key = Sys.getenv(),
           account_id,
           base_url,
           template_id,
           template_roles,
           email_subject,
           email_blurb) {
    # XML for authentication
    auth <- XML::newXMLNode("DocuSignCredentials")
    XML::newXMLNode("Username", username, parent = auth)
    XML::newXMLNode("Password", password, parent = auth)
    XML::newXMLNode("IntegratorKey", integrator_key, parent = auth)
    
    # request body
    body <- list(
      status = "created",
      accountId = account_id,
      templateId = template_id,
      emailSubject = email_subject,
      emailBlurb = email_blurb,
      templateRoles = I(template_roles)
    ) %>%
      jsonlite::toJSON(auto_unbox = TRUE)
    
    url <- httr::modify_url(base_url, "/envelopes")
    
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

docu_embed <- function(username = Sys.getenv(),
                       password = Sys.getenv(),
                       integrator_key = Sys.getenv(),
                       base_url,
                       return_url,
                       signer_name,
                       client_user_id,
                       uri) {
  # XML for authentication
  auth <- XML::newXMLNode("DocuSignCredentials")
  XML::newXMLNode("Username", username, parent = auth)
  XML::newXMLNode("Password", password, parent = auth)
  XML::newXMLNode("IntegratorKey", integrator_key, parent = auth)
  
  # request body
  body <- list(
    authenticationMethod = "email",
    email = username,
    returnUrl = return_url,
    userName = signer_name,
    clietUserId = client_user_id
  )
  
  header <- docu_header(auth)
  
  url <- httr::modify_url(base_url,
                          paste0(uri, "/views/sender"))
  
  res <- httr::POST(url, header, body = body)
  
  parsed <- parse_response(res)
  
  parsed$url
  
}

#' Process results from POST or GET
#'
#' @param response Result of POST or GET

parse_response <- function(response) {
  parsed <- response %>%
    httr::content(type = "text") %>%
    jsonlite::fromJSON(FALSE)
  
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

#' Create header for docuSign
#' 
#' Create header for authentication with docuSign
#' @param auth XML object with authentication info

docu_header <- function(auth) {
  httr::add_headers('X-DocuSign-Authentication' = auth,
                    'Accept' = 'application/json')
}
