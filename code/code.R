### CAA 2026
## Pajdla - TKáč - Kozák
# From Zero to Plotting: R for Anyone
# March 31

# -------------------------------------------------------------------------
# BLOCK I -----------------------------------------------------------------
# Petr Pajdla -------------------------------------------------------------
# -------------------------------------------------------------------------
      
      # Introduction
      # Environment
      # Preparing environment
      # Installing packages
      # Loading packages

      # 1+1 etc.

# Environment preparation -------------------------------------------------

dir.create("./data")
dir.create("./data/raw")
dir.create("./data/processed")
dir.create("./code")
dir.create("./plots")

# packages ----------------------------------------------------------------

# install.packages("readr")
# install.packages("readxl")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("janitor")
# install.packages("ggplot2")
# install.packages("tidyverse")

library(readr)      # reading data (.csv)
library(readxl)     # reading excel files (.xslx)

library(dplyr)      # data manipulation
library(tidyr)      # tidying data
library(janitor)    # clearing data

library(ggplot2)    # data visualisation, Grammar of Graphics

library(tidyverse)  # collection of several useful packages (dplyr, ggplot2, readr, tidyr, stringr, forcats, purrr, tibble)


# -------------------------------------------------------------------------
# BLOCK II ----------------------------------------------------------------
# Vít Kozák ---------------------------------------------------------------
# -------------------------------------------------------------------------


# Overview ----------------------------------------------------------------
     
      # Loading data
      # Exploring data
        # through visualisation - ggplot
      # Identifying problems


# Data import -------------------------------------------------------------

# Download data from "https://www.our-data.com" and move it to raw data repository

burials <- read_csv("./data/raw/burials.csv")

# Explore data ------------------------------------------------------------

burials
head(burials,4)
tail(burials, 4)

# How many variables do we have in the data frame?

ncol(burials)

# How many observations are there in the data frame?

nrow(burials)

# What variables are there?

names(burials)

# When did these excavations start and end?

min(burials$Excavation_year)
max(burials$Excavation_year)


# -------------------------------------------------------------------------
# Visualisation -----------------------------------------------------------

# Let´s explore our data through visualisation
# Let´s use ggplot!


# Basics + barplot --------------------------------------------------------

##
# How many individuals of different sex are there in the burial ground?

# data
ggplot(data = burials)

# aesthetics mapping
ggplot(data = burials, mapping = aes(x = Sex))

# geometry
ggplot(data = burials, mapping = aes(x = Sex)) + 
  geom_bar()

# shortened
ggplot(burials,aes(x = Sex)) +      # ggplot recognises that first argument is always data and so on...
  geom_bar()

# using pipeline operator
burials %>% 
  ggplot(aes(x = Sex)) +            # pipeline operator takes what is on left side and passes it on to the right side (here argument "data")
  geom_bar()


# For now, let's stick with basic graphs to identify problems in the dataset. Plots beuitification time will come after lunch.

# What problems can you observe within this plot?
  # inconsistent coding of unknown/not filled values (NA, ?. unknown)

##
# What is orientation of the graves?

burials %>% 
  ggplot(aes(x = orientation)) +
  geom_bar()

  # inconsistent coding of orientation

##
# What was the most intensive excavation season?

burials %>% 
  ggplot(aes(x = Excavation_year)) +
  geom_bar()

  # Data are ok here

# Histogram ---------------------------------------------------------------

##
# What is distribution of grave pit depth?

burials %>% 
  ggplot(aes(x = Depth_cm)) +
  geom_histogram()

  # depth values seems to be ok. Warning message: missing values


# Boxplot -----------------------------------------------------------------

##
# Are there differences in grave depth across age categories?
# !!! Two variables !!!

str(burials)

burials %>% 
  ggplot(aes(x = Age_category, y = Depth_cm)) +
  geom_boxplot()

  # Median seems to be higher within infant categories
  # Results distorted by inconsistent category values


# Choose geometry! --------------------------------------------------------

##
# Anthropologists asked us for number of well preserved indivduals suitable for certain analyses
# What geometry will you chose?

burials %>% 
  ggplot(aes(x = Preservation)) +
  geom_bar()

  # It seems there is enough well preserved skeletons
  # However, there are again inconsistently employed values. Will fix it soon

# Anthropologists are asking us for the plot (they are in hurry). Let´s export it:

ggsave("plot1.png")

# we can have more control over the result:

p1 <- burials %>% 
  ggplot(aes(x = Preservation)) +
  geom_bar()


ggsave("./plots/plot1.png", plot = p1, width = 8, height = 6, dpi = 300)



# -------------------------------------------------------------------------
# BLOCK III ---------------------------------------------------------------
# Peter Tkáč  -------------------------------------------------------------
# Petr Pajdla -------------------------------------------------------------
# -------------------------------------------------------------------------


# Part I ------------------------------------------------------------------

      # cleaning data
      # Data transformation
      # Pivoting


# Part II -----------------------------------------------------------------

## INDEPENDENT WORK ##

# We just got new data from fellow archaeologists.
# Use previous script to explore it and 

goods <- read_xlsx("./data/raw/grave_goods.xlsx")




# Export data -------------------------------------------------------------

write_csv(burials, "./data/processed/burials.csv")
write_csv(goods, "./data/processed/goods.csv")


# -------------------------------------------------------------------------
# BLOCK IV ----------------------------------------------------------------
# Vít Kozák ---------------------------------------------------------------
# -------------------------------------------------------------------------
      

      # Plots Beutification
      # Will be work on when transformation and merging part is done

