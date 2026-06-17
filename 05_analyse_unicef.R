#Research Questions:
#Question 1: How does stunting in Southern Africa compare to global averages?
#Question 2: Has stunting improved over time in Southern Africa?
#Question 3: Is there a gender gap in STUNTING rates across Southern Africa?
#Question 4: Which Southern African countries have the highest burden of child malnutrition (most recent data)?
#NOTE: South Africa (ZAF) has no stunting/underweight data in this dataset-> only educational attainment. All nutrition questions therefore cover the broader Southern Africa region.

library(tidyverse)
library(ggplot2)
library(scales)

#Create a plots folder if it doesn't exist
dir.create("plots", showWarnings = FALSE)


#################################LOAD CLEAN DATA#####################################
wq <- read_csv("data/clean/unicef_clean.csv", show_col_types = FALSE)
wq

#Define Southern Africa countries (SADC region)
southern_africa_codes <- c(
  "ZAF", #South Africa
  "ZWE", #Zimbabwe
  "ZMB", #Zambia
  "MOZ", #Mozambique
  "MWI", #Malawi
  "NAM", #Namibia
  "BWA", #Botswana
  "LSO", #Lesotho
  "SWZ", #Eswatini
  "AGO", #Angola
  "MDG", #Madagascar
  "COM", #Comoros
  "MUS", #Mauritius
  "SYC"  #Seychelles
)

#Stunting indicators (two measures exist in this dataset)
stunting_codes <- c(
  "UNICEF_DW_FD_STUNTING",      #Moderate & severe stunting (functional difficulties)
  "UNICEF_DW_NT_ANT_HAZ_NE2"   #Height-for-age < -2 SD (standard WHO definition)
)

#Underweight indicator
underweight_code <- "UNICEF_DW_FD_UNDERWEIGHT"


#Question 1: HOW DOES STUNTING IN SOUTHERN AFRICA COMPARE TO GLOBAL AVERAGES? #high stunting prevalence percentage in the Southern African region. 
#Approach: Take the most recent value per country, calculate regional medians, compare Southern Africa vs rest of world

#Get most recent stunting value per country (using HAZ_NE2 = WHO standard)
stunting_latest <- wq %>%
  filter(
    indicator_code == "UNICEF_DW_NT_ANT_HAZ_NE2",
    sex == "Total",
    reliable == TRUE          #exclude low reliability records
  ) %>%
  group_by(country_code, country) %>%
  slice_max(year, n = 1) %>%  #keep only the most recent year per country
  ungroup() %>%
  mutate(
    region = if_else(country_code %in% southern_africa_codes,
                     "Southern Africa", "Rest of World")
  )

#Summary stats per region
q1_summary <- stunting_latest %>%
  group_by(region) %>%
  summarise(
    n_countries   = n(),
    median_stunting = median(value, na.rm = TRUE),
    mean_stunting   = mean(value, na.rm = TRUE),
    min_stunting    = min(value, na.rm = TRUE),
    max_stunting    = max(value, na.rm = TRUE),
    .groups = "drop"
  )

print("=== Q1: Regional Comparison ===")
print(q1_summary)

#PLOT Q1: Boxplot comparing Southern Africa vs World
plot_q1 <- ggplot(stunting_latest, aes(x = region, y = value, fill = region)) +
  geom_boxplot(width = 0.5, outlier.shape = 21, outlier.size = 2,
               outlier.alpha = 0.6) +
  geom_jitter(width = 0.15, alpha = 0.3, size = 1.5, colour = "grey40") +
  #Highlight Southern Africa countries by name
  geom_text(
    data = stunting_latest %>% filter(region == "Southern Africa"),
    aes(label = country),
    hjust = -0.15, size = 2.8, colour = "#1a3a5c"
  ) +
  scale_fill_manual(values = c("Southern Africa" = "#e07b00",
                               "Rest of World"   = "#2d6a9f")) +
  scale_y_continuous(labels = label_percent(scale = 1),
                     limits = c(0, NA)) +
  labs(
    title    = "Child Stunting: Southern Africa vs Global",
    subtitle = "Most recent available data per country | Height-for-age < -2 SD",
    x        = NULL,
    y        = "Stunting prevalence (%)",
    fill     = NULL,
    caption  = "Source: UNICEF Data Warehouse | Reliable observations only"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position  = "none",
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(colour = "grey50", size = 10),
    panel.grid.minor = element_blank()
  )

