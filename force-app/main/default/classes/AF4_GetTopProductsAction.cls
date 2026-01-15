public with sharing class AF4_GetTopProductsAction {

    public class Input {
        @InvocableVariable(description='Optional scope; ignored for demo.')
        public String scope;
    }

    public class Output {
        @InvocableVariable public AF4_TopProductsPayload topProducts;
    }

    @InvocableMethod(
        label='AF4 - Get Top Products'
        description='Demo: returns hard-coded top add-on products.'
    )
    public static List<Output> run(List<Input> inputs) {
        List<Output> outs = new List<Output>();

        for (Input inVal : inputs) {
            Output out = new Output();
            out.topProducts = new AF4_TopProductsPayload(
                'Top Add-On Products',
                'Amended increased contracts',
                new List<AF4_TopProductMetric>{
                    new AF4_TopProductMetric('Inventory Intelligence Platform (IAP)', 42),
                    new AF4_TopProductMetric('Conversations', 31),
                    new AF4_TopProductMetric('Display Advertising', 24),
                    new AF4_TopProductMetric('Marketplace Enhanced Leads', 18)
                }
            );
            outs.add(out);
        }

        return outs;
    }
}

