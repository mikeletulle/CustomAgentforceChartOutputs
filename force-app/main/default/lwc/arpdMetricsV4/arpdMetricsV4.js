import { LightningElement, api } from "lwc";

export default class ArpdMetricsV4 extends LightningElement {
  @api value;
  @api data;
  @api output;
  @api payload;

  get resolvedPayload() {
    const candidates = [
      this.payload,
      this.value,
      this.data,
      this.output,
      this.value?.value,
      this.data?.value,
      this.output?.value,
      this.value?.output,
      this.data?.output,
      this.output?.output
    ];

    for (const c of candidates) {
      if (c && typeof c === "object") {
        // If Apex included json string, prefer that as the most stable shape
        if (typeof c.json === "string" && c.json.trim().startsWith("{")) {
          try {
            const parsed = JSON.parse(c.json);
            return parsed && typeof parsed === "object" ? parsed : c;
          } catch (e) {
            return c;
          }
        }

        // Direct payload shape
        if (
          "momPercent" in c ||
          "qoqPercent" in c ||
          "yoyPercent" in c ||
          "metricName" in c ||
          "headline" in c
        ) {
          return c;
        }

        // One-level unwrap
        if (c.value && typeof c.value === "object") {
          const inner = c.value;
          if (typeof inner.json === "string" && inner.json.trim().startsWith("{")) {
            try {
              const parsed = JSON.parse(inner.json);
              return parsed && typeof parsed === "object" ? parsed : inner;
            } catch (e) {
              return inner;
            }
          }
          if (
            "momPercent" in inner ||
            "qoqPercent" in inner ||
            "yoyPercent" in inner ||
            "metricName" in inner ||
            "headline" in inner
          ) {
            return inner;
          }
        }
      }
    }
    return {};
  }

  // ---------- helpers ----------
  toNumber(x) {
    if (x === null || x === undefined || x === "") return null;
    const n = Number(x);
    return Number.isFinite(n) ? n : null;
  }

  formatPercent(x) {
    const n = this.toNumber(x);
    if (n === null) return "—";
    const isInt = Math.abs(n - Math.round(n)) < 1e-9;
    return isInt ? String(Math.round(n)) : n.toFixed(1);
  }

  formatUSD(x) {
    const n = this.toNumber(x);
    if (n === null) return "—";
    try {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
        maximumFractionDigits: 0
      }).format(n);
    } catch (e) {
      // Fallback if Intl is restricted for some reason
      return `$${Math.round(n)}`;
    }
  }

  // ---------- text ----------
  get metricTitle() {
    const name = this.resolvedPayload.metricName;
    return name ? `${name} Metrics` : "ARPD Metrics";
  }

  get headline() {
    return this.resolvedPayload.headline || "";
  }

  // ---------- tiles ----------
  get tiles() {
    const p = this.resolvedPayload;

    const mom = this.toNumber(p.momPercent);
    const qoq = this.toNumber(p.qoqPercent);
    const yoy = this.toNumber(p.yoyPercent);

    const percents = [mom, qoq, yoy].filter((v) => v !== null);
    const maxPercent = percents.length ? Math.max(...percents) : null;

    const barWidth = (percent) => {
      const n = this.toNumber(percent);
      if (n === null || !maxPercent || maxPercent <= 0) return "width:0%;";
      const pct = Math.max(0, (n / maxPercent) * 100);
      // cap at 100 so it never overflows
      return `width:${Math.min(100, pct)}%;`;
    };

    return [
      {
        key: "mom",
        label: "MoM",
        percentText: this.formatPercent(p.momPercent),
        fromText: this.formatUSD(p.momFrom),
        toText: this.formatUSD(p.momTo),
        barStyle: barWidth(p.momPercent)
      },
      {
        key: "qoq",
        label: "QoQ",
        percentText: this.formatPercent(p.qoqPercent),
        fromText: this.formatUSD(p.qoqFrom),
        toText: this.formatUSD(p.qoqTo),
        barStyle: barWidth(p.qoqPercent)
      },
      {
        key: "yoy",
        label: "YoY",
        percentText: this.formatPercent(p.yoyPercent),
        fromText: this.formatUSD(p.yoyFrom),
        toText: this.formatUSD(p.yoyTo),
        barStyle: barWidth(p.yoyPercent)
      }
    ];
  }
}
