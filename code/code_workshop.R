# CAA 2026
# From Zero to Plotting: R for Anyone
# March 31

# Workshop outline:
# BLOCK I   — Environment setup & packages           (Petr Pajdla)
# BLOCK II  — Data import, exploration & first plots (Vít Kozák)
# BLOCK III — Data cleaning                          (Petr Pajdla)
# BLOCK IV  — Data transformation                    (Peter Tkáč)
# BLOCK V   — Plots                                  (Vít Kozák)


# BLOCK I: Introduction --------------------------------------------------------

# - Welcome
# - Introduce us
# - Introductions of participants
# - What is your experience with programming?
# - What is your experience with R?

# - What to expect from the workshop
# - Organization - coffee breaks, lunch break

# GitHub repository with code and data:
# https://github.com/petrpajdla/intRo

# Stickers/Post-it method:
# - green = everything is fine 
# - blue = working on it, need more time 
# - red = I am lost, please help!
# Cheat sheet with special signs and shortcuts
# Find out how to write stuff on your keyboard!


## Introduction to R and RStudio/Positron --------------------------------------

# R is a smart calculator
# Use Ctrl/Cmd + Enter to run the line where your cursor is located
# Line starting with a # hash is commented, i.e. the code is not run
1 + 1



# Comparator operations return TRUE or FALSE



# Assignment operator is <-
# Value is assigned to an object, kind of a 
# "save this thing under this name" operation
# Written with Alt + - shortcut
one <- 1
two <- 2
one + two


# Vector is the simplest array of values
# It is created using c() function
c()

# Vector always consists of values of the same type
c("a", "b") # character strings
c(1.5, 2, pi) # continuous numeric values

# TASK: 
# 1. Create a vector called "numbers" with 5 random numbers
numbers <- c()
# 2. View it by typing and evaluating the objects name


# Functions
# Functions do things on values or objects...
# function(argument1 = value1, argument2 = value2, ...)
str(numbers)







# R is case sensitive
object <- "Hello World!"
OBJECT <- "HELLO WORLD!"

object == OBJECT

# More complex data can be stored in data frames
# Data frame is basically a table
df <- data.frame(
  numbers = 20:24,
  letters = c("a", "b", "c", "d", "e")
)

df

View(df)

# Pull columns from data frames with $ dollarsign
df$numbers
df$

# Inspect the structure of your object using str() function
str(df)

# Look for help with ?function_name
?mean


## Project structure -----------------------------------------------------------

# TASK: create a new project 

# here::here() builds paths relative to the project root
# This keeps paths portable across machines

dir.create(here::here("data"))
dir.create(here::here("data/raw")) 
dir.create(here::here("data/processed"))
dir.create(here::here("code"))
dir.create(here::here("plots"))

## Packages --------------------------------------------------------------------

# Install packages (only needed once, then comment out):

install.packages("readr")
install.packages("readxl")
install.packages("dplyr")
install.packages("tidyr")
install.packages("janitor")
install.packages("ggplot2")
install.packages("tidyverse")

# Load packages (needed every session):

library(readr) # reading data (.csv)









# BLOCK II: Reading and exploring data -----------------------------------------

# Data import, exploration & first visualisations
# Goal: get to know the dataset and identify data quality issues

## Data import -----------------------------------------------------------------

# Download data from
# https://github.com/petrpajdla/intRo/blob/main/data/burials.csv
# save it as a CSV in you working directory under /data/raw/

burials_url = "https://raw.githubusercontent.com/petrpajdla/intRo/refs/heads/main/data/burials.csv"
download.file(burials_url, destfile = here::here("data/raw/burials.csv"))

burials <- read_csv(here::here("data/raw/burials.csv"))

## Explore data ----------------------------------------------------------------

# Print the tibble — shows first rows and column types
burials

head(burials, 4)
tail(burials, 4)

# Compact overview of all columns and their types
glimpse(burials)

# Statistical summary of each column
summary(burials)

# How many variables do we have in the data frame?
ncol(burials)

# How many observations are there in the data frame?
nrow(burials)

# What variables are there?
names(burials)

# When did these excavations start and end?
min(burials$Excavation_year)
max(burials$Excavation_year)

# Preview unique values in columns we'll plot
# This hints at data quality issues before we even visualise
# TASK: explore two other variables

distinct(burials, Sex)
distinct(burials, Preservation)
distinct(burials, orientation)


