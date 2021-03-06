# nocov start
replace_fn_names <- function(fn, replace = list()){
  rec_fn <- function(cl) {
    if (!is_call(cl)) {
      return(cl)
    }
    if (any(repl_fn <- names(replace) %in% call_name(cl))) {
      cl[[1]] <- replace[[repl_fn]]
    }
    as.call(append(cl[[1]], purrr::map(as.list(cl[-1]), rec_fn)))
  }
  body(fn) <- rec_fn(body(fn))
  fn
}
# nocov end

#' Sliding window calculation
#'
#' Rolling window with overlapping observations:
#' * `slide()` always returns a list.
#' * `slide_lgl()`, `slide_int()`, `slide_dbl()`, `slide_chr()` use the same
#' arguments as `slide()`, but return vectors of the corresponding type.
#' * `slide_dfr()` `slide_dfc()` return data frames using row-binding & column-binding.
#'
#' @param .x An atomic vector. Instead [lslide] takes list & data.frame.
#' @inheritParams purrr::map
#' @param .size An integer for window size.
#' @param .fill A single value or data frame to replace `NA`.
#'
#' @rdname slide
#' @export
#' @seealso
#' * [slide2], [pslide]
#' * [tile] for tiling window without overlapping observations
#' * [stretch] for expanding more observations
#' @details The `slide()` function attempts to tackle more general problems using
#' the purrr-like syntax. For some specialist functions like `mean` and `sum`,
#' you may like to check out for
#' [RcppRoll](https://CRAN.R-project.org/package=RcppRoll) for faster performance.
#'
#' @examples
#' # sliding through a vector ----
#' x <- 1:10
#' slide_dbl(x, mean, .size = 3)
#' slide_dbl(x, mean, .size = 3, .fill = 0)
#' slide_lgl(x, ~ mean(.) > 1, .size = 3)
#' @export
slide <- function(.x, .f, ..., .size = 1, .fill = NA) {
  if (is_list(.x)) {
    lst_x <- lslider(.x, .size = .size) %>% 
      purrr::modify_depth(1, unlist2)
  } else {
    lst_x <- slider(.x, .size = .size)
  }
  c(rep_len(.fill, .size - 1), purrr::map(lst_x, .f, ...))
}

#' @evalRd paste0('\\alias{slide_', c("lgl", "chr", "int", "dbl"), '}')
#' @name slide
#' @rdname slide
#' @exportPattern ^slide_
for(type in c("lgl", "chr", "int", "dbl")){
  assign(
    paste0("slide_", type),
    replace_fn_names(slide, list(map = sym(paste0("map_", type))))
  )
}

#' @rdname slide
#' @export
slide_dfr <- function(.x, .f, ..., .size = 1, .fill = NA, .id = NULL) {
  out <- slide(.x, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, .id = .id)
}

#' @rdname slide
#' @export
slide_dfc <- function(.x, .f, ..., .size = 1, .fill = NA) {
  out <- slide(.x, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, byrow = FALSE)
}

#' Sliding window calculation over multiple inputs simultaneously
#'
#' Rolling window with overlapping observations:
#' * `slide2()` and `pslide()` always returns a list.
#' * `slide2_lgl()`, `slide2_int()`, `slide2_dbl()`, `slide2_chr()` use the same
#' arguments as `slide2()`, but return vectors of the corresponding type.
#' * `slide2_dfr()` `slide2_dfc()` return data frames using row-binding & column-binding.
#'
#' @param .x,.y An atomic vector.
#' @inheritParams slide
#'
#' @rdname slide2
#' @export
#' @seealso
#' * [slide]
#' * [tile2] for tiling window without overlapping observations
#' * [stretch2] for expanding more observations
#'
#' @export
#' @examples
#' x <- 1:10
#' y <- 10:1
#' z <- x * 2
#' slide2_dbl(x, y, cor, .size = 3)
#' slide2(x, y, cor, .size = 3)
#' pslide_dbl(list(x, y, z), sum, .size = 3)
slide2 <- function(.x, .y, .f, ..., .size = 1, .fill = NA) {
  if (is_list(.x)) {
    lst <- lslider(list(.x, .y), .size = .size) %>% 
      purrr::modify_depth(2, unlist2)
  } else {
    lst <- slider(list(.x, .y), .size = .size)
  }
  c(rep_len(.fill, .size - 1), purrr::map2(lst[[1]], lst[[2]], .f = .f, ...))
}

#' @evalRd paste0('\\alias{slide2_', c("lgl", "chr", "int", "dbl"), '}')
#' @name slide2
#' @rdname slide2
#' @exportPattern ^slide2_
for(type in c("lgl", "chr", "int", "dbl")){
  assign(
    paste0("slide2_", type),
    replace_fn_names(slide2, list(map2 = sym(paste0("map2_", type))))
  )
}

#' @rdname slide2
#' @export
slide2_dfr <- function(.x, .y, .f, ..., .size = 1, .fill = NA, .id = NULL) {
  out <- slide2(.x, .y, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, .id = .id)
}

