# Custom Agentforce Chart Outputs (Salesforce Demo)

This repository contains a set of **custom Lightning Web Component (LWC) visualizations** designed to be used as **Agentforce custom outputs** in Salesforce. The project demonstrates how Agentforce actions can return structured data that is rendered as rich, executive-friendly charts instead of plain text responses.

While this repository is intended for **demo and exploration purposes**, the underlying architecture closely mirrors how these patterns would be implemented in real-world Salesforce solutions.

---

## What This Repository Demonstrates

- Custom **Lightning Types** wired to LWCs via `renderer.json`
- Agentforce actions returning structured data from **Apex**
- LWCs that defensively resolve payloads passed through Agentforce
- KPI-style visualizations with tiles, bars, percentages, and currency
- Clear separation between **data generation (Apex)** and **presentation (LWC)**

---

## ARPD Metrics Visualization (Apex-driven)

<img src="ARPDMetrics.png" width="500" />

The **Average Revenue Per Dealer (ARPD)** chart is the most complete and realistic use case in this repository.

### Key Characteristics

- **All data is generated in Apex**
- The Agentforce action (`AF4_GetArpdMetricsAction`) returns:
  - Month-over-Month (MoM), Quarter-over-Quarter (QoQ), and Year-over-Year (YoY) percentage changes
  - Dollar values showing **from → to** revenue per dealer
  - A narrative summary sentence
- The LWC (`arpdMetricsV4`) is responsible only for:
  - Rendering the tiles
  - Scaling bars relative to the largest percentage
  - Formatting percentages and currency
  - Displaying the summary below the chart

This mirrors a real production setup where business logic and calculations live in Apex (or upstream systems), and the UI layer remains lightweight and reusable.

---

## Agentforce Output Configuration

<img src="ARPDMetricsActionOutputConfig.png" width="500" />

This image shows how the **ARPD Agentforce action output** is configured to map its structured Apex response to the Lightning Type used by the renderer. This configuration allows the Agentforce response to be visualized as a chart instead of plain text.

---

## Top Products Visualization (LWC-mocked)

<img src="TopProducts.png" width="500" />

The **Top Add-On Products** visualization demonstrates a second charting pattern but currently uses **mocked data inside the LWC**.

### Current State

- The Lightning Type and renderer wiring is fully functional
- The chart renders correctly inside Agentforce
- Product names and values are currently hard-coded in the LWC

### Why Mocked?

There is an outstanding issue being investigated around payload binding and rendering for this use case. Mocking the data allows the UI and renderer wiring to be validated independently of that issue.

Once resolved, the mock data can be replaced with Apex-, CRM Analytics-, or Tableau-driven data without redesigning the component.

---

## How This Would Work in a Real Production Environment

### If the data lives inside Salesforce

You would typically:
- Aggregate and calculate metrics using **Apex** or **CRM Analytics (CRMA)**
- Return structured results via an Agentforce action
- Render the output using a custom LWC like the ones in this repo

This approach is ideal when:
- Data already exists in Salesforce objects
- Row-level security and sharing rules must be enforced
- Calculations belong close to the transactional data

### If the data lives outside Salesforce

You might instead:
- Use a **Tableau LWC** or analytics extension
- Pull metrics from an external data warehouse
- Let Tableau handle aggregation and visualization while Salesforce provides context

This pattern is common when:
- Metrics span multiple systems
- Large-scale analytics are required
- A centralized BI platform already exists

---

## How to Deploy

> **Important:** Due to Lightning Type → LWC binding behavior, deployment must be done in a specific order.

### Step 1: Temporarily comment out `<targetConfigs>` in LWC meta files

In each LWC `.js-meta.xml` file used by Lightning Types:
- Comment out or remove the entire `<targetConfigs>` section
- Leave the `<targets>` section intact

This prevents deployment failures caused by Lightning Types referencing LWCs that are not yet fully registered.

### Step 2: Deploy LWCs first

```bash
sf project deploy start   --source-dir "CustomAgentforceChartOutputs/force-app/main/default/lwc"   --ignore-conflicts
```

### Step 3: Deploy Lightning Types

```bash
sf project deploy start   --source-dir "CustomAgentforceChartOutputs/force-app/main/default/lightningTypes"
```

### Step 4: Restore `<targetConfigs>` and redeploy LWCs

- Uncomment or restore the `<targetConfigs>` sections in each LWC `.js-meta.xml` file

```bash
sf project deploy start   --source-dir "CustomAgentforceChartOutputs/force-app/main/default/lwc"   --ignore-conflicts
```

### Step 5 (Optional): Deploy Apex classes

```bash
sf project deploy start   --source-dir "CustomAgentforceChartOutputs/force-app/main/default/classes"
```

