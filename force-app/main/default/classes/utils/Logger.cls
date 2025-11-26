/**
 * @description Utility class for centralized logging.
 * Wraps system debug statements and can be extended to write logs to a custom object.
 * * @author Lucas Duque
 * @group Utils
 */
public with sharing class Logger {

    /**
     * @description Logs an informational message.
     * @param context The class or method name
     * @param message The message to log
     */
    public static void info(String context, String message) {
        System.debug(LoggingLevel.INFO, 'INFO [' + context + ']: ' + message);
    }

    /**
     * @description Logs an warning message.
     * @param context The class or method name
     * @param message The message to log
     */
    public static void warning(String context, String message) {
        System.debug(LoggingLevel.WARN, 'INFO [' + context + ']: ' + message);
    }

    /**
     * @description Logs an exception with stack trace.
     * @param context The class or method name where error occurred
     * @param e The Exception object
     */
    public static void error(String context, Exception e) {
        System.debug(LoggingLevel.ERROR, 'ERROR [' + context + ']: ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
    }
}