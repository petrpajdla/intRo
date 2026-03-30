# CAA 2026
# From Zero to Plotting: R for Anyone
# March 31
#
# Workshop outline:
# BLOCK I   — Environment setup & packages           (Petr Pajdla)
# BLOCK II  — Data import, exploration & first plots (Vít Kozák)
# BLOCK III — Data cleaning & transformation         (Peter Tkáč & Petr Pajdla)
# BLOCK IV  — Plot beautification                    (Vít Kozák)


# BLOCK I: Introduction ---------------------------------------------------


## Introduction to R and RStudio/Positron ----------------------------------

# R is a smart calculator
# Use Ctrl/Cmd + Enter to run the line where your cursor is located
# Line starting with a # hash is commented, i.e. the code is not run
1 + 1
10 / 2
sqrt(9)

# Comparator operations return TRUE or FALSE
4 > 1
pi == 3.14

# Assignment operator is <-
# Value is assigned to an object, kind of a "save this thing under this name" operation
# Written with Alt + - shortcut
one <- 1
two <- 2
one + two
one == two

# Vector is the simplest array of values
# It is created using c() function
c(1, 2, 5)

# Vector always consists of values of the same type
c("a", "b", "c") # character strings
c(1.5, 2, pi) # continuous numeric values

# Create a vector called "numbers" with 5 random numbers
numbers <- c(8, 42, pi, 264.2, 0.1)
# View it by typing and evaluating the objects name
numbers

# Functions
# Functions do things on values or objects...
# function(argument1 = value1, argument2 = value2, ...)
mean(numbers)
max(numbers)
min(numbers)
sum(numbers)
length(numbers)
summary(numbers)
str(numbers)

# R is case sensitive
object <- "Hello World!"
OBJECT <- "HELLO WORLD!"

object == OBJECT

# More complex data can be stored in data frames
# Data frame is basically a table
df <- data.frame(
  numbers = 20:24,
  strings = c("a", "b", "c", "d", "e")
)

df

# Pull columns from data frames with $ dollarsign
df$numbers
df$strings

# Inspect the structure of your object using str() function
str(df)

## Project structure -------------------------------------------------------

# here::here() builds paths relative to the project root
# This keeps paths portable across machines

dir.create(here::here("data"))
dir.create(here::here("data/raw")) 
dir.create(here::here("data/processed"))
dir.create(here::here("code"))
dir.create(here::here("plots"))

## Packages ----------------------------------------------------------------

# Install packages (only needed once, then comment out):

# install.packages("readr")
# install.packages("readxl")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("janitor")
# install.packages("ggplot2")
# install.packages("tidyverse")

# Load packages (needed every session):

library(readr) # reading data (.csv)
library(readxl) # reading excel files (.xlsx)

library(dplyr) # data manipulation
library(tidyr) # tidying data
library(janitor) # cleaning data

library(ggplot2) # data visualisation, Grammar of Graphics

# Alternatively, load all at once with tidyverse:
# library(tidyverse) # includes dplyr, ggplot2, readr, tidyr, stringr, forcats, purrr, tibble


# BLOCK II: Reading and exploring data ------------------------------------


# Data import, exploration & first visualisations
# Goal: get to know the dataset and identify data quality issues

## Data import -------------------------------------------------------------

# Download data from
# https://github.com/petrpajdla/intRo/blob/main/data/burials.csv
# save it as a CSV in you working directory under /data/raw/

burials_url = "https://raw.githubusercontent.com/petrpajdla/intRo/refs/heads/main/data/burials.csv"
download.file(burials_url, destfile = here::here("data/raw/burials.csv"))

burials <- read_csv(here::here("data/raw/burials.csv"))

## Explore data ------------------------------------------------------------

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
distinct(burials, Sex)
distinct(burials, Preservation)
distinct(burials, orientation)


## Visualisation with ggplot2 ----------------------------------------------

# ggplot builds plots in layers: data + aesthetics + geometry
# We use simple plots here to spot data problems; beautification comes later

### Basics + barplot --------------------------------------------------------

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

# Using the pipe operator # PT: ja by som pipe operator nekombinoval v úvode ggplotu ale dal by som ho až na neskôr
# %>% (from magrittr / dplyr) or
# |> native R pipe (since R 4.1)
# It takes the left-hand side and passes it as the first argument to the right
burials |>
  ggplot(aes(x = Sex)) +
  geom_bar()

# What problems can you observe within this plot?
# -> inconsistent coding: NA, ?, empty string, "unknown" all mean "not known"

# What is the orientation of the graves?

