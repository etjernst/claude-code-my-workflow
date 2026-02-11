# Data Acquisition: Paper 1 — The Productive Cost of Salty Water

## Overview

This paper estimates the causal effect of irrigation water salinity on agricultural productivity using the staggered commissioning of 14 salt interception schemes (SIS) along the lower Murray River (1991–2014) as instruments for downstream EC changes. The unit of observation for the second stage is SA2 × year. The first stage operates at monitoring-station × day/month.

---

## Step 1: Build the Treatment Variable — SIS Commissioning Dates and Locations

**Goal:** A table with 14 rows: scheme name, lat/lon, commissioning date, expected EC reduction at Morgan (μS/cm), managing jurisdiction.

**Sources:**
- MDBA SIS overview page: https://www.mdba.gov.au/climate-and-river-health/water-quality/salinity/managing-salinity
  - Lists all 14 schemes by name: Waikerie, Qualco-Sunlands, Woolpunda, Loxton, Bookpurnong, Pike, Murtho, Rufus River, Mildura-Merbein, Buronga, Mallee Cliffs, Upper Darling, Barr Creek, Pyramid Creek
- MDBA factsheets (PDF per scheme): https://www.mdba.gov.au/sites/default/files/pubs/Salt_interception_scheme_River_Murray.pdf
  - Each factsheet reports commissioning year and EC credit at Morgan
- Hart et al. (2020), "Salinity Management in the Murray–Darling Basin, Australia," *Water* 12(6):1829 — contains a timeline figure and EC reduction estimates per scheme
- BSM2030 annual reports contain the salinity register with scheme-by-scheme credits. Request from MDBA if not published online.

**Action items:**
1. Download all MDBA SIS factsheet PDFs and extract commissioning dates
2. Cross-check dates against Hart et al. (2020) Table/Figure data
3. Geocode each scheme (bore-field centroid) using MDBA spatial data or Google Earth
4. Record expected EC reduction at Morgan from the MDBA salinity register

---

## Step 2: Water Quality Monitoring Data (First Stage)

**Goal:** Daily or sub-daily EC readings at all monitoring stations along the Murray River and key tributaries, 1980–present.

**Sources (by jurisdiction):**

### NSW — WaterNSW
- **API portal:** https://api-portal.waternsw.com.au/
  - Register for free API key. Two relevant APIs:
    - *Surface Water Data API* — time-series EC data (variable code 2010.00 = EC in μS/cm)
    - *Water Quality External API* — field and lab sample WQ data
  - Documentation (community): https://github.com/andrewcowley/WaterNSW-data-API-documentation
  - Base URL: `https://realtimedata.waternsw.com.au/cgi/webservice.pl`
  - Key function: `get_ts_traces` with `varfrom=2010.00` and `varto=2010.00`
- **Interactive portal:** https://realtimedata.waternsw.com.au/
- Key stations: Euston, Wentworth, downstream Murray sites in NSW

### Victoria — Water Measurement Information System (WMIS)
- **Portal:** https://data.water.vic.gov.au/
  - Provides continuous EC at Victorian gauging stations
  - Key stations: Kerang, Swan Hill, Echuca, Yarrawonga
- Contact DEECA (Dept. of Energy, Environment and Climate Action) for historical data requests if portal coverage is limited

### South Australia — SA Water / DEW
- **Portal:** https://water.data.sa.gov.au/
  - Key stations: Morgan (the basin reference point for salinity), Murray Bridge, Berri, Renmark, Loxton
  - Morgan EC is the single most important time series — verify daily coverage from ~1980

### MDBA River Murray Water Quality Monitoring Program
- 28 sites along the Murray and tributaries
- Data available via WaterNSW and Victorian WMIS (above)
- MDBA page: https://www.mdba.gov.au/water-management/river-operations/water-quality/monitoring
- If gaps remain, submit a formal data request to MDBA

### Bureau of Meteorology — Water Data Online
- **Portal:** https://www.bom.gov.au/waterdata/
  - Nationally consistent discharge and level data (~3,500 stations)
  - EC data coverage is limited here — use state portals for WQ
  - Use BOM for **streamflow** data (needed as a control variable)

