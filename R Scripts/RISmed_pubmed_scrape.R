library(RISmed)

res <- EUtilsSummary("Zika", type="esearch", db="pubmed", 
                     datetype='pdat', mindate=1900, maxdate=2016, retmax=50)
summary(res)
fetch <- EUtilsGet(res)
AuthorList<-Author(fetch)
Title<-ArticleTitle(fetch)
PublicationType(fetch) # Letter, Journal Article, ect
PublicationStatus(fetch) # epub, ahead, etc.
Affiliation(fetch) # institution
Agency(fetch) # funded?
Issue(fetch)
Volume(fetch)
Title(fetch) #Journal title!
ISSNLinking(fetch)


library(magrittr)
ebola <- read.csv('http://apps.who.int/gho/athena/xmart/DATAPACKAGEID/2016-01-13?format=csv&profile=text&filter=COUNTRY:SLE')
ebola <- tbl_df(ebola)
ebola <- ebola %>%
  select(Country, Location, Case.definition, Ebola.data.source, Epi.week, Numeric)
ebola$Numeric[ebola$Numeric == "NA"] <- NA
View(ebola)

ebola_sum <- ebola %>%
  filter(Case.definition == "Confirmed" & Ebola.data.source == "Situation report") %>%
  group_by(Epi.week) %>%
  summarise(count = sum(Numeric))
ebola_sum
str(ebola_sum)
Sum
View(ebola_sum)

confirm <- filter(ebola, Case.definition == "Confirmed" & Ebola.data.source == "Situation report")
confirm
View(confirm)