burials |>
  ggplot(aes(x = orientation)) +
  geom_bar()

# -> mix of compass labels ("W-E") and degree values ("270")

# What was the most intensive excavation season?

burials |>
  ggplot(aes(x = Excavation_year)) +
  geom_bar()

# -> data look consistent here, no issues

### Histogram ---------------------------------------------------------------

# What is the distribution of grave pit depth?

burials |>
  ggplot(aes(x = Depth_cm)) +
  geom_histogram()

# Warning about missing values is expected — some depths are NA
# The distribution looks reasonable, but watch for extreme outliers
# (values like 1500 or 2200 cm are likely typos — 150 and 220 cm)

## Exercise: choose a geometry! ---------------------------------------------

# Anthropologists need a count of well-preserved individuals.
# What geometry will you choose?

burials |>
  ggplot(aes(x = Preservation)) +
  geom_bar()

# -> enough well-preserved skeletons, but values are inconsistent
#    ("GOOD", "Good", "good" are treated as separate categories)

## Exporting plots ---------------------------------------------------------

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



# BLOCK III: Data cleaning and transformations ----------------------------

## Data cleaning -----------------------------------------------------------

# Goal: fix the issues we spotted during exploration
# Later: data transformation, pivoting, joining

# Problems spotted during exploration:
# 1. Column names are inconsistent (spaces, mixed case)
# 2. Preservation has mixed case ("GOOD", "Good", "fair", "poor")
# 3. Sex has "?", "unknown", empty strings, and NA for missing values
# 4. Orientation mixes compass labels ("W-E") and degrees ("180")
# 5. Depth has likely typos (1500 cm, 2200 cm — probably 150 and 220)

# Let's inspect the column names first:
names(burials)

### Step 1: Clean column names ----------------------------------------------

# First option: rename by hand
burials |>
  rename(
    Grave_ID = "grave id", # PT: ja mám "grave.id"
    Orientation = "orientation"
  )

# Second option: use a package janitor
# janitor::clean_names() converts all column names to a consistent format:
# - lowercase
# - spaces replaced with underscores
# - special characters removed

burials_clean <- burials |>
  janitor::clean_names()

names(burials_clean)

# "grave id" became "grave_id" — no more backticks needed!

### Step 2: Standardise preservation ----------------------------------------

# What values are in the preservation column?
burials_clean |>
  count(preservation)

# We have: Fair, GOOD, Good, NA, Poor, fair, poor
# Let's make them all lowercase using str_to_lower() from stringr

burials_clean <- burials_clean |>
  mutate(preservation = stringr::str_to_lower(preservation))

# Check the result:
burials_clean |>
  count(preservation)

### Step 3: Standardise sex -------------------------------------------------

# What values are in the sex column?
burials_clean |>
  count(sex)

# We have: ?, F, M, NA, empty string (""), unknown
# "?", "unknown", and "" all mean "we don't know" — let's unify them
# Note: empty strings ("") are NOT the same as NA — case_match's
# .default = NA_character_ catches them # PT: nerozumiem tej poznámke: v kóde nižšie sa predsa z "" stane NA

# TODO: Polyfinality, if_else, case_when etc.
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
burials_clean |>
  count(sex)

### Step 4: Standardise orientation -----------------------------------------
# TODO: samostatná práce
# What values do we have?
burials_clean |>
  count(orientation)

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
      "90" ~ "E-W",
      "180" ~ "S-N",
      "270" ~ "W-E",
      .default = orientation
    )
  )

# Check:
burials_clean |>
  count(orientation)

# TODO: nepřevádět na factory
### Step 5: Convert character columns to factors ----------------------------

# # Factors represent categorical data with a fixed set of values (levels)
# # Useful for: controlling order in plots, preventing typos, statistical models

# burials_clean <- burials_clean |>
#   mutate(
#     sex = as.factor(sex),
#     preservation = as.factor(preservation),
#     orientation = as.factor(orientation),
#     age_category = factor(
#       age_category,
#       levels = c("infant", "child", "juvenile", "adult", "mature"),
#       ordered = TRUE
#     )
#   )

### Step 6: Check the result -----------------------------------------------

glimpse(burials_clean)

# TODO: Nedělat summarise across...
# How many NAs do we have per column?
# burials_clean |>
#   summarise(across(everything(), \(x) sum(is.na(x))))

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

# PT: niesú vyriešené NA v depth_cm
# burials_clean <- burials_clean |> 
# na.omit(depth_cm)


## Data transformation ------------------------------

