package checkout.data;


import checkout.Entry;
import checkout.Money;

public class EntryBuilder {
    private String itemCode;
    private Money unitPrice;
    private Money kiloPrice;

    public Entry build() {
        return new Entry(itemCode, unitPrice, kiloPrice);
    }

    public EntryBuilder withItemCode(String itemCode) {
        this.itemCode = itemCode;
        return this;
    }

    public EntryBuilder withUnitPrice(String unitPrice) {
        this.unitPrice = new Money(unitPrice);
        return this;
    }

    public EntryBuilder withKiloPrice(String kiloPrice) {
        this.kiloPrice = new Money(kiloPrice);
        return this;
    }
}
