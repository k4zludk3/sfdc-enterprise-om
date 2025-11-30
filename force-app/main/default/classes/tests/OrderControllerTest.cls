@IsTest
public class OrderControllerTest {
    
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId, PMD.MethodNamingConventions')
    static void getRecentOrders_UsingStub() {
        // Create fake data
        Order o = new Order(
            Id = '801000000000001AAA',
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
        List<Order> recentOrders;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            recentOrders = OrderController.getRecentOrders();
            Test.stopTest();
        }
        
        // Assert
        Assert.areEqual(1, recentOrders.size(), 'Should return one order');
        Assert.areEqual('Actived', recentOrders[0].Status, 'Status should match');
    }
}
