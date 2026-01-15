import { LightningElement, api } from "lwc";

export default class TopProductsV4 extends LightningElement {
  @api data;

  unwrap(input) {
    let v = input;

    // Agentforce often passes [{type, value:{...}}]
    if (Array.isArray(v)) v = v[0];

    // Wrapper: { type, value: {...} }
    if (v && typeof v === "object" && "value" in v) v = v.value;

    return v;
  }

  get payload() {
    const v = this.unwrap(this.data);
    // Handle both direct payload and wrapped structure
    if (v && typeof v === "object" && "topProducts" in v) {
      return v.topProducts;
    }
    return v?.topProducts ?? v;
  }

  get title() {
    return this.payload?.title || "Top Products";
  }

  get subtitle() {
    return this.payload?.subtitle || "";
  }

  get products() {
    const p = this.payload?.products;
    return Array.isArray(p) ? p : [];
  }

  get hasProducts() {
    return this.products.length > 0;
  }

  get maxValue() {
    const vals = this.products.map((x) => Number(x?.value) || 0);
    const max = Math.max(0, ...vals);
    return max > 0 ? max : 1;
  }

  formatValue(v) {
    const n = Number(v);
    if (Number.isNaN(n)) return "—";
    return `${Math.round(n)}`;
  }

  get rows() {
    const max = this.maxValue;

    return this.products.map((p, idx) => {
      const val = Number(p?.value) || 0;
      const pct = Math.max(0, Math.min(100, Math.round((val / max) * 100)));
      return {
        key: `${idx}-${p?.name || "item"}`,
        name: p?.name || "—",
        valueText: this.formatValue(p?.value),
        style: `width:${pct}%;`
      };
    });
  }
}
