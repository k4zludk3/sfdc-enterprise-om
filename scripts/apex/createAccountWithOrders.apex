// Anonymous Apex: Create Account, Contract, Price Books, Products, Orders, and Order Items
// Defaults:
// - Creates 1 Account, 1 Contract
// - Ensures Standard Price Book is active; creates a custom active Price Book
// - Creates 2 Products, with Standard and Custom PricebookEntries
// - Creates 3 Orders (Draft) each with 2 Order Items
// - Activation step for Orders is optional and commented at the end

// Adjust these parameters as needed
Integer numberOfOrders = 3;
Integer itemsPerOrder = 2;
Integer productCount = 2;
Decimal basePrice = 10;
Integer priceStep = 5;
Decimal customPriceMarkup = 2;
Boolean activateOrdersAfterCreation = false; // set true to try activating orders

String unique = String.valueOf(Datetime.now().getTime());

// 1) Account
Account acc = new Account(Name = 'Commerce Account ' + unique);
insert acc;

// 2) Contract (often required by Orders)
Contract c = new Contract(
    AccountId = acc.Id,
    StartDate = Date.today(),
    Status = 'Draft',
    ContractTerm = 12
);
insert c;

// 3) Price Books
// Find Standard Price Book
Pricebook2 std = [SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
if (!std.IsActive) {
    std.IsActive = true;
    update std;
}

// Create a custom price book
Pricebook2 pb = new Pricebook2(Name = 'PB ' + unique, IsActive = true);
insert pb;

// 4) Products
List<Product2> products = new List<Product2>();
for (Integer i = 1; i <= productCount; i++) {
    products.add(new Product2(
        Name = 'Product ' + i + ' ' + unique,
        IsActive = true
    ));
}
insert products;

// 5) Pricebook Entries (Standard and Custom PB)
// Standard PB entries are required to allow adding products to other price books
List<PricebookEntry> stdPbes = new List<PricebookEntry>();
for (Integer i = 0; i < products.size(); i++) {
    Product2 p = products[i];
    stdPbes.add(new PricebookEntry(
        Pricebook2Id = std.Id,
        Product2Id  = p.Id,
        UnitPrice   = basePrice + (i * priceStep),
        IsActive    = true,
        UseStandardPrice = false
    ));
}
insert stdPbes;

// Custom PB entries (often with different price than standard)
List<PricebookEntry> customPbes = new List<PricebookEntry>();
for (Integer i = 0; i < products.size(); i++) {
    Product2 p = products[i];
    customPbes.add(new PricebookEntry(
        Pricebook2Id = pb.Id,
        Product2Id  = p.Id,
        UnitPrice   = (basePrice + (i * priceStep)) + customPriceMarkup,
        IsActive    = true,
        UseStandardPrice = false
    ));
}
insert customPbes;

// 6) Orders
List<Order> orders = new List<Order>();
Date today = Date.today();
for (Integer i = 1; i <= numberOfOrders; i++) {
    orders.add(new Order(
        AccountId     = acc.Id,
        ContractId    = c.Id,
        Pricebook2Id  = pb.Id,
        EffectiveDate = today,
        Status        = 'Draft',
        Description   = 'Order ' + i + ' for ' + acc.Name
    ));
}
insert orders;

// 7) Order Items
List<OrderItem> items = new List<OrderItem>();
for (Order o : orders) {
    for (Integer i = 0; i < itemsPerOrder; i++) {
        Integer pbeIndex = Math.mod(i, customPbes.size());
        PricebookEntry pbe = customPbes[pbeIndex];
        items.add(new OrderItem(
            OrderId          = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 1 + i,
            UnitPrice        = pbe.UnitPrice
        ));
    }
}
insert items;

// Optional: Activate Orders if org allows
if (activateOrdersAfterCreation) {
    for (Order o : orders) {
        o.Status = 'Activated';
    }
    try {
        update orders;
    } catch (DmlException ex) {
        System.debug('Order activation failed: ' + ex.getMessage());
    }
}

// Output summary
System.debug('Account Id: ' + acc.Id);
System.debug('Contract Id: ' + c.Id);
System.debug('Custom Pricebook Id: ' + pb.Id);
System.debug('Order Count: ' + orders.size() + ' => ' + new Map<Id, Order>(orders).keySet());
System.debug('OrderItem count: ' + items.size());
