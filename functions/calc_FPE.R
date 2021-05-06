# this script calculate forest production efficiency as in Collalti et al. 2020
calc_fpe <- function(MAT,age,TAP,lat) {
  0.19 + 0.0060*MAT + (-0.00038)*age + 6.8E-5*TAP + 0.0039*abs(lat)
}