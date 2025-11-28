public interface IOrderSelector {
    List<Order> selectRecentOrders(Integer limitSize);
}