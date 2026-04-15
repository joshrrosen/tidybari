# Declare global variables to avoid R CMD check notes
utils::globalVariables(c("boston_tracts", "boston_block_groups", "boston_neighborhoods"))

#' Get Boston geography boundaries
#'
#' Returns spatial geometries (sf objects) for Boston at different geographic
#' levels. These can be used for mapping or joined with ecometric data using
#' `get_ecometrics(geometry = TRUE)`.
#'
#' @param level Character. Geographic level, one of:
#'   \describe{
#'     \item{"tract"}{Census tracts (default)}
#'     \item{"block_group"}{Census block groups}
#'     \item{"neighborhood"}{BPDA neighborhood districts}
#'   }
#' @param year Integer. Optional. Controls which vintage of geometry to use.
#'   Currently only 2010 vintage is available, so this parameter is reserved
#'   for future use.
#'
#' @return An sf object containing polygon geometries with associated attributes.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(ggplot2)
#'
#' # Get census tract boundaries
#' tracts <- get_geography("tract")
#' plot(tracts["NAME"])
#'
#' # Get neighborhood boundaries
#' neighborhoods <- get_geography("neighborhood")
#'
#' # Map neighborhoods
#' ggplot(neighborhoods) +
#'   geom_sf(aes(fill = NAME)) +
#'   theme_minimal() +
#'   labs(title = "Boston Neighborhoods")
#' }
get_geography <- function(level = c("tract", "block_group", "neighborhood"),
                          year = NULL) {

  # Match level argument
  level <- rlang::arg_match(level)

  # Note about year parameter (not yet implemented)
  if (!is.null(year)) {
    cli::cli_inform(c(
      "i" = "The {.arg year} parameter is not yet implemented.",
      "i" = "Currently returning 2010 vintage geography for all levels."
    ))
  }

  # Return the appropriate dataset
  geography <- switch(
    level,
    "tract" = boston_tracts,
    "block_group" = boston_block_groups,
    "neighborhood" = boston_neighborhoods
  )

  # Verify the data loaded correctly
  if (!inherits(geography, "sf")) {
    cli::cli_abort(c(
      "Geography data failed to load as an sf object.",
      "i" = "This may indicate a problem with the package installation.",
      "i" = "Try reinstalling: {.code remotes::install_github('joshrrosen/tidybari')}"
    ))
  }

  geography
}
