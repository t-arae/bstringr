% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bstr_remove.R
\name{remove}
\alias{remove}
\alias{bstr_remove}
\alias{bstr_remove_num}
\alias{bstr_remove_notalpha}
\alias{bstr_remove_gap}
\title{Remove all matched patterns in bstr sequences}
\usage{
bstr_remove(bstrobj, pattern, case_sensitive = FALSE)

bstr_remove_num(bstrobj)

bstr_remove_notalpha(bstrobj)

bstr_remove_gap(bstrobj, gap_chr = "-")
}
\arguments{
\item{bstrobj}{bstr class object or character vector}

\item{pattern}{regex pattern}

\item{case_sensitive}{sensitive to case in pattern (default:FALSE)}

\item{gap_chr}{a gap character}
}
\value{
A bstr object.
}
\description{
Remove all matched patterns in bstr sequences
}
\examples{
temp <- bstr(c("ATGCCCTAG", "aTGCcCtAg"))
c(temp, remove = bstr_remove(temp, "[aT]"))
c(temp, remove = bstr_remove(temp, "aT"))
c(temp, remove = bstr_remove(temp, "aT", TRUE))

bstr_remove_num(bstr("ac12 -xe gg. "))
bstr_remove_notalpha(bstr("ac12 -xe gg. "))
bstr_remove_gap(bstr("ac12 -xe gg. "))

}