#' @rdname slide2
#' @export
slide2_dfc <- function(.x, .y, .f, ..., .size = 1, .fill = NA) {
  out <- slide2(.x, .y, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, byrow = FALSE)
}

#' @rdname slide2
#' @inheritParams purrr::pmap
#' @export
pslide <- function(.l, .f, ..., .size = 1, .fill = NA) {
  if (is.data.frame(.l)) {
    .l <- as.list(.l)
  }
  depth <- purrr::vec_depth(.l)
  if (depth == 2) {
    lst <- slider(.l, .size = .size)
  } else if (depth == 3) {
    lst <- lslider(.l, .size = .size) %>% 
      purrr::modify_depth(2, unlist2)
  }
  c(rep_len(.fill, .size - 1), purrr::pmap(lst, .f, ...))
}

#' @evalRd paste0('\\alias{pslide_', c("lgl", "chr", "int", "dbl"), '}')
#' @name pslide
#' @rdname slide2
#' @exportPattern ^pslide_
for(type in c("lgl", "chr", "int", "dbl")){
  assign(
    paste0("pslide_", type),
    replace_fn_names(pslide, list(pmap = sym(paste0("pmap_", type))))
  )
}

#' @rdname slide2
#' @export
pslide_dfr <- function(.l, .f, ..., .size = 1, .fill = NA, .id = NULL) {
  out <- pslide(.l, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, .id = .id)
}

#' @rdname slide2
#' @export
#' @examples
#' \dontrun{
#' jan <- pedestrian %>%
#'   filter(Date <= as.Date("2015-01-31")) %>%
#'   split_by(Sensor)
#' # returns a data frame of fitted values and residuals for each sensor,
#' # and then combines
#' my_diag <- function(...) {
#'   l <- list(...)
#'   fit <- lm(l$Count ~ l$Time)
#'   data.frame(fitted = fitted(fit), resid = residuals(fit))
#' }
#' diag_jan <- jan %>%
#'   purrr::map_dfr(
#'     ~ pslide_dfr(., my_diag, .size = 48)
#'   )
#' }
pslide_dfc <- function(.l, .f, ..., .size = 1, .fill = NA) {
  out <- pslide(.l, .f = .f, ..., .size = .size, .fill = .fill)
  new_data_frame(out, .size, .fill = .fill, byrow = FALSE)
}

#' Splits the input to a list according to the rolling window .size.
#'
#' @param ... Objects to be splitted.
#' @inheritParams slide
#' @rdname slider
#' @export
#' @examples
#' x <- 1:10
#' slider(x, .size = 3)
#' y <- 10:1
#' slider(x, y, .size = 3)
slider <- function(.x, .size = 1) {
  if (is_atomic(.x)) {
    return(slider_base(.x, .size = .size))
  } else {
    return(purrr::map(.x, ~ slider_base(., .size = .size)))
  }
}

# if .x is a list, slide over elements with this list
# if .x is a list of lists, slide over each nested list simultaneously
lslider <- function(.x, .size = 1) {
  depth <- purrr::vec_depth(.x)
  if (depth == 1) {
    return(slider(.x, .size = .size))
  } else if (depth == 2) { # a list
    if (is.data.frame(.x)) .x <- as.list(.x)
    return(slider_base(.x, .size = .size))
  } else if (depth == 3) { # a list of lists
    df_lgl <- purrr::map_lgl(.x, is.data.frame)
    if (any(df_lgl)) {
      .x[df_lgl] <- purrr::map(.x[df_lgl], as.list)
    }
    return(purrr::map(.x, ~ slider_base(., .size = .size)))
  } else {
    abort(".x` must not be deeper than 3.")
  }
}

slider_base <- function(x, .size = 1) {
  bad_window_function(x, .size)
  len_x <- NROW(x)
  lst_idx <- seq_len(len_x - .size + 1)
  if (is_atomic(x)) {
    return(purrr::map(lst_idx, ~ x[(.):(. + .size - 1)]))
  }
  purrr::map(lst_idx, ~ x[(.):(. + .size - 1)])
}

bad_window_function <- function(.x, .size) {
  if (purrr::vec_depth(.x) > 3) {
    abort("`.x` must not be a list of lists.")
  }
  if (!is_bare_numeric(.size, n = 1) || .size < 1) {
    abort("`.size` must be a positive integer.")
  }
}

incr <- function(init, size) {
  init
  function() {
    init <<- init + size
    init
  }
}

unlist2 <- function(x) {
  unlist(x, recursive = FALSE, use.names = FALSE)
}

new_data_frame <- function(x, .size, .fill = NA, .id = NULL, byrow = TRUE) {
  lst <- new_list_along(x[[.size]])
  lst[] <- .fill
  lst <- rep_len(list(lst), .size - 1)
  if (byrow) {
    return(dplyr::bind_rows(lst, x[-seq_len(.size - 1)], .id = .id))
  }
  dplyr::bind_cols(lst, x[-seq_len(.size - 1)])
}
