
[![Build Status](https://travis-ci.org/CannaData/docuSignr.svg?branch=master)](https://travis-ci.org/CannaData/docuSignr)[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/CannaData/docuSignR?branch=master&svg=true)](https://ci.appveyor.com/project/CannaData/docuSignR)[![Coverage Status](https://img.shields.io/codecov/c/github/CannaData/docuSignr/master.svg)](https://codecov.io/github/CannaData/docuSignr?branch=master)

docuSignR
=========

[DocuSign](https://www.docusign.com/) is the leader in online document signing. They provide a REST API which allows for [embedded document](https://www.docusign.com/developer-center/recipes/signing-from-your-app) signing in several server-side languages, not currently including R.

The `docuSignR` package uses `httr` to embed DocuSign into Shiny applications.

Installation
============

`docuSignR` is only available on Github at the moment.

``` r
devtools::install_github("CannaData/docuSignR")
```

Requirements
============

For `docuSignR` to function you will need several things:

-   DocuSign account
-   DocuSign integrator key
-   DocuSign templates
-   DocuSign envelopes

Set-Up
======

It is recommended that you set the DocuSign username, password, and integrator key as environmental variables idealy in your .Rprofile.

``` r
Sys.setenv(docuSign_username = "username")
Sys.setenv(docuSign_password = "password")
Sys.setenv(docuSign_integrator_key = "integrator_key")
```

Example
=======

``` r
library(docuSignr)
# login to get baseURL and accountID
login <- docu_login(username = Sys.getenv("docuSign_username"), password = Sys.getenv("docuSign_password"), 
    integrator_key = Sys.getenv("docuSign_integrator_key"))

# get envelope
env <- docu_envelope(username = Sys.getenv("docuSign_username"), password = Sys.getenv("docuSign_password"), 
    integrator_key = Sys.getenv("docuSign_integrator_key"), account_id = login[1, 
        "accountId"], base_url = login[1, "baseUrl"], template_id = "e86ad42d-f935-4a95-8019-c9e2c902de15", 
    template_roles = list(name = "Name", email = "email@example.com", roleName = "Role"), 
    email_subject = "Subject", email_blurb = "Body")

# get URL to pass user to
URL <- docu_embed(username = Sys.getenv("docuSign_username"), password = Sys.getenv("docuSign_password"), 
    integrator_key = Sys.getenv("docuSign_integrator_key"), base_url = login[1, 
        "baseUrl"], return_url = "URL/of/Shiny/App", signer_name = "Name", client_user_id = "1", 
    uri = env$uri)

browseURL(URL)
```

Code of Conduct
===============

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Also see [contributing](CONTRIBUTE.md).
