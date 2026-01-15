public with sharing class AF4_GetArpdMetricsAction {

    public class Input {
        @InvocableVariable(description='Optional scope; ignored for demo.')
        public String scope;
    }

    public class Output {
        @InvocableVariable public AF4_ArpdMetricsPayload arpd;
    }

    @InvocableMethod(
        label='AF4 - Get ARPD Metrics'
        description='Demo: returns hard-coded ARPD MoM/QoQ/YoY changes + dollar amounts with JSON fallback.'
    )
    public static List<Output> run(List<Input> inputs) {
        List<Output> outs = new List<Output>();

        List<Input> safeInputs = (inputs == null || inputs.isEmpty())
            ? new List<Input>{ new Input() }
            : inputs;

        // “Believable demo” baseline (per dealer, per month)
        // These are illustrative numbers for a marketplace like Cars.com.
        Decimal momFrom = 1300;
        Decimal qoqFrom = 1250;
        Decimal yoyFrom = 1100;

        Decimal momPct = 3;
        Decimal qoqPct = 6;
        Decimal yoyPct = 12;

        // Compute "to" amounts from the percents
        Decimal momTo = roundCurrency(momFrom * (1 + (momPct / 100)));
        Decimal qoqTo = roundCurrency(qoqFrom * (1 + (qoqPct / 100)));
        Decimal yoyTo = roundCurrency(yoyFrom * (1 + (yoyPct / 100)));

        String metricName = 'Average Revenue Per Dealer (ARPD)';

        // Summary shown under tiles
        String headline =
            'ARPD increased across all periods, with the strongest gains YoY, ' +
            'suggesting sustained adoption of higher-value add-on products.';

        for (Input inVal : safeInputs) {
            Output out = new Output();

            AF4_ArpdMetricsPayload p = new AF4_ArpdMetricsPayload(
                metricName,
                momPct, qoqPct, yoyPct,
                momFrom, momTo,
                qoqFrom, qoqTo,
                yoyFrom, yoyTo,
                headline
            );

            if (String.isBlank(p.json)) {
                p.json = AF4_ArpdMetricsPayload.buildJson(
                    p.metricName,
                    p.momPercent, p.qoqPercent, p.yoyPercent,
                    p.momFrom, p.momTo,
                    p.qoqFrom, p.qoqTo,
                    p.yoyFrom, p.yoyTo,
                    p.headline
                );
            }

            out.arpd = p;
            outs.add(out);
        }

        return outs;
    }

    private static Decimal roundCurrency(Decimal x) {
        // Round to whole dollars for clean tiles; change scale if you want cents.
        if (x == null) return null;
        return x.setScale(0);
    }
}