## Visualisation with ggplot2 --------------------------------------------------

# ggplot builds plots in layers: data + aesthetics + geometry
# We use simple plots here to spot data problems; beautification comes later

### Basics + barplot -----------------------------------------------------------

# How many individuals of different sex are there in the burial ground?

# Layer 1: data
ggplot(data = burials)

# Layer 2: aesthetics — map a variable to a visual property
ggplot(data = burials, mapping = aes(x = Sex))

# Layer 3: geometry — choose how to represent the data
ggplot(data = burials, mapping = aes(x = Sex)) +
  geom_bar()

# Shorthand — ggplot knows the first arg is data, second is mapping
ggplot(burials, aes(x = Sex)) +
  geom_bar()


# What problems can you observe within this plot?
# -> inconsistent coding: NA, ?, empty string, "unknown" all mean "not known"

# What is the orientation of the graves?

ggplot(burials, aes(x = orientation)) +
  geom_bar()

# -> mix of compass labels ("W-E") and degree values ("270")

# What was the most intensive excavation season?

ggplot(burials, aes(x = Excavation_year)) +
  geom_bar()

# -> data look consistent here, no issues

### Histogram ------------------------------------------------------------------

# What is the distribution of grave pit depth?

ggplot(burials, aes(x = Depth_cm)) +
  geom_histogram()

# Warning about missing values is expected — some depths are NA
# The distribution looks reasonable, but watch for extreme outliers
# (values like 1500 or 2200 cm are likely typos — 150 and 220 cm)

## Exercise: choose a geometry! ------------------------------------------------

# Anthropologists need a count of well-preserved individuals.
# What geometry will you choose?

ggplot(burials, aes(x = Preservation)) +
  geom_???()

# -> enough well-preserved skeletons, but values are inconsistent
#    ("GOOD", "Good", "good" are treated as separate categories)

## Exporting plots -------------------------------------------------------------

# Anthropologists need the plot now — let's export it:

ggsave(here::here("plots", "plot1.png"))

# For more control, save the plot to a variable first:

p1 <- burials |>
  ggplot(aes(x = Preservation)) +
  geom_bar()


ggsave(
  here::here("plots", "plot1.png"),
  plot = p1,
  width = 8,
  height = 6,
  dpi = 300
)


# BLOCK III: Data cleaning -----------------------------------------------------

## Data cleaning ---------------------------------------------------------------

# Goal: fix the issues we spotted during exploration
# Later: data transformation, pivoting, joining

# Problems spotted during exploration:
# 1. Column names are inconsistent (spaces, mixed case)
# 2. Preservation has mixed case ("GOOD", "Good", "fair", "poor")
# 3. Sex has "?", "unknown", empty strings, and NA for missing values
# 4. Orientation mixes compass labels ("W-E") and degrees ("180")
# 5. Depth has likely typos (1500 cm, 2200 cm — probably 150 and 220) 
# and missing values (NAs)

# Let's inspect the column names first:
names(burials)

### Pipe operator ---------
# Sidenote: Using the pipe operator
# %>% (from magrittr / dplyr) or
# |> native R pipe (since R 4.1)
# It takes the left-hand side and passes it as the first argument to the right
# data |> function(arg1, arg2) is the same as function(data, arg1, arg2)

### Step 1: Clean column names -------------------------------------------------

# First option: rename by hand
burials |>
  rename(
    Grave_ID = "grave id",
    # rename Orientation to orientation - fix the capital letter
  )

# Second option: use a package janitor
# janitor::clean_names() converts all column names to a consistent format:
# - lowercase
# - spaces replaced with underscores
# - special characters removed

burials_clean <- burials |>
  janitor::clean_names()

# Check names again:


# "grave id" became "grave_id" — no more backticks needed!

### Step 2: Standardise preservation -------------------------------------------

# What values are in the preservation column?
burials_clean |>
  count(preservation)

# We have: Fair, GOOD, Good, NA, Poor, fair, poor
# Let's make them all lowercase using str_to_lower() from stringr

burials_clean <- burials_clean |>
  mutate(preservation = stringr::str_to_lower(preservation))

# Check the result:
burials_clean |>
  count()

### Step 3: Standardise sex ----------------------------------------------------

# What values are in the sex column?
burials_clean |>
  count()

