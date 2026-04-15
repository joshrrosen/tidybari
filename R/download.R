#' Download a BARI file from Dataverse
#'
#' Internal function to download CSV files from Harvard Dataverse with caching.
#'
#' @param doi Character. The dataset DOI (e.g., "10.7910/DVN/XTEJRE").
#' @param filename Character. The exact filename to download.
#' @param cache Logical. Whether to use cached files if available.
#' @param refresh Logical. If TRUE, download fresh data even if cached.
#'
#' @return A tibble containing the downloaded data.
#' @noRd
.download_bari_file <- function(doi, filename, cache = TRUE, refresh = FALSE) {
  # Determine cache file path
  cache_file <- .cache_path(doi, filename)

  # Check cache first (if enabled and not refreshing)
  if (cache && !refresh && file.exists(cache_file)) {
    cli::cli_inform(c(
      "i" = "Using cached data from {.path {basename(cache_file)}}"
    ))
    return(readr::read_csv(cache_file, show_col_types = FALSE))
  }

  # Download from Dataverse
  cli::cli_inform(c(
    ">" = "Downloading {.file {filename}} from Harvard Dataverse..."
  ))

  # Try to download the original CSV file first
  data <- tryCatch(
    {
      dataverse::get_dataframe_by_name(
        filename = filename,
        dataset  = paste0("doi:", doi),
        server   = .bari_server(),
        original = TRUE,
        .f       = readr::read_csv,
        show_col_types = FALSE
      )
    },
    error = function(e) {
      # If original file fails, try the ingested version
      cli::cli_inform(c(
        "i" = "Original file not available, trying ingested version..."
      ))

      tryCatch(
        {
          dataverse::get_dataframe_by_name(
            filename = filename,
            dataset  = paste0("doi:", doi),
            server   = .bari_server(),
            original = FALSE
          )
        },
        error = function(e2) {
          cli::cli_abort(c(
            "Failed to download {.file {filename}} from Dataverse.",
            "x" = "Error: {e2$message}",
            "i" = "DOI: {.val {doi}}",
            "i" = "Check that the file exists and is accessible on Harvard Dataverse."
          ))
        }
      )
    }
  )

  # Ensure data is a tibble
  data <- tibble::as_tibble(data)

  # Save to cache if caching is enabled
  if (cache) {
    # Ensure cache directory exists
    cache_dir <- dirname(cache_file)
    if (!dir.exists(cache_dir)) {
      dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    }

    readr::write_csv(data, cache_file)

    cli::cli_inform(c(
      "v" = "Data cached to {.path {basename(cache_file)}}"
    ))
  }

  data
}


#' Download a BARI shapefile from Dataverse
#'
#' Internal function to download and read shapefiles from Harvard Dataverse.
#'
#' @param doi Character. The dataset DOI.
#' @param filename Character. The shapefile filename (usually a .zip).
#' @param cache Logical. Whether to use cached files if available.
#' @param refresh Logical. If TRUE, download fresh data even if cached.
#'
#' @return An sf object containing the spatial data.
#' @noRd
.download_bari_shapefile <- function(doi, filename, cache = TRUE, refresh = FALSE) {
  # Determine cache file path (store the extracted directory)
  cache_dir <- bari_cache_dir()
  sanitized_doi <- gsub("[/.]", "_", doi)
  shapefile_cache_dir <- file.path(cache_dir, paste0(sanitized_doi, "_", tools::file_path_sans_ext(filename)))

  # Check cache first (if enabled and not refreshing)
  if (cache && !refresh && dir.exists(shapefile_cache_dir)) {
    cli::cli_inform(c(
      "i" = "Using cached shapefile from {.path {basename(shapefile_cache_dir)}}"
    ))

    # Find the .shp file in the cache directory
    shp_files <- list.files(shapefile_cache_dir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)

    if (length(shp_files) == 0) {
      cli::cli_abort(c(
        "Cached shapefile directory exists but contains no .shp file.",
        "i" = "Try clearing the cache with {.code bari_cache_clear()} and downloading again."
      ))
    }

    return(sf::st_read(shp_files[1], quiet = TRUE))
  }

  # Download from Dataverse
  cli::cli_inform(c(
    ">" = "Downloading shapefile {.file {filename}} from Harvard Dataverse..."
  ))

  # Create temporary file for the zip
  temp_zip <- tempfile(fileext = ".zip")

  # Download the raw file
  tryCatch(
    {
      dataverse::get_file_by_name(
        filename = filename,
        dataset  = paste0("doi:", doi),
        server   = .bari_server()
      ) %>%
        writeBin(temp_zip)
    },
    error = function(e) {
      cli::cli_abort(c(
        "Failed to download shapefile {.file {filename}} from Dataverse.",
        "x" = "Error: {e$message}",
        "i" = "DOI: {.val {doi}}"
      ))
    }
  )

  # Unzip to cache directory (if caching enabled) or temp directory
  if (cache) {
    extract_dir <- shapefile_cache_dir
  } else {
    extract_dir <- tempfile()
  }

  dir.create(extract_dir, recursive = TRUE, showWarnings = FALSE)

  utils::unzip(temp_zip, exdir = extract_dir)

  # Find the .shp file
  shp_files <- list.files(extract_dir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)

  if (length(shp_files) == 0) {
    cli::cli_abort(c(
      "Downloaded archive contains no .shp file.",
      "i" = "Filename: {.file {filename}}",
      "i" = "DOI: {.val {doi}}"
    ))
  }

  # Read the shapefile
  sf_data <- sf::st_read(shp_files[1], quiet = TRUE)

  if (cache) {
    cli::cli_inform(c(
      "v" = "Shapefile cached to {.path {basename(shapefile_cache_dir)}}"
    ))
  }

  # Clean up temp zip
  unlink(temp_zip)

  sf_data
}
