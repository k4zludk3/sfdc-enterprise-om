import { LightningElement, wire } from 'lwc';

// 1. Import the Apex Method
import getRecentOrders from '@salesforce/apex/OrderController.getRecentOrders';

// 2. Import LMS features
import { publish, MessageContext } from 'lightning/messageService';
import ORDER_CHANNEL from '@salesforce/messageChannel/OrderMessageChannel__c';

export default class OrderList extends LightningElement {
    
    // 3. Wire the Message Context (Required to publish)
    @wire(MessageContext)
    messageContext;

    // 4. Wire the Data (Fetch Orders automatically)
    // 'orders' becomes an object with { data, error }
    @wire(getRecentOrders)
    orders;

    // 5. Handle the Click
    handleSelect(event) {
        // Stop the link from actually navigating (it's just a button disguised as a link)
        event.preventDefault();

        // Get the ID from the HTML 'data-id' attribute
        const selectedId = event.target.dataset.id;
        
        console.log('Publishing Order ID:', selectedId);

        // 6. Create Payload and Publish
        const payload = { orderId: selectedId };
        publish(this.messageContext, ORDER_CHANNEL, payload);
    }
}