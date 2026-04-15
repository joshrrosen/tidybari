#' Get BARI ecometrics data
#'
#' Download aggregated ecometric measures from the Boston Area Research Initiative.
#' Ecometrics are neighborhood-level indices derived from administrative data that
#' measure social and physical characteristics of place.
#'
#' @param domain Character. Required. Data domain, one of: "311", "911", "permits",
#'   "airbnb", "craigslist", "yelp".
#' @param geography Character. Geographic level of aggregation. One of:
#'   \describe{
#'     \item{"tract"}{Census tract (default)}
#'     \item{"block_group"}{Census block group}
#'     \item{"parcel"}{Land parcel}
#'   }
#' @param year Integer. Data year. If NULL, uses the most recent year available
#'   for the specified domain.
#' @param variables Character vector. Specific variable names to keep. If NULL,
#'   returns all variables. Geographic ID columns are always retained.
#' @param geometry Logical. If TRUE, return an sf object with spatial geometries
#'   for mapping. Default is FALSE.
#' @param longitudinal Logical. If TRUE, return longitudinal data (multiple years).
#'   When TRUE, the geography and year arguments are ignored. Default is FALSE.
#' @param cache Logical. Whether to cache downloaded files locally. Default is TRUE.
#' @param refresh Logical. If TRUE, download fresh data even if cached. Default is FALSE.
#'
#' @return A tibble (or sf object if geometry = TRUE) containing ecometric data.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get 311 ecometrics for census tracts in 2020
#' data_311 <- get_ecometrics("311", geography = "tract", year = 2020)
#'
#' # Get the most recent year automatically
#' data_permits <- get_ecometrics("permits")
#'
#' # Get specific variables only
#' data_subset <- get_ecometrics("311", variables = c("private_neglect", "engagement"))
#'
#' # Get data with spatial geometries for mapping
#' data_spatial <- get_ecometrics("311", year = 2020, geometry = TRUE)
#'
#' # Get longitudinal data across multiple years
#' data_longitudinal <- get_ecometrics("permits", longitudinal = TRUE)
#' }
get_ecometrics <- function(domain,
                           geography = c("tract", "block_group", "parcel"),
                           year = NULL,
                           variables = NULL,
                           geometry = FALSE,
                           longitudinal = FALSE,
                           cache = TRUE,
                           refresh = FALSE) {

  # Validate domain
  domain <- .validate_domain(domain)

  # Match geography argument
  geography <- rlang::arg_match(geography)

  # Determine the catalog level from geography and longitudinal flag
  if (longitudinal) {
    # Longitudinal data is only available at census tract level
    if (geography != "tract") {
      cli::cli_inform(c(
        "i" = "Longitudinal data only available at census tract level.",
        "i" = "Ignoring geography argument and using 'tract'."
      ))
    }
    level <- "ecometrics_ct_longitudinal"
    year <- NULL  # Longitudinal files don't have a specific year
  } else {
    # Map geography to catalog level
    level <- switch(
      geography,
      "tract" = "ecometrics_ct",
      "block_group" = "ecometrics_cbg",
      "parcel" = "ecometrics_lp"
    )
  }

  # If the requested level doesn't exist for this domain, check for longitudinal
  if (!longitudinal) {
    catalog_levels <- bari_catalog(domain = domain)$level
    if (!level %in% catalog_levels) {
      long_level <- paste0(level, "_longitudinal")
      if (long_level %in% catalog_levels) {
        cli::cli_inform(c(
          "i" = "{.val {domain}} ecometrics are only available as longitudinal data.",
          "i" = "Switching to longitudinal. Use {.code longitudinal = TRUE} to suppress this message."
        ))
        longitudinal <- TRUE
        level <- long_level
        year <- NULL
      }
    }
  }

  # Get the catalog entry
  entry <- .get_catalog_entry(domain = domain, level = level, year = year)

  # Download the data
  data <- .download_bari_file(
    doi = entry$doi,
    filename = entry$filename,
    cache = cache,
    refresh = refresh
  )

  # Identify geographic ID columns (to always keep)
  geo_id_cols <- grep("^(CT_ID|CBG_ID|BG_ID|PROPID|GEOID)", names(data), value = TRUE)

  # Select variables if specified
  if (!is.null(variables)) {
    # Always keep geographic ID columns
    cols_to_keep <- unique(c(geo_id_cols, variables))

    # Check that requested variables exist
    missing_vars <- setdiff(variables, names(data))
    if (length(missing_vars) > 0) {
      cli::cli_warn(c(
        "!" = "Some requested variables not found in data: {.val {missing_vars}}",
        "i" = "Available variables: {.val {setdiff(names(data), geo_id_cols)}}"
      ))
    }

    # Select only columns that exist
    cols_to_keep <- intersect(cols_to_keep, names(data))
    data <- data %>% dplyr::select(dplyr::all_of(cols_to_keep))
  }

  # Handle geometry if requested
  if (geometry) {
    # Get the appropriate geography level
    geo_sf <- get_geography(level = geography)

    # Determine the join key based on geography level
    join_key <- switch(
      geography,
      "tract" = "CT_ID_10",
      "block_group" = "CBG_ID_10",
      "parcel" = "PROPID"
    )

    # Coerce join key to character so numeric IDs in downloaded data match
    # the character IDs stored in the geometry objects
    if (join_key %in% names(data)) {
      data[[join_key]] <- as.character(data[[join_key]])
    }

    # Check if the join key exists in both datasets
    if (!join_key %in% names(data)) {
      cli::cli_abort(c(
        "Cannot join geometry: geographic ID column {.val {join_key}} not found in data.",
        "i" = "Available columns: {.val {names(data)}}"
      ))
    }

    if (!join_key %in% names(geo_sf)) {
      cli::cli_abort(c(
        "Cannot join geometry: geographic ID column {.val {join_key}} not found in geography data.",
        "i" = "Available columns: {.val {names(geo_sf)}}"
      ))
    }

    # Join the ecometric data to the spatial geometries
    # Use left_join to keep all ecometric rows even if geometry is missing
    data <- geo_sf %>%
      dplyr::left_join(data, by = join_key)

    # Verify result is an sf object
    if (!inherits(data, "sf")) {
      cli::cli_warn(c(
        "!" = "Spatial join did not produce an sf object.",
        "i" = "Returning regular tibble instead."
      ))
    } else {
      cli::cli_inform(c(
        "v" = "Joined ecometric data to {geography} geometries."
      ))
    }
  }

  data
}
