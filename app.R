library(shiny)
library(raster)
library(leaflet)

LINK1 = Sys.getenv("LINK1")

source("testhelper.R")
ic = raster(paste0('viscurl/', LINK1))

ui = fluidPage(
  titlePanel("Irrecoverable Carbon in Wetlands"),
  sidebarLayout(
    sidebarPanel(
      fileInput("area", 
                label="Upload shapefile",
                multiple = TRUE,
                accept = c('.shp','.dbf','.sbn','.sbx','.shx','.prj'))
    ),
      mainPanel(
        leafletOutput("icinarea")
    )
  )
)

server = function(input, output) {
  map <- reactive({
    req(input$area)
    shpdf <- input$area
    tempdirname <- dirname(shpdf$datapath[1])
    for (i in 1:nrow(shpdf)) {
      file.rename(
        shpdf$datapath[i],
        paste0(tempdirname, "/", shpdf$name[i])
      )
    }
    map <- shapefile(paste(tempdirname,
                           shpdf$name[grep(pattern = "*.shp$", shpdf$name)],
                           sep = "/"
    ))
    map
  })
  
  output$icinarea = renderLeaflet({
    if (is.null(map())) {
      return(NULL)
    }
    map = map()
    icinarea = clipping(ic, map)
    leaflet() %>% 
      addTiles() %>% 
      addRasterImage(icinarea)
  })
}

shinyApp(ui=ui, server=server)

