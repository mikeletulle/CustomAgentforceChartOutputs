
public class AF4_TopProductsPayload {
    @AuraEnabled @InvocableVariable public String title;
    @AuraEnabled @InvocableVariable public String subtitle;
    @AuraEnabled @InvocableVariable public List<AF4_TopProductMetric> products;

    public AF4_TopProductsPayload() {}

    public AF4_TopProductsPayload(String title, String subtitle, List<AF4_TopProductMetric> products) {
        this.title = title;
        this.subtitle = subtitle;
        this.products = products;
    }
}

