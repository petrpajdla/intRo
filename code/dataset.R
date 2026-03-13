# Generate sample burial dataset for R workshop
# "From Zero to Plotting: R for Anyone"
# 2026-02-04
# by pajdla@arub.cz

set.seed(42) # For reproducibility

# Number of burials
n_burials <- 1215

# Generate main burials dataset (CSV)
burials <- data.frame(
  # Intentionally inconsistent column naming
  Grave_ID = paste0(
    "G",
    stringr::str_pad(1:n_burials, 3, side = "left", pad = "0")
  ),
  Context = paste0("C", 1000 + 1:n_burials),

  # Age categories with some NAs
  Age_category = sample(
    c("infant", "child", "adult", "mature", NA),
    n_burials,
    replace = TRUE,
    prob = c(0.15, 0.2, 0.4, 0.2, 0.05)
  ),

  # Sex with various ways to express "unknown"
  Sex = sample(
    c("M", "F", "?", NA, "", "unknown"),
    n_burials,
    replace = TRUE,
    prob = c(0.4, 0.4, 0.05, 0.05, 0.05, 0.05)
  ),

  # Orientation - mix of degrees and text, with NAs
  orientation = sample(
    c("90", "180", "270", "0", "E-W", "N-S", "W-E", NA),
    n_burials,
    replace = TRUE
  ),

  # Depth with some typos and NAs
  Depth_cm = c(
    sample(50:200, n_burials - 5, replace = TRUE),
    1500, # obvious typo (should be 150)
    45,
    NA,
    2200, # another typo (should be 220)
    NA
  )[sample(n_burials)], # shuffle

  # Preservation with inconsistent capitalization
  Preservation = sample(
    c("good", "Good", "GOOD", "fair", "Fair", "poor", "Poor", NA),
    n_burials,
    replace = TRUE
  ),

  # Excavation year
  Excavation_year = sample(2019:2023, n_burials, replace = TRUE)
)

# burials |> tibble::tibble()

# Introduce some column name variations for a few rows
# (simulating merged data from different seasons)
colnames(burials)[1] <- "grave id" # Will need renaming

# Write CSV
write.csv(
  burials,
  here::here("data", "burials.csv"),
  row.names = FALSE,
  na = ""
)


# Generate grave goods inventory dataset (XLSX - wide format that needs pivoting)
# Each row is an individual artifact find

# Define artifact types with their categories
artifact_types <- data.frame(
  artifact = c(
    "sword",
    "spearhead",
    "shield boss",
    "knife",
    "axe",
    "pottery fragment",
    "pottery vessel",
    "bone fragment",
    "loom weight",
    "bead",
    "bracelet",
    "ring",
    "pendant",
    "fibula",
    "pin",
    "bone comb",
    "belt buckle",
    "textile fragment"
  ),
  supercategory = c(
    "weapons and armour",
    "weapons and armour",
    "weapons and armour",
    "tools",
    "tools",
    "common find",
    "common find",
    "common find",
    "common find",
    "adornment",
    "adornment",
    "adornment",
    "adornment",
    "clothing",
    "clothing",
    "clothing",
    "clothing",
    "clothing"
  ),
  stringsAsFactors = FALSE
)

# Generate individual artifact records
# Not all contexts have finds, and some have multiple
n_artifacts <- round(n_burials * 0.88) # Total artifact count


# Generate artifact types first
artifact_type <- sample(artifact_types$artifact, n_artifacts, replace = TRUE)

material_map <- list(
  "sword" = c("iron"),
  "spearhead" = c("iron", "bronze"),
  "shield boss" = c("iron", "bronze"),
  "knife" = c("iron"),
  "axe" = c("iron"),
  "pottery fragment" = c("ceramic"),
  "pottery vessel" = c("ceramic"),
  "bone fragment" = c("bone"),
  "loom weight" = c("ceramic", "stone", "bone"),
  "bead" = c("glass", "amber", "bone", "ceramic"),
  "bracelet" = c("bronze", "copper alloy"),
  "ring" = c("bronze", "copper alloy", "silver"),
  "pendant" = c("bronze", "copper alloy", "silver", "amber", "bone"),
  "fibula" = c("bronze", "copper alloy", "silver", "copper"),
  "pin" = c("bronze", "copper alloy", "bone", "copper"),
  "bone comb" = c("bone"),
  "belt buckle" = c("iron", "bronze", "copper alloy"),
  "textile fragment" = c("textile")
)

