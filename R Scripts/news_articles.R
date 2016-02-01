# News feeds on Zika

# Load the packages required 
library(XML)
library(RCurl)
library(dplyr)

# Inoreader RSS feed
zika_news_rss <- 'http://www.inoreader.com/stream/user/1005593243/tag/Zika%20News%20Articles'
script <- getURL(zika_news_rss)
doc <- xmlInternalTreeParse(script)


title <- xpathSApply(doc, "//item/title", xmlValue)
url <- xpathSApply(doc, "//item/link", xmlValue)
authors <- xpathSApply(doc, "//item/dc:creator", xmlValue)
pubDate<- xpathSApply(doc, "//item/pubDate", xmlValue)
pub <- xpathSApply(doc, "//item/source", xmlValue)
description <- xpathSApply(doc, "//item/description", xmlValue)

news <- data.frame(title, url, authors, pubDate, pub, description)
library(stringr)
news$title <- str_trim(news$title)
news$url <- str_trim(news$url)
news$authors <- str_trim(news$authors)
news$pub <- str_trim(news$pub)
news$description <- str_trim(news$description)

news
news <- tbl_df(news)


# create date variable, by extracting the last day of the epidemiological week from the title
library(stringr)
pattern2 = "\\d{2} [a-zA-Z]{3} \\d{4}"
news$pubDate <- unlist(str_extract_all(news$pubDate, pattern2))
news$pubDate <- dmy(news$pubDate)
news$pubDate

# detect language
library(textcat) 
news$lang <- textcat(paste(title, description, sep = ""))
news$lang


########################################
# Additional articles
# ======================================

# English
a_en <- "http://sbmt.org.br/portal/zika-e-microcefalia-uma-relacao-que-exige-acoes-e-cautelas/?lang=en"
# Portuguese
a_pt <- "http://sbmt.org.br/portal/zika-e-microcefalia-uma-relacao-que-exige-acoes-e-cautelas/?locale=pt-BR"

# PT
b_pt <- "http://g1.globo.com/bemestar/noticia/2016/01/obama-pede-agilidade-em-pesquisas-de-vacina-e-tratamentos-para-o-zika.html"
b_en <- [NYT]

########################################
# Inoreader API
# ======================================
appID <- "1000001062"
appKEY <- "bWJq_CYpDoKw4cW_QO5dMBp2Fi4ZjBDE"

# Constructing URL for last json snapshot
json.url <- paste0('https://www.inoreader.com/reader/api/0/stream/contents/?AppId=', 
                   appID, '&AppKey=', 
                   appKEY, '&it=user/',
                   zikanewsID, 
                   '/state/com.google/starred', 
                   sep="")




json <- getURL(json.url)
json.data <- fromJSON(json)

  paste0('https://www.inoreader.com/reader/api/0/user-info?AppId=', 
                   appID, '&AppKey=', appKEY)



'https://www.inoreader.com/reader/api/0/stream/contents/tag/zika%20virus?it=user/-/state/com.google/starred'

  
