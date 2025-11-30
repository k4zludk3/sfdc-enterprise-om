@IsTest
@SuppressWarnings('PMD.ExcessiveParameterList')
public class MockProvider implements System.StubProvider {
    
    // This holds the method name -> return value mapping
    private Map<String, Object> returnValues = new Map<String, Object>();

    public void mock(String methodName, Object returnObject) {
        returnValues.put(methodName, returnObject);
    }

    // This is the magic method Salesforce calls automatically
    public Object handleMethodCall(
        Object stubbedObject,
        String stubbedMethodName,
        Type returnType,
        List<Type> listOfParamTypes,
        List<String> listOfParamNames,
        List<Object> listOfArgs
    ) {
        //if we defined a return value for this method, return it
        if (returnValues.containsKey(stubbedMethodName)) {
            return returnValues.get(stubbedMethodName);
        }

        return null;
    }
}