# We have: ?, F, M, NA, empty string (""), unknown
# "?", "unknown", and "" all mean "we don't know" — let's unify them
# Note: empty strings ("") are NOT the same as NA — case_match's
# .default = NA_character_ catches them 

burials_clean <- burials_clean |>
  mutate(
    sex = case_match(
      sex,
      "F" ~ "female",
      "M" ~ "male",
      "?" ~ "unknown",
      "unknown" ~ "unknown",
      .default = NA_character_
    )
  )

# Check:



### Step 4: Standardise orientation --------------------------------------------

# What values do we have?



# Mix of compass labels (E-W, N-S, W-E) and degrees (0, 180, 270, 90)
# Let's convert degrees to compass labels so everything is consistent

# Quick reference for archaeologists:
# 0°   = N-S (head to North, feet to South)
# 90°  = E-W
# 180° = S-N
# 270° = W-E

burials_clean <- burials_clean |>
  mutate(
    orientation = case_match(
      orientation,
      "0" ~ "N-S",



      .default = orientation
    )
  )

# Check:



### Step 5: Missing values -----------------------------------------------------

# Check the distribution of depth_cm — watch for outliers and NAs
burials_clean$depth_cm |> summary()

burials_clean <- burials_clean |>
  na.omit(depth_cm)


### Step 6: Check the result ---------------------------------------------------

glimpse(burials_clean)

# How many NAs do we have per column?
burials_clean$sex |> is.na() |> sum()
burials_clean$orientation
burials_clean



# Compare original vs. cleaned:
# BEFORE:
burials |> count(Sex)
burials |> count(Preservation)
burials |> count(orientation)

# AFTER:
burials_clean |> count(sex)
burials_clean |> count(preservation)
burials_clean |> count(orientation)

# Let's verify with a quick plot — does it look cleaner now?
burials_clean |>
  ggplot(aes(x = preservation)) +
  geom_bar()

burials_clean |>
  ggplot(aes(x = sex)) +
  geom_bar()


# BLOCK IV: Data transformation ------------------------------------------------

### Overview -------------------------------------------------------------------

# You will learn to:
# - select specific columns or remove them - select()
# - create new columns and change the values based on different conditions - mutate(), case_when()
# - filter specific rows based on various conditions - filter()
# - order your rows from lowest to highest values (or vice versa) - arrange()
# - group your data and calculate different summary statistics - summarise(), group_by()
# - work with different functions more effectively with the pipe operator - |>

### dplyr package --------------------------------------------------------------

# we will work with the dplyr package which uses tidy data logic 
# (one variable = one column, one observation = one row,...)
# a major advantage of this package is its more intuitive, human-readable syntax

# In Base R, the code for filtering those burials would look like this:


burials_clean[burials_clean$preservation == "good",]


# and this is a solution with the filter() function from the dplyr package:

filter(burials_clean, preservation == "good")

# Similarly, if your dataframe has too many unnecessary columns, you can select a few to make it easier to navigate.
# This would be the solution in R Base:

burials_clean[, c("grave_id", "age_category", "sex", "preservation")]

# And this is done with the select() function from the dplyr package.

select(burials_clean, grave_id, age_category, sex, preservation)


### pipe operator |> -----------------------------------------------------------

# Using the pipe operator
# %>% (from magrittr / dplyr) or
# |> native R pipe (since R 4.1)
# It takes the left-hand side and passes it as the first argument to the right

# The pipe operator |> allows you to combine various functions into one code chunk, making your code shorter and easier to read.

# syntax:
#  dataframe |> function_1(variable, condition) |> function_2(variable, condition)

# You can combine functions select(), filter() and head():

burials_clean |> 
  select(grave_id, age_category, sex, preservation) |> 
  filter(preservation == "good") |> 
  head(4)

### filter() function ----------------------------------------------------------

# We already know function `filter()`

burials_clean |> 
  filter(preservation == "good")

# For specifying conditions for filtering, dplyr uses the following logical and mathematical operators: ==, !=, <, >, >=, <=, &, |, %in%, (etc.)

burials_clean |> 
  filter(depth_cm >= 175)

# PT: tejto premennej sú aj hodnoty 1500 

# watch the difference between & (AND) and | (OR)

burials_clean |> 
  filter(preservation == "good" & depth_cm >= 175)

burials_clean |> 
  filter(preservation == "good" | depth_cm >= 175)

# filtering by vector

