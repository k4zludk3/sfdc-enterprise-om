/**
 * @description The Central Factory for the Enterprise Architecture.
 * Handles Dependency Injection and Mocking.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public inherited sharing class Application {
   
    //The Unit of Work Factory
    public static final UnitOfWorkFactory UnitOfWork = new UnitOfWorkFactory();

    //The Service Factory
    public static final ServiceFactory Service = new ServiceFactory();

    //The Selector Factory
    public static final SelectorFactory Selector = new SelectorFactory();

    // --- FACTORY CLASSES --- 

    public class ServiceFactory {
        // Map to hold Mock implementations during tests
        private Map<Type, Object> mocks = new Map<Type, Object>();

        public Object newInstance(Type serviceType) {
            // The Injection Point:
            // If a mock is registered, return that (Test Mode).
            if (mocks.containsKey(serviceType)) {
                return mocks.get(serviceType);
            } 
            // Otherwise, return the real implementation (Production Mode).
            return serviceType.newInstance();
        }

        //Test class call this to inject mock
        @TestVisible
        private void setMock(Type serviceType, Object mockInstance) {
            mocks.put(serviceType, mockInstance);
        }
    }

    public class SelectorFactory {
        private Map<Type, Object> mocks = new Map<Type, Object>();

        public Object newInstance(Type selectorType) {
            if (mocks.containsKey(selectorType)) {
                return mocks.get(selectorType);
            }

            return selectorType.newInstance();
        }

        @TestVisible
        private void setMock(Type selectorType, Object mockInstance){
            mocks.put(selectorType, mockInstance);
        }
    }

    public class UnitOfWorkFactory {
        private Map<Type, Object> mocks = new Map<Type, Object>();
        
        public Object newInstance(Type uowType) {
            if(mocks.containsKey(uowType)) {
                return mocks.get(uowType);
            }
            
            return uowType.newInstance();
        }

        @TestVisible
        private void setMock(Type uowType, Object mockInstance) {
            mocks.put(uowType, mockInstance);   
        }
    }
}