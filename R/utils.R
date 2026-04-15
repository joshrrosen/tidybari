#' Get the BARI Dataverse server
#'
#' Internal function that returns the Harvard Dataverse server URL.
#'
#' @return Character string with the server URL.
#' @noRd
.bari_server <- function() {
  "dataverse.harvard.edu"
}


#' Validate domain argument
#'
#' Internal function to validate that the domain argument is one of the
#' accepted values.
#'
#' @param domain Character. The domain to validate.
#'
#' @return The validated domain (invisibly).
#' @noRd
.validate_domain <- function(domain) {
  valid_domains <- c("311", "911", "permits", "assessments", "airbnb", "craigslist", "yelp")

  domain <- rlang::arg_match(domain, valid_domains)

  domain
}


#' Find the most recent year for a domain and level
#'
#' Internal function to determine the most recent available year for a given
#' domain and level combination.
#'
#' @param domain Character. The data domain.
#' @param level Character. The dataset level.
#'
#' @return Integer with the most recent year, or NA if the dataset is not
#'   year-specific.
#' @noRd
.most_recent_year <- function(domain, level) {
  catalog <- bari_catalog(domain = domain)

  catalog <- catalog %>%
    dplyr::filter(.data$level == .env$level)

  if (nrow(catalog) == 0) {
    cli::cli_abort(c(
      "No data found for domain = {.val {domain}}, level = {.val {level}}",
      "i" = "Use {.code bari_catalog()} to see available datasets."
    ))
  }

  # If all years are NA, return NA (non-temporal dataset)
  if (all(is.na(catalog$year))) {
    return(NA_integer_)
  }

  # Return the maximum year
  max(catalog$year, na.rm = TRUE)
}
