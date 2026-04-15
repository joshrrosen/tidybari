# Mock data for testing
mock_records_data <- tibble::tibble(
  permit_id = c("2020-001", "2020-002", "2020-003"),
  address = c("123 Main St", "456 Oak Ave", "789 Elm St"),
  permit_type = c("Residential", "Commercial", "Residential"),
  value = c(50000, 200000, 75000),
  issue_date = as.Date(c("2020-01-15", "2020-02-20", "2020-03-10"))
)

test_that("get_records returns a tibble", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_records_data
  )

  result <- get_records("permits")
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

test_that("get_records errors for 911 domain with helpful message", {
  expect_error(
    get_records("911"),
    "restricted by BARI"
  )

  expect_error(
    get_records("911"),
    "get_ecometrics"
  )
})

test_that("get_records validates domain argument", {
  expect_error(
    get_records("not_a_domain"),
    "must be one of"
  )
})

test_that("get_records accepts valid domains", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_records_data
  )

  # Should not error for valid domains (except 911)
  expect_s3_class(get_records("permits"), "tbl_df")
  expect_s3_class(get_records("assessments"), "tbl_df")
  expect_s3_class(get_records("airbnb"), "tbl_df")
  expect_s3_class(get_records("craigslist"), "tbl_df")
  expect_s3_class(get_records("yelp"), "tbl_df")
})

test_that("get_records handles year argument", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_records_data
  )

  # Should accept year argument
  result <- get_records("permits", year = 2025)
  expect_s3_class(result, "tbl_df")
})

test_that("get_records passes cache and refresh arguments", {
  local_mocked_bindings(
    .download_bari_file = function(doi, filename, cache, refresh) {
      # Verify arguments are passed through
      expect_type(cache, "logical")
      expect_type(refresh, "logical")
      mock_records_data
    }
  )

  get_records("permits", cache = FALSE, refresh = TRUE)
})

test_that("get_records works without year (uses most recent)", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_records_data
  )

  # Should work without year argument
  result <- get_records("permits")
  expect_s3_class(result, "tbl_df")
})
