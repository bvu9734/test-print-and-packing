# COSMO Print & Packaging Accelerator – MVP Introduction

| | |
|---|---|
| **Product** | COSMO Print & Packaging Accelerator for Microsoft Dynamics 365 Business Central |
| **Document version** | 0.2 |
| **Last updated** | 2026-10-30 |
| **Covers** | Phase 1 – Packaging master data, Phase 2 – Cost calculation |
| **Audience** | Business users, key users, and customer stakeholders |

> This is a living document. A new chapter is added after each implementation phase. Planned features are marked 🔜 and described only briefly until they are available.

---

## Contents

1. [What the MVP does](#1-what-the-mvp-does)
2. [End-to-end process and feature status](#2-end-to-end-process-and-feature-status)
3. [Key concepts](#3-key-concepts)
4. [One-time setup](#4-one-time-setup)
5. [Worked example: from specification to price ladder](#5-worked-example-from-specification-to-price-ladder)
6. [How the price is calculated](#6-how-the-price-is-calculated)
7. [Good to know](#7-good-to-know)
8. [Roles and permissions](#8-roles-and-permissions)
9. [Coming next](#9-coming-next)
10. [Known limitations](#10-known-limitations)
11. [Change log](#11-change-log)

---

## 1. What the MVP does

Packaging and print companies receive many requests for custom products: boxes, labels, wraps. Each request needs a technical description, a reliable cost calculation, a price for several order quantities, and—once the customer accepts—production.

The goal of the MVP is that a user can, **within a few minutes**:

1. Describe a custom packaging product in a **Packaging Specification**.
2. Calculate its **cost and sales price** for a range of order quantities.
3. Create a **Sales Quote** from the chosen price. 🔜
4. Turn the accepted quote into a **Sales Order**. 🔜
5. Generate the **Production Order**, including the bill of materials and routing. 🔜

The accelerator does not replace Business Central processes. Sales, manufacturing, inventory, and finance continue to run on the **standard Business Central documents**. The accelerator adds the packaging-specific steps in front of them.

---

## 2. End-to-end process and feature status

| # | Process step | Where it happens | Status |
|---|---|---|---|
| 1 | Customer request | Outside the system | – |
| 2 | Packaging specification | Packaging Specification card | ✅ Available (Phase 1) |
| 3 | Finished item creation | Automatic on release of the specification | ✅ Available (Phase 2) |
| 4 | Material and production cost calculation | Packaging Cost Sheet | ✅ Available (Phase 2) |
| 5 | Sales price calculation (price ladder) | Packaging Cost Sheet | ✅ Available (Phase 2) |
| 6 | Sales Quote | Packaging Quote Wizard → standard Sales Quote | 🔜 Phase 3 |
| 7 | Customer approval → Sales Order | Standard Business Central | 🔜 Phase 3 |
| 8 | Production BOM and routing generation | Packaging BOM, routing templates | 🔜 Phase 4 |
| 9 | Production Order | Action on the Sales Order | 🔜 Phase 5 |
| 10 | Consumption, output, shipment, invoice | Standard Business Central | Standard |

---

## 3. Key concepts

| Term | Meaning |
|---|---|
| **Packaging Specification** | The technical description of one custom product: dimensions, material, print process, number of colors, lamination, die cutting, and expected waste. |
| **Finished item** | A standard Business Central item that represents the product. It is created automatically when the specification is released and is used later on quotes, orders, and production orders. |
| **Packaging material** | A standard item marked with a *Packaging Material Type* (Paper, Corrugated, Ink, Glue, Foil, Film) and a *Cost per m²*. |
| **Print Cost Matrix** | The printing, machine setup, and labor rates for each print process (Digital, Offset, Flexo, Screen). |
| **Cost Sheet** | The calculation of one specification: a breakdown of the cost per piece plus a **price ladder**. |
| **Price ladder** | Unit cost and unit price for several order quantities. The default quantities are 100, 500, 1,000, 5,000, and 10,000 pieces. |
| **Variable cost** | Costs that apply to every piece: material, ink, glue, lamination, printing, and labor. |
| **Fixed cost** | Costs that apply once per order: machine setup and the cutting die. They are spread over the order quantity, so larger orders get a lower unit cost. |
| **Margin %** | A markup on cost: *Unit Price = Unit Cost × (1 + Margin % / 100)*. Each customer can have a default packaging margin. |

---

## 4. One-time setup

Complete these steps once before the first calculation. Search for each page with **Tell me** (Alt+Q). All amounts are in local currency (LCY).

> The values below are **example values** used throughout this document. Replace them with your own rates.

### Step 4.1 – Number series

Create three number series on the **No. Series** page:

| Purpose | Example code | Example first number |
|---|---|---|
| Packaging specifications | `PP-SPEC` | `SPEC0001` |
| Cost sheets | `PP-COST` | `CS0001` |
| Finished packaging items | `PP-ITEM` | `PPI0001` |

### Step 4.2 – Packaging materials

Create or update the material items, and fill in the **Packaging** section of the item card.

| Item no. | Description | Packaging Material Type | Cost per m² | Unit Cost |
|---|---|---|---|---|
| `MAT-CB-E` | Corrugated board, E-flute, white | Corrugated | 2.50 | – |
| `INK-BLACK` | Printing ink (per liter) | Ink | – | 20.00 |
| `GLUE-01` | Hot-melt glue (per kg) | Glue | – | 4.00 |
| `FILM-GLOSS` | Gloss lamination film | Film | 1.00 | – |

Only items with a Packaging Material Type can be selected as the material of a specification. The item's GSM (grams per square meter) is copied to the specification automatically.

### Step 4.3 – Packaging Setup

Open **Packaging Setup** and fill in:

| Section | Field | Example value | Meaning |
|---|---|---|---|
| Numbering | Packaging Spec. Nos. | `PP-SPEC` | Numbers new specifications. |
| Numbering | Cost Sheet Nos. | `PP-COST` | Numbers new cost sheets. |
| Item Creation | Item Nos. | `PP-ITEM` | Numbers the finished items. |
| Item Creation | Item Template Code | `PACKAGING` | Applied to new finished items. Recommended: the template should set the base unit of measure and posting groups. |
| Consumption | Ink Item No. | `INK-BLACK` | Its unit cost prices the ink. |
| Consumption | Ink Qty. per m² per Color | 0.01 | Liters of ink per m² for each color. |
| Consumption | Glue Item No. | `GLUE-01` | Its unit cost prices the glue. |
| Consumption | Glue Qty. per Piece | 0.005 | Kilograms of glue per piece. |
| Consumption | Lamination Film Item No. | `FILM-GLOSS` | Its cost per m² prices the film. |
| Consumption | Lamination Cost per Piece | 0.03 | Lamination process cost per piece. |

### Step 4.4 – Print Cost Matrix

From Packaging Setup choose **Print Cost Matrix**, and enter one line per print process you use:

| Print Process | Print Cost per Piece | Machine Setup Cost (per order) | Labor Cost per Piece |
|---|---|---|---|
| Digital | 0.02 | 100.00 | 0.05 |
| Offset | 0.01 | 250.00 | 0.03 |
| Flexo | 0.015 | 400.00 | 0.02 |

The printing prices per piece come from the MVP specification. The setup and labor values are examples.

### Step 4.5 – Customer margin

On each customer card, fill in **Packaging Margin %** in the **Packaging** section. In the example, customer `C-PIZZA` (Pizza Kft.) has a margin of **20%**.

---

## 5. Worked example: from specification to price ladder

**Scenario:** Pizza Kft. asks for a printed, laminated takeaway food box with a custom cutting die.

### Step 5.1 – Create the packaging specification

Open **Packaging Specifications**, choose **New**, and fill in the card:

| Field | Value |
|---|---|
| No. | *(leave blank – assigned from `PP-SPEC`, e.g. `SPEC0001`)* |
| Description | Takeaway food box, 2-color print |
| Customer No. | `C-PIZZA` |
| Width (mm) | 200 |
| Length (mm) | 400 |
| Height (mm) | 300 |
| Material Code | `MAT-CB-E` *(GSM is copied from the item)* |
| Print Process | Digital |
| No. of Colors | 2 |
| Lamination | Yes |
| Die Cut | Yes |
| Die Cost | 500.00 |
| Waste % | 10 |

### Step 5.2 – Release the specification

Set **Status** to **Released**. The system creates the finished item automatically:

| Item field | Value |
|---|---|
| No. | `PPI0001` (from `PP-ITEM`) |
| Description | Takeaway food box, 2-color print |
| Replenishment System | Prod. Order |
| Manufacturing Policy | Make-to-Order |
| Packaging Spec. No. | `SPEC0001` |

The specification's **Item No.** now shows `PPI0001`. A released specification stays editable.

### Step 5.3 – Create the cost sheet

On the specification card, choose **Create Cost Sheet**. A new cost sheet (for example `CS0001`) opens:

- It is linked to `SPEC0001` and customer `C-PIZZA`.
- **Margin %** is **20**, taken from the customer.
- The **Calculation Basis** section shows the specification values used, so later changes to the specification don't silently change this calculation.

### Step 5.4 – Review the unit cost breakdown

The **Unit Cost Breakdown** section shows the cost of one piece:

| Line | How it is calculated | Result |
|---|---|---|
| Base Area (m²) | 300 × 200 / 1,000,000 | 0.06 |
| Required Area (m²) | 0.06 × (100 + 10) / 100 | 0.066 |
| Material Cost | 0.066 m² × 2.50 per m² | 0.165 |
| Ink Cost | 0.066 m² × 0.01 l × 2 colors × 20.00 per l | 0.0264 |
| Glue Cost | 0.005 kg × 4.00 per kg | 0.02 |
| Lamination Cost | 0.066 m² × 1.00 per m² + 0.03 | 0.096 |
| Printing Cost | Print Cost Matrix, Digital | 0.02 |
| Labor Cost | Print Cost Matrix, Digital | 0.05 |
| **Variable Unit Cost** | Sum of the lines above | **0.3774** |
| Machine Setup Cost | Print Cost Matrix, Digital (per order) | 100.00 |
| Die Cost | From the specification, because Die Cut = Yes (per order) | 500.00 |
| **Fixed Cost** | Machine setup + die | **600.00** |

### Step 5.5 – Review the price ladder

The **Price Ladder** lines show how the price drops as the fixed cost is spread over more pieces (margin 20%):

| Quantity | Fixed Cost per Piece | Unit Cost | Unit Price | Line Amount |
|---:|---:|---:|---:|---:|
| 100 | 6.00 | 6.3774 | 7.65288 | 765.288 |
| 500 | 1.20 | 1.5774 | 1.89288 | 946.44 |
| 1,000 | 0.60 | 0.9774 | **1.17288** | 1,172.88 |
| 5,000 | 0.12 | 0.4974 | 0.59688 | 2,984.40 |
| 10,000 | 0.06 | 0.4374 | 0.52488 | 5,248.80 |

Example for 1,000 pieces: 600 / 1,000 = 0.60 fixed cost per piece; 0.3774 + 0.60 = 0.9774 unit cost; 0.9774 × 1.20 = **1.17288** unit price.

> The same figures are used in an automated test of the calculation.

### Step 5.6 – Adjust and recalculate

| You want to… | Do this | Result |
|---|---|---|
| Offer a different margin | Change **Margin %**, e.g. to 25 | All unit prices and line amounts update immediately. |
| Price a quantity that isn't in the ladder | Add a line, e.g. Quantity 2,500 | The line is calculated as soon as the quantity is entered. |
| Use updated rates or a changed specification | Choose **Calculate** | All costs and the ladder are recalculated from the current specification and rates. |
| See all calculations for a product | On the specification, choose **Cost Sheets** | Lists every cost sheet for that specification. |

---

## 6. How the price is calculated

For each piece, with order quantity **Q**:

| Component | Formula |
|---|---|
| Base Area (m²) | Height (mm) × Width (mm) / 1,000,000 |
| Required Area (m²) | Base Area × (100 + Waste %) / 100 |
| Material Cost | Required Area × material Cost per m² |
| Ink Cost | Required Area × Ink Qty. per m² per Color × No. of Colors × ink Unit Cost |
| Glue Cost | Glue Qty. per Piece × glue Unit Cost |
| Lamination Cost *(only if Lamination)* | Required Area × film Cost per m² + Lamination Cost per Piece |
| Printing Cost | Print Cost per Piece of the print process |
| Labor Cost | Labor Cost per Piece of the print process |
| **Variable Unit Cost** | Sum of the components above |
| **Fixed Cost** | Machine Setup Cost of the print process + Die Cost *(only if Die Cut)* |
| Fixed Cost per Piece | Fixed Cost / Q |
| **Unit Cost** | Variable Unit Cost + Fixed Cost per Piece |
| **Unit Price** | Unit Cost × (1 + Margin % / 100) |
| Line Amount | Unit Price × Q |

---

## 7. Good to know

- **Required data:** a calculation needs a material, a width, a height, and a print process on the specification, plus a Print Cost Matrix line for that print process. Missing data is reported with a clear message.
- **Consumption settings are optional:** if an ink or glue quantity is 0 in Packaging Setup, that cost is 0. If a quantity is filled in, the matching item must also be filled in.
- **Die cost** is charged on every order when the specification uses die cutting.
- **Customer margin:** if the customer has no packaging margin, the cost sheet starts with 0%. Check the margin before you send a price.
- **Snapshot:** a cost sheet keeps the values it was calculated with. After changing the specification or rates, choose **Calculate** to update it. Selecting a different specification on a cost sheet clears its calculation date until it's recalculated.
- **Released specifications remain editable.** Releasing creates the finished item only once.

---

## 8. Roles and permissions

| Permission set | Intended for | Can do |
|---|---|---|
| **PP_USER** | Sales and calculation staff | Create and maintain specifications and cost sheets; release specifications (creates the finished item); read setup and rates. |
| **PP_POWERUSER** | Key users | Everything in PP_USER, plus maintain Packaging Setup, the Print Cost Matrix, and customer packaging margins. |
| **PP_ADMIN** | Administrators | Everything in PP_POWERUSER, plus full item maintenance. |

Users also need the standard Business Central permissions for their role, for example for working with items and customers.

---

## 9. Coming next

### 9.1 Phase 3 – Quote Wizard and Sales Quote 🔜

A guided wizard: select the customer, select the specification, choose a quantity from the price ladder, run the calculation, and create a standard **Sales Quote** with the finished item and the calculated unit price. The accepted quote is turned into a Sales Order with the standard *Make Order* function.

### 9.2 Phase 4 – Production BOM and routing 🔜

From the specification, the system generates a **Production BOM** (board, ink, glue, film) and a **Routing** from templates such as `BOX_STD` (Printing → Die Cutting → Folding → Gluing → Packing), `LABEL_STD`, and `DIGITAL_STD`.

### 9.3 Phase 5 – Production order 🔜

A **Create Packaging Production** action on the Sales Order generates the BOM and routing, if needed, and creates the **Production Order** as *Firm Planned* or *Released*, depending on the setup.

---

## 10. Known limitations

| Topic | Current behavior | Impact |
|---|---|---|
| Material area | Uses Height × Width only, as defined in the MVP specification; Length is not used. | Accurate for flat products such as labels. For boxes, the flat blank is larger than Height × Width, so material cost may be understated. |
| Print cost | One rate per print process; the number of colors and the quantity don't change the rate. | Colors still affect the ink cost. |
| Currency | All rates and prices are in local currency (LCY). | Quotes in foreign currency are not handled yet. |
| Rounding | Unit prices keep up to 5 decimals on the cost sheet. | Rounding to sales prices will be handled when the quote is created (Phase 3). |

---

## 11. Change log

| Version | Date | Change |
|---|---|---|
| 0.2 | 2026-10-30 | Phase 2: finished item on release, Print Cost Matrix, consumption setup, customer margin, cost sheet with price ladder. |
| 0.1 | 2026-10-29 | Phase 1: packaging specification, material fields on items, setup, permission sets. |

---

### Maintaining this document

`MVP-Introduction.md` is the source. After editing it, regenerate the HTML version from the app folder (`Vib Print & Packing`):

```powershell
python -m pip install markdown   # once
python docs/build_html.py
```

When a phase is delivered: update the status in chapters 2 and 9, add a setup step and a worked-example step, and add a change log line.
