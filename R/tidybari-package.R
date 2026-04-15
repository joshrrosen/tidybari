#' @keywords internal
#' @importFrom rlang .data .env
#' @importFrom dplyr filter select mutate
#' @importFrom tibble tibble as_tibble
"_PACKAGE"

#' @noRd
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "tidybari: Access Boston Area Research Initiative data in R\n",
    "Data source: BARI Data Portal on Harvard Dataverse\n",
    "https://dataverse.harvard.edu/dataverse/BARI"
  )
}
