public interface IOrderService {
    List<Order> calculatePricing(List<Order> orders);
    void publishOrderFinalized(List<Order> orders);
}