table(burials_clean$age_category)

list_adults <- c("adult", "mature") 

burials_clean |> 
  filter(age_category %in% list_adults)

# negative filtering

burials_clean |> 
  filter(preservation != "poor")

### Important ------------------------------------------------------------------

# This code instantly returns dataframe with male graves only, but without saving the result
burials_clean |> 
  filter(sex == "male")

# This code saves all male burials_clean into new dataframe "male_burial", but is not showing the result
male_burials <- burials_clean |> 
  filter(sex == "male")

# To see the result, we need to add aditional line
male_burials <- burials_clean |> 
  filter(sex == "male")
male_burials


### select() -------------------------------------------------------------------
names(burials_clean)

burials_clean |> 
  select(grave_id, age_category, sex) |> 
  head(4)

# negative selecting

burials_clean |> 
  select(-excavation_year) |> 
  head(4)

# selecting variables from age_category to depth_cm
burials_clean |> 
  select(grave_id, age_category:depth_cm) |> 
  head(4)

### mutate() -------------------------------------------------------------------

# this function creates new columns that are calculated from existing ones 
# (i.e. the new columns are functions of the original variables)

# syntax:
#   dataframe |> mutate(variable_name = function())

# in the example below, a new column called "depth_m" is created by dividing the "depth_cm" column by 100

burials_clean |> 
  mutate(depth_m = depth_cm/100) |> 
  head(4)

# this example creates new variable "site_name" and adds value "Haithabu" to all rows

burials_clean |> 
  mutate(site_name = "Haithabu") |> 
  head(4)

### mutate() and case_when() ---------------------------------------------------

# you can create new variables with values based on conditions in other variables

burials_clean |> 
  mutate(depth_category = case_when(
    depth_cm < 100 ~ "shallow grave",
    depth_cm > 180 ~ "deep grave",
    .default = "normal grave"
  )) |> 
  head(4)

### summarise() and group_by() -------------------------------------------------
# lets say we want to know the average depth of the graves

# this code returns single value - the average depth of all graves

burials_clean |> 
  summarise(mean_depth = mean(depth_cm))

# it is not very helpfull so we will have a look on average depth based of sex of the buried individuals

burials_clean |>
  group_by(sex) |> 
  summarise(mean_depth = mean(depth_cm),
            n_graves = n()) |> 
  arrange(n_graves)


## adding table with the artefacts ---------------------------------------------

# We just got new data from fellow archaeologists, 
# which contains information about artefacts from the same burial site. 
# our colleagues had send us the file in excel format, 
# so now we will how to import ecxel sheets

### importing .xlsx file -------------------------------------------------------

# Download data from
# https://github.com/petrpajdla/intRo/blob/main/data/grave_goods.xlsx
# save it as XLSX in you working directory under /data/raw/

goods_url = "https://github.com/petrpajdla/intRo/raw/refs/heads/main/data/grave_goods.xlsx"
download.file(goods_url, destfile = here::here("data/raw/grave_goods.xlsx"))

goods <- readxl::read_xlsx("data/raw/grave_goods.xlsx")


### checking the variables -----------------------------------------------------

str(goods)

# the table goods contains information about individual artefacts found in the graves from the burials table
# lets try to connect it with the burials table

# first, we need to identify the key variables, that will allow us to create a relation between the two tables


str(goods)
str(burials_clean)

# we see that the key variables are "Context" from the table goods and "context" from the table burials_clean


### left_join() ----------------------------------------------------------------

# we will use the left_join() function to attach variables from the "goods" to the "burials_clean"
# the key will be specified using the "join_by()" attribute

burials_goods <- burials_clean |> 
  left_join(goods, join_by(context == Context))
head(burials_goods, 4)

# the result is combined table where each burial have also variables about the artefacts
# note that one burial can be now on more than one row and that the new table still includes burials without any artifacts

# for example, grave GO19 contains 3 artifacts:

burials_goods |> 
  filter(grave_id == "G019")

### checking the new data ------------------------------------------------------

str(burials_goods)

## reparing the numbers

burials_goods <- burials_goods |> 
  mutate(weight_g = as.numeric(weight_g))

## TASKS! ----------------------------------------------------------------------

### Task 1: female graves with weapons -----------------------------------------
# find out all female graves with weapons or armour and 
# create a new table showing number of weapons in each (female) grave

# hints: burials_goods$supercategory, filter(), group_by(), summarise()

