@IsTest
private class MyIterableTest {

    @isTest
    static void testIterableForLoop() {
        List<String> strings = new List<String>{'Hello', 'World'};
        MyIterable mi = new MyIterable(strings);

        for(String s : mi) {
            System.debug(s);
        }
    }

    @IsTest
    static void iteratorReturnsFunctioningIterator() {
        // Arrange
        List<String> input = new List<String>{ 'A', 'B', 'C' };
        MyIterable iterable = new MyIterable(input);

        // Act
        Iterator<String> it = iterable.iterator();

        // Assert
        System.assertNotEquals(null, it, 'Iterator should not be null');
        System.assert(it.hasNext(), 'Iterator should have elements');
        System.assertEquals('A', it.next(), 'First element should match input order');
        System.assert(it.hasNext(), 'Iterator should still have elements');
        System.assertEquals('B', it.next(), 'Second element should match input order');
        System.assert(it.hasNext(), 'Iterator should still have elements');
        System.assertEquals('C', it.next(), 'Third element should match input order');
        System.assertEquals(false, it.hasNext(), 'Iterator should be exhausted');
    }

    @IsTest
    static void iterationOrderMatchesInputList() {
        // Arrange
        List<String> input = new List<String>{ 'one', 'two', 'three', 'four' };
        MyIterable iterable = new MyIterable(input);

        // Act
        List<String> visited = new List<String>();
        for (String s : iterable) {
            visited.add(s);
        }

        // Assert
        System.assertEquals(input.size(), visited.size(), 'Visited size should equal input size');
        System.assertEquals(input, visited, 'Visited order should match input order exactly');
    }

    @IsTest
    static void worksWithEmptyList() {
        // Arrange
        List<String> input = new List<String>();
        MyIterable iterable = new MyIterable(input);

        // Act
        Integer count = 0;
        for (String s : iterable) {
            count++;
        }

        // Assert
        System.assertEquals(0, count, 'No elements should be iterated for an empty list');
        // Direct iterator checks
        Iterator<String> it = iterable.iterator();
        System.assertNotEquals(null, it, 'Iterator should not be null for empty list');
        System.assertEquals(false, it.hasNext(), 'Iterator should have no elements for empty list');
    }

    @IsTest
    static void nullInputCausesExceptionOnIteratorAccess() {
        // Arrange
        // Current implementation stores reference without null checks; calling iterator() will NPE
        MyIterable iterable = new MyIterable(null);

        // Act + Assert
        Boolean threw = false;
        try {
            iterable.iterator();
        } catch (NullPointerException e) {
            threw = true;
        }
        System.assertEquals(true, threw, 'Calling iterator() with null internal list should throw NullPointerException based on current implementation');
    }
}