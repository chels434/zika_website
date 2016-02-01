
# Get the working directory
getwd()
# See what objects (variables) you have attached
ls()
# Removed all objects (variables) you have attached
rm(list = ls())


# Code source: https://github.com/Sobach/SMCourse/blob/715a62f266c3ea28aa729274d61c25f81e6941da/lecture6_snippets.R

# Required libraries:
# RCurl, rjson, ggplot2, RColorBrewer
# If you haven't installed them yet, uncomment and execute this command:
# install.packages(c("RCurl", "rjson", "lubridate", "ggplot2", "RColorBrewer"))
# Loading libraries
library(RCurl)
library(rjson)
library(lubridate)



# Declaring constants
# These are for my Kimono labs APIs, which scrape the websites that public epidemiological updates
api.WHOdon <- 'dbe78bwy'
api.ECDC <- 'a1w6692y'
api.MoSbr <- '9tttjw2g'
api.PAHO <- # no API yet; website blocks it
api.key <- 'DDP9sIpmcX5DLJmLFZILwwknMOoBbAai'


########################################
# WHO Outbreak News
# ======================================
# Constructing URL for last json snapshot
json.url <- paste0('https://www.kimonolabs.com/api/', api.WHOdon, '?apikey=', api.key)

# Loading json as list object
# ssl.verifypeer - for https on Windows
json <- getURL(json.url, .encoding = 'UTF-8',
               .opts = list(ssl.verifypeer = FALSE))
json.data <- fromJSON(json)
str(json.data)


# Parsing JSON to data table
WHOdon <-  data.frame(date=json.data$results$collection1$date.text,
                      siteurl=json.data$results$collection1$url, 
                      site=json.data$results$collection1$api, 
                      title=json.data$results$collection1$title, 
                      link=json.data$results$collection1$date.href)
head(WHOdon)
WHOdon
rm(json.data, json, json.url)


########################################
# ECDC EPidemiological Updates
# ======================================
# Constructing URL for last json snapshot
json.url <- paste0('https://www.kimonolabs.com/api/', api.ECDC, '?apikey=', api.key)

# Loading json as list object
# ssl.verifypeer - for https on Windows
json.file <- getURL(json.url)
json.data <- fromJSON(json.file)



# Parsing JSON
ECDC <-data.frame(date=dmy(json.data$results$collection1$date),
                  siteurl=json.data$results$collection1$url, 
                  site=json.data$name, 
                  title=json.data$results$collection1$title$text, 
                  link=json.data$results$collection1$title$href)
  
head(ECDC)
rm(json.data, json.file, json.url)


########################################
# Ministerio do Saude Brazil Epidemiological Bulletin
# ======================================
# Constructing URL for last json snapshot
json.url <- paste0('https://www.kimonolabs.com/api/', api.MoSbr, '?apikey=', api.key)

# Loading json as list object
# ssl.verifypeer - for https on Windows
json.file <- getURL(json.url)
json.data <- fromJSON(json.file)
str(json.data)
summary(json.data)

# Parsing JSON
MoSbr <- data.frame(siteurl=json.data$results$collection1$url, 
                    site=json.data$name, 
                    title=json.data$results$collection1$title$text, 
                    link=json.data$results$collection1$title$href)
  
  
head(MoSbr)

# Select only the titles with contain the word "Informe" - the bulletins
MoSbr <- MoSbr[grepl("Informe Epi", MoSbr$title),]
MoSbr

# create date variable, by extracting the last day of the epidemiological week from the title
library(stringr)
pattern4 = "\\d{2}/\\d{2}/\\d+\\)"
MoSbr$date <- unlist(str_extract_all(MoSbr$title, pattern4))
grep(pattern4, as.character(MoSbr$title))
MoSbr$date <- dmy(gsub(")", "", MoSbr$date))
MoSbr$date

# remove >> from title
MoSbr$title
pattern1 <- "^\\>\\>\\s"
unlist(str_extract_all(MoSbr$title, pattern1))
MoSbr$title <- str_replace_all(MoSbr$title, pattern = pattern1, replacement = "")
MoSbr

########################################
# PAHO Epidemiological Updates
# ======================================
library(XML)

url <- 'http://www.paho.org/hq/index.php?option=com_topics&view=readall&cid=7880&Itemid=41484&lang=en'

raw <- read_html(url)
text <- raw %>% 
  html_nodes("#content_left li a")%>%
  html_text(trim = TRUE)

text
pattern3 = "\\d{1,2} [a-zA-Z]{3,9} \\d{4}"
pubDate <- unlist(str_extract_all(text, pattern3))
pubDate <- dmy(pubDate)
pubDate[6] <- NA
pubDate

