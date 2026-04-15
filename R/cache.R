#' Get or set the tidybari cache directory
#'
#' Downloaded BARI data files are cached locally to improve performance and
#' reduce load on the Dataverse servers. This function gets or sets the cache
#' directory location.
#'
#' @param path Optional character string. If provided, sets the cache directory
#'   to this path. If NULL (default), returns the current cache directory.
#'
#' @return The cache directory path (invisibly if setting, visibly if getting).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get current cache directory
#' bari_cache_dir()
#'
#' # Set a custom cache directory
#' bari_cache_dir("~/my_bari_cache")
#' }
bari_cache_dir <- function(path = NULL) {
  if (!is.null(path)) {
    # Set the cache directory
    options("tidybari.cache_dir" = path)

    # Create the directory if it doesn't exist
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE, showWarnings = FALSE)
    }

    return(invisible(path))
  }

  # Get the cache directory
  cache_dir <- getOption("tidybari.cache_dir")

  if (is.null(cache_dir)) {
    # Use default: platform-specific user cache directory
    cache_dir <- rappdirs::user_cache_dir("tidybari")
  }

  # Create the directory if it doesn't exist
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  }

  cache_dir
}


#' Clear the tidybari cache
#'
#' Deletes all cached BARI data files. Use this to free up disk space or
#' force fresh downloads of all data.
#'
#' @return Invisibly returns the number of files removed.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Clear all cached files
#' bari_cache_clear()
#' }
bari_cache_clear <- function() {
  cache_dir <- bari_cache_dir()

  if (!dir.exists(cache_dir)) {
    cli::cli_inform("Cache directory does not exist. Nothing to clear.")
    return(invisible(0))
  }

  # Get all files in the cache directory
  files <- list.files(cache_dir, full.names = TRUE, recursive = FALSE)

  if (length(files) == 0) {
    cli::cli_inform("Cache is already empty.")
    return(invisible(0))
  }

  # Remove all files
  file.remove(files)

  cli::cli_inform(c(
    "v" = "Cleared {length(files)} file{?s} from cache.",
    "i" = "Cache directory: {.path {cache_dir}}"
  ))

  invisible(length(files))
}


#' Construct cache file path
#'
#' Internal function to generate the full file path for a cached dataset.
#'
#' @param doi Character. The dataset DOI (e.g., "10.7910/DVN/XTEJRE").
#' @param filename Character. The filename within the dataset.
#'
#' @return Character string with the full cache file path.
#' @noRd
.cache_path <- function(doi, filename) {
  cache_dir <- bari_cache_dir()

  # Sanitize the DOI for use in a filename
  # Replace "/" and "." with "_"
  sanitized_doi <- gsub("[/.]", "_", doi)

  # Construct the cache filename
  cache_filename <- paste0(sanitized_doi, "_", filename)

  # Return the full path
  file.path(cache_dir, cache_filename)
}