**Action items:**
1. Register for WaterNSW API. Pull daily EC for all Murray stations from 1980 to present.
2. Download Victorian WMIS EC data for all Murray/tributary stations
3. Download SA DEW data for Morgan and upstream SA stations
4. Download BOM daily streamflow for all corresponding gauging stations (control variable)
5. Compile station metadata: lat/lon, river km from Morgan, upstream SIS identifiers
6. Identify which monitoring stations are upstream vs. downstream of each SIS

---

## Step 3: Agricultural Outcome Data (Second Stage)

**Goal:** SA2-level panel of agricultural output, crop composition, and land values, covering ~1990–2023.

### ABS Agricultural Census
- **Available waves:** 2000–01, 2005–06, 2010–11, 2015–16, 2020–21
- **TableBuilder (free, aggregate):** https://www.abs.gov.au/statistics/microdata-tablebuilder
  - Cat. 7121.0 — Agricultural Commodities, Australia
  - Extract SA2-level: gross value of production by commodity, area planted by crop, irrigation status
- **Microdata via DataLab (detailed, restricted):** https://www.abs.gov.au/statistics/microdata-tablebuilder/datalab
  - Required for farm-level analysis. Application process:
    1. Organisation needs a Responsible Officer Undertaking (ROU) with ABS
    2. Submit project proposal via https://mydataportal.abs.gov.au/
    3. Complete safe researcher training
    4. Timeline: ~1 month for standard data; longer for integrated data
  - The Farm-level Longitudinal Analysis Dataset (FLAD) in BLADE contains census + survey data from 2000–01 onward, linked at the business level
  - Contact: info@mydata.abs.gov.au

### ABS Value of Agricultural Commodities Produced (VACP)
- Cat. 7503.0 — annual, SA2-level, more temporal frequency than the census
- Available via ABS.Stat or TableBuilder
- https://www.abs.gov.au/statistics/industry/agriculture

### ABARES Farm Survey Data
- **Farm Data Portal (aggregate, free):** https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data
  - Broadacre and dairy farm survey results by region
  - ABARES Australian Gridded Farm Data (model-predicted outcomes on 5km grid)
- **Murray-Darling Basin Irrigation Survey** — specifically targets irrigation farms across MDB
- **Microdata access:** Negotiate directly with ABARES. Contact: abares@agriculture.gov.au
  - ABARES farm-level data are not in ABS DataLab — separate access agreement needed

### Land Values
- State valuation offices:
  - **NSW:** Valuer General NSW — https://www.valuergeneral.nsw.gov.au/ (property sales data)
  - **VIC:** Valuer-General Victoria — land value data
  - **SA:** Office of the Valuer-General SA
- Alternative: ABS Cat. 6416.0 (House Price Indexes) — too coarse. Rural land values better from state valuers.

**Action items:**
1. Pull SA2-level VACP and Agricultural Census tables from ABS TableBuilder for all MDB SA2s, all available years
2. Apply for ABS DataLab access to BLADE/FLAD for farm-level panel
3. Contact ABARES to discuss MDB Irrigation Survey microdata access
4. Request rural land sales data from NSW/VIC/SA Valuer Generals for SA2s along the Murray

---

## Step 4: Water Market Data

**Goal:** Allocation and entitlement trade data (price, volume, origin, destination) for the southern MDB, 2000–present.

**Sources:**
- **ABARES MDB Water Market Catchment Dataset (2021)**
  - **Direct download:** https://www.agriculture.gov.au/abares/research-topics/water/mdb-water-market-dataset
  - Supply tables (XLSX, 128KB) and Demand tables (XLSX, 577KB)
  - Covers 2000–01 to 2020–21 by catchment: allocations, carryover, prices, trade flows, irrigation activity
  - This is the single best pre-assembled dataset for the water market analysis
- **BOM Water Markets Dashboard:** https://www.bom.gov.au/water/market/
  - Trade-level records: entitlement and allocation trades by trading zone
  - Annual water market reports: https://www.bom.gov.au/water/market/reports.shtml
