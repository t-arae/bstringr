% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bstr_extract.R
\name{bstr_extract}
\alias{bstr_extract}
\title{Extract matching patterns from a bstr object}
\usage{
bstr_extract(bstrobj, pattern)
}
\arguments{
\item{bstrobj}{bstr class object or character vector}

\item{pattern}{regex pattern}
}
\description{
Extract matching patterns from a bstr object
}
\examples{
bstr_locate(c("ABCDE"), c("A", "C"))
bstr_extract(c("ABCDE"), c("A", "C"))

bstr_locate(c("ABCDE", "BC"), c("A", "C"))
bstr_extract(c("ABCDE", "BC"), c("A", "C"))

}