print(plot_q1)
ggsave("plots/Q1_southern_africa_vs_global.png", plot_q1,
       width = 9, height = 6, dpi = 300)


#Question 2: HAS STUNTING IMPROVED OVER TIME IN SOUTHERN AFRICA? In most countries, the stuntting has improved over time. Countries like Madagascar, mozambique, namibia, mauritus...
#Approach: Plot stunting trend for each Southern African country that has at least 2 data points over time

stunting_sa_trend <- wq %>%
  filter(
    indicator_code == "UNICEF_DW_NT_ANT_HAZ_NE2",
    country_code %in% southern_africa_codes,
    sex == "Total",
    reliable == TRUE
  ) %>%
  group_by(country) %>%
  filter(n() >= 2) %>%   #only countries with enough data to show a trend
  ungroup()

#How many countries have trend data? 14 
stunting_sa_trend %>% count(country)

#PLOT Question 2: Line chart — one line per country
plot_q2 <- ggplot(stunting_sa_trend,
                  aes(x = year, y = value,
                      colour = country, group = country)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_text(
    data = stunting_sa_trend %>% group_by(country) %>% slice_max(year, n=1),
    aes(label = country),
    hjust = -0.1, size = 3, fontface = "bold"
  ) +
  scale_y_continuous(labels = label_percent(scale = 1),
                     limits = c(0, NA)) +
  scale_x_continuous(breaks = seq(1990, 2025, 5),
                     expand = expansion(mult = c(0.02, 0.2))) +
  labs(
    title    = "Stunting Trends Over Time — Southern Africa",
    subtitle = "Countries with 2+ data points shown | Height-for-age < -2 SD",
    x        = "Year",
    y        = "Stunting prevalence (%)",
    colour   = NULL,
    caption  = "Source: UNICEF Data Warehouse"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position  = "none",
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(colour = "grey50", size = 10),
    panel.grid.minor = element_blank()
  )

print(plot_q2)
ggsave("plots/Q2_stunting_trends_southern_africa.png", plot_q2,
       width = 10, height = 6, dpi = 300)


#Question 3: Is there a gender gap in STUNTING rates across Southern Africa?

stunting_gender <- wq %>%
  filter(
    indicator_code == "UNICEF_DW_NT_ANT_HAZ_NE2",  #stunting
    country_code %in% southern_africa_codes,
    sex %in% c("Male", "Female"),
    reliable == TRUE
  ) %>%
  group_by(country_code, country, sex) %>%
  slice_max(year, n = 1) %>%
  ungroup()

#Pivot wide to calculate the gap
stunting_wide <- stunting_gender %>%
  group_by(country, sex) %>%
  summarise(value = mean(value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = sex, values_from = value) %>%
  mutate(
    gender_gap = Male - Female,
    direction = if_else(gender_gap > 0,
                        "Boys higher",
                        "Girls higher")
  )



print("=== Q3: Gender Gap in Stunting ===")
print(stunting_wide %>% arrange(desc(abs(gender_gap))))

# PLOT Q3: Dumbbell chart
plot_q3 <- stunting_gender %>%
  filter(country %in% stunting_wide$country) %>%
  ggplot(aes(x = value, y = reorder(country, value), colour = sex)) +
  geom_line(aes(group = country), colour = "grey70", linewidth = 1) +
  geom_point(size = 4) +
  scale_colour_manual(values = c("Male" = "#2d6a9f", "Female" = "#e07b00")) +
  scale_x_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "Gender Gap in Child Stunting - Southern Africa",
    subtitle = "Most recent data per country | Height-for-age < -2 SD",
    x        = "Stunting prevalence (%)",
    y        = NULL,
    colour   = NULL,
    caption  = "Source: UNICEF Data Warehouse"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position    = "top",
    plot.title         = element_text(face = "bold", size = 14),
    plot.subtitle      = element_text(colour = "grey50", size = 10),
    panel.grid.minor   = element_blank()
  )

print(plot_q3)
ggsave("plots/Q3_gender_gap_stunting.png", plot_q3,
       width = 9, height = 6, dpi = 300)



#Question 4: WHICH SOUTHERN AFRICAN COUNTRIES HAVE THE HIGHEST BURDEN OF CHILD MALNUTRITION (MOST RECENT DATA)?
#Approach: Combine stunting + underweight + wasting into one "burden" view using most recent data per country

#Indicators to include
burden_indicators <- c(
  "UNICEF_DW_NT_ANT_HAZ_NE2",   #Stunting
  "UNICEF_DW_FD_UNDERWEIGHT",    #Underweight
  "UNICEF_DW_NT_ANT_WHZ_NE2"    #Wasting
)

burden_labels <- c(
  "UNICEF_DW_NT_ANT_HAZ_NE2"  = "Stunting",
  "UNICEF_DW_FD_UNDERWEIGHT"   = "Underweight",
  "UNICEF_DW_NT_ANT_WHZ_NE2"  = "Wasting"
)


malnutrition_burden <- wq %>%
  filter(
    indicator_code %in% burden_indicators,
    country_code %in% southern_africa_codes,
    sex == "Total",
    urbanisation == "All areas",   # ADD THIS - removes urban/rural duplicates
    reliable == TRUE
  ) %>%
  group_by(country_code, country, indicator_code) %>%
  slice_max(year, n = 1, with_ties = FALSE) %>%  # ADD with_ties = FALSE
  ungroup() %>%
  mutate(
    indicator_short = burden_labels[indicator_code],
    data_year       = year
  )

# Now check duplicates are gone
malnutrition_burden %>%
  summarise(n = n(), .by = c(country, indicator_short)) %>%
  filter(n > 1L)




#Show the data table
print("=== Q4: Malnutrition Burden by Country ===")
malnutrition_burden %>%
  select(country, indicator_short, value, data_year) %>%
  pivot_wider(names_from = indicator_short, values_from = c(value, data_year)) %>%
  arrange(desc(value_Stunting)) %>%
  print()

#PLOT Question 4: Grouped bar chart — three indicators per country
plot_q4 <- ggplot(
  malnutrition_burden,
  aes(x = reorder(country, value), y = value,
      fill = indicator_short)
) +
  geom_col(position = "dodge", width = 0.7) +
  geom_text(
    aes(label = paste0(round(value, 1), "%")),
    position = position_dodge(width = 0.7),
    hjust = -0.1, size = 2.8
  ) +
  coord_flip() +
  scale_fill_manual(values = c(
    "Stunting"    = "#1a3a5c",
    "Underweight" = "#e07b00",
    "Wasting"     = "#c0392b"
  )) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    expand = expansion(mult = c(0, 0.2))
  ) +
  labs(
    title    = "Child Malnutrition Burden — Southern Africa",
    subtitle = "Most recent available data per country",
    x        = NULL,
    y        = "Prevalence (%)",
    fill     = NULL,
    caption  = "Source: UNICEF Data Warehouse | Note: data years vary by country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position  = "top",
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(colour = "grey50", size = 10),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

print(plot_q4)
ggsave("plots/Q4_malnutrition_burden_southern_africa.png", plot_q4,
       width = 10, height = 7, dpi = 300)


#Summary findings table — useful for your README


cat("\n========================================\n")
cat("KEY FINDINGS SUMMARY\n")
cat("========================================\n")

#Question 1
sa_median <- q1_summary %>% filter(region == "Southern Africa") %>% pull(median_stunting)
world_median <- q1_summary %>% filter(region == "Rest of World") %>% pull(median_stunting)
cat(paste0("\nQ1: Median stunting in Southern Africa = ", round(sa_median, 1),
           "% vs global median = ", round(world_median, 1), "%\n"))

#Question 4 - worst country
worst <- malnutrition_burden %>%
  filter(indicator_short == "Stunting") %>%
  slice_max(value, n = 1)
cat(paste0("\nQ4: Highest stunting burden = ", worst$country,
           " at ", worst$value, "% (", worst$data_year, ")\n"))

#Question 3 - average gap
avg_gap <- mean(abs(stunting_wide$gender_gap), na.rm = TRUE)
cat(paste0("\nQ3: Average male-female stunting gap = ",
           round(avg_gap, 1), " percentage points\n"))

cat("\nPlots saved to: plots/\n")
cat("Q1_southern_africa_vs_global.png\n")
cat("Q2_stunting_trends_southern_africa.png\n")
cat("Q3_gender_gap_stunting.png\n")
cat("Q4_malnutrition_burden_southern_africa.png\n")