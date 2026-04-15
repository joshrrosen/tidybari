#' Get BARI record-level data
#'
#' Download individual records from BARI administrative datasets. Unlike ecometrics,
#' which are aggregated to neighborhoods, records are individual events or observations
#' (e.g., individual building permits, Airbnb listings, or Yelp reviews).
#'
#' @param domain Character. Required. Data domain, one of: "permits",
#'   "assessments", "airbnb", "craigslist", "yelp". Note: "911" records are
#'   restricted and not publicly available. "311" case records are distributed
#'   as multi-year bundles; use `bari_catalog(domain = "311")` to see the files.
#' @param year Integer. Data year. If NULL, uses the most recent year available
#'   for the specified domain.
#' @param cache Logical. Whether to cache downloaded files locally. Default is TRUE.
#' @param refresh Logical. If TRUE, download fresh data even if cached. Default is FALSE.
#'
#' @return A tibble containing record-level data.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get building permit records for 2020
#' permits <- get_records("permits", year = 2020)
#'
#' # Get Airbnb listings (not year-specific)
#' airbnb <- get_records("airbnb")
#'
#' # Get the most recent year automatically
#' permits_recent <- get_records("permits")
#' }
get_records <- function(domain,
                        year = NULL,
                        cache = TRUE,
                        refresh = FALSE) {

  # Special handling for 911 domain
  if (domain == "911") {
    cli::cli_abort(c(
      "Raw 911 dispatch records are restricted by BARI.",
      "i" = "Aggregated ecometrics are available: {.code get_ecometrics('911')}",
      "i" = "For record-level access, contact BARI at {.email [email protected]}"
    ))
  }

  # Validate domain
  domain <- .validate_domain(domain)

  # Get the catalog entry for records
  entry <- .get_catalog_entry(domain = domain, level = "records", year = year)

  # Download the data
  data <- .download_bari_file(
    doi = entry$doi,
    filename = entry$filename,
    cache = cache,
    refresh = refresh
  )

  data
}
