# tidybari

> Access Boston Area Research Initiative Data in R

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

**tidybari** provides easy access to data from the [Boston Area Research Initiative (BARI)](https://cssh.northeastern.edu/bari/), hosted on Harvard Dataverse. Think of it as "tidycensus for BARI data." Users can pull neighborhood-level data for Boston into R with a single function call and optionally get spatial geometries for mapping.

BARI curates and provides access to administrative, commercial, and social media data about Boston neighborhoods. This package makes it easy to:

- **Browse** available datasets with `bari_catalog()`
- **Discover** variables with `load_variables()`
- **Download** ecometrics (neighborhood-level indices) with `get_ecometrics()`
- **Access** record-level data with `get_records()`
- **Cache** downloads locally for faster re-use
- **Map** data with built-in spatial geometries

## Installation

You can install the development version of tidybari from GitHub:

```r
# install.packages("remotes")
remotes::install_github("joshrrosen/tidybari")
```

## Quick Start

```r
library(tidybari)

# Browse available datasets
bari_catalog()

# View available variables for a domain
load_variables("311")

# Get 311 ecometrics for census tracts
data_311 <- get_ecometrics("311")

# Get building permit ecometrics for 2020
permits <- get_ecometrics("permits", year = 2020)

# Get data with spatial geometries for mapping
data_spatial <- get_ecometrics("permits", year = 2020, geometry = TRUE)
```

## Available Data Domains

| Domain | Description | Records | Ecometrics | Spatial Levels |
|--------|-------------|---------|------------|----------------|
| **311** | Non-emergency service requests | — | ✅ | Tract, Block Group |
| **911** | Emergency dispatch calls | Restricted | ✅ | Tract, Block Group |
| **permits** | Building permit applications | ✅ | ✅ | Tract, Block Group, Parcel |
| **assessments** | Property assessment data | ✅ | ✅ | Tract, Block Group |
| **airbnb** | Airbnb listings in Greater Boston | ✅ | ✅ | Tract |
| **craigslist** | Housing postings in Massachusetts | ✅ | ✅ | Tract |
| **yelp** | Restaurant reviews and ratings | ✅ | ✅ | Tract |

**Note:** Raw 911 dispatch records are restricted by BARI for privacy reasons. Aggregated ecometrics are publicly available. 311 record-level cases are available in multi-year bundles; use `bari_catalog(domain = "311")` to see the files.

## Key Features

### Ecometrics

Ecometrics are neighborhood-level indices that measure social and physical characteristics of place. For example:

```r
# Get 311 ecometrics (measures of disorder, engagement, etc.)
data <- get_ecometrics("311")

# Get specific variables only
data <- get_ecometrics("permits",
                       variables = c("investment", "growth"),
                       year = 2020)

# Get longitudinal data (multiple years)
data_long <- get_ecometrics("permits", longitudinal = TRUE)
```

### Record-Level Data

Access individual records from administrative datasets:

```r
# Get building permit applications (most recent year)
permits <- get_records("permits")

# Get Airbnb listings
airbnb <- get_records("airbnb")

# Get Yelp reviews
yelp <- get_records("yelp")

# Get property assessment records
assessments <- get_records("assessments")
```

### Data Discovery

Explore what's available before downloading:

```r
# See all datasets
bari_catalog()

# Filter to a specific domain
bari_catalog(domain = "permits")

# View available variables
load_variables("311")

# In RStudio, use View() for interactive browsing
View(load_variables())
```

### Caching

Downloaded files are automatically cached locally to improve performance and reduce load on Dataverse servers:

```r
# View cache directory
bari_cache_dir()

# Set custom cache directory
bari_cache_dir("~/my_bari_cache")

# Clear all cached files
bari_cache_clear()

# Force fresh download even if cached
data <- get_ecometrics("permits", year = 2020, refresh = TRUE)

# Disable caching for a single download
data <- get_ecometrics("permits", year = 2020, cache = FALSE)
```

## Geography Levels

Different datasets are available at different geographic levels:

- **Census Tract** (`geography = "tract"`): Most common, available for all domains
- **Block Group** (`geography = "block_group"`): Finer detail, available for permits, 311, assessments
- **Land Parcel** (`geography = "parcel"`): Property-level, available for permits

## Data Citation

All data are provided by the [Boston Area Research Initiative (BARI)](https://cssh.northeastern.edu/bari/) and hosted on [Harvard Dataverse](https://dataverse.harvard.edu/dataverse/BARI).

When using BARI data in publications, please cite the appropriate dataset:

```r
# Find the DOI for your data
catalog <- bari_catalog(domain = "permits", year = 2020)
print(catalog$doi)
```

### Example Citation

> Boston Area Research Initiative, [YEAR]. [Dataset Name]. Harvard Dataverse. https://doi.org/[DOI]

For questions about data access or usage, contact BARI at [email protected].

## Acknowledgments

- **Boston Area Research Initiative (BARI)** at Northeastern University for curating and providing these data
- **Harvard Dataverse** for hosting the data infrastructure
- **tidycensus** package by Kyle Walker for inspiration and design patterns

## Development Status

- ✅ Phase 0: Project Setup
- ✅ Phase 1: Dataset Catalog (50 datasets)
- ✅ Phase 2: Download Layer & Caching
- ✅ Phase 3: Core Accessor Functions
- ✅ Phase 4: Spatial Integration
- ✅ Phase 5: Variable Dictionary
- ✅ Phase 6: Documentation
- ✅ Phase 7: Final Checks

## Getting Help

- Browse function documentation: `?get_ecometrics`, `?bari_catalog`, etc.
- Report bugs or request features: [GitHub Issues](https://github.com/joshrrosen/tidybari/issues)
- Questions about BARI data: [email protected]

## License

MIT © Josh Rosen

---

**Disclaimer:** This package is not officially affiliated with BARI or Northeastern University. It is a community-developed tool to facilitate access to publicly available BARI data.