### Overview -----------
# In this course, you will learn how to:
#   
# - select specific columns or remove them -- select()
# - create new columns and change the values based on different conditions -- mutate(), case_when()
# - filter specific rows based on various conditions -- filter()
# - order your rows from lowest to highest values (or vice versa) -- arrange()
# - group your data and calculate different summary statistics -- summarise(), group_by()
# - work with different functions more effectively with the pipe operator -- |>

### dplyr package ----------
# we will work with the dplyr package which uses tidy data logic (one variable = one column, one observation = one row,...)
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


### pipe operator |> -----------------

# The pipe operator |> allows you to combine various functions into one code chunk, making your code shorter and easier to read.

# syntax:
#  dataframe |> function_1(variable, condition) |> function_2(variable, condition)


# You can combine functions select(), filter() and head():

burials_clean |> 
  select(grave_id, age_category, sex, preservation) |> 
  filter(preservation == "good") |> 
  head(4)




### filter() function ------------

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

### Important --------------

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


### select() ------------
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

### mutate() ---------------

# this function creates new columns that are calculated from existing ones (i.e. the new columns are functions of the original variables)

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

### mutate() and case_when() --------------------

# you can create new variables with values based on conditions in other variables

burials_clean |> 
  mutate(depth_category = case_when(
    depth_cm < 100 ~ "shallow grave",
    depth_cm > 180 ~ "deep grave",
    .default = "normal grave"
  )) |> 
  head(4)



### summarise() and group_by() -----------
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


# Part II -----------------------------------------------------------------
# PT: kde je Part I?

## adding table with the artefacts --------

# We just got new data from fellow archaeologists, which contains information about artefacts from the same burial site. 
# our colleagues had send us the file in excel format, so now we will how to import ecxel sheets


### importing .xlsx file ----------

goods <- readxl::read_xlsx("data/grave_goods.xlsx")
#goods <- read_csv2(here::here("data/grave_goods.csv"))



### checking the variables ----

str(goods)

# the table goods contains information about individual artefacts found in the graves from the burials table
# lets try to connect it with the burials table

# first, we need to identify the key variables, that will allow us to create a relation between the two tables


str(goods)
str(burials_clean)

# we see that the key variables are "Context" from the table goods and "context" from the table burials_clean


### left_join() --------

# we will use the left_join() function to attach variables from the "goods" to the "burials_clean"
# the key will be specified using the "join_by()" attribute

burials_goods <- burials_clean |> 
  left_join(goods_clean, join_by(context == Context))
head(burials_goods, 4)

# the result is combined table where each burial have also variables about the artefacts
# note that one burial can be now on more than one row and that the new table still includes burials without any artifacts

# for example, grave GO19 contains 3 artifacts:

burials_goods |> 
  filter(grave_id == "G019")

### checking the new data -------

# PT: weight_g sú s čiarkou ako desatinnou čiarkou, potreba zjednotiť

str(burials_goods)


## Tasks! -------------------

### Task 1: female graves with weapons ---------------
# find out all female graves with weapons or armour and create a new table showing number of weapons in each (female) grave

# hints: burials_goods$supercategory, filter(), group_by(), summarise()

table(burials_goods$artifact_type)

table(burials_goods$supercategory)

female_wariors <- burials_goods |> 
  filter(sex == "female" & supercategory == "weapons and armour") |> 
  group_by(grave_id) |> 
  summarise(number_of_weapons = n())


### Task 2: dating--------------
# Try to identify any problems with the variable "dating" and propose a solution


### Task 3: relocate() ----------------

# what is the function "relocate()" doing here?

burials_goods |> 
  relocate(dating, .after = material) |> 
  head(4)

## Export data -------------------------------------------------------------

write_csv(burials_clean, "./data/processed/burials.csv") # PT: ja by som ten výsledný súbor taktiež premenoval aby bolo jasné že sú to už vyčistené data
write_csv(goods, "./data/processed/goods.csv")

# PT: alternatives 

library(writexl)

write_xlsx(burials_goods, path = here("data/burials_goods.xlsx"))


# CAA 2026

## Just Vítek things -------------------------------------------------------


library(readr) # reading data (.csv)
library(readxl) # reading excel files (.xlsx)

library(dplyr) # data manipulation
library(tidyr) # tidying data
library(janitor) # cleaning data

library(ggplot2) # data visualisation, Grammar of Graphics

library(forcats) # tools for work with categorical variables


## data --------------------------------------------------------------------


burials_url = "https://raw.githubusercontent.com/petrpajdla/intRo/refs/heads/main/data/burials.csv"

