library(jsonlite)
library(leaflet)
# From http://data.okfn.org/data/datasets/geo-boundaries-world-110m
geojson <- readLines(file("https://raw.githubusercontent.com/datasets/geo-boundaries-world-110m/master/countries.geojson"), warn = FALSE) %>%
  paste(collapse = "\n") %>%
  fromJSON(simplifyVector = FALSE)

# Default styles for all features
geojson$style = list(
  weight = 1,
  color = "#555555",
  opacity = 1,
  fillOpacity = 0.8
)

# Gather GDP estimate from all countries
gdp_md_est <- sapply(geojson$features, function(feat) {
  feat$properties$gdp_md_est
})
# Gather population estimate from all countries
pop_est <- sapply(geojson$features, function(feat) {
  max(1, feat$properties$pop_est)
})

# Color by per-capita GDP using quantiles
pal <- colorQuantile("Greens", gdp_md_est / pop_est)
# Add a properties$style list to each feature
geojson$features <- lapply(geojson$features, function(feat) {
  feat$properties$style <- list(
    fillColor = pal(
      feat$properties$gdp_md_est / max(1, feat$properties$pop_est)
    )
  )
  feat$properties$popup = paste(rep(letters,3), sep = "", collapse = "")
  #
  feat$properties$popupOptions = list(maxWidth = 1000, keepInView = TRUE)
  feat
})

#---------------------------------------------------------------------------------
# Adding popups
#---------------------------------------------------------------------------------

# Add the now-styled GeoJSON object to the map
leaflet() %>% addGeoJSON(geojson)

