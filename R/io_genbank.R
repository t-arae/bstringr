
#' Read Genbank file
#' @param fpath A genbank file path.
#' @param ucase logical
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' read_genbank(inf)
#'
read_genbank <-
  function(fpath, ucase = F){
    . <- NULL
    gblines <- readr::read_lines(fpath)
    n <- parse_LOCUS_FIELD(gblines) %>% .["LocusName"]
    s <- parse_ORIGIN_FIELD(gblines)
    bstr(s, n, ucase = ucase)
  }

#' Write Genbank file
#' @param x x
#' @param fpath A genbank file path.
#' @export
#' @examples
#' (temp <- dstr_rand_seq(1, 100, seed = 1))
#' write_genbank(temp)
#'
write_genbank <- function(x, fpath) {
  . <- NULL
  name <- names(x)
  name_trunc <- name %>% stringr::str_sub(1, 10)
  len <- bstringr::bstr_length(x)
  Sys.setlocale("LC_TIME", "C")
  today <- format(Sys.Date(), "%Y-%b-%d")
  sequence <- x %>% stringr::str_extract_all(".{1,10}") %>% .[[1]]
  seq_li <- character()
  for(i in seq_along(sequence)) {
    line <- ((i - 1L) %/% 6) + 1
    if((i %% 6) == 1L) {
      seq_li[line] <- paste((i-1)*10+1, sequence[i])
    } else {
      seq_li[line] <- paste(seq_li[line], sequence[i])
    }
  }
  # max_col <- max(nchar(seq_li))
  x <- stringr::str_extract(seq_li[length(seq_li)], "\\d+") %>% nchar
  seq_li <-
    c(
      # stringr::str_pad(seq_li[1:(length(seq_li)-1)], max_col+9, side = "left"),
      stringr::str_pad(seq_li[1:(length(seq_li)-1)], 75L, side = "left"),
      stringr::str_c(paste(rep(" ", 9L-x), collapse = ""),
                     seq_li[length(seq_li)])
    )
  temp <-
    c(
      stringr::str_glue("LOCUS       {name_trunc}        {len} bp ds-DNA     linear       {today}"),
      "DEFINITION  .",
      "ACCESSION",
      "VERSION",
      "SOURCE      .",
      "  ORGANISM  .",
      stringr::str_glue("COMMENT     >{name}"),
      "ORIGIN      ",
      seq_li,
      "//"
    )
  if(missing(fpath)){
    return(temp)
  }else{
    readr::write_lines(temp, fpath)
  }
}

#' Create and Insert FEATURE field to a Genbank file
#' @name gb_feature
#' @param feature_key string
#' @param loc_start integer or string
#' @param loc_end integer or string
#' @param locus_tag string
#' @param feature_key string
#' @param gb_line character vector of a Genbank file.
#' @param features line of FEATURES, constructed by create_FEATURE() and add_FEATURES_FIELD_HEADER()
#' @param ... ...
#' @export
#' @examples
#' create_FEATURE("CDS", 10, 100, "CDS 1")
#'
#' f <-
#'   create_FEATURE("CDS", 10, 100, "CDS 1") %>%
#'   add_FEATURES_FIELD_HEADER()
#' cat(f, sep = "\n")
#'
#' (temp <- dstr_rand_seq(1, 100, seed = 1))
#' write_genbank(temp) %>%
#'   insert_FEATURES(features = f) %>%
#'   cat(sep = "\n")
#'

#' @rdname gb_feature
#' @export
create_FEATURE <- function(feature_key, loc_start, loc_end, locus_tag) {
  feature_key <-
    paste0("     ", stringr::str_pad(feature_key, width = 16, side = "right"))
  c(
    stringr::str_glue('{feature_key}{loc_start}..{loc_end}'),
    stringr::str_glue('                     /locus_tag="{locus_tag}"')
  )
}

#' @rdname gb_feature
#' @export
add_FEATURES_FIELD_HEADER <- function(...) {
  header <-
    paste0(
      stringr::str_pad("FEATURES", width = 21, side = "right"),
      "Location/Qualifiers"
    )
  body <- c(...)
  c(header, body)
}

#' @rdname gb_feature
#' @export
insert_FEATURES <- function(gb_line, features) {
  gb_line <- as.character(gb_line)
  origin_ln <- stringr::str_which(gb_line, "^ORIGIN      $")
  c(
    gb_line[1:(origin_ln-1L)],
    features,
    gb_line[origin_ln:length(gb_line)]
  )
}

