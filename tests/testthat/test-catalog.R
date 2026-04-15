test_that("bari_catalog returns a tibble", {
  catalog <- bari_catalog()
  expect_s3_class(catalog, "tbl_df")
  expect_true(nrow(catalog) > 0)
})

test_that("bari_catalog has the expected columns", {
  catalog <- bari_catalog()
  expected_cols <- c("domain", "level", "year", "doi", "filename",
                     "restricted", "description", "census_vintage")
  expect_true(all(expected_cols %in% names(catalog)))
})

test_that("bari_catalog filters by domain correctly", {
  catalog_911 <- bari_catalog(domain = "911")
  expect_s3_class(catalog_911, "tbl_df")
  expect_true(all(catalog_911$domain == "911"))
  expect_true(nrow(catalog_911) > 0)
})

test_that("bari_catalog filters by year correctly", {
  catalog_2020 <- bari_catalog(year = 2020)
  expect_s3_class(catalog_2020, "tbl_df")
  # Should include rows where year == 2020 OR year is NA (non-temporal datasets)
  expect_true(all(catalog_2020$year == 2020 | is.na(catalog_2020$year)))
})

test_that("bari_catalog errors for invalid domain", {
  expect_error(
    bari_catalog(domain = "not_a_real_domain"),
    "No datasets found"
  )
})

test_that("bari_catalog can combine filters", {
  catalog <- bari_catalog(domain = "permits", year = 2020)
  expect_s3_class(catalog, "tbl_df")
  expect_true(all(catalog$domain == "permits"))
  expect_true(all(catalog$year == 2020 | is.na(catalog$year)))
})

test_that(".get_catalog_entry returns exactly one row for valid combo", {
  entry <- tidybari:::.get_catalog_entry(domain = "permits", level = "ecometrics_ct", year = 2020)
  expect_s3_class(entry, "tbl_df")
  expect_equal(nrow(entry), 1)
  expect_equal(entry$domain, "permits")
  expect_equal(entry$level, "ecometrics_ct")
  expect_equal(entry$year, 2020)
})

test_that(".get_catalog_entry returns most recent year when year is NULL", {
  entry <- tidybari:::.get_catalog_entry(domain = "permits", level = "ecometrics_ct", year = NULL)
  expect_s3_class(entry, "tbl_df")
  expect_equal(nrow(entry), 1)
  expect_equal(entry$domain, "permits")
  expect_equal(entry$level, "ecometrics_ct")
  # Should be the most recent year available for permits ecometrics_ct
  expect_true(entry$year >= 2015)
})

test_that(".get_catalog_entry errors for invalid domain", {
  expect_error(
    tidybari:::.get_catalog_entry(domain = "invalid_domain", level = "records"),
    "No data found"
  )
})

test_that(".get_catalog_entry errors for invalid level", {
  expect_error(
    tidybari:::.get_catalog_entry(domain = "911", level = "invalid_level"),
    "No data found"
  )
})

test_that(".get_catalog_entry errors for 911 records with helpful message", {
  expect_error(
    tidybari:::.get_catalog_entry(domain = "911", level = "records"),
    "restricted by BARI"
  )
  expect_error(
    tidybari:::.get_catalog_entry(domain = "911", level = "records"),
    "get_ecometrics"
  )
})

test_that(".get_catalog_entry errors for invalid year", {
  expect_error(
    tidybari:::.get_catalog_entry(domain = "911", level = "ecometrics_ct", year = 1999),
    "No data found"
  )
})

test_that(".get_catalog_entry handles datasets without year (NA)", {
  entry <- tidybari:::.get_catalog_entry(domain = "airbnb", level = "ecometrics_ct", year = NULL)
  expect_s3_class(entry, "tbl_df")
  expect_equal(nrow(entry), 1)
  expect_true(is.na(entry$year))
})