### Step 6: Verify in Agentforce

- Close any open Agentforce preview tabs
- Reopen the conversation or preview session
- Confirm that charts render correctly and reflect recent changes

---

## Important Notes

- This repository is **not production-ready**
- All numbers shown are **illustrative**
- The focus is on **architecture, patterns, and visualization**
- Lightning Type caching and renderer binding quirks are actively being explored

---

## Summary

This project demonstrates how **Agentforce custom outputs** can move beyond plain text and into meaningful, data-driven visualizations:

- **ARPD Metrics** shows a realistic Apex → Agentforce → LWC pipeline
- **Top Products** shows a UI-first approach while backend integration is refined
- The same architecture can support Apex, CRMA, Tableau, or external analytics

Together, these examples illustrate how Agentforce can function as an intelligent business assistant rather than just a conversational interface.

## How the Pieces Wire Together (Exact V4 Names in This Repo)

Custom Agentforce chart outputs only work when several independently-deployed artifacts **all reference each other correctly**. Most “There was a problem rendering” or “it’s still showing the old version” issues come from a **single name mismatch** across these layers:

- LWC bundle name
- Lightning Type folder + metadata
- `schema.json` and `renderer.json` content
- Apex action + Apex payload class names
- LWC `.js-meta.xml` `targetConfigs` values (when used)
- Agent action output configuration in Setup (output “name” + output “type”)

This repo contains two V4 use cases:

1. **ARPD Metrics (Apex-driven end-to-end)**
2. **Top Products (currently renderer uses `topProductsMockV4` due to the binding/rendering bug being investigated)**

---

# 1) ARPD Metrics (Apex → Lightning Type → LWC)

### A. Apex classes (data source)
- **Action (Invocable):** `AF4_GetArpdMetricsAction.cls`
- **Payload type:** `AF4_ArpdMetricsPayload.cls`

The action returns an output field named **`arpd`**:
- `AF4_GetArpdMetricsAction.Output.arpd : AF4_ArpdMetricsPayload`

### B. Lightning Type bundle (binding contract)
- **Lightning Type folder:** `force-app/main/default/lightningTypes/AF4ArpdMetricsTypeV4/`
- **Type metadata:** `AF4ArpdMetricsTypeV4.lightningTypeBundle-meta.xml`
- **Schema:** `schema.json`
- **Renderer config:** `lightningDesktopGenAi/renderer.json`
- **Renderer implementation (if present/required in your org):** `lightningDesktopGenAi/renderer.js`

Key references that must match:

**1) schema.json → Apex payload type**
- File: `lightningTypes/AF4ArpdMetricsTypeV4/schema.json`
- Current content references:
  - `@apexClassType/AF4_ArpdMetricsPayload`

**2) renderer.json → LWC bundle**
- File: `lightningTypes/AF4ArpdMetricsTypeV4/lightningDesktopGenAi/renderer.json`
- Current content references:
  - `c/arpdMetricsV4`

> Note on renderer.js location  
> If your org requires a `renderer.js`, it must live here:
> `lightningTypes/AF4ArpdMetricsTypeV4/lightningDesktopGenAi/renderer.js`  
> (It cannot sit beside `schema.json` or at the type root.)

### C. LWC renderer (presentation layer)
- **LWC bundle folder:** `force-app/main/default/lwc/arpdMetricsV4/`
- **Meta file:** `arpdMetricsV4.js-meta.xml`

Key references that must match:

**3) LWC meta targetConfigs → Lightning Type API name**
- File: `lwc/arpdMetricsV4/arpdMetricsV4.js-meta.xml`
- Current config references:
  - `sourceType name="c__AF4ArpdMetricsTypeV4"`
  - `property name="data" type="c__AF4ArpdMetricsTypeV4"`

That means the Lightning Type API name being targeted is:
- **`c__AF4ArpdMetricsTypeV4`**

### D. Agent action output configuration (Setup/UI)
In the Agentforce action output mapping UI:

- The **output name** should match what your action emits (commonly `arpd`).
- The **output type** must be set to the Lightning Type:
  - **`c__AF4ArpdMetricsTypeV4`**

If the output type is still pointed at an older type (V2/V3), you will keep seeing old behavior even when V4 is deployed.

---

# 2) Top Products (Apex present, but renderer currently points to mock LWC)

### A. Apex classes (intended data source)
- **Action (Invocable):** `AF4_GetTopProductsAction.cls`
- **Payload type:** `AF4_TopProductsPayload.cls`
- **Metric row type:** `AF4_TopProductMetric.cls`

Typically you’ll see an output field like:
- `AF4_GetTopProductsAction.Output.<something> : AF4_TopProductsPayload`

(Exact output variable name depends on your action class definition.)

