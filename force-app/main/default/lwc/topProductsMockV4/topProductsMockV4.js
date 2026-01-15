import { LightningElement } from "lwc";

export default class TopProductsMockV4 extends LightningElement {
  // Completely ignores incoming data on purpose.
  mock = [
    { name: "Inventory Intelligence Platform (IAP)", value: 42 },
    { name: "Conversations", value: 31 },
    { name: "Display Advertising", value: 24 },
    { name: "Marketplace Enhanced Leads", value: 18 }
  ];

  get max() {
    return Math.max(...this.mock.map((m) => m.value), 1);
  }

  get rows() {
    const max = this.max;
    return this.mock.map((m) => {
      const pct = Math.max(0, Math.min(100, Math.round((m.value / max) * 100)));
      return {
        ...m,
        barStyle: `width:${pct}%;`
      };
    });
  }
}
