#installing the required package
install.packages("ggplot2")
install.packages("ggmap")
install.packages("tidyverse")
install.packages("readxl")
install.packages("rgdal")
install.packages("magrittr")
install.packages("leaflet")
install.packages("htmltools")

#required library
library(ggplot2)
library(ggmap)
library(tidyverse)
library(dplyr)
library(rgdal)
library(leaflet)
library(htmltools)


#Reading csv data regarding COVID- 19 information in massachusetts
mapData = read_csv("/Users/ayshazenabkenza/Desktop/Web_Analytics/MyData3.csv")

#Preparing the address section to generate the geocode
mapData$address = paste(mapData$CTYNAME,mapData$STNAME)

#API for google maps  
register_google(key = "Enter your API")
has_google_key()

#Generation longitude and latitude for each address
geocodes <- geocode(mapData$address,source = "google")
mapData$lon <- geocodes$lon
mapData$lat <- geocodes$lat

#Storing the data into csvfile
write_csv(mapData,"/Users/ayshazenabkenza/Desktop/Web_Analytics/MyData3.csv")
#------------------------------------------------------------------------------------------------------------------------#

mapData = read_csv("/Users/ayshazenabkenza/Desktop/Web_Analytics/MyData3.csv")

#Reading shapefile for Massachusetts
mapshape <- readOGR("/Users/ayshazenabkenza/Desktop/Web_Analytics/Massachusetts_Counties-shp/Massachusetts_Counties.shp")

#Ordering the county name in the data according to shapefile
mapData <- mapData[order(match(mapshape$COUNTY,mapData$CTYNAME)),]
mapData <- mapData[complete.cases(mapData),]

#Preparing the palette according to Confirmed Cases
bin <- c(50,100,1000,5000,10000,15000,20000,30000)
mappal <- colorBin("Reds",domain = mapData$`NUMBER OF CONFIRMED CASES`,bins = bin)
popup1 <- paste("<span style='color: #7f0000'><strong>Coronavirus Disease 2019 (COVID-19) Cases in MA</strong></span>",
                "<br><span style='color: salmon;'><strong>COUNTY: </strong></span>", 
                 mapData$CTYNAME, 
                 "<br><span style='color: salmon;'><strong>NUMBER OF CONFIRMED CASES: </strong></span>", 
                 mapData$`NUMBER OF CONFIRMED CASES`
)

#Plotting the map
map <- leaflet()%>%
  addProviderTiles(providers$Esri.WorldGrayCanvas)%>%
  setView(-71,42,zoom = 8)%>%
  addPolygons(data = mapshape,
              color = "white",
              weight = 1,
              smoothFactor = 1,
              fillOpacity = 0.8,
              fillColor = mappal(mapData$`NUMBER OF CONFIRMED CASES`),
              label = lapply(popup1, HTML))%>%
  addLegend(title = "Total Cases per County",pal = mappal,
            values = mapData$`NUMBER OF CONFIRMED CASES`,
            opacity = 0.7,
            position = "topright")

map

