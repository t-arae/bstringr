
#' Reverse bstr sequence
#' @inheritParams class_bstr
#' @export
#' @name reverse
#' @examples
#' temp <- bstr_rand_seq(2, 6, seed = 1)
#' c(temp, reverse = bstr_reverse(temp))
#'
bstr_reverse <- function(bstrobj) {
  bstrobj <- as_bstr(bstrobj)
  at <- attributes(bstrobj)

  bstrobj <- stringi::stri_reverse(bstrobj)

  attributes(bstrobj) <- at
  bstrobj
}

