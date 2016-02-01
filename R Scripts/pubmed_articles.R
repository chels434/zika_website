# PubMed search: Zika virus

# Load the packages required 
library(XML)
library(RCurl)
library(dplyr)
library(RISmed)
search_topic <- 'zika'
search_query <- EUtilsSummary(search_topic, retmax=100, mindate=1900, maxdate=2016)
search_query

records<- EUtilsGet(search_query)
pubmed_data <- data.frame('Title'=ArticleTitle(records),'Abstract'=AbstractText(records),
                          'Year'=YearPubmed(records), 'Month'=MonthPubmed(records), 
                          'Day'=DayPubmed(records), 'Author'=Author(records))
ISSN(records)
print(records)
head(pubmed_data,1)
#=============
# PubMed query
#=============
library(RCurl)
library(XML)
library(plyr)
require(reports) # capitalizing
library(stringr)


query <- 'zika'
pubmed_ask(query)
pubmed_count(query)
pubmed_get("zika", file = "24jan")
doc <- pubmed_journals("pubmed_24jan")
years <- pubmed_years("pubmed_24jan")
pubmed_timeline("pubmed_24jan")

zika <- pubmed_get(query, "zika", list = TRUE)
# Plot data details (not run).
require(ggplot2)
qplot(data = zika$years, x = year, y = count, stat = "identity", geom = "bar")
qplot(data = FCTC$authors, x = authors, y = count, stat = "identity", geom = "bar")
qplot(data = subset(FCTC$journals, count > 5), x = reorder(journal, count), 
      y = count, stat = "identity", geom = "bar") + 
  labs(x = NULL) + 
  coord_flip()

#=============
# Zika Build
#=============
xml.url <- "http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1t9NTJWhkapza5BO0F18d7Aueo6BeZiLnkto40KEUWpmXBfMcr"
script <- getURL(xml.url)
doc <- xmlInternalTreeParse(script)
titles <- xpathSApply(doc, "//item/title", xmlValue)
url <- xpathSApply(doc, "//item/link", xmlValue)
authors <- xpathSApply(doc, "//item/author", xmlValue)
journal <- xpathSApply(doc, "//item/category", xmlValue)


zika <- data.frame(titles, url, authors, journal)
zika <- tbl_df(zika)
zika <- arrange(zika, desc(journal))

cat(paste('<a href=\"', zika$url, '\" target="_blank"> ', 
          zika$titles, ' </a>', '<br /><br />', sep = ""))


xml.url <- "http://www.inoreader.com/stream/user/1005593243/tag/zika%20journals?n=6"
script <- getURL(xml.url)
doc <- xmlInternalTreeParse(script)
titles <- xpathSApply(doc, "//item/title", xmlValue)
url <- xpathSApply(doc, "//item/link", xmlValue)
authors <- xpathSApply(doc, "//item/author", xmlValue)
journal <- xpathSApply(doc, "//item/category", xmlValue)


zika <- data.frame(titles, url)
zika <- tbl_df(zika)



# articles to add
CHIMERE <- "http://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0002996"