table(burials_goods$artifact_type)

table(burials_goods$supercategory)

female_wariors <- burials_goods |> 
  filter(sex == "female" & supercategory == "weapons and armour") |> 
  group_by(grave_id) |> 
  count()

head(female_wariors, 10)


### Task 2: dating--------------------------------------------------------------
# Try to identify any problems with the variable "dating" and propose a solution


### Task 3: relocate() ---------------------------------------------------------

# what is the function "relocate()" doing here?

burials_goods |> 
  relocate(dating, .after = material) |> 
  head(4)

## Export data -----------------------------------------------------------------

# Write a CSV
write_csv(burials_clean, here::here("data/processed/burials_clean.csv")) 

# Write an XLX file
library(writexl)
write_xlsx(burials_goods, path = here::here("data/processed/burials_goods.xlsx"))


# BLOCK V: Plots ---------------------------------------------------------------

## Scatter plot ----------------------------------------------------------------

# New data
# Let´s briefly explore another basic type of plot: scatterplot 

# Relationship between two continuous variables (weight and length)

burials_goods |> 
  ggplot() +
  aes()


  
  







## Plot "beautification" -------------------------------------------------------
# Making publication-ready figures from our cleaned data

### Labels and titles ----------------------------------------------------------

# labs() adds titles, axis labels, and captions

burials_goods |>
  ggplot(aes(x = sex)) +
  geom_bar()












### Themes ---------------------------------------------------------------------

# Themes control the overall look (background, gridlines, fonts)

burials_goods |>
  ggplot(aes(x = sex)) +
  geom_bar()








# Other built-in themes: theme_bw(), theme_classic(), theme_light()

### Colour and fill ------------------------------------------------------------

# Map a variable to colour/fill to add a visual dimension

burials_goods |>
  ggplot(aes(x = age_category)) +
  geom_bar() 








# attribute "position"
# scale_fill_brewer() and scale_colour_manual() control palettes

### Faceting -------------------------------------------------------------------

# Split one plot into panels by a value of categorical variable


burials_clean |>
  ggplot(aes(x = sex)) +
  geom_bar()







## scatter plot ----------------------------------------------------------------


# Let´s subset iron weapons

iron <- burials_goods |> 
  filter(material == "iron" & artifact_type %in% c("knife", "sword", "spearhead"))|>
  drop_na()

# basic
  
  iron |> 
  ggplot() + 
  aes(x = length_mm, y = weight_g) +
  geom_point()
  
  





























## Box plot --------------------------------------------------------------------

burials_goods |> 
  ggplot() +
  aes(x = age_category, y = depth_cm) + 
  geom_boxplot()


# variable values as factor
# library(forcats)

burials_goods <- burials_goods |> 
  mutate(age_category = fct_relevel(age_category, "infant", "child", "mature", "adult", "NA"))


burials_goods |> filter(depth_cm < 1000) |> 
  ggplot() + 
  aes(x = age_category, y = depth_cm) + 
  geom_boxplot() +
  # geom_point(position = "jitter", alpha = 0.5, aes(colour = sex)) +
  theme_bw() +
  labs(title = "Grave depth by Age category",
       subtitle = "Early medieval graves",
       x = "Age category",
       y = "Depth (cm)",
       caption = "CAA 2026",
       colour = "Gender"
  ) 



## violin plot -----------------------------------------------------------------


burials_goods |> filter(depth_cm < 1000) |> 
  ggplot() +
  aes(x = age_category, y = depth_cm) + 
  geom_violin()

























## Reordering ------------------------------------------------------------------
# and tilting labels

burials_goods |> 
  ggplot() +
  aes(x = material) +
  geom_bar()








# Alphabetic order :( => fct_infreq !



## Percent stacked barchart ----------------------------------------------------

burials_goods |> 
  ggplot(aes(y = supercategory, fill = material)) + 
  geom_bar(position = "dodge")
  














  


## Plot export -----------------------------------------------------------------

ggsave(
  here::here("plots", "plotXY.png"),
  plot = pXY,
  width = 8,
  height = 6,
  dpi = 300
)




# BLOCK X: Time for practice or your own problems ------------------------------

# Time left? Lets practice with package "archdata"

# install.packages("archdata")
# library(archdata)
# data(DartPoints)

# Do you have any problems with your own data? 
# Let's try to solve them together!

