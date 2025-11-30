/**
 * orderDetails.js
 * Subscriber LWC that listens to ORDER_CHANNEL and loads Order details for the clicked Id.
 */
import { LightningElement, wire, track } from 'lwc';
// Import LMS subscribe/unsubscribe APIs and MessageContext to interact with the channel
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe } from 'lightning/messageService';
// The custom Lightning Message Channel used by orderList publisher
import ORDER_CHANNEL from '@salesforce/messageChannel/OrderMessageChannel__c';
// Apex method that returns a single Order with Account.Name and Owner.Name
import getOrderDetails from '@salesforce/apex/OrderController.getOrderDetails';

export default class OrderDetails extends LightningElement {
    // Wire the MessageContext (required to subscribe to/publish messages)
    @wire(MessageContext) messageContext;

    // Holds the active LMS subscription
    subscription;
    // Last selected Order Id received from the message channel
    orderId;
    // Holds the loaded Order record
    @track order;
    // Holds any error message from Apex
    error;
    // Simple flag to control spinner visibility
    loading = false;

    // Subscribe when component is inserted in the DOM
    connectedCallback() {
        this.subscribeToChannel();
    }

    // Clean up subscription when component is removed
    disconnectedCallback() {
        this.unsubscribeFromChannel();
    }

    // Establish LMS subscription to receive { orderId } messages from ORDER_CHANNEL
    subscribeToChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,               // LMS context
            ORDER_CHANNEL,                     // Channel to listen to
            (message) => this.handleMessage(message), // Callback on incoming message
            { scope: APPLICATION_SCOPE }       // Receive messages app-wide on the page
        );
    }

    // Unsubscribe to avoid memory leaks
    unsubscribeFromChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    // Handle incoming LMS message payload: { orderId }
    async handleMessage(message) {
        const incoming = message?.orderId;
        if (!incoming) {
            return; // ignore malformed payloads
        }
        // Avoid redundant server calls if the same order is re-selected
        if (incoming === this.orderId && this.order) {
            return;
        }
        this.orderId = incoming;
        await this.loadDetails();
    }

    // Imperative Apex call to fetch details for the selected orderId
    async loadDetails() {
        if (!this.orderId) {
            this.order = null;
            this.error = null;
            return;
        }
        this.loading = true;
        this.error = null;
        try {
            // Call Apex and store the returned Order record
            console.debug('Loading details for Order Id: ' + this.orderId);
            const result = await getOrderDetails({ orderId: this.orderId });
            this.order = result;
        } catch (e) {
            // Normalize error message for display
            this.error = e?.body?.message || e?.message || 'Unknown error';
            this.order = null;
        } finally {
            this.loading = false;
        }
    }

    // Used by the template to show an empty state before any selection
    get hasSelection() {
        return !!this.orderId;
    }
}
