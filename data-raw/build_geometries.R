# Build Boston Geography Data for tidybari Package
#
# Downloads real Census Bureau boundaries for Suffolk County, MA (2010 vintage)
# using the tigris package. Suffolk County covers the City of Boston plus
# Chelsea, Revere, and Winthrop — the primary geographic scope of BARI data.
#
# Run this script manually to regenerate the geography data:
#   source("data-raw/build_geometries.R")

library(sf)
library(dplyr)
library(httr)
library(tigris)

options(tigris_use_cache = TRUE)

# ---------------------------------------------------------------------------
# Census Tracts (2010 vintage, Suffolk County MA)
# ---------------------------------------------------------------------------
# CT_ID_10 = GEOID10: standard 11-digit FIPS (state + county + tract)
# e.g. "25025010100"

boston_tracts <- tigris::tracts(
  state  = "MA",
  county = "Suffolk",
  year   = 2010
) %>%
  dplyr::select(CT_ID_10 = GEOID10, NAME = NAMELSAD10) %>%
  sf::st_transform(4326)

# ---------------------------------------------------------------------------
# Census Block Groups (2010 vintage, Suffolk County MA)
# ---------------------------------------------------------------------------
# CBG_ID_10 = GEOID10:  12-digit FIPS (state + county + tract + blkgrp)
# CT_ID_10  = parent tract FIPS (11-digit, prefixed with "25025")
# BG_ID_10  = block group number within its tract (1 digit)

boston_block_groups <- tigris::block_groups(
  state  = "MA",
  county = "Suffolk",
  year   = 2010
) %>%
  dplyr::mutate(CT_ID_10 = paste0("25025", TRACTCE10)) %>%
  dplyr::select(
    CBG_ID_10 = GEOID10,
    BG_ID_10  = BLKGRPCE10,
    CT_ID_10,
    NAME      = NAMELSAD10
  ) %>%
  sf::st_transform(4326)

# ---------------------------------------------------------------------------
# Boston Neighborhoods (BPDA Planning Districts)
# ---------------------------------------------------------------------------
# Real polygon boundaries for the 17 BPDA Planning Districts, downloaded from
# BARI Administrative Geographies, Harvard Dataverse (DOI: 10.7910/DVN/JZV6ON)
# File: BPDA_Planning_Districts 2017.zip (file ID 3308528)

bpda_url  <- "https://dataverse.harvard.edu/api/access/datafile/3308528"
bpda_zip  <- tempfile(fileext = ".zip")
bpda_dir  <- file.path(tempdir(), "bpda_shp")
dir.create(bpda_dir, showWarnings = FALSE)

httr::GET(bpda_url, httr::write_disk(bpda_zip, overwrite = TRUE), httr::timeout(60))
utils::unzip(bpda_zip, exdir = bpda_dir)

bpda_shp <- list.files(bpda_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
bpda_raw <- sf::st_read(bpda_shp[1], quiet = TRUE)

boston_neighborhoods <- bpda_raw %>%
  dplyr::mutate(
    neighborhood = gsub("[^a-z0-9]+", "_", tolower(PD)),
    NAME         = PD
  ) %>%
  dplyr::select(neighborhood, NAME) %>%
  sf::st_transform(4326)

# ---------------------------------------------------------------------------
# Save as package data
# ---------------------------------------------------------------------------
usethis::use_data(boston_tracts, overwrite = TRUE)
usethis::use_data(boston_block_groups, overwrite = TRUE)
usethis::use_data(boston_neighborhoods, overwrite = TRUE)

message("Geography data created successfully!")
message("  - boston_tracts: ", nrow(boston_tracts), " census tracts (real, 2010 vintage)")
message("  - boston_block_groups: ", nrow(boston_block_groups), " block groups (real, 2010 vintage)")
message("  - boston_neighborhoods: ", nrow(boston_neighborhoods), " BPDA planning districts (real polygons, 2017)")
