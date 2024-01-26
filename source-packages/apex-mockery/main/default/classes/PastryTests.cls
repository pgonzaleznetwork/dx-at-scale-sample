@IsTest
public class PastryTests {
    
    @IsTest
    static void testMethodName() {
        
        Pastry bread = new Pastry('Bread');
        Pastry croissant = new Pastry('Croissant');
        bread.equals(croissant);
        bread.hashCode();

    }

}