- **State water registers (raw trade data):**
  - NSW: WaterNSW water register
  - VIC: Victorian Water Register (Goulburn-Murray Water, Northern Victoria Resource Manager)
  - SA: SA Dept. for Environment and Water

**Action items:**
1. Download ABARES MDB catchment dataset (supply + demand XLSX files)
2. Download BOM water market trade data for southern MDB trading zones
3. If trade-level spatial detail needed beyond catchment aggregates, request from state water registers

---

## Step 5: Spatial Linkage Data

**Goal:** Link SIS locations → monitoring stations → SA2 agricultural areas along the river network.

**Sources:**
- **BOM Australian Hydrological Geospatial Fabric (Geofabric)**
  - https://www.bom.gov.au/water/geofabric/
  - Digitised river network with catchment boundaries, flow direction, connectivity
  - Enables: "which monitoring stations are downstream of which SIS?" and "which SA2s draw water from which river reaches?"
- **ABS ASGS SA2 boundaries**
  - https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3
  - Shapefiles for SA2 regions
- **MDBA spatial data on data.gov.au**
  - MDB boundary, water resource plan areas, SDL resource units
  - https://data.gov.au/data/dataset?organization=murray-darlingbasinauthority

**Action items:**
1. Download Geofabric surface network and catchment products
2. Download SA2 shapefiles (ASGS Edition 3)
3. Build a GIS layer mapping: SIS bore-field centroids → river network → downstream monitoring stations → SA2 polygons
4. Compute hydrological distance (river-km) from each SIS to each downstream monitoring station

---

## Step 6: Climate Controls

**Goal:** Temperature, precipitation, and evapotranspiration at SA2 level, monthly/annual, ~1980–present.

**Sources:**
- **BOM Climate Data Online:** https://www.bom.gov.au/climate/data/
  - Station-level daily temperature, rainfall, evaporation
  - Gridded products (AWAP/AGCD) preferred for SA2-level aggregation
- **SILO (Scientific Information for Land Owners):**
  - https://www.longpaddock.qld.gov.au/silo/
  - Gridded daily climate data (0.05° resolution) across Australia
  - API access available; covers rainfall, temperature, evapotranspiration, solar radiation
  - Preferred source — can extract by point or polygon (SA2)

**Action items:**
1. Register for SILO data drill or gridded data
2. Extract SA2-level monthly averages: max/min temperature, rainfall, reference ET
3. Match temporal coverage to the agricultural panel

---

## Data Assembly Sequence (Recommended)

1. **Treatment:** SIS commissioning dates and locations (Step 1) — can start immediately
2. **First stage:** Water quality + streamflow from state APIs (Step 2) — can start immediately
3. **Spatial linkage:** Geofabric + SA2 boundaries (Step 5) — can start immediately
4. **Second stage (public):** ABS VACP + Census via TableBuilder (Step 3) — can start immediately
5. **Water market:** ABARES dataset download (Step 4) — can start immediately
6. **Climate controls:** SILO gridded data (Step 6) — can start immediately
7. **Second stage (restricted):** ABS DataLab application + ABARES microdata negotiation (Step 3) — start early, 1–4 month lead time

---

## Key Risks

- **Morgan EC gap:** If daily EC at Morgan does not extend continuously to 1980, the first stage loses pre-treatment observations for early schemes (Woolpunda commissioned 1991). Check SA DEW archives.
- **SA2 boundary changes:** ASGS editions changed SA2 boundaries (2011, 2016, 2021). Harmonise using ABS correspondence tables or work in a fixed geography (e.g., 2016 SA2).
- **ABARES microdata access:** Farm-level data may require a co-author with an existing ABARES relationship or a formal MOU. Budget 2–3 months.
- **Thin agricultural panel:** Census waves are quinquennial. The annual VACP provides frequency but less crop-level detail. The ABARES gridded farm data (model-predicted) fills gaps but introduces model uncertainty. Document which specification uses which source.
