#' Load BARI variable dictionary
#'
#' Returns a dictionary of available variables in BARI datasets, with labels
#' and descriptions. Use this to explore what ecometric measures are available
#' before downloading data.
#'
#' @param domain Optional character string. Filter to a specific data domain.
#'   One of: "311", "911", "permits", "assessments", "airbnb", "craigslist", "yelp".
#' @param year Optional integer. Reserved for future use. Some variables may
#'   only be available in certain years.
#'
#' @return A tibble containing the variable dictionary with columns:
#'   \describe{
#'     \item{domain}{Data source domain}
#'     \item{variable}{Variable name (column name in the data)}
#'     \item{label}{Short human-readable label}
#'     \item{description}{Detailed description of what the variable measures}
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # View all available variables
#' load_variables()
#'
#' # View variables for a specific domain
#' load_variables("311")
#'
#' # In RStudio, use View() for interactive browsing
#' View(load_variables())
#' }
load_variables <- function(domain = NULL, year = NULL) {
  # Locate the variable dictionary file
  dict_path <- system.file("extdata", "variable_dictionary.csv", package = "tidybari")

  if (dict_path == "") {
    cli::cli_abort(c(
      "Could not find variable_dictionary.csv in package installation.",
      "i" = "This may indicate a problem with the package installation."
    ))
  }

  # Read the dictionary
  dictionary <- readr::read_csv(
    dict_path,
    col_types = readr::cols(
      domain = readr::col_character(),
      variable = readr::col_character(),
      label = readr::col_character(),
      description = readr::col_character()
    ),
    show_col_types = FALSE
  )

  # Filter by domain if provided
  if (!is.null(domain)) {
    domain <- .validate_domain(domain)
    dictionary <- dictionary %>% dplyr::filter(.data$domain == .env$domain)

    if (nrow(dictionary) == 0) {
      cli::cli_warn(c(
        "No variables found for domain {.val {domain}}",
        "i" = "The variable dictionary may be incomplete for this domain."
      ))
    }
  }

  # year parameter is reserved for future use
  if (!is.null(year)) {
    cli::cli_inform(c(
      "i" = "The {.arg year} parameter is not yet implemented.",
      "i" = "Currently showing all variables for the domain regardless of year."
    ))
  }

  dictionary
}
