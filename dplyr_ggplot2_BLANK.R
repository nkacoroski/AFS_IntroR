# ---- Clear Environment ----
# rm(a)
rm(list = ls())

# ---- Clear Console ----
# Windows: Ctrl-L
# Mac: Cmmd-L

# ---- Load packages ----
# Note: If an error is produced saying there is no such package
# it means you need to install the package using install.packages()
library(lubridate)
library(dplyr)
library(ggplot2)


# ---- Import Data ----
# 1. Check your working directory
getwd()

# 2. List files in your working directory
list.files()

# 3. Import the data
data <- read.csv("KingsCreekFishSurveys.csv")

# ---- Exploring Data Frames ----
  # View data in a new tab

  # Number of rows and columns
  # Number of rows
  # Number of columns

  # Display the first six rows
  # Display the last six rows
  # Display the names of each column

  # Summarise each column
  # Display the structure of the object
  # Display the structure of the object using {dplyr}

str(data)
glimpse(data)

# ---- Factors ----
# Factors are variables that have levels / categories / groups
# By default, read.csv() treats all strings (characters) as factors
class(data$habitat)


# Goal: What are the levels of habitat?
levels(data$habitat)

# Goal: What would this column look like if it was treated as a number?
data$habitat
as.numeric(data$habitat)

# ---- {tidyverse} ----
# The {tidyverse} is a collection of packages that share an
# underlying design philosophy, grammar, and data structures and
# work with "tidy data", which follows specific rules and best practices

# {dplyr}: data manipulation #
# {ggplot2}: visualizing data #
# {lubridate}: working with dates and times #
# {tidyr}: tidying data
# {broom}: tidying output from models
# {stringr}: working with strings
# {forcats}: working with factors
# {purrr}: functional programming
# {rvest}: web scraping

# https://www.tidyverse.org/packages/

# ---- Subsetting Data with {dplyr} ----
# select() : selects columns from a data frame and outputs as a data frame
# Goal: Output the column called year
head(select(data, year))

## Can you explain why the output is different for each of these?
data$year # vector
select(data, year) # column

# Goal: Output the columns called site and common_name
select(data, site, common_name)

# Goal: Convert the data frame to a tibble for easier viewing
data_tb <- as_tibble(data)

# Goal: Output the columns called site and common_name
select(data_tb, site, common_name)

# filter() : filters rows from a data frame
# Example: Output the rows where year is less than or equal to 2000
filter(data_tb, year <= 2000)

# Goal: Output the rows that correspond to data from site D
filter(data_tb, site == "D")

# Goal: Output the rows that correspond to data from pools in site D
filter(data_tb, site == "D" & habitat == "pool") # may use comma instead of ampersand

## What is the output from the following line of code?
filter(data_tb,
       year %in% c(1999, 2001),
       month > 6,
       site == "A",
       common_name == "Creek Chub")

## What is the output from the following line of code?
filter(data_tb,
       between(year, 1999, 2001),
       month > 1,
       month < 4,
       site != "A",
       common_name == "Creek Chub")

# ---- Pipes ----
# Information is put into a pipe %>%
# It comes out the other end and is used as the first argument
# for the function on the other side

# Goal: Find the square root of 81
sqrt(81)
81 %>% sqrt()

# Goal: Output the rows that correspond to data from site A
filter(data_tb, site == "A")
data_tb %>% filter(site == "A")


# Pipes are valuable when we want to perform multiple steps

# Goal: Find the square root of the absolute value of -16
# Nested functions
sqrt(abs(-16))

-16 %>% abs() %>% sqrt() 

# Pipes
-16 %>% # Start with a value
  abs() %>% # Step One: absolute value
  sqrt() # Step Two: square root

# Goal: Considering only data collected in 2000
# ouput the columns called year, habitat, and common_name
data_tb %>%
  filter(year == 2000) %>% # Step One: include only year 2000
  select(year, habitat, common_name) # Step TWo: include only year, habitat, and common name


