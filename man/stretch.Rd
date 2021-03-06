% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stretch.R
\name{stretch}
\alias{stretch}
\alias{stretch}
\alias{stretch_dfr}
\alias{stretch_dfc}
\title{Stretching window calculation}
\usage{
stretch(.x, .f, ..., .size = 1, .init = 1)

stretch_dfr(.x, .f, ..., .size = 1, .init = 1, .id = NULL)

stretch_dfc(.x, .f, ..., .size = 1, .init = 1)
}
\arguments{
\item{.x}{An atomic vector. Instead \link{lslide} takes list & data.frame.}

\item{.f}{A function, formula, or atomic vector.

If a \strong{function}, it is used as is.

If a \strong{formula}, e.g. \code{~ .x + 2}, it is converted to a function. There
are three ways to refer to the arguments:
\itemize{
\item For a single argument function, use \code{.}
\item For a two argument function, use \code{.x} and \code{.y}
\item For more arguments, use \code{..1}, \code{..2}, \code{..3} etc
}

This syntax allows you to create very compact anonymous functions.

If \strong{character vector}, \strong{numeric vector}, or \strong{list}, it
is converted to an extractor function. Character vectors index by name
and numeric vectors index by position; use a list to index by position
and name at different levels. Within a list, wrap strings in \code{\link[=get-attr]{get-attr()}}
to extract named attributes. If a component is not present, the value of
\code{.default} will be returned.}

\item{...}{Additional arguments passed on to \code{.f}.}

\item{.size, .init}{An integer for moving and initial window size.}

\item{.id}{If not \code{NULL} a variable with this name will be created
giving either the name or the index of the data frame.}
}
\description{
Fixing an initial window and expanding more observations:
\itemize{
\item \code{stretch()} always returns a list.
\item \code{stretch_lgl()}, \code{stretch_int()}, \code{stretch_dbl()}, \code{stretch_chr()} use the same
arguments as \code{stretch()}, but return vectors of the corresponding type.
\item \code{stretch_dfr()} \code{stretch_dfc()} return data frames using row-binding & column-binding.
}
}
\examples{
x <- 1:10
stretch(x, mean, .init = 3)
stretch_dbl(x, ~ mean(.), .init = 3)
}
\seealso{
\itemize{
\item \link{stretch2}, \link{pstretch}, \link{lstretch}
\item \link{slide} for sliding window with overlapping observations
\item \link{tile} for tiling window without overlapping observations
}
}
\alias{stretch_lgl}
\alias{stretch_chr}
\alias{stretch_dbl}
\alias{stretch_int}
