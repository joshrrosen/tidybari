#' Boston Census Tracts
#'
#' Spatial geometries for Boston census tracts (2010 vintage) for Suffolk
#' County, Massachusetts. Downloaded from the U.S. Census Bureau TIGER/Line
#' shapefiles via the tigris package.
#'
#' @format An sf object with 204 features and 2 fields:
#' \describe{
#'   \item{CT_ID_10}{Census tract ID (11-digit FIPS code, 2010 vintage)}
#'   \item{NAME}{Census tract name}
#'   \item{geometry}{Polygon geometry (EPSG:4326)}
#' }
#'
#' @source U.S. Census Bureau, TIGER/Line Shapefiles 2010, Suffolk County MA.
#'   Downloaded via the tigris R package.
#'
#' @examples
#' \dontrun{
#' library(sf)
#' plot(boston_tracts["NAME"])
#' }
"boston_tracts"


#' Boston Census Block Groups
#'
#' Spatial geometries for Boston census block groups (2010 vintage) for Suffolk
#' County, Massachusetts. Downloaded from the U.S. Census Bureau TIGER/Line
#' shapefiles via the tigris package.
#'
#' @format An sf object with 646 features and 4 fields:
#' \describe{
#'   \item{CBG_ID_10}{Census block group ID (12-digit FIPS code, 2010 vintage)}
#'   \item{BG_ID_10}{Block group number within tract}
#'   \item{CT_ID_10}{Parent census tract ID}
#'   \item{NAME}{Block group name}
#'   \item{geometry}{Polygon geometry (EPSG:4326)}
#' }
#'
#' @source U.S. Census Bureau, TIGER/Line Shapefiles 2010, Suffolk County MA.
#'   Downloaded via the tigris R package.
#'
#' @examples
#' \dontrun{
#' library(sf)
#' plot(boston_block_groups["NAME"])
#' }
"boston_block_groups"


#' Boston Neighborhoods (BPDA Planning Districts)
#'
#' Real polygon boundaries for the 17 Boston Planning & Development Agency
#' (BPDA) planning districts, downloaded from the BARI Administrative
#' Geographies dataset on Harvard Dataverse.
#'
#' @format An sf object with 17 features and 2 fields:
#' \describe{
#'   \item{neighborhood}{Planning district slug (lowercase with underscores,
#'     e.g. \code{"back_bay_beacon_hill"})}
#'   \item{NAME}{Official BPDA planning district name}
#'   \item{geometry}{Multipolygon geometry (EPSG:4326)}
#' }
#'
#' @source Boston Area Research Initiative, Administrative Geographies,
#'   Harvard Dataverse, https://doi.org/10.7910/DVN/JZV6ON.
#'   File: BPDA_Planning_Districts 2017.zip
#'
#' @examples
#' \dontrun{
#' library(sf)
#' library(ggplot2)
#' ggplot(boston_neighborhoods) +
#'   geom_sf(aes(fill = NAME)) +
#'   theme_minimal()
#' }
"boston_neighborhoods"
