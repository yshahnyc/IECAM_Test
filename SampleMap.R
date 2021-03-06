#load libraries
library(tidyverse)
library(leaflet)
library(rgdal)
library(BAMMtools)

#prepare data
demodata_raw <- read.csv("iecamdata.csv")
demodata_raw$Counties <- str_to_upper(demodata_raw$Counties)

Illinois_map <- readOGR("Shapefile/IL_BNDY_County_Py.shp")
Merge_CountyPop <- subset(merge(Illinois_map@data, 
                               demodata_raw, 
                               by.x = "COUNTY_NAM", 
                               by.y = "Counties", 
                               all = TRUE, 
                               sort = FALSE))
Illinois_map@data <- Merge_CountyPop

#here define which variable you want to map
Ill_var <- Illinois_map$X5.years.and.under

#define bins for colour palette
Ill_bins <- getJenksBreaks(Ill_var, 9, subset = NULL)

pal <- colorBin("Blues", 
               domain = Ill_var, 
               bins = Ill_bins,
               pretty = TRUE)
#define labels
Ill_labels <- sprintf("Under 5 Population <br/><strong>%s</strong>:%s", Illinois_map$COUNTY_NAM, prettyNum(Ill_var, big.mark = ",")) %>%
  lapply(htmltools::HTML)
Ill_labelOpts <- labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),
                             textsize = "15px",
                             direction = "auto")
Ill_highlights <- highlightOptions(
  weight = 5,
  color = "white",
  dashArray = "",
  fillOpacity = 0.7,
  bringToFront = TRUE)

#load everything into leaflet
viewmap <- leaflet(data = Illinois_map) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(fillColor = ~pal(Ill_var),
              weight = 2,
              opacity = 1,
              color = "Black",
              dashArray = "3",
              fillOpacity = 0.7,
              highlightOptions = Ill_highlights,
              label = Ill_labels,
              labelOptions = Ill_labelOpts) %>%
  addLegend(pal = pal, values = ~Ill_var, opacity = 0.7, title = NULL,
            position = "bottomright") %>%
  setMaxBounds(-91.51352, 36.96997, -87.49521, 42.50835)

viewmap

