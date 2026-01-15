public class AF4_ArpdMetricsPayload {
    @AuraEnabled @InvocableVariable public String metricName;

    @AuraEnabled @InvocableVariable public Decimal momPercent;
    @AuraEnabled @InvocableVariable public Decimal qoqPercent;
    @AuraEnabled @InvocableVariable public Decimal yoyPercent;

    // Dollar amounts (per dealer). Keep as Decimal; LWC formats as currency.
    @AuraEnabled @InvocableVariable public Decimal momFrom;
    @AuraEnabled @InvocableVariable public Decimal momTo;

    @AuraEnabled @InvocableVariable public Decimal qoqFrom;
    @AuraEnabled @InvocableVariable public Decimal qoqTo;

    @AuraEnabled @InvocableVariable public Decimal yoyFrom;
    @AuraEnabled @InvocableVariable public Decimal yoyTo;

    // Summary text shown under the tiles
    @AuraEnabled @InvocableVariable public String headline;

    // JSON escape hatch for LWC parsing (reliable even if binding/wrapping changes)
    @AuraEnabled @InvocableVariable public String json;

    public AF4_ArpdMetricsPayload() {}

    public AF4_ArpdMetricsPayload(
        String metricName,
        Decimal momPercent,
        Decimal qoqPercent,
        Decimal yoyPercent,
        Decimal momFrom,
        Decimal momTo,
        Decimal qoqFrom,
        Decimal qoqTo,
        Decimal yoyFrom,
        Decimal yoyTo,
        String headline
    ) {
        this.metricName = metricName;

        this.momPercent = momPercent;
        this.qoqPercent = qoqPercent;
        this.yoyPercent = yoyPercent;

        this.momFrom = momFrom;
        this.momTo   = momTo;

        this.qoqFrom = qoqFrom;
        this.qoqTo   = qoqTo;

        this.yoyFrom = yoyFrom;
        this.yoyTo   = yoyTo;

        this.headline = headline;

        // Do NOT JSON.serialize(this) because it contains json itself.
        this.json = buildJson(
            metricName,
            momPercent, qoqPercent, yoyPercent,
            momFrom, momTo,
            qoqFrom, qoqTo,
            yoyFrom, yoyTo,
            headline
        );
    }

    public static String buildJson(
        String metricName,
        Decimal momPercent,
        Decimal qoqPercent,
        Decimal yoyPercent,
        Decimal momFrom,
        Decimal momTo,
        Decimal qoqFrom,
        Decimal qoqTo,
        Decimal yoyFrom,
        Decimal yoyTo,
        String headline
    ) {
        Map<String, Object> m = new Map<String, Object>();
        m.put('metricName', metricName);

        m.put('momPercent', momPercent);
        m.put('qoqPercent', qoqPercent);
        m.put('yoyPercent', yoyPercent);

        m.put('momFrom', momFrom);
        m.put('momTo', momTo);

        m.put('qoqFrom', qoqFrom);
        m.put('qoqTo', qoqTo);

        m.put('yoyFrom', yoyFrom);
        m.put('yoyTo', yoyTo);

        m.put('headline', headline);

        return JSON.serialize(m);
    }
}