#' Parse Genbank file LOCUS FIELD
#' @param gb_line character vector of a Genbank file.
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' readLines(inf) %>% parse_LOCUS_FIELD()
#'
parse_LOCUS_FIELD <-
  function(gb_line) {
    . <- NULL
    # Get a LOCUS FIELD line
    locus_field_line <-
      stringr::str_detect(gb_line, "^LOCUS       ") %>%
      {gb_line[.]}

    # This closure removes the matched string and its left or right side of
    # characters from string of "locus_field_line".
    f <- function(chr, side = c("l", "r")) {
      if(!is.na(chr)) {
        if(side == "l")
          temp <- stringr::str_remove(locus_field_line, paste0(".*", chr))
        if(side == "r")
          temp <- stringr::str_remove(locus_field_line, paste0(chr, ".*"))
        locus_field_line <<- temp
      }
    }

    locus_name <-
      stringr::str_remove(locus_field_line, "^LOCUS       ") %>%
      stringr::str_sub(start = 1, end = 10)
    f(locus_name, "l")

    sequence_length <-
      stringr::str_extract(locus_field_line, "\\d+ bp")
    f(sequence_length, "l")

    modification_date <-
      stringr::str_extract(locus_field_line, "\\s\\S+$") %>%
      stringr::str_trim("both")
    f(modification_date, "r")

    genbank_division <-
      stringr::str_trim(locus_field_line, "both") %>%
      stringr::str_extract("[A-Z]{3}$")
    f(genbank_division, "r")

    molecule_type <- stringr::str_trim(locus_field_line, "both")

    return(c(
      LocusName = locus_name,
      SequenceLength = sequence_length,
      MoleculeType = molecule_type,
      GenbankDivision = genbank_division,
      ModificationDate = modification_date
    ))
  }

include_blank_header_line <-
  function(gb_line, header) {
    if(is.logical(header)) header <- which(header)

    blank_lines <- stringr::str_detect(gb_line, "^            ")
    num_blank <- 0
    for (i in blank_lines[(header + 1L):length(blank_lines)]) {
      if(!i) break()
      num_blank <- num_blank + 1
    }
    lines <- rep(FALSE, length(gb_line))
    lines[header:(header + num_blank)] <- TRUE
    lines
  }

#' Parse Genbank file DIFINITION FIELD
#' @param gb_line character vector of a Genbank file.
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' readLines(inf) %>% parse_DEFINITION_FIELD()
#'
parse_DEFINITION_FIELD <-
  function(gb_line) {
    . <- NULL
    # Get DEFINITION FIELD lines
    definition_field_line <-
      stringr::str_detect(gb_line, "^DEFINITION  ") %>%
      include_blank_header_line(gb_line, header = .) %>%
      gb_line[.]

    definition <-
      stringr::str_remove(definition_field_line, "^DEFINITION  ") %>%
      stringr::str_trim("both")
    definition
  }

#' Parse Genbank file ACCESSION FIELD
#' @param gb_line character vector of a Genbank file.
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' readLines(inf) %>% parse_ACCESSION_FIELD()
#'
parse_ACCESSION_FIELD <-
  function(gb_line) {
    . <- NULL
    # Get an ACCESSION FIELD line
    accession_field_line <-
      stringr::str_detect(gb_line, "^ACCESSION   ") %>%
      gb_line[.]

    accession <-
      stringr::str_remove(accession_field_line, "^ACCESSION   ") %>%
      stringr::str_trim("both")
    accession
  }

#' Parse Genbank file VERSION FIELD
#' @param gb_line character vector of a Genbank file.
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' readLines(inf) %>% parse_VERSION_FIELD()
#'
parse_VERSION_FIELD <-
  function(gb_line) {
    . <- NULL
    # Get a VERSION FIELD line
    version_field_line <-
      stringr::str_detect(gb_line, "^VERSION     ") %>%
      gb_line[.]

    version <-
      stringr::str_remove(version_field_line, "^VERSION     ") %>%
      stringr::str_trim("both")
    version
  }

#' Parse Genbank file ORIGIN FIELD
#' @param gb_line character vector of a Genbank file.
#' @export
#' @examples
#' inf <- system.file("extdata", "sample.gb", package = "bstringr")
#' readLines(inf) %>% parse_ORIGIN_FIELD()
#'
parse_ORIGIN_FIELD <-
  function(gb_line) {
    . <- NULL
    # Get ORIGIN FIELD lines
    origin_field_line <-
      stringr::str_which(gb_line, "^ORIGIN") %>%
      {gb_line[.:length(gb_line)]}

    origin_field_line %>%
      {.[!stringr::str_detect(., "^ORIGIN")]} %>%
      {.[!stringr::str_detect(., "//")]} %>%
      stringr::str_remove_all("[\\s\\d]") %>%
      stringr::str_c(collapse = "")
  }

