@IsTest
public class OrderControllerTest {
    
    @isTest
    @SupressWarnings('PMD.AvoidHardcodingId')
    static void getRecentOrders_UsingStub() {
        // Create fake data
        Order o = new Order(
            Id = '801000000000001AAA',
            OrderNumber = 'ORD-001',
            TotalAmount = 1000,
            Status = 'Actived'
        );

        // Create the mock provider 
        MockProvider mocks = new MockProvider();
        mocks.mock('selectRecentOrders', new List<Order>{ o });

        // Generate the Stub (The Hologram)
        IOrderSelector stubSelector = (IOrderSelector) Test.createStub(OrderSelector.class, mocks);

        // INJECTION: Tell the Application to use the Stub
        Application.Selector.setMock(OrderSelector.class, stubSelector);

        // Act: Call the controller
        System.runAs(new User(UserInfo.getUserId())) {
            Test.startTest();
            List<Order> recentOrders = OrderController.getRecentOrders();   
            Test.stopTest();
        }
        
        // Assert
        Assert.areEqual(1, recentOrders.size(), 'Should return one order');
        Assert.areEqual('ORD-001', recentOrders[0].OrderNumber, 'OrderNumber should match');
    }
}