## Can you explain why this gives the same output?
data_tb %>%
  select(year, habitat, common_name) %>%
  filter(year == 2000)

## What would happen if you tried to run this?
data_tb %>%
  select(habitat, common_name) %>%
  filter(year == 2000)

## Choose any species.
# Output the common_name and count columns associated with that species.
unique(data$common_name)

data_tb %>%
  filter(common_name == "Creek Chub") %>%
  select(common_name, count)

## Output the year, month, and site columns from instances where at least two
## individuals of that species were captured in a pool.
data_tb %>%
  filter(habitat == "pool",
         count >= 2,
         common_name == "Creek Chub") %>%
  select(year, month, site)
  

# ---- Summarising Data with {dplyr} ----
# summarise() : returns a single value based on the instructions you give it
# Goal: Find the maximum count
max(data_tb$count)

data_tb %>%
  summarise(max(count))

# group_by() : splits your data into groups based on the variables you specify
# Goal: Group by site
data_tb %>%
  group_by(site)

# Goal: Use group_by() and summarise() together to find the average
# number of fish caught at each site
data_tb %>%
  group_by(site) %>%
  summarise(mean(count))

# This can be stored as a data frame
mean_counts <- data_tb %>%
  group_by(site) %>%
  summarise(average = mean(count))

mean_counts

# The column names can be specified in summarise


# Goal: What is the average and sd of counts in each habitat type?
mean_counts <- data_tb %>%
  group_by(site) %>%
  summarise(average = mean(count),
            stdev = sd(count))


# Goal: What is the average and sd of counts in each habitat type, by year?
data_tb %>%
  group_by(year, habitat) %>%
  summarise(average = mean(count),
            stdev = sd(count))

# Goal: What was the average number of Creek Chub captured at each site?
data_tb %>%
  filter(common_name == "Creek Chub") %>%
  group_by(site) %>%
  summarise(average = mean(count)) %>%
  arrange(desc(average))

# count() : counts occurences

# Goal: How many records at each site?
data_tb %>%
  count(site)


# n() : counts occurences in each group using summarise()

# Goal: How many records at each site by habitat type?
data_tb %>%
  group_by(site) %>%
  summarise(numberofrecords = n())


## When might you use count() vs summarise(n())?
# if you need more than just count for a summary



# n_distinct() : count unique values in each group using summarise()

# Goal: In how many unique years was each site sampled?
data_tb %>%
  group_by(site) %>%
  summarise(n_distinct(year))

## Goal: How many total specimens were captured at each site?
data_tb %>%
  group_by(site) %>%
  summarise(total = sum(count)) %>%
  arrange(desc(total))


## Goal: How many unique species were captured at each site?
data_tb %>%
  filter(count > 0) %>%
  group_by(site) %>%
  summarise(unique_species = n_distinct(common_name))


# ---- Manipulating Data with {dplyr} ----
# mutate() : create a new column
# Goal: Create a column called area, containing simulated sampling areas
# generated using rnorm()
set.seed(123)
myareas <- rnorm(n = nrow(data_tb), mean = 100, sd = 20)
length(myareas)

data_tb %>%
  mutate(area = myareas)

glimpse(data_tb)

# To make this change permanent, overwrite the data frame
data_tb <- data_tb %>%
  mutate(area = myareas)

glimpse(data_tb)
# mutate() : create a new column based on another column
# Example: Create a column called density
data_tb <- data_tb %>%
  mutate(density = count/area)

glimpse(data_tb)
# Goal: Create a column called "present", that contains TRUE if a
# species was captured and FALSE if a species was not captured
data_tb <- data_tb %>%
  mutate(present = count > 0)

# Goal: Create a column called "present_v2" that contains "yes" if a 
# species was captured and "no" if a species was not captured
ifelse(5 >7, "yes", "no")

