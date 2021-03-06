
#' Calculate the vector volume for In-Fusion reaction
#' @param seq_i DNA sequence of insertion
#' @param seq_v DNA sequence of vector
#' @param conc_i DNA concentration (ng/uL) of purified insertion
#' @param conc_v DNA concentration (ng/uL) of purified vector
#' @param uL_i Supplied volume (uL) of purified insertion
#' @param ratio_i Molecular ratio of insertion
#' @param ratio_v Molecular ratio of vector
#' @export
#' @examples
#' calc_InFusion_vector_volume(
#'   seq_i = dstr_rand_seq(1, 1000, seed = 1),
#'   seq_v = dstr_rand_seq(1, 5000, seed = 1),
#'   conc_i = 5, conc_v = 30,
#'   uL_i = 3
#' )
#'
calc_InFusion_vector_volume <-
  function(seq_i, seq_v, conc_i, conc_v, uL_i, ratio_i = 2, ratio_v = 1) {
    info_i <- dstr(seq_i, "insert") %>% calc_mw_dsDNA()
    info_v <- dstr(seq_v, "vector") %>% calc_mw_dsDNA()

    ng_i <- conc_i * uL_i
    nmol_i <- ng_i / (info_i$applox_MW * 10^-9)

    nmol_v <- nmol_i * (ratio_v / ratio_i)
    ng_v <- nmol_v * info_v$applox_MW * 10^-9
    uL_v <- ng_v / conc_v

    dplyr::bind_rows(info_i, info_v) %>%
      dplyr::bind_cols(
        tibble::tibble(
          conc = c(conc_i, conc_v),
          sup_uL = c(uL_i, uL_v),
          sup_ng = c(ng_i, ng_v),
          sup_nmol = c(nmol_i, nmol_v)
        )
    ) %>%
      dplyr::select(-seq)
  }

#' Calculate the insert volume for In-Fusion reaction
#' @inheritParams calc_InFusion_vector_volume
#' @param uL_v Supplied volume (uL) of purified insertion
#' @export
#' @examples
#' calc_InFusion_insert_volume(
#'   seq_i = dstr_rand_seq(1, 1000, seed = 1),
#'   seq_v = dstr_rand_seq(1, 5000, seed = 1),
#'   conc_i = 5, conc_v = 30,
#'   uL_v = 1.25
#' )
#'
calc_InFusion_insert_volume <-
  function(seq_i, seq_v, conc_i, conc_v, uL_v, ratio_i = 2, ratio_v = 1) {
    info_i <- dstr(seq_i, "insert") %>% calc_mw_dsDNA()
    info_v <- dstr(seq_v, "vector") %>% calc_mw_dsDNA()

    ng_v <- conc_v * uL_v
    nmol_v <- ng_v / (info_v$applox_MW * 10^-9)

    nmol_i <- nmol_v * (ratio_i / ratio_v)
    ng_i <- nmol_i * info_i$applox_MW * 10^-9
    uL_i <- ng_i / conc_i

    dplyr::bind_rows(info_i, info_v) %>%
      dplyr::bind_cols(
        tibble::tibble(
          conc = c(conc_i, conc_v),
          sup_uL = c(uL_i, uL_v),
          sup_ng = c(ng_i, ng_v),
          sup_nmol = c(nmol_i, nmol_v)
        )
    ) %>%
      dplyr::select(-seq)
  }
