# Resources


# PAHO Zika Virus Infection: Scientific and Technical Materials
# PDF Download only
url <- 'http://www.paho.org/hq/index.php?option=com_topics&view=readall&cid=7916&Itemid=41484&lang=en'
raw <- read_html(url)
nodes <- raw %>%
  html_node("ul~ ul")

text <-  html_text(nodes, trim = TRUE)
text