weight_map <- list(
  "sword" = list(mean = 900, sd = 150),
  "spearhead" = list(mean = 380, sd = 80),
  "shield boss" = list(mean = 340, sd = 100),
  "knife" = list(mean = 120, sd = 40),
  "axe" = list(mean = 600, sd = 150),
  "pottery fragment" = list(mean = 80, sd = 30),
  "pottery vessel" = list(mean = 600, sd = 200),
  "bone fragment" = list(mean = 15, sd = 10),
  "loom weight" = list(mean = 180, sd = 50),
  "bead" = list(mean = 5, sd = 2),
  "bracelet" = list(mean = 30, sd = 10),
  "ring" = list(mean = 8, sd = 3),
  "pendant" = list(mean = 12, sd = 5),
  "fibula" = list(mean = 18, sd = 6),
  "pin" = list(mean = 10, sd = 4),
  "bone comb" = list(mean = 25, sd = 8),
  "belt buckle" = list(mean = 45, sd = 15),
  "textile fragment" = list(mean = 20, sd = 8)
)

length_map <- list(
  "sword" = list(mean = 750, sd = 80),
  "spearhead" = list(mean = 300, sd = 60),
  "shield boss" = list(mean = 160, sd = 30),
  "knife" = list(mean = 180, sd = 40),
  "axe" = list(mean = 180, sd = 40),
  "pottery fragment" = list(mean = 60, sd = 20),
  "pottery vessel" = list(mean = 220, sd = 60),
  "bone fragment" = list(mean = 40, sd = 20),
  "loom weight" = list(mean = 70, sd = 15),
  "bead" = list(mean = 12, sd = 4),
  "bracelet" = list(mean = 70, sd = 10),
  "ring" = list(mean = 22, sd = 3),
  "pendant" = list(mean = 35, sd = 10),
  "fibula" = list(mean = 50, sd = 15),
  "pin" = list(mean = 80, sd = 20),
  "bone comb" = list(mean = 100, sd = 20),
  "belt buckle" = list(mean = 45, sd = 10),
  "textile fragment" = list(mean = 60, sd = 25)
)

grave_goods <- data.frame(
  Context = sample(burials$Context, n_artifacts, replace = TRUE),

  artifact_type = artifact_type,

  material = mapply(
    function(art) {
      choices <- material_map[[art]]
      # small chance of NA or empty string for any type
      if (runif(1) < 0.05) {
        return(sample(c(NA, ""), 1))
      }
      sample(choices, 1)
    },
    artifact_type
  ),

  weight_g = {
    weights <- mapply(
      function(art) {
        if (runif(1) < 0.05) {
          return(NA_real_)
        }
        p <- weight_map[[art]]
        abs(round(rnorm(1, mean = p$mean, sd = p$sd), 1))
      },
      artifact_type
    )
    # Introduce a couple of obvious typos
    typo_idx <- sample(length(weights), 2)
    weights[typo_idx] <- weights[typo_idx] * c(10, 0.01)
    weights
  },

  # Length in mm (some missing, some as "fragment")
  length_mm = vapply(
    artifact_type,
    function(art) {
      r <- runif(1)
      if (r < 0.03) {
        return("fragment")
      }
      if (r < 0.08) {
        return(NA_character_)
      }
      p <- length_map[[art]]
      as.character(round(max(1, abs(rnorm(1, mean = p$mean, sd = p$sd))), 0))
    },
    character(1)
  ),

  # Dating - mix of specific and broad periods, some contradictory, some NA
  dating = sample(
    c(
      "Early Medieval",
      "early medieval",
      "9th century",
      "10th century",
      "9th-10th century",
      "Viking Age",
      "Late Iron Age",
      "medieval",
      "undated",
      NA,
      ""
    ),
    n_artifacts,
    replace = TRUE,
    prob = c(0.15, 0.1, 0.15, 0.15, 0.2, 0.1, 0.05, 0.03, 0.03, 0.02, 0.02)
  )
)


# Add supercategory by matching artifact types
grave_goods$supercategory <- artifact_types$supercategory[
  match(grave_goods$artifact_type, artifact_types$artifact)
]

# Reorder columns for better readability
grave_goods <- grave_goods[, c(
  "Context",
  "artifact_type",
  "supercategory",
  "material",
  "weight_g",
  "length_mm",
  "dating"
)]

# Introduce some weight outliers/typos
grave_goods$weight_g[sample(nrow(grave_goods), 2)] <- c(4500, 8.5) # Obvious errors

# Write XLSX
readr::write_excel_csv2(grave_goods, here::here("data", "grave_goods.csv"))