download.file(burials_url, destfile = here::here("data/raw/burials.csv"))

burials <- read_csv(here::here("data/raw/burials.csv"))

## Explore data ------------------------------------------------------------

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
distinct(burials, Sex)
distinct(burials, Preservation)
distinct(burials, orientation)




## Visualisation with ggplot2 ----------------------------------------------

# ggplot builds plots in layers: data + aesthetics + geometry
# We use simple plots here to spot data problems; beautification comes later

### Basics + barplot --------------------------------------------------------

# How many individuals of different sex are there in the burial ground?

# Layer 1: data
ggplot(data = burials)

# Layer 2: aesthetics — map a variable to a visual property
ggplot(data = burials, mapping = aes(x = Sex))

# Layer 3: geometry — choose how to represent the data
ggplot(data = burials, mapping = aes(x = Sex)) +
  geom_bar()

# Shorthand — ggplot knows the first argument is data, second is mapping
ggplot(burials, aes(x = Sex)) +
  geom_bar()

# Using the pipe operator

# |> (from magrittr / dplyr) or
# |> native R pipe (since R 4.1)
# It takes the left-hand side and passes it as the first argument to the right

burials |>
  ggplot(aes(x = Sex)) +
  geom_bar()

#or
burials |> 
  ggplot() +
  aes(x=Sex) + 
  geom_bar()


# What problems can you observe within this plot?
# -> inconsistent coding

# What is the orientation of the graves?

burials |>
  ggplot(aes(x = orientation)) +
  geom_bar()

# -> mix of compass labels ("W-E") and degree values ("270")

# What was the most intensive excavation season?

burials |>
  ggplot(aes(x = Excavation_year)) +
  geom_bar()

# -> data look consistent here, no issues

### Histogram ---------------------------------------------------------------

# What is the distribution of grave pit depth?

burials |>
  ggplot(aes(x = Depth_cm)) +
  geom_histogram()

burials |> 
  ggplot() +
  aes(x = Depth_cm) +
  geom_histogram()

# Warning about missing values is expected — some depths are NA
# The distribution looks reasonable, but watch for extreme outliers
# (values like 1500 or 2200 cm are likely typos — 150 and 220 cm)

## Exercise: choose a geometry! ---------------------------------------------

# Anthropologists need a count of well-preserved individuals.
# What geometry will you choose?

burials |>
  ggplot() +
  aes(x = Preservation)) +
  geom_???()
  
  
# -> enough well-preserved skeletons, but values are inconsistent
#    ("GOOD", "Good", "good" are treated as separate categories)

## Exporting plots ---------------------------------------------------------

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



# quick join - will be done by Peto ---------------------------------------
# 
# 
# burials_clean <- burials |>
#   janitor::clean_names()
# 
# goods <- read_csv2("./data/raw/grave_goods.csv")
# 
# 
# glimpse(burials_clean)
# glimpse (goods)
# 
# PT: neviem presne ako a prečo, ale keď som spojil tabulky goods a burials, tak sa length_mm automaticky zmenila na numeric a z fragment sa stali NA 
# goods_clean <- goods |>
#   janitor::clean_names() |> 
#   mutate(
#     length_mm = case_when(
#       length_mm == "fragment" | length_mm == "NA" ~ NA_character_,
#       TRUE ~ length_mm),
#     length_mm = as.numeric(length_mm))
# 
# 
# data <- left_join(burials_clean, goods_clean, by = "context")
# 
# str(data)







# BLOCK IV ----------------------------------------------------------------
# Vít Kozák 


## Scatter plot ------------------------------------------------------------

# New data
# Let´s briefly explore another basic type of plot: scatterplot 

# Relationship between two continuous variables (weight and length)

data |> 
  ggplot() +
  aes() +


  
  
data |> 
  ggplot() +
  aes(x = weight_g, y = length_mm) + 
  geom_point()



## Plot "beautification" ---------------------------------------------------
# Making publication-ready figures from our cleaned data

### Labels and titles -------------------------------------------------------

# labs() adds titles, axis labels, and captions

data |>
  ggplot(aes(x = sex)) +
  geom_bar()


data |>
  ggplot(aes(x = sex)) +
  geom_bar() +
  labs(
    title = "Sex distribution in the burial ground",
    x = "Sex",
    y = "Count",
    caption = "Data: CAA 2026 workshop"
  )

### Themes ------------------------------------------------------------------

# Themes control the overall look (background, gridlines, fonts)

data |>
  ggplot(aes(x = sex)) +
  geom_bar()



