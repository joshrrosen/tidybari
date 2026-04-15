#' View the BARI dataset catalog
#'
#' Returns a catalog of all datasets available through the tidybari package.
#' The catalog maps each dataset to its location on Harvard Dataverse.
#'
#' @param domain Optional character string. Filter to a specific data domain.
#'   One of: "311", "911", "permits", "assessments", "airbnb", "craigslist", "yelp".
#' @param year Optional integer. Filter to datasets from a specific year.
#'
#' @return A tibble containing the dataset catalog with columns:
#'   \describe{
#'     \item{domain}{Data source domain (e.g., "311", "permits")}
#'     \item{level}{Geographic or data level (e.g., "records", "ecometrics_ct")}
#'     \item{year}{Data year (NA for non-year-specific datasets)}
#'     \item{doi}{Dataverse persistent identifier}
#'     \item{filename}{Exact filename on Dataverse}
#'     \item{restricted}{Whether the file requires special access permission}
#'     \item{description}{Human-readable description}
#'     \item{census_vintage}{Census geography vintage (2010 or 2020)}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # View all available datasets
#' bari_catalog()
#'
#' # View only 311 datasets
#' bari_catalog(domain = "311")
#'
#' # View datasets from 2020
#' bari_catalog(year = 2020)
#'
#' # Combine filters
#' bari_catalog(domain = "permits", year = 2020)
#' }
bari_catalog <- function(domain = NULL, year = NULL) {
  # Locate the catalog file
  catalog_path <- system.file("extdata", "catalog.csv", package = "tidybari")

  if (catalog_path == "") {
    cli::cli_abort(c(
      "Could not find catalog.csv in package installation.",
      "i" = "This may indicate a problem with the package installation."
    ))
  }

  # Read the catalog
  catalog <- readr::read_csv(
    catalog_path,
    col_types = readr::cols(
      domain = readr::col_character(),
      level = readr::col_character(),
      year = readr::col_integer(),
      doi = readr::col_character(),
      filename = readr::col_character(),
      restricted = readr::col_logical(),
      description = readr::col_character(),
      census_vintage = readr::col_integer()
    ),
    show_col_types = FALSE
  )

  # Apply filters if provided
  if (!is.null(domain)) {
    catalog <- catalog %>% dplyr::filter(.data$domain == .env$domain)

    if (nrow(catalog) == 0) {
      available_domains <- unique(
        readr::read_csv(catalog_path, show_col_types = FALSE)$domain
      )
      cli::cli_abort(c(
        "No datasets found for domain {.val {domain}}",
        "i" = "Available domains: {.val {available_domains}}"
      ))
    }
  }

  if (!is.null(year)) {
    catalog <- catalog %>% dplyr::filter(.data$year == .env$year | is.na(.data$year))

    if (nrow(catalog) == 0) {
      cli::cli_abort("No datasets found for year {.val {year}}")
    }
  }

  catalog
}


#' Get a single catalog entry
#'
#' Internal function to look up one specific dataset in the catalog.
#'
#' @param domain Character. Data domain (e.g., "311", "permits").
#' @param level Character. Dataset level (e.g., "records", "ecometrics_ct").
#' @param year Integer or NULL. Data year. If NULL, returns the most recent available.
#'
#' @return A single-row tibble with the catalog entry.
#' @noRd
.get_catalog_entry <- function(domain, level, year = NULL) {
  catalog <- bari_catalog()

  # Filter by domain and level
  matches <- catalog %>%
    dplyr::filter(
      .data$domain == .env$domain,
      .data$level == .env$level
    )

  # Check if any matches exist
  if (nrow(matches) == 0) {
    # Special error message for 911 records
    if (domain == "911" && level == "records") {
      cli::cli_abort(c(
        "Raw 911 dispatch records are restricted by BARI.",
        "i" = "Aggregated ecometrics are available: {.code get_ecometrics('911')}",
        "i" = "For record-level access, contact BARI at {.email [email protected]}"
      ))
    }

    # Generic error message
    available_levels <- unique(
      catalog %>% dplyr::filter(.data$domain == .env$domain) %>% dplyr::pull(.data$level)
    )

    if (length(available_levels) == 0) {
      cli::cli_abort(c(
        "No data found for domain {.val {domain}}",
        "i" = "Use {.code bari_catalog()} to see all available datasets."
      ))
    } else {
      cli::cli_abort(c(
        "No data found for domain = {.val {domain}}, level = {.val {level}}",
        "i" = "Available levels for {.val {domain}}: {.val {available_levels}}"
      ))
    }
  }

  # Handle year selection
  if (!is.null(year)) {
    year_matches <- matches %>% dplyr::filter(.data$year == .env$year)

    if (nrow(year_matches) == 0) {
      available_years <- matches %>%
        dplyr::filter(!is.na(.data$year)) %>%
        dplyr::pull(.data$year) %>%
        unique() %>%
        sort()

      cli::cli_abort(c(
        "No data found for domain = {.val {domain}}, level = {.val {level}}, year = {.val {year}}",
        "i" = "Available years: {.val {available_years}}"
      ))
    }

    return(year_matches[1, ])
  }

  # If year is NULL, return the most recent year (or the NA year for non-temporal data)
  if (any(is.na(matches$year))) {
    # For datasets without year (like Airbnb, Craigslist), return that entry
    return(matches %>% dplyr::filter(is.na(.data$year)) %>% dplyr::slice(1))
  } else {
    # Return the most recent year
    return(matches %>% dplyr::filter(.data$year == max(.data$year, na.rm = TRUE)))
  }
}