### B. Lightning Type bundle
- **Lightning Type folder:** `force-app/main/default/lightningTypes/AF4TopProductsTypeV4/`
- **Schema:** `schema.json`
- **Renderer config:** `lightningDesktopGenAi/renderer.json`
- **Renderer implementation (if present/required):** `lightningDesktopGenAi/renderer.js`

Key references that must match:

**1) schema.json → Apex payload type**
- File: `lightningTypes/AF4TopProductsTypeV4/schema.json`
- Current content references:
  - `@apexClassType/AF4_TopProductsPayload`

**2) renderer.json → which LWC actually renders**
- File: `lightningTypes/AF4TopProductsTypeV4/lightningDesktopGenAi/renderer.json`
- In this repo, it currently points to:
  - **`c/topProductsMockV4`**

Even though the schema description says “renders with topProductsV4”, the runtime renderer selection is controlled by **renderer.json**.

### C. LWCs involved
There are two LWCs in the repo that relate to Top Products:

1) **Mock renderer (known-good UI wiring)**
- `force-app/main/default/lwc/topProductsMockV4/`
- `topProductsMockV4.js-meta.xml` includes **only**:
  - `<target>lightning__AgentforceOutput</target>`
- No `targetConfigs` are required for the mock to render.

2) **Real renderer target (in progress / bug investigation)**
- `force-app/main/default/lwc/topProductsV4/`
- `topProductsV4.js-meta.xml` currently includes `targetConfigs` referencing:
  - `c__AF4TopProductsTypeV4`

If you switch `renderer.json` to `c/topProductsV4`, then `topProductsV4` must be stable against payload shape and the binding bug you’re working through.

### D. Agent action output configuration (Setup/UI)
In the Agentforce action output mapping UI:

- The **output type** for Top Products must be:
  - **`c__AF4TopProductsTypeV4`**
- If the Lightning Type points to `topProductsMockV4` but the action output is still set to an older type, you’ll get inconsistent behavior that looks like caching.

---

# Quick “Does This Name Match?” Checklist

Use this when something doesn’t render:

### For ARPD
- Lightning Type schema points to: `@apexClassType/AF4_ArpdMetricsPayload`
- Lightning Type renderer points to: `c/arpdMetricsV4`
- LWC meta targetConfig points to: `c__AF4ArpdMetricsTypeV4`
- Agent action output “type” points to: `c__AF4ArpdMetricsTypeV4`

### For Top Products
- Lightning Type schema points to: `@apexClassType/AF4_TopProductsPayload`
- Lightning Type renderer points to: `c/topProductsMockV4` (current)
- If you change renderer to `c/topProductsV4`, ensure:
  - `topProductsV4.js-meta.xml` targetConfig references `c__AF4TopProductsTypeV4`
  - LWC JS tolerates payload wrapper differences and null/undefined lists

---

# Important Note on `renderer.json` Location

If you are using (or your org requires) a Lightning Type renderer implementation file, it must live at:

- `force-app/main/default/lightningTypes/<LightningTypeName>/lightningDesktopGenAi/renderer.json`

Examples:
- `.../lightningTypes/AF4ArpdMetricsTypeV4/lightningDesktopGenAi/renderer.json`

Placing `renderer.json` at the Lightning Type root (next to schema.json) will not work.

---

## A Note on LWC Caching (Yes, It’s Frustrating)

Lightning Web Component caching in the context of **Agentforce custom outputs and Lightning Types** can be extremely frustrating and non-obvious.

In practice, changes to LWCs often **do not appear immediately**, even after:
- successful deployments
- hard refreshes
- clearing browser cache
- restarting VS Code
- redeploying the same bundle

### What Actually Worked

During development of this repo, the only reliable ways to force changes to appear were:

- **Renaming the LWC bundle itself** (for example `arpdMetricsV3` → `arpdMetricsV4`)
- Updating the Lightning Type `renderer.json` to point at the new bundle name
- Using a **browser Guest Profile**
- Fully **closing the Guest Profile window and reopening it** after deployments

Simply refreshing the page was not sufficient. If the Guest Profile remained open, Salesforce would frequently continue rendering an older cached version of the LWC.

### Why This Matters

This behavior makes it very easy to misdiagnose issues as:
- broken deployments
- incorrect renderer wiring
- payload binding problems

when in reality the correct code *is deployed*, but the UI is still rendering a cached version.

### Practical Advice

If you believe your changes are correct but are not appearing:

1. Assume caching first.
2. Try a new LWC bundle name (V4, V5, etc.).
3. Close and reopen the Guest Profile completely.
4. Verify the Agent action output is pointing at the newest Lightning Type.

This is not ideal, but it is currently the most reliable workflow when iterating on Agentforce-rendered LWCs.


---

