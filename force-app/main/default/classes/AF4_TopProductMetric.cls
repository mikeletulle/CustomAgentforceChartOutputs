
public class AF4_TopProductMetric {
    @AuraEnabled @InvocableVariable public String name;
    @AuraEnabled @InvocableVariable public Decimal value;

    public AF4_TopProductMetric() {}

    public AF4_TopProductMetric(String name, Decimal value) {
        this.name = name;
        this.value = value;
    }
}
