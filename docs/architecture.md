%% Architecture diagrams for sfdc-enterprise-order-management

%% 1) High-level component architecture (module relationships)

flowchart TD
    subgraph Presentation
        LWCOrderList[orderList LWC]
        LWCOrderDetails[orderDetails LWC]
        MsgChannel[OrderMessageChannel]
    end

    subgraph Apex_Controllers
        OrderCtrl[OrderController.cls]
    end

    subgraph Domain_Layer
        OrderDomain[OrderDomain.cls]
        AccountDomain[AccountDomain.cls]
    end

    subgraph Service_Layer
        OrderService[OrderService.cls]
        AccountService[AccountService.cls]
    end

    subgraph Selector_Layer
        OrderSelector[OrderSelector.cls]
    end

    subgraph Strategy_Pattern
        PricingFactory[PricingStrategyFactory.cls]
        StandardPricing[StandardPriceStrategy.cls]
        VipPricing[VipPriceStrategy.cls]
        IPricing[IPricingStrategy.cls]
    end

    subgraph Postal_Code_Strategy
        PostalFactory[PostalCodeStrategyFactory.cls]
        BrazilPostalStrategy[BrazilPostalCodeStrategy.cls]
        IPostalCodeStrategy[IPostalCodeStrategy.cls]
        PostalCodeBrazil[PostalCodeBrazil.cls]
        IPostalCode[IPostalCode.cls]
    end

    subgraph Framework
        Application[Application.cls]
        TriggerDispatcher[TriggerDispatcher.cls]
        TriggerHandler[TriggerHandler.cls]
        ITriggerHandler[ITriggerHandler.cls]
        UnitOfWork[UnitOfWork.cls]
        IUnitOfWork[IUnitOfWork.cls]
        MockProvider[MockProvider.cls]
    end

    subgraph Triggers
        AccountTrigger[AccountTrigger.trigger]
        OrderTrigger[OrderTrigger.trigger]
    end

    subgraph Utils
        Logger[Logger.cls]
        CustomException[CustomException.cls]
        RecursionCheck[RecursionCheck.cls]
    end

    subgraph Platform_Events
        OrderEvt[Order_Notification__e]
    end

    subgraph Integrations_Async
        BillingCodeQ[BillingCodeAPIQueuable.cls]
    end

    %% Presentation to Controller and Message Channel
    LWCOrderList --> OrderCtrl
    LWCOrderDetails --> OrderCtrl
    LWCOrderList <---> MsgChannel
    LWCOrderDetails <---> MsgChannel

    %% Controller to Domain/Service
    OrderCtrl --> OrderService
    OrderCtrl --> OrderDomain
    OrderCtrl --> UnitOfWork

    %% Service uses Selector, Domain, Strategies, UoW, Utils
    OrderService --> OrderSelector
    OrderService --> OrderDomain
    OrderService --> PricingFactory
    OrderService --> PostalFactory
    OrderService --> UnitOfWork
    OrderService --> Logger
    OrderService -.-> CustomException
    OrderService --> BillingCodeQ
    OrderService -.-> OrderEvt

    %% Pricing strategy factory to concrete strategies
    PricingFactory --> IPricing
    PricingFactory --> StandardPricing
    PricingFactory --> VipPricing

    %% Postal code strategy
    PostalFactory --> IPostalCodeStrategy
    PostalFactory --> BrazilPostalStrategy
    BrazilPostalStrategy --> PostalCodeBrazil
    PostalCodeBrazil --> IPostalCode

    %% Triggers use dispatcher and handlers
    AccountTrigger --> TriggerDispatcher
    OrderTrigger --> TriggerDispatcher
    TriggerDispatcher --> TriggerHandler
    TriggerHandler --> ITriggerHandler
    TriggerHandler --> Application
    TriggerHandler --> UnitOfWork
    TriggerHandler --> RecursionCheck
    TriggerHandler --> Logger

    %% Domain depends on Utils
    OrderDomain --> Logger
    AccountDomain --> Logger


%% 2) Request flow sequence (LWC through Apex to DB/event/async)

sequenceDiagram
    participant LWC as LWC (orderList/orderDetails)
    participant CTRL as Apex OrderController
    participant SVC as OrderService
    participant SEL as OrderSelector
    participant DOM as OrderDomain
    participant UOW as UnitOfWork
    participant STRAT as PricingStrategyFactory/Standard/Vip
    participant PSTRAT as PostalCodeStrategyFactory/BrazilPostalCodeStrategy
    participant QUEUE as BillingCodeAPIQueuable
    participant EVT as Order_Notification__e

    LWC->>CTRL: @AuraEnabled(call)
    CTRL->>UOW: start()
    CTRL->>SVC: execute business operation
    SVC->>SEL: query data per selector pattern
    SVC->>DOM: apply domain rules
    SVC->>STRAT: select pricing strategy
    STRAT-->>SVC: price calculation
    SVC->>PSTRAT: postal code validation/normalization
    PSTRAT-->>SVC: result
    SVC->>UOW: register DML via Unit of Work
    SVC->>EVT: publish Order_Notification__e (optional)
    SVC->>QUEUE: enqueue external billing update (optional)
    SVC-->>CTRL: result DTO
    CTRL->>UOW: commit()
    CTRL-->>LWC: return data



%% 3) Trigger handling overview

flowchart LR
    AccountTrigger[AccountTrigger.trigger] --> Dispatcher[TriggerDispatcher]
    OrderTrigger[OrderTrigger.trigger] --> Dispatcher

    subgraph Trigger Framework
        Dispatcher --> Handler[TriggerHandler]
        Handler --> ITriggerHandler[ITriggerHandler]
        Handler --> Application[Application]
        Handler --> UnitOfWork[UnitOfWork]
        Handler --> RecursionCheck[RecursionCheck]
        Handler --> Logger[Logger]
    end

    Handler --> Domain[Domain Classes]
    Handler --> Services[Service Classes]



%% 4) Pricing strategy pattern focus

classDiagram
    class IPricingStrategy {
      +calculatePrice(order) Decimal
    }
    class StandardPriceStrategy {
      +calculatePrice(order) Decimal
    }
    class VipPriceStrategy {
      +calculatePrice(order) Decimal
    }
    class PricingStrategyFactory {
      +for(order): IPricingStrategy
    }

    IPricingStrategy <|.. StandardPriceStrategy
    IPricingStrategy <|.. VipPriceStrategy
    PricingStrategyFactory --> IPricingStrategy


%% 5) Postal code strategy focus

classDiagram
    class IPostalCode {
      +value: String
    }
    class IPostalCodeStrategy {
      +normalize(pc: IPostalCode): IPostalCode
      +validate(pc: IPostalCode): Boolean
    }
    class PostalCodeBrazil {
      +value: String
    }
    class BrazilPostalCodeStrategy {
      +normalize(pc: IPostalCode): IPostalCode
      +validate(pc: IPostalCode): Boolean
    }
    class PostalCodeStrategyFactory {
      +for(country): IPostalCodeStrategy
    }

    IPostalCode <|.. PostalCodeBrazil
    IPostalCodeStrategy <|.. BrazilPostalCodeStrategy
    PostalCodeStrategyFactory --> IPostalCodeStrategy
    BrazilPostalCodeStrategy --> PostalCodeBrazil
