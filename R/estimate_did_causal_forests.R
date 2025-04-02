#' Estimate Difference-in-Difference Causal Forests for Long Format Data
#'
#' This function computes the difference outcome
#' \deqn{Z_{it} = Y_{it} - Y_{ib}}
#' for each time period \( t \) (using base period \( b \)) and estimates a causal forest
#' using the grf package on \((Z, W, X)\). Y is assumed to be in long format. Therefore, you
#' must provide the corresponding `time` and `id` vectors. It is required that every unit
#' (as identified by `id`) has an observation in the base period \( b \).
#'
#' Additional arguments (...) are passed directly to the call to `grf::causal_forest`.
#'
#' @param Y A numeric vector of the outcome variable.
#' @param W A vector of treatment indicators (one per unit).
#' @param X A numeric matrix or data frame of features that vary only in the cross-sectional dimension (one row per unit).
#' @param b The value in the `time` vector corresponding to the base period.
#' @param time A vector indicating the time period for each observation in Y.
#' @param id A vector indicating the unit identifier for each observation in Y.
#' @param ... Additional arguments to be forwarded to `grf::causal_forest`.
#'
#' @return A list of causal forest objects (one for each time period other than the base period).
#' @import grf
#' @examples
#' estimate_DiDCF(example_data$Y,
#'                example_data$t_indicator[example_data$period==1],
#'                as.data.frame(model.matrix(~.,data=example_data[example_data$period==1,c("x_1","x_2")])),
#'                1,
#'                data$period,
#'                data$unit_id)
#' @export
estimate_DiDCF <- function(Y, W, X, b, time, id, ...) {

  if (!requireNamespace("grf", quietly = TRUE)) {
    stop("The package 'grf' is required but not installed. Please install it using install.packages('grf').")
  }

  # Check that Y, time, and id are vectors of equal length
  if (!is.vector(Y) || !is.vector(time) || !is.vector(id)) {
    stop("Y, time, and id must all be vectors.")
  }
  if (length(Y) != length(time) || length(Y) != length(id)) {
    stop("Y, time, and id must be of equal length.")
  }

  # Create a long-format data frame
  data_long <- data.frame(id = id, time = time, Y = Y)

  # Check that every unique unit has an observation in the base period
  all_units <- unique(data_long$id)
  base_units <- unique(data_long$id[data_long$time == b])
  if (length(all_units) != length(base_units)) {
    stop("Not every unit has a base period observation. Each unit must be observed in the base period.")
  }

  # Get unique units with base period data (this should now equal all_units)
  unique_units <- base_units

  # Ensure that treatment (W) and features (X) match the unique units
  if (length(W) != length(unique_units) || nrow(X) != length(unique_units)) {
    stop("The number of units in W and rows in X must equal the number of unique units with base period observations in Y.")
  }

  forests <- list()
  # Get all time periods except the base period, sorted for consistency
  time_periods <- sort(unique(data_long$time))
  time_periods <- time_periods[time_periods != b]

  for (t in time_periods) {
    # Select observations for the current time period
    current_data <- data_long[data_long$time == t, ]

    # Merge with base period data to get Y_base for each unit
    merged_data <- merge(current_data, data_long[data_long$time == b, c("id", "Y")],
                         by = "id", suffixes = c("", "_base"))

    # Compute the difference outcome
    merged_data$Z <- merged_data$Y - merged_data$Y_base

    # Align ordering with unique_units (assumed to match the order of W and X)
    order_index <- match(merged_data$id, unique_units)
    valid <- !is.na(order_index)
    if (sum(valid) == 0) {
      warning(paste("No matching units found for time period", t))
      next
    }
    merged_data <- merged_data[valid, ]
    order_index <- order_index[valid]

    # Fit the causal forest, passing any additional arguments via ...
    cf <- grf::causal_forest(X[order_index, , drop = FALSE],
                             merged_data$Z,
                             W[order_index],
                             ...)

    forests[[paste("DiDCF", as.character(t), sep = "_")]] <- cf
  }

  return(forests)
}