data |>
  ggplot(aes(x = sex)) +
  geom_bar() +
  theme_minimal()

# Other built-in themes: theme_bw(), theme_classic(), theme_light()

### Colour and fill ---------------------------------------------------------

# Map a variable to colour/fill to add a visual dimension

data |>
  ggplot(aes(x = age_category)) +
  geom_bar() 



data |>
  ggplot(aes(x = age_category, fill = sex)) +
  geom_bar(position = "dodge")


# attribute "position"
# scale_fill_brewer() and scale_colour_manual() control palettes

### Faceting ----------------------------------------------------------------

# Split one plot into panels by a value of categorical variable


burials_clean |>
  ggplot(aes(x = sex)) +
  geom_bar()


burials_clean |>
  ggplot(aes(x = sex)) +
  geom_bar() +
  facet_wrap(~ age_category)

## scatter plot ------------------------------------------------------------


# Let´s subset iron weapons

iron <- data |> 
  filter(material == "iron" & artifact_type %in% c("knife", "sword", "spearhead"))|>
  drop_na()

# basic
  
  iron |> 
  ggplot() + 
  aes(x = length_mm, y = weight_g) +
  geom_point()
  
  

#beuatiful

iron |> 
  ggplot() +
  aes(x = length_mm, y = weight_g, colour = artifact_type, shape = sex) +
  geom_point(size = 2) +
  geom_smooth(aes(group = 1), method = "lm") +
  scale_x_continuous(
    breaks = seq(0, 1000, by = 200),
    limits = c(100, 900)
  ) +
  scale_y_continuous(
    breaks= seq(0,1400, by = 200),
    limits = c(100, 1450)
  ) +
  scale_color_brewer(palette = "Set2") + #other values - different purpose (Set2, Accent, ...) +
  theme_bw() + 
  # facet_wrap(~age_catgory) +
  labs(title = "The relationship between length and weight",
       subtitle = "EM knives, swords and spearheads", 
       x = "Length (mm)",
       y = "Weight (g)",
       caption = "CAA 2026",
       colour = "Weapon type",
       shape = "Gender")



## Box plot ----------------------------------------------------------------

data |> 
  ggplot() +
  aes(x = age_category, y = depth_cm) + 
  geom_boxplot()


# variable values as factor
# library(forcats)

data <- data |> mutate(age_category = fct_relevel(age_category, "infant", "child", "mature", "adult", "NA"))


data |> filter(depth_cm < 1000) |> 
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



## violin plot -------------------------------------------------------------


data |> filter(depth_cm < 1000) |> 
  ggplot() +
  aes(x = age_category, y = depth_cm) + 
  geom_violin()





data |> filter(depth_cm < 1000) |> 
  ggplot() +
  aes(x = age_category, y = depth_cm) + 
  geom_violin() +
  geom_hline(yintercept = median(data$depth_cm, na.rm = TRUE), linetype = "dashed", linewidth = 1) +
  scale_y_continuous(
    breaks = seq(0, 200, by = 25),
    limits = c(50, 200)
  ) +
  geom_point(position = "jitter", alpha = 0.5, colour = "steelblue") +
  theme_bw() +
  labs(title = "Grave depth by Age category",
       subtitle = "Early medieval graves",
       x = "Age category",
       y = "Depth (cm)",
       caption = "CAA 2026",
       # fill = "Age category"
  )


## Reordering --------------------------------------------------------------
# + tilting labels

data |> 
  ggplot() +
  aes(x = material) +
  geom_bar()


data |> 
  ggplot() +
  aes(x = fct_infreq(material)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

# Alphabetic order :( => fct_infreq !



## Percent stacked barchart ------------------------------------------------

data |> 
  ggplot(aes(y = supercategory, fill = material)) + 
  geom_bar(position = "dodge")
  


data |> 
  drop_na(supercategory) |>
  drop_na(material) |> 
  ggplot(aes(y = supercategory, fill = material)) + 
  geom_bar(position = "fill") +
  labs(x = "Percentage",
       title = "Artifacts by material",
       subtitle = "Early medieval grave contexts",
       caption = "CAA 2026") +
  scale_fill_viridis_d(option = "turbo") +
  theme_classic() +
  theme(legend.position = "right")
  


## Plot export -------------------------------------------------------------

ggsave(
  here::here("plots", "plotXY.png"),
  plot = pXY,
  width = 8,
  height = 6,
  dpi = 300
)






# Time left? Lets practice with package "archdata"
# install.packages("archdata")
# library(archdata)
# data(DartPoints)