# extract date
pattern5 <- "\\d{1,2} [a-zA-Z]{3,9} \\d{4} "
test <- str_replace(text, pattern3, "")
test
# remove ": "
library(qdapRegex)
rm_white_punctuation(test)
text <- rm_non_words(test)
text

# create dataframe for paho updates
paho <- data.frame(date=pubDate,
                   site="PAHO Epidemiological Updates",
                   siteurl=url,
                   title=text, 
                   link=url)
paho




########################################
# Merge all 3 sources
# ======================================
# convert to tbl_df to  make dataframe easier to work with
library(dplyr)
MoSbr <- tbl_df(MoSbr)
WHOdon <- tbl_df(WHOdon)
ECDC <- tbl_df(ECDC)
paho <- tbl_df(paho)

# make sure columns are in the same order in all dataframes
names(c(ECDC, WHOdon, MoSbr))
MoSbr <- select(MoSbr, date, site, siteurl, title, link)
WHOdon <- select(WHOdon, date, site, siteurl, title, link)

# combine the 4 sources into one dataframe
x <- rbind(WHOdon, ECDC, MoSbr, paho)
x

# arrange updates by date, newest to oldest
x <- arrange(x, desc(date))
x
View(x)

########################################
# Convert to html
# ======================================

# First, the 'Latest Information' page with 6 latest
latest <- head(x,6)
cat(paste('<h5><a class="fr-strong" href="', 
          latest$link, 
          '" target="_blank">',  
          latest$title, 
          '</a></h5><p><span style="font-size: 12px;">', 
          latest$date,
          ' via <a href="',
          latest$siteurl,
          '" target="_blank"><span style="color: rgb(184, 49, 47);">',
          latest$site,
          '</span></a></span></p><hr>',
          sep = ""))



# Next, all updates, with no line between

cat(paste('<h5><a class="fr-strong" href="', 
          x$link, 
          '" target="_blank">',  
          x$title, 
          '</a></h5><p><span style="font-size: 12px;">', 
          x$date,
          ' via <a href="',
          x$siteurl,
          '" target="_blank"><span style="color: rgb(184, 49, 47);">',
          x$site,
          '</span></a></span></p>',
          sep = ""))


# Add to website!!







# 
# 
# # Clearing from duplicates
# nrow(df)
# df <- unique(df)
# nrow(df)
# 
# # Transforming date-time strings to date-time objects
# df$timestamp <- strptime(as.character(df$timestamp), format = '%H:%M %d.%m.%Y')
# 
# # Simple plot
# hist(df$timestamp, breaks='hours')
# 
# # Summary
# summary(df$timestamp)
# 
# # DEALING WITH DATES
# # Filtering by datetime
# timelimits <- list(
#   from = as.POSIXct('2014-10-30 00:00:00'),
#   to = as.POSIXct('2014-10-30 23:59:59')
# )
# 
# df.filtered.1 <- df[df$timestamp >= timelimits$from & df$timestamp <= timelimits$to, ]
# summary(df.filtered.1$timestamp)
# hist(df.filtered.1$timestamp, breaks='hours')
# 
# # Summarizing by hour
# df$hour <- df$timestamp$hour
# hist(df$hour, breaks=24)
# 
# # Summarizing by date
# df$day <- strftime(df$timestamp, format='%d %b')
# 
# # DEALING WITH TEXT
# # Filtering by one field
# df[grep('путин', tolower(df$text)), ]
# 
# # Filtering by multiple fields
# filter.vec <- append(grep('путин', tolower(df$text)), grep('путин', tolower(df$title.text)))
# filter.vec <- unique(filter.vec)
# df[filter.vec, ]
# 
# # PLOTTING
# library(ggplot2)
# library(RColorBrewer)
# 
# # Preparing data (more about this: reshape2, melt, dcast)
# df.plot <- aggregate(df, by = list(df$day, df$hour), FUN = length)
# df.plot <- df.plot[, 1:3]
# names(df.plot) <- c('Date', 'Hour', 'Amount')
# 
# # Define palette
# specPal <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
# 
# # Create plot
# plot <- ggplot(df.plot,
#                aes(x = Hour, y = Date, fill = Amount))
# # Adding geom
# plot <- plot + geom_tile()
# 
# # Selecting scales
# plot <- plot + scale_fill_gradientn(guide="colourbar", colours = specPal(100), guide_legend(title="Количество \nновостей"))
# plot <- plot + scale_x_discrete("Часы", limits=0:22, labels=0:23)
# plot <- plot + scale_y_discrete("Дата")
# 
# # Adding details
# plot <- plot + coord_equal()
# plot <- plot + theme_bw()
# plot <- plot + theme(legend.position="bottom", legend.background = element_rect(colour = "grey"))
# plot <- plot + ggtitle(expression("Частота публикации новостей"))
# 
# # Showing
# plot