# Mock data for testing
mock_ecometrics_data <- tibble::tibble(
  CT_ID_10 = c("25025000100", "25025000201", "25025000202"),
  year = c(2020L, 2020L, 2020L),
  private_neglect = c(0.5, 0.3, 0.7),
  public_denigration = c(0.2, 0.4, 0.1),
  engagement = c(0.6, 0.8, 0.5),
  custodianship = c(0.4, 0.7, 0.3)
)

test_that("get_ecometrics returns a tibble", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  result <- get_ecometrics("permits")
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

test_that("get_ecometrics validates domain argument", {
  expect_error(
    get_ecometrics("not_a_domain"),
    "must be one of"
  )
})

test_that("get_ecometrics accepts valid domains", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  # Should not error for valid domains
  # 911 only has longitudinal data, so longitudinal = TRUE is required
  expect_s3_class(get_ecometrics("911", longitudinal = TRUE), "tbl_df")
  expect_s3_class(get_ecometrics("permits"), "tbl_df")
  expect_s3_class(get_ecometrics("airbnb"), "tbl_df")
})

test_that("get_ecometrics filters variables correctly", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  result <- get_ecometrics("permits", variables = "private_neglect")

  # Should keep geographic ID column and requested variable
  expect_true("CT_ID_10" %in% names(result))
  expect_true("private_neglect" %in% names(result))

  # Should not keep other variables
  expect_false("public_denigration" %in% names(result))
  expect_false("engagement" %in% names(result))
})

test_that("get_ecometrics keeps geographic ID columns when selecting variables", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  result <- get_ecometrics("permits", variables = c("private_neglect", "engagement"))

  # Geographic ID should always be present
  expect_true("CT_ID_10" %in% names(result))
  expect_true("private_neglect" %in% names(result))
  expect_true("engagement" %in% names(result))
})

test_that("get_ecometrics warns about missing variables", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  expect_warning(
    get_ecometrics("permits", variables = c("private_neglect", "nonexistent_var")),
    "not found"
  )
})

test_that("get_ecometrics handles geography argument", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  # Should accept valid geography values
  expect_s3_class(get_ecometrics("permits", geography = "tract"), "tbl_df")
  expect_s3_class(get_ecometrics("permits", geography = "block_group"), "tbl_df")
  expect_s3_class(get_ecometrics("permits", geography = "parcel"), "tbl_df")
})

test_that("get_ecometrics errors for invalid geography", {
  expect_error(
    get_ecometrics("permits", geography = "invalid"),
    "must be one of"
  )
})

test_that("get_ecometrics handles year argument", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  # Should accept year argument
  result <- get_ecometrics("permits", year = 2020)
  expect_s3_class(result, "tbl_df")
})

test_that("get_ecometrics geometry argument works", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  # Should return an sf object when geometry = TRUE
  result <- get_ecometrics("permits", geometry = TRUE)
  expect_s3_class(result, "sf")
})

test_that("get_ecometrics handles longitudinal flag", {
  local_mocked_bindings(
    .download_bari_file = function(...) mock_ecometrics_data
  )

  # Should work with longitudinal = TRUE
  result <- get_ecometrics("permits", longitudinal = TRUE)
  expect_s3_class(result, "tbl_df")
})

test_that("get_ecometrics passes cache and refresh arguments", {
  local_mocked_bindings(
    .download_bari_file = function(doi, filename, cache, refresh) {
      # Verify arguments are passed through
      expect_type(cache, "logical")
      expect_type(refresh, "logical")
      mock_ecometrics_data
    }
  )

  get_ecometrics("permits", cache = FALSE, refresh = TRUE)
})
