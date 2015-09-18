# Our function declaration that will make below steps much simpler
# to call
readcenus <- function(bz2filename, lines, CHUNKSIZE, SAMPLE_SIZE,
                      use_readcsv, debug) {
# Open the file from a bzip2 stream using our file name argument
bz2file <- bzfile(bz2filename,"r")
# This ensures our sampling will be consistent every time.  Which 
# is important for computationally reproduceable results
set.seed(0)
# Our selection, which needs to be sorted to work with our for
# loop, is generated from the uniformly on [1, lines]
# (but without replacement).
selection <- sort(sample.int(lines, size=SAMPLE_SIZE, 
                             replace=FALSE, prob=NULL))
# Alternating methods will be used for timing purposes later, which
# is why we include this boolean option.  Here we read the header
# which will inform the column names for our data frame.
if (use_readcsv) {
  header=readLines(bz2file,n=1)
}
else {
  header=c(unlist(strsplit(scan(bz2file,what="character"
                                ,nlines=1),",")))
}
# Initialize the empty array, which will allow us to avoid using
# the append function later
to_store <- matrix("NA", nrow=SAMPLE_SIZE, ncol=length(header))
counter <- 1
# Count the number of blocks by dividing lines by the block size,
# and then rounding up
print(system.time(for (i in seq(ceiling(lines/CHUNKSIZE))) {
  start <- ((i-1)*CHUNKSIZE)+1;
  end <- start+CHUNKSIZE-1;
  if (use_readcsv) {
    x <- as.matrix(read.csv(bz2file,nrows=CHUNKSIZE));
  }
  else {
    x <- readLines(bz2file,n=CHUNKSIZE)
  }
  # Select our subset, and then ensure the numbers are
  # appropriately scaled back so we can collect in the
  # block.
  subset =
  (start:end)[start:end %in% selection] - (i-1)*CHUNKSIZE;
  for (n in subset) {
    if (use_readcsv) {
      to_store[counter,] <- x[n]
    }
    else {
      to_store[counter,] <- 
        c(unlist(strsplit(x[n], "," ,fixed=TRUE)))  
    }
    counter <- counter+1
  }
  # This debug feature is very helpful for examinging the
  # time each "step" or block reading takes.  It will allow
  # us to debug quickly, and with the use_readcsv flag, 
  # compare various R functions.
  if (debug)
  {
    if (i==3) { break }
  }
}))
# Finally store the information as a data frame, 
# populate the headers of the file, and then close the
# bz2file stream before returning the finished data frame.
to_store_df = data.frame(to_store)
colnames(to_store_df) <- c(header)
close(bz2file)
return(to_store_df)
}

# mylines <- as.numeric(system(sprintf("bzcat %s | wc -l", bz2filename),intern=TRUE))-1 # -1 for the header
bz2filename <- "/Users/Alex/stat243-fall-2015/ps/ps2_solutions/ss13hus.csv.bz2"
mylines <-7219001-1
mylines <- as.numeric(system(sprintf("bzcat %s |
wc -l", bz2filename),intern=TRUE))-1
# Used for testing: mylines <-7219001-1
MYCHUNKSIZE <- 100000
MYSAMPLE_SIZE <- 10000
to_store_df <- 
  readcenus(bz2file=bz2filename, lines=mylines, 
            CHUNKSIZE=MYCHUNKSIZE, SAMPLE_SIZE=MYSAMPLE_SIZE,
            use_readcsv=FALSE, debug=FALSE)
myvars <- 
  c("ST","NP","BDSP","BLD","RMSP", "TEN", "FINCP",
    "FPARC", "HHL", "NOC", "MV", "VEH", "YBL")
write.csv(to_store_df[,myvars],file="/Users/Alex/stat243-fall-2015/ps/ps2_solutions/cenus_test.csv")

# Construct a table based on our subsampling routine, looking at the
# region of the country with respect to the languages spoken in the home
con_table<-table(to_store_df$DIVISION,to_store_df$HHL)
# We populate the row/column names based on the .pdf explaining the
# various codes and their meanings for each country
colnames(con_table) <- 
  c("NA", "English Only", "Spanish", 
    "Other Indo-Euro", 
    "Asian/Pac", "Other")
rownames(con_table) <- 
  c("New England", "Mid Atlantic", "E N Central", 
    "W N Central", "S Atlantic", "E S Central", 
    "W S Central", "Mountain", "Pacific")
# Print the table, and a summary of the statistical significances
con_table
summary(con_table)
