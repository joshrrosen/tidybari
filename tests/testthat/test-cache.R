test_that("bari_cache_dir returns a valid path", {
  cache_dir <- bari_cache_dir()
  expect_type(cache_dir, "character")
  expect_true(nchar(cache_dir) > 0)
  expect_true(dir.exists(cache_dir))
})

test_that("bari_cache_dir can be set to a custom path", {
  # Create a temporary directory for testing
  temp_cache <- tempfile("tidybari_test_cache")

  # Set the cache directory
  result <- bari_cache_dir(temp_cache)

  # Should return the path invisibly
  expect_equal(result, temp_cache)

  # Directory should be created
  expect_true(dir.exists(temp_cache))

  # Getting the cache dir should return the new path
  expect_equal(bari_cache_dir(), temp_cache)

  # Clean up: reset to default
  options("tidybari.cache_dir" = NULL)
  unlink(temp_cache, recursive = TRUE)
})

test_that("bari_cache_dir creates directory if it doesn't exist", {
  temp_cache <- tempfile("tidybari_test_cache")

  # Ensure it doesn't exist
  expect_false(dir.exists(temp_cache))

  # Set and it should be created
  bari_cache_dir(temp_cache)
  expect_true(dir.exists(temp_cache))

  # Clean up
  options("tidybari.cache_dir" = NULL)
  unlink(temp_cache, recursive = TRUE)
})

test_that(".cache_path returns a string ending in the filename", {
  path <- tidybari:::.cache_path("10.7910/DVN/XTEJRE", "911.Ecometrics.CT.2020.csv")

  expect_type(path, "character")
  expect_true(grepl("911\\.Ecometrics\\.CT\\.2020\\.csv$", path))
  expect_true(grepl("10_7910_DVN_XTEJRE", path))
})

test_that(".cache_path sanitizes DOI correctly", {
  path <- tidybari:::.cache_path("10.7910/DVN/XTEJRE", "test.csv")

  # Should not contain "/" or "." from the DOI (except in the filename)
  filename <- basename(path)
  expect_false(grepl("/", filename))

  # Should contain sanitized DOI
  expect_true(grepl("10_7910_DVN_XTEJRE", filename))
})

test_that("bari_cache_clear runs without error on empty cache", {
  # Set up a temporary empty cache
  temp_cache <- tempfile("tidybari_test_cache")
  dir.create(temp_cache)
  bari_cache_dir(temp_cache)

  # Should run without error
  expect_message(result <- bari_cache_clear(), "empty")
  expect_equal(result, 0)

  # Clean up
  options("tidybari.cache_dir" = NULL)
  unlink(temp_cache, recursive = TRUE)
})

test_that("bari_cache_clear removes files from cache", {
  # Set up a temporary cache with some files
  temp_cache <- tempfile("tidybari_test_cache")
  dir.create(temp_cache)
  bari_cache_dir(temp_cache)

  # Create some dummy files
  file.create(file.path(temp_cache, "file1.csv"))
  file.create(file.path(temp_cache, "file2.csv"))

  expect_equal(length(list.files(temp_cache)), 2)

  # Clear cache
  result <- bari_cache_clear()

  expect_equal(result, 2)
  expect_equal(length(list.files(temp_cache)), 0)

  # Clean up
  options("tidybari.cache_dir" = NULL)
  unlink(temp_cache, recursive = TRUE)
})

test_that("bari_cache_clear handles non-existent cache directory", {
  # Set cache to a non-existent directory
  temp_cache <- tempfile("tidybari_test_cache_nonexistent")
  options("tidybari.cache_dir" = temp_cache)

  # bari_cache_clear creates the directory if it doesn't exist (via bari_cache_dir())
  # So it should show "empty" message instead of "does not exist"
  result <- bari_cache_clear()
  expect_equal(result, 0)

  # Clean up
  options("tidybari.cache_dir" = NULL)
  if (dir.exists(temp_cache)) unlink(temp_cache, recursive = TRUE)
})
