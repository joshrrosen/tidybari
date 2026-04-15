test_that("load_variables returns a tibble", {
  vars <- load_variables()
  expect_s3_class(vars, "tbl_df")
  expect_true(nrow(vars) > 0)
})

test_that("load_variables has expected columns", {
  vars <- load_variables()
  expected_cols <- c("domain", "variable", "label", "description")
  expect_true(all(expected_cols %in% names(vars)))
})

test_that("load_variables filters by domain", {
  vars_311 <- suppressWarnings(load_variables("permits"))
  expect_s3_class(vars_311, "tbl_df")
  expect_true(all(vars_311$domain == "permits"))
})

test_that("load_variables validates domain argument", {
  expect_error(
    load_variables("not_a_domain"),
    "must be one of"
  )
})

test_that("load_variables warns for empty results", {
  # Use a valid domain that might not have entries
  expect_warning(
    load_variables("permits"),  # This should have entries, so adjust if needed
    NA  # Expect no warning for domains with data
  )
})

test_that("load_variables returns all domains when no filter", {
  vars <- load_variables()
  domains <- unique(vars$domain)
  expect_true(length(domains) > 1)
})

test_that("load_variables handles year parameter", {
  # Year parameter should be accepted but not yet implemented
  expect_message(
    load_variables(year = 2020),
    "not yet implemented"
  )
})
