clipping = function(ic, area) {
  icinarea = mask(crop(ic, extent(area)), area)
  return(icinarea)
}