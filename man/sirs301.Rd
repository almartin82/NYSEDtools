% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sirs301.R
\name{sirs301}
\alias{sirs301}
\title{Create a sirs301 object}
\usage{
sirs301(csvs, cohort_kind, roster, verbose, ...)
}
\arguments{
\item{csvs}{data frame of sirs 301 exports from New York's L2RPT - eg output of
sirs301_import_csvs}

\item{cohort_kind}{should we name cohorts by their college entry
or college graduation year?}

\item{roster}{data frame, with additional student demographic information.
if NA (default), this is ignored.}

\item{verbose}{should sirs301 print status updates?  default is FALSE.}

\item{...}{additional arguments to pass to constructor functions}
}
\description{
\code{sirs301} creates a sirs301 object, enabling analysis and reporting.
}
