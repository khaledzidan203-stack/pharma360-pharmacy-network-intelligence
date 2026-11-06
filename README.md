# Pharma360 — Pharmacy Network Intelligence

**Synthetic Pharmacy Retail | Category Analytics | Inventory & Expiry | Supply Chain | Forecast Evaluation | Power BI**  
**Prepared by Khaled Zidan**

This repository contains the runnable Power BI bundle for Pharma Category Decision Intelligence 360.

Repository: [pharma360-pharmacy-network-intelligence](https://github.com/khaledzidan203-stack/pharma360-pharmacy-network-intelligence)

> **Synthetic only.** Stores, products, suppliers, inventory, invoices and policy scenarios are simulated. No real pharmacy-chain records are represented. The report authorizes no operational procurement, clinical substitution, transfers, vendor returns or inventory disposal.
>
> **Validation status:** the owner confirms that the launcher and report opened and worked locally in Power BI Desktop. This is owner-confirmed local QA; independent clean-clone and cross-device refresh certification has not been performed. Forecast and procurement policy approval remains **NOT CERTIFIED / NOT APPROVED**.

## Project overview

Pharma Category Decision Intelligence 360 is an end-to-end pharmacy-retail decision-support case study, connecting commercial results with supplier operations, store and distribution-center inventory, batch/expiry risk, availability, forecast-model assessment, and governed business decisions. It demonstrates how to distinguish descriptive findings, analytical alternatives, constraints, and **authorization**, rather than treating a dashboard recommendation as an executable transaction.

The core analytical work spans:

- **Commercial & category performance:** net sales, COGS, gross profit, gross margin, distinct invoices, average basket value (ABV), GMROI, inventory turnover, period comparisons and branch/SKU concentration.
- **Inventory and lot quality:** physical, saleable, reserved, ATP, held and withdrawn states; retail versus wider network scope; expiry, withdrawal, supplier claims and credits.
- **Procurement and supplier intelligence:** ordered versus received units, supplier fulfillment, delayed receipts, constrained replenishment candidates, and approval/review statuses.
- **Demand and forecasting:** observed/fulfilled rate of sale (ROS), stocked trading exposure, censoring, validation/holdout metrics, model and horizon comparisons, and known provenance restrictions.
- **Decision governance and evaluation:** review queues, non-executable proposed alternatives, scenario-policy comparisons, service safeguards, evidence quality and availability status.

## Bundle contents

- One native PBIP project with its matching PBIR report, semantic model, DAX, theme and resources.
- Exactly **47 actively imported Parquet files**, retaining the relative paths expected by the model.
- **15 report pages**, **14 Index destinations**, and 15 genuine report screenshots.
- A Windows launcher that configures the local data root and opens the existing PBIP.
- The synthetic original world covers **25 stores, 280 SKUs, 8 categories and 10 suppliers**.

```text
README.md
RUN_PHARMA360.cmd
.gitignore
tools/launch_pharma360.ps1
powerbi/Pharma_Category_Management_POC.pbip
powerbi/Pharma_Category_Management_POC.Report/
powerbi/Pharma_Category_Management_POC.SemanticModel/
data/                         47 imported synthetic Parquets
screen_shoots/                15 genuine report screenshots
```

Bundled Parquets feed Power Query through `PharmaDataRoot`, then the semantic model and report pages. This bundle supports opening and refreshing the supplied report; identical from-zero synthetic-world regeneration is not claimed.

## Open in Power BI Desktop — Windows

Install a compatible Power BI Desktop version with PBIP support. Download the complete repository using **Code → Download ZIP**, then extract it fully before running the launcher. Alternatively:

```powershell
git clone https://github.com/khaledzidan203-stack/pharma360-pharmacy-network-intelligence.git
cd pharma360-pharmacy-network-intelligence
```

From the extracted or cloned repository folder:

```powershell
# Check the bundled sources without changing or opening the report
.\RUN_PHARMA360.cmd --verify-only

# Configure the local data root if needed and open the report
.\RUN_PHARMA360.cmd
```

Close Power BI Desktop before launching from a new folder if the data root must change. The launcher derives the root from its own location, validates all imported sources, and changes only `PharmaDataRoot` when necessary, with a local backup and rollback on configuration failure. It prints `NO_CHANGES` when already configured. Keep the complete directory structure together.

In Desktop, select **Refresh**, inspect the report, then **Save → Close → Reopen**. Confirm the 14 Index buttons, the 06↔07 links, EGP presentation, expiry-month order, forecast precision and evidence states. The launcher does not perform refresh or save automatically. If Windows cannot open the PBIP, install Power BI Desktop and associate `.pbip` files with it.

## Report pages and screenshots

The links below follow the current saved display order. Page 07 is the supplementary expiry and withdrawal decision review.

| Saved page | Authentic screenshot |
|---|---|
| 00 | [INDEX](screen_shoots/00%20INDEX.png) |
| 01 | [EXECUTIVE OVERVIEW](screen_shoots/01%20EXECUTIVE%20OVERVIEW.png) |
| 02 | [CATEGORY PERFORMANCE & PROFITABILITY](screen_shoots/02%20CATEGORY%20PERFORMANCE%20%26%20PROFITABILITY.png) |
| 03 | [BRANCH PERFORMANCE](screen_shoots/03%20BRANCH%20PERFORMANCE.png) |
| 04 | [SKU & ASSORTMENT](screen_shoots/04%20SKU%20%26%20ASSORTMENT.png) |
| 05 | [INVENTORY & DISTRIBUTION NETWORK](screen_shoots/05%20INVENTORY%20%26%20DISTRIBUTION%20NETWORK.png) |
| 06 | [EXPIRY, WITHDRAWAL & QUALITY](screen_shoots/06%20EXPIRY%2C%20WITHDRAWAL%20%26%20QUALITY.png) |
| 07 | [EXPIRY & WITHDRAWAL DECISION REVIEW](screen_shoots/07%20EXPIRY%20%26%20WITHDRAWAL%20DECISION%20REVIEW.png) |
| 08 | [SUPPLIER PERFORMANCE & RETURNS](screen_shoots/08%20SUPPLIER%20PERFORMANCE%20%26%20RETURNS.png) |
| 09 | [REPLENISHMENT & CONSTRAINT INTELLIGENCE](screen_shoots/09%20REPLENISHMENT%20%26%20CONSTRAINT%20INTELLIGENCE.png) |
| 10 | [ROS, EXPOSURE & AVAILABILITY](screen_shoots/10%20ROS%2C%20EXPOSURE%20%26%20AVAILABILITY.png) |
| 11 | [FORECAST PERFORMANCE](screen_shoots/11%20FORECAST%20PERFORMANCE.png) |
| 12 | [DECISION REVIEW WORKBENCH](screen_shoots/12%20DECISION%20REVIEW%20WORKBENCH.png) |
| 13 | [POLICY SCENARIOS & GUARDRAILS](screen_shoots/13%20POLICY%20SCENARIOS%20%26%20GUARDRAILS.png) |
| 14 | [DATA QUALITY, EVIDENCE & METHODS](screen_shoots/14%20DATA%20QUALITY%2C%20EVIDENCE%20%26%20METHODS.png) |

## Data and calculation integrity

- The financial source stores some amounts as integer **minor units** with project-defined `÷100` formatting/calculation; **EGP is a presentation relabel**, not a reassessment of the historical nominal values or conversion from SAR at an exchange rate.
- **Invoices are distinct headers**, not summed line or category counts. The approved Category ABV repair uses `DIVIDE([SKU Sales SAR], [Category Invoices])` to respect matched Branch × Category scope. The internal measure name retains its historical currency label.
- Store, distribution-center and transit inventory represent different locations/populations. Snapshot, lot, status, ownership, as-of time and SKU granularity are integral to correct reporting; inventory snapshots must not be summed across dates.
- Forecast test targets are **observed fulfilled sales**, not independently verified latent demand. Historical forecasting calibration/source-calendar knowledge risks remain **ON HOLD / NOT CERTIFIED**.
- Historical policy trials are **simulations**, not field-measured causal improvements. The recorded guardrails include blocked policy alternatives; current proposed actions are **not executable**.

## Evidence and analytical limitations

- The 6 Nov evidence-page run reported **21 of 24 source cases proven**, **2 not observed**, **1 unverifiable**. Therefore `21/24 = 87.5%` (displayed as **88%**), *not* 24/24 proven. Missing/unavailable states are not equivalent to business zero.
- The final pre-release output recorded **763 network-scope** versus **584 retail-scope** expiry/withdrawal-related units. Different populations may explain the difference, but the exact reconciliation must not be asserted without aligned filters, location types and as-of evidence.
- Financial/snapshot questions flagged in the final output include **33.76% vs 33.77%** margins under potentially different contexts/rounding, **92 vs 91 days** in compared periods, and distinct GMROI denominator grains. These differences remain unresolved analytical disclosures.
- The final display correction reported changes to **25 files including 24 visuals**: EGP labels, period ordering, formatting precision and negative-zero presentation. This was a **file-level correction**, not by itself complete native Desktop acceptance.
- Some older source cases or policies remain blocked/unavailable; concise executive wording does not remove these scientific limitations.

The report is a synthetic portfolio and technical education demonstration. Policy simulations do not establish field-measured causal effects, and proposed movements are not executable approvals. EGP is a presentation label with the original synthetic numerical units retained 1:1; no exchange-rate conversion was performed.
