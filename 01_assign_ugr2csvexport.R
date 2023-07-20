#### ASSIGN UGR TO ARTICLE NUMBER ----
library(tidyverse)

# 1.0 DATA IMPORT ----
# 1.1 myview CmCSVExport ----
# Show myview columns for reimporting data
myview_tbl <- read.delim(
	file             = "0_data/CmCSVExport.csv", 
	header           = TRUE,
	sep              = "\t",
	fileEncoding     = "UTF-16LE",
	skip             = 28,
	stringsAsFactors = F,
	colClasses       = "character"
) %>% 
	as_tibble() %>% 
	glimpse()

# 1.2 EulumDB filelist_ldt ----
filelist_ldt_tbl <- read.delim(
	file             = "0_data/filelist_ldt.csv", 
	header           = FALSE,
	sep              = ";",
	fileEncoding     = "UTF-16LE",
	skip             = 1,
	stringsAsFactors = F,
	colClasses       = "character"
) %>% 
	as_tibble() %>% 
	select(V2, V12, V13) %>% 
	rename(artno = V2, ugr_c0 = V12, ugr_c90 = V13) %>% 
	mutate(across( c(ugr_c0, ugr_c90), ~str_replace(., "\\.", ","))) %>% 
	glimpse()

# 2.0 JOIN DATA ----
output_tbl <- myview_tbl %>% 
	mutate(across(
		.cols = c(Name, Blendbewertung.UGR..quer.:LDT.Datei.Text.), 
		.fns  = ~str_replace_all(., ".", "")
		)) %>% 
	select(-Blendbewertung.UGR..quer., -Blendbewertung.UGR..stirnseitig.) %>% 
	left_join(filelist_ldt_tbl, by = c("Artikelnummer.PRACHT" = "artno")) %>% 
	relocate(ugr_c0,  .before = Blendbewertung.UGR..quer..Unit.) %>% 
	relocate(ugr_c90, .before = Blendbewertung.UGR..stirnseitig..Unit.) %>% 

	glimpse()


# 3.0 CREATE MYVIEW IMPORT FILE ----

# 3.1 Preparing import csv-file for appending data ----
# Extract header from csv-export
myview_lines <- stringi::stri_read_lines(
	"0_data/CmCSVExport.csv",
	encoding = "UTF-16LE"
) 

# Removing data rows
myview_header <- myview_lines[1:29]

# Writing csv-file for import into myview
stringi::stri_write_lines(
	myview_header, 
	"0_data/myview_ugr_import.csv",
	encoding = "UTF-16LE"
)

# 3.2 Append rows to csv-import-file ----
output_tbl %>% 
	write.table(
		"0_data/myview_ugr_import.csv", 
		append = TRUE, 
		quote = FALSE,
		sep = "\t",
		na = "",
		row.names = FALSE,
		col.names = FALSE,
		fileEncoding = "UTF-16LE"
	)