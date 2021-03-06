% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr.R
\name{docu_download}
\alias{docu_download}
\title{Download Document from DocuSign}
\usage{
docu_download(file, username = Sys.getenv("docuSign_username"),
  password = Sys.getenv("docuSign_password"),
  integrator_key = Sys.getenv("docuSign_integrator_key"), base_url,
  envelope_id)
}
\arguments{
\item{file}{a character string naming a file}

\item{username}{docuSign username}

\item{password}{docuSign password}

\item{integrator_key}{docusign integratorKey}

\item{base_url}{base_url}

\item{envelope_id}{id of envelope}
}
\description{
Download Document from DocuSign
}
\examples{
\dontrun{
login <- docu_login(demo = TRUE)
 envelopes <- docu_list_envelopes(base_url = login$baseUrl[1], from_date = "2017/1/1")
 envelope_id <- envelopes[envelopes$status == "completed","envelopeId"][1]
 file <- tempfile()
 document <- docu_download(file, base_url = login[1, 3], 
                           envelope_id = envelope_id)
}

}
