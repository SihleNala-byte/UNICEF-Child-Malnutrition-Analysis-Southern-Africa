#  UNICEF Child Malnutrition Analysis - Southern Africa

An exploratory data analysis of child malnutrition indicators across Southern Africa, using UNICEF's global nutrition dataset spanning 1970–2023. The analysis investigates stunting trends, gender gaps, and the regional burden of malnutrition across 200 countries, with a focused lens on the Southern African region.



---

##  Background & Motivation

Child malnutrition remains one of the most persistent development challenges in Sub-Saharan Africa. Stunting, a marker of chronic undernutrition, affects millions of children under five and has lifelong consequences for cognitive development, educational outcomes, and economic productivity.

This project uses publicly available UNICEF data to answer four targeted questions about the state of child malnutrition in Southern Africa, comparing the region to global benchmarks, tracking progress over time, examining gender disparities, and identifying which countries carry the highest burden.

---

##  Research Questions

| # | Question |
|---|---|
| Q1 | How does stunting in Southern Africa compare to global averages? |
| Q2 | Has stunting improved over time in Southern Africa? |
| Q3 | Is there a gender gap in stunting rates across Southern Africa? |
| Q4 | Which Southern African countries have the highest burden of child malnutrition? |

---

##  Data Source

**UNICEF Data Warehouse (DW)**
Accessed at [data.unicef.org](https://data.unicef.org)

> UNICEF Data Warehouse (2025). *Child nutrition indicators, global dataset.* Retrieved from https://data.unicef.org

- **Coverage:** 200 countries | 16 indicators | 1970–2023
- **Format:** Single CSV export | 27,893 rows
- **Access:** Publicly available, no login required

### Variables Used

| Variable | Column Name | Description |
|---|---|---|
| Country | `country` | Country name |
| Country code | `country_code` | ISO 3-letter code (e.g. ZWE) |
| Indicator | `indicator_code` | Which nutrition measure |
| Sex | `sex` | Male / Female / Total |
| Age group | `age_group` | Under-5 children |
| Urbanisation | `urbanisation` | All areas / Urban / Rural |
| Year | `year` | Survey or estimate year |
| Value | `value` | Prevalence (%) |
| Data quality flag | `obs_status` | Reanalysed / Low reliability / Reported |
| Data source | `data_source` | e.g. DHS_2019, MICS_2022 |
| Reliable flag | `reliable` | TRUE/FALSE: excludes low reliability records |

### Key Indicators

| Indicator Code | What It Measures | Used In |
|---|---|---|
| UNICEF_DW_NT_ANT_HAZ_NE2 | Stunting: Height-for-age < -2 SD (WHO standard) | Q1, Q2, Q3 |
| UNICEF_DW_FD_UNDERWEIGHT | Underweight (functional difficulties measure) | Q4 |
| UNICEF_DW_NT_ANT_WHZ_NE2 | Wasting: Weight-for-height < -2 SD | Q4 |

---

##  Key Findings

### Q1 - Southern Africa vs Global Stunting
- Southern Africa's median stunting prevalence was **notably higher** than the global median
- Countries like **Mozambique, Madagascar, and Malawi** pulled the regional median up significantly
- **Mauritius and Seychelles** were close to or below the global median, highlighting enormous development inequality within the region
- The regional boxplot showed a **wider spread** than the global distribution, indicating high between-country inequality

### Q2 - Stunting Trends Over Time
- A **mixed picture** - no single regional trend
- **Improving:** Malawi, Zambia, Zimbabwe - all show declining stunting over 10-20 year periods (typically 0.5-1.5 percentage points per year)
- **Persistently high:** Madagascar and Mozambique remained above 40% across multiple decades
- **No Southern African country** has reached the WHO global nutrition target of <10% stunting

### Q3 - Gender Gap in Stunting
- A consistent pattern: **boys are more stunted than girls** across most Southern African countries
- The male-female gap was typically **2-5 percentage points**, with boys on the higher side
- This aligns with global literature, boys under 5 are biologically more vulnerable to growth faltering
- No country showed girls significantly more stunted than boys

### Q4 - Country-Level Malnutrition Burden
- **Madagascar** had the highest stunting burden, consistently above 40%
- **Mozambique and Malawi** followed closely, both above 35%
- Wasting told a different story, some countries with moderate stunting had relatively high wasting, indicating acute rather than chronic undernutrition
- **Botswana and Namibia** showed the lowest malnutrition burden, reflecting higher income levels and better nutrition programmes

---

##  Data Limitations

- **South Africa (ZAF) had no nutrition data** in this dataset, only educational attainment indicators were present. All analysis therefore focused on the broader Southern Africa region. This reflects a genuine data gap, not an analytical error.
- Data years varied significantly by country, some values from 2018–2020, others earlier, so cross-country comparisons should be interpreted cautiously.
- Underweight data was only available for 6 countries (Comoros, Eswatini, Lesotho, Madagascar, Malawi, Zimbabwe), limiting its use in regional comparisons.
- The gender gap analysis (Q3) used stunting rather than the originally planned underweight indicator, as underweight had no sex disaggregation in this dataset.

---

##  Tools & Technologies

| Tool | Purpose |
|---|---|
| R | Core analysis and data wrangling |
| tidyverse | Data manipulation and cleaning |
| ggplot2 | Data visualisation |
| dplyr | Filtering, grouping, summarising |
| ggalt | Dumbbell charts (Q3 gender gap) |

---

##  Visualisations

| Chart | Question |
|---|---|
| Boxplot - regional vs global stunting distribution | Q1 |
| Line chart - stunting trends per country over time | Q2 |
| Dumbbell chart - male vs female stunting gap | Q3 |
| Grouped bar chart - stunting & wasting burden by country | Q4 |

---

##  Repository Structure

```
unicef-child-malnutrition/
├── analysis.R              # Full analysis script
├── data/                   # Raw CSV from UNICEF Data Warehouse
├── outputs/                # Exported charts and figures
├── assets/                 # README images
└── README.md
```

---

##  Running Locally

```r
# Install dependencies
install.packages(c("tidyverse", "ggplot2", "dplyr", "ggalt"))

# Run the analysis
source("analysis.R")
```

---

##  Author

**Sihle** : MSc Environmental Science | Data Analyst