data_tb <- data_tb %>%
  mutate(present_v2 = ifelse(count > 0, "yes", "no"))


## Goal: Create a column called "records" that contains "new" if the 
# record was collected after 2010 and "old" if it was collected in 2009 or earlier
data_tb <- data_tb %>%
  mutate(records = ifelse(year >= 2010, "new", "old"))

# ---- Dealing with dates and times with {lubridate} ----
# ymd() : takes a string representing year-month-day and converts it to a date


# Goal: Combine year, month, and day into a format that can be 
# converted to a date


# ---- Capstone {dplyr} Exercise ----
## Create a summary table called "table1" that contains the
# total, mean, maximum, and minimum number of Central Stonerollers
# captured by year, site, and habitat


# ---- Visualizations in {ggplot2} ----
# Any visualization has three components:
# 1. a data set (What are you trying to look at?)
# 2. a coordinate system (The most common are x and y axes)
# 3. a geom (How do you want to visualize the data set on the coordinate system?)
# ggplot2 uses layers to build plots

# ---- Starting with ggplot() ----
# Initialize ggplot()


# 1. Specify a data set


# 2. Specify a coordinate system


# 3. Specify a geom


# Goal: Create a boxplot with site on the x axis and area on the y axis
# Remember that this is simulated data!


## What happens if a continuous variable is used on the x axis?


# Goal: Create a histogram of area sampled


# ---- Adding Colour ----
## Create a scatterplot of mean number of individuals captured by year


# Goal: Make points blue  
## Can you explain why this happens?

## How would you fix this?


# Goal: Make the color of each point based on the month


# Goal: Make the color of each point based on site


# ---- ggplot() as an Object ----
# Store ggplot plots as an object

# Goal: Add labels on x and y axis


# Goal: Tidy up the background colours


# ---- Facetting ----
# Goal: Add a layer to plot3 that creates a separate panel for each habitat type


# Goal: Arrange the panels as a single column


# ---- Capstone {ggplot2} Exercise ----
# Reproduce the plot found here:
# https://github.com/DanielleQuinn/OTN_workshop/blob/master/GapMinderReport.pdf

# Tip: Make a list of what needs to be done and tackle ONE thing at a time.

# Here is a list of things you'll
# need to do; see how many you can accomplish

# Don't hesitate to consult resources:
# http://www.cookbook-r.com/Graphs/
# We haven't seen all of these yet!

# data preparation:
# (1) subset table1 to only include samples from pools

# creating the plot:
# (1) Scatterplot with year on x axis and mean on y axis
# (2) X axis label is Year
# (3) Y axis label is Mean Number Caught
# (4) Theme is black and white
# (5) Point colour is based on site
# (6) NEW! Points are triangles
## See if you can work this one out with a partner
# (7) Facet your plot based on site using facet_wrap
# (8) Stack all facets into one column
# (9) NEW! Draw a line connecting the points
## Hint: geom_line()
# (10) NEW! Draw a dashed line represented the maximum number captured per year
## Hint: Just like col and shape, there is an argument called linetype
# (11) Draw a dashed line representing the minumum number captured per year
# (12) NEW! Allow the y axis limits to be based only on the points within them
## Hint: Look at R Cookbook ggplot2 under "Facets"
# (13) NEW! Specificy the colors to be used as red, blue, purple, orange, and black
## Hint: Look at R Cookbook ggplot2 under "Colors" > "Palettes Manually Defined"
# (14) NEW! Name the lengend SITE ID
## Hint: You can specify this in the name argument of the function used in step (13) 
# (16) NEW! Add a title: "Mean number of Central Stonerollers captured in pools between 2000 and 2015"
## Hint: ggtitle()
# (17) Store your finished plot in an object called myfigure
# (18) NEW! Save your plot to your working directory!
## Hint: ggsave()

# As you solve each piece, add an "x" next to it on the etherpad
# https://etherpad.net/p/2019-09-28-afs
