public interface Order {
    void doOrder(CreditSystem creditSystem, Opportunity opportunity, String errorMessage, String internalId);
    String getSuccessfulOrderStatus();
}