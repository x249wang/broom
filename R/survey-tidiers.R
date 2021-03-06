#' @templateVar class svyolr
#' @template title_desc_tidy
#' 
#' @param x A `svyolr` object returned from [survey::svyolr()].
#' @inherit tidy.polr params details
#' 
#' @export
#' 
#' @examples
#' 
#' library(MASS)
#' 
#' fit <- polr(Sat ~ Infl + Type + Cont, weights = Freq, data = housing)
#' 
#' tidy(fit, exponentiate = TRUE, conf.int = TRUE)
#' glance(fit)
#' 
#' @evalRd return_tidy(regression = TRUE)
#'
#' @aliases svyolr_tidiers
#' @export
#' @seealso [tidy], [survey::svyolr()]
#' @family ordinal tidiers
tidy.svyolr <- tidy.polr

#' @templateVar class svyolr
#' @template title_desc_glance
#' 
#' @inherit tidy.svyolr params examples
#'
#' @evalRd return_glance(
#'   "edf",
#'   "df.residual",
#'   "nobs"
#' )
#'
#' @export
#' @seealso [tidy], [survey::svyolr()]
#' @family ordinal tidiers
glance.svyolr <- function(x, ...) {
  tibble(
    edf = x$edf,
    df.residual = stats::df.residual(x),
    nobs = stats::nobs(x)
  )
}

#' @templateVar class svyglm
#' @template title_desc_tidy_lm_wrapper
#'
#' @param x A `svyglm` object returned from [survey::svyglm()].
#'
#' @export
#' @family lm tidiers
#' @seealso [survey::svyglm()], [stats::glm()]
#' 
tidy.svyglm <- function(x, conf.int = FALSE, conf.level = .95,
                        exponentiate = FALSE, ...) {
  
  s <- survey:::summary.svyglm(x)
  ret <- tidy.summary.lm(s)
  
  # TODO: drop process_lm() dependence
  process_lm(ret, x,
             conf.int = conf.int, conf.level = conf.level,
             exponentiate = exponentiate
  )
  
}

#' @templateVar class svyglm
#' @template title_desc_glance
#'
#' @param x A `svyglm` object returned from [survey::svyglm()].
#' @param maximal A `svyglm` object corresponding to the maximal
#'   model against which to compute the BIC. See Lumley and Scott
#'   (2015) for details. Defaults to `x`, which is equivalent
#'   to not using a maximal model.
#'   
#' @template param_unused_dots
#'
#' @evalRd return_glance(
#'   "null.deviance",
#'   "df.null",
#'   "AIC",
#'   "BIC",
#'   "deviance",
#'   "df.residual"
#' )
#'
#' @examples
#'
#' library(survey)
#' 
#' set.seed(123)
#' data(api)
#' 
#' # survey design
#' dstrat <-
#'   svydesign(
#'     id =  ~ 1,
#'     strata =  ~ stype,
#'     weights =  ~ pw,
#'     data = apistrat,
#'     fpc =  ~ fpc
#'   )
#' 
#' # model
#' m <- survey::svyglm(
#'   formula = sch.wide ~ ell + meals + mobility,
#'   design = dstrat,
#'   family = quasibinomial()
#' )
#' 
#' glance(m)
#'
#' @references Lumley T, Scott A (2015). AIC and BIC for modelling with complex 
#'   survey data. *Journal of Survey Statistics and Methodology*, 3(1).
#'   <https://doi.org/10.1093/jssam/smu021>.
#' 
#' @export
#' @family lm tidiers
#' @seealso [survey::svyglm()], [stats::glm()], [survey::anova.svyglm]
glance.svyglm <- function(x, maximal = x, ...) {

  # NOTES:
  #
  # (1) log-likelihood does not apply (returns deviance instead)
  #   logLik.svyglm() should result in a warning:
  #
  #   > Warning in logLik.svyglm(x) : svyglm not fitted by maximum likelihood.
  #
  # (2) AIC is not always directly computed by svyglm,
  #   e.g. if family = quasibinomial()
  
  tibble(
    null.deviance = x$null.deviance,
    df.null = x$df.null,
    AIC = survey:::AIC.svyglm(x)["AIC"],
    BIC = survey:::dBIC(x, maximal)["BIC"],  # equiv to stats::BIC(x, maximal)
    deviance = x$deviance,
    df.residual = x$df.residual
  )
}
