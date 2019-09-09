## setup
library(googleAuthR)
library(googleAnalyticsR)
require(devtools)
remotes::install_github("MarkEdmondson1234/googleAuthR", ref = "paging")
remotes::install_github("MarkEdmondson1234/googleAnalyticsR", ref = "paging")

Sys.setenv(GAR_CLIENT_JSON = "auth/offline_creds.json")
Sys.setenv(GAR_CLIENT_WEB_JSON = "auth/web_creds.json")
gar_set_client(scopes = c("https://www.googleapis.com/auth/analytics.readonly"))


auth <- callModule(googleAuth_js, "authApp")

## This should send you to your browser to authenticate your email. 
# Authenticate with an email that has access to the 
# Google Analytics View you want to use.
ga_auth()

## get your accounts
account_list <- ga_account_list()

## account_list will have a column called "viewId"
account_list$viewId

## View account_list and pick the viewId you want to extract data from. 
ga_id <- 61593498

## simple query to test connection

segment_for_call <- "gaid::-5"

## make the v3 segment object in the v4 segment object:
seg_obj <- segment_ga4("Organic Traffic", segment_id = segment_for_call)


google_analytics(ga_id,
                 date_range = c("2017-01-01", "2017-03-01"),
                 metrics = "sessions",
                 segments=seg_obj,
                 dimensions = "date")


segments <- ga_segment_list() 
segments[["name"]]

# test <- get_all_segments()

get_all_segments <- function(){
  
  url <- "https://www.googleapis.com/analytics/v3/management/segments"
  
  segs <- googleAuthR::gar_api_generator(baseURI = url,
                                         http_header = "GET",
                                         data_parse_function = function(x) x)
  req <- segs()
  
  ## page through list if necessary
  if(req$totalResults > 1000){
    
    nl <- req$nextLink
    
    segs2 <- googleAuthR::gar_api_generator(baseURI = url,
                                            http_header = "GET",
                                            pars_args = c(list(`start-index` = 1001)),
                                            data_parse_function = function(x) x)
    req2 <- segs2()
    
    req_all <- rbind(req$items, req2$items)
  }else{
    req_all <- req
  }
  
  req_all
  
}