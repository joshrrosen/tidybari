test_that("get_geography returns an sf object", {
  tracts <- get_geography("tract")
  expect_s3_class(tracts, "sf")
  expect_true("geometry" %in% names(tracts))
})

test_that("get_geography works for all levels", {
  # Census tracts
  tracts <- get_geography("tract")
  expect_s3_class(tracts, "sf")
  expect_true(nrow(tracts) > 0)
  expect_true("CT_ID_10" %in% names(tracts))

  # Block groups
  bg <- get_geography("block_group")
  expect_s3_class(bg, "sf")
  expect_true(nrow(bg) > 0)
  expect_true("CBG_ID_10" %in% names(bg))

  # Neighborhoods
  neighborhoods <- get_geography("neighborhood")
  expect_s3_class(neighborhoods, "sf")
  expect_true(nrow(neighborhoods) > 0)
})

test_that("get_geography validates level argument", {
  expect_error(
    get_geography("invalid_level"),
    "must be one of"
  )
})

test_that("get_geography handles year parameter", {
  expect_message(
    get_geography("tract", year = 2020),
    "not yet implemented"
  )
})

test_that("get_geography returns correct structure", {
  tracts <- get_geography("tract")

  # Should have geometry column
  expect_true("geometry" %in% names(tracts))

  # Geometry column should be sfc
  expect_s3_class(tracts$geometry, "sfc")

  # Should have CRS set
  expect_false(is.na(sf::st_crs(tracts)))
})

test_that("get_ecometrics with geometry = TRUE returns sf object", {
  local_mocked_bindings(
    .download_bari_file = function(...) {
      tibble::tibble(
        CT_ID_10 = c("25025000100", "25025000201", "25025000202"),
        year = c(2020L, 2020L, 2020L),
        private_neglect = c(0.5, 0.3, 0.7),
        engagement = c(0.6, 0.8, 0.5)
      )
    }
  )

  result <- get_ecometrics("permits", geometry = TRUE)

  expect_s3_class(result, "sf")
  expect_true("geometry" %in% names(result))
})

test_that("get_ecometrics with geometry = TRUE has both data and geometry", {
  local_mocked_bindings(
    .download_bari_file = function(...) {
      tibble::tibble(
        CT_ID_10 = c("25025000100", "25025000201", "25025000202"),
        year = c(2020L, 2020L, 2020L),
        private_neglect = c(0.5, 0.3, 0.7),
        engagement = c(0.6, 0.8, 0.5)
      )
    }
  )

  result <- get_ecometrics("permits", year = 2020, geometry = TRUE)

  # Should have ecometric columns
  expect_true("private_neglect" %in% names(result))
  expect_true("engagement" %in% names(result))

  # Should have geometry column
  expect_true("geometry" %in% names(result))

  # Should have geographic ID
  expect_true("CT_ID_10" %in% names(result))
})

test_that("get_ecometrics geometry join works for block groups", {
  local_mocked_bindings(
    .download_bari_file = function(...) {
      tibble::tibble(
        CBG_ID_10 = c("250250001001", "250250001002"),
        year = c(2020L, 2020L),
        investment = c(1000000, 500000)
      )
    }
  )

  result <- get_ecometrics("permits", geography = "block_group",
                          year = 2020, geometry = TRUE)

  expect_s3_class(result, "sf")
  expect_true("CBG_ID_10" %in% names(result))
  expect_true("investment" %in% names(result))
  expect_true("geometry" %in% names(result))
})

test_that("get_ecometrics geometry = FALSE returns regular tibble", {
  local_mocked_bindings(
    .download_bari_file = function(...) {
      tibble::tibble(
        CT_ID_10 = c("25025000100", "25025000201"),
        year = c(2020L, 2020L),
        engagement = c(0.6, 0.8)
      )
    }
  )

  result <- get_ecometrics("permits", year = 2020, geometry = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_false(inherits(result, "sf"))
  expect_false("geometry" %in% names(result))
})

test_that("boston_tracts dataset is properly formatted", {
  expect_s3_class(boston_tracts, "sf")
  expect_true("CT_ID_10" %in% names(boston_tracts))
  expect_true("NAME" %in% names(boston_tracts))
  expect_true(nrow(boston_tracts) > 0)
})

test_that("boston_block_groups dataset is properly formatted", {
  expect_s3_class(boston_block_groups, "sf")
  expect_true("CBG_ID_10" %in% names(boston_block_groups))
  expect_true("CT_ID_10" %in% names(boston_block_groups))
  expect_true(nrow(boston_block_groups) > 0)
})

test_that("boston_neighborhoods dataset is properly formatted", {
  expect_s3_class(boston_neighborhoods, "sf")
  expect_true("neighborhood" %in% names(boston_neighborhoods))
  expect_true("NAME" %in% names(boston_neighborhoods))
  expect_true(nrow(boston_neighborhoods) > 0)
})
