# CAA 2026
# From Zero to Plotting: R for Anyone
# March 31
#
# Workshop outline:
# BLOCK I   — Environment setup & packages           (Petr Pajdla)
# BLOCK II  — Data import, exploration & first plots (Vít Kozák)
# BLOCK III — Data cleaning & transformation         (Peter Tkáč & Petr Pajdla)
# BLOCK IV  — Plot beautification                    (Vít Kozák)

# -------------------------------------------------------------------------
# BLOCK I: Introduction ---------------------------------------------------
# -------------------------------------------------------------------------

# Introduction to R and RStudio/Positron ----------------------------------

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

# Project structure -------------------------------------------------------

# here::here() builds paths relative to the project root
# This keeps paths portable across machines

dir.create(here::here("data"))
dir.create(here::here("data/raw"))
dir.create(here::here("data/processed"))
dir.create(here::here("code"))
dir.create(here::here("plots"))

# Packages ----------------------------------------------------------------

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

# -------------------------------------------------------------------------
# BLOCK II: Reading and exploring data ------------------------------------
# -------------------------------------------------------------------------

# Data import, exploration & first visualisations
# Goal: get to know the dataset and identify data quality issues

# Data import -------------------------------------------------------------

# Download data from
# https://github.com/petrpajdla/intRo/blob/main/data/burials.csv
# save it as a CSV in you working directory under /data/raw/

burials_url = "https://raw.githubusercontent.com/petrpajdla/intRo/refs/heads/main/data/burials.csv"
download.file(burials_url, destfile = here::here("data/raw/burials.csv"))

burials <- read_csv(here::here("data/raw/burials.csv"))

# Explore data ------------------------------------------------------------

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


# Visualisation with ggplot2 ----------------------------------------------

# ggplot builds plots in layers: data + aesthetics + geometry
# We use simple plots here to spot data problems; beautification comes later

# Basics + barplot --------------------------------------------------------

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

# Using the pipe operator
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

# Histogram ---------------------------------------------------------------

# What is the distribution of grave pit depth?

burials |>
  ggplot(aes(x = Depth_cm)) +
  geom_histogram()

# Warning about missing values is expected — some depths are NA
# The distribution looks reasonable, but watch for extreme outliers
# (values like 1500 or 2200 cm are likely typos — 150 and 220 cm)

# Exercise: choose a geometry! ---------------------------------------------

# Anthropologists need a count of well-preserved individuals.
# What geometry will you choose?

burials |>
  ggplot(aes(x = Preservation)) +
  geom_bar()

# -> enough well-preserved skeletons, but values are inconsistent
#    ("GOOD", "Good", "good" are treated as separate categories)

# Exporting plots ---------------------------------------------------------

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


# -------------------------------------------------------------------------
# BLOCK III: Data cleaning and transformations ----------------------------
# -------------------------------------------------------------------------

# Data cleaning -----------------------------------------------------------

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

# Step 1: Clean column names ----------------------------------------------

# First option: rename by hand
burials |>
  rename(
    Grave_ID = "grave id",
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

# Step 2: Standardise preservation ----------------------------------------

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

# Step 3: Standardise sex -------------------------------------------------

# What values are in the sex column?
burials_clean |>
  count(sex)

# We have: ?, F, M, NA, empty string (""), unknown
# "?", "unknown", and "" all mean "we don't know" — let's unify them
# Note: empty strings ("") are NOT the same as NA — case_match's
# .default = NA_character_ catches them

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

# Step 4: Standardise orientation -----------------------------------------
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
# # Step 5: Convert character columns to factors ----------------------------

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

# Step 6: Check the result -----------------------------------------------

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

# Part II -----------------------------------------------------------------

## INDEPENDENT WORK ##

# We just got new data from fellow archaeologists.
# Use previous script to explore it and

goods <- readxl::read_xlsx("data/grave_goods.xlsx")
goods <- read_csv2(here::here("data/grave_goods.csv"))

good_counts <- goods |>
  group_by(Context, artifact_type) |>
  count() |>
  pivot_wider(
    values_from = n,
    id_cols = Context,
    names_from = artifact_type,
    values_fill = 0
  )

burials_clean |>
  left_join(good_counts, join_by(context == Context)) |>
  View()

# Export data -------------------------------------------------------------

write_csv(burials_clean, "./data/processed/burials.csv")
write_csv(goods, "./data/processed/goods.csv")

# -------------------------------------------------------------------------
# BLOCK IV: Plots ---------------------------------------------------------
# -------------------------------------------------------------------------

# Plot beautification
# Making publication-ready figures from our cleaned data

# Labels and titles -------------------------------------------------------

# labs() adds titles, axis labels, and captions

# burials_clean |>
#   ggplot(aes(x = sex)) +
#   geom_bar() +
#   labs(
#     title = "Sex distribution in the burial ground",
#     x = "Sex",
#     y = "Count",
#     caption = "Data: CAA 2026 workshop"
#   )

# Themes ------------------------------------------------------------------

# Themes control the overall look (background, gridlines, fonts)

# burials_clean |>
#   ggplot(aes(x = sex)) +
#   geom_bar() +
#   theme_minimal()

# Other built-in themes: theme_bw(), theme_classic(), theme_light()

# Colour and fill ---------------------------------------------------------

# Map a variable to colour/fill to add a visual dimension

# burials_clean |>
#   ggplot(aes(x = age_category, fill = sex)) +
#   geom_bar(position = "dodge")

# scale_fill_brewer() and scale_colour_manual() control palettes

# Faceting ----------------------------------------------------------------

# Split one plot into panels by a categorical variable

# burials_clean |>
#   ggplot(aes(x = depth_cm)) +
#   geom_histogram() +
#   facet_wrap(~ sex)
