@isTest 
private class WMS_Cargo_LastWosLineTest {

	@isTest
	private static void test_getWosLines() {
		System.assertEquals(0, WMS_Cargo_LastWosLine.getWosLines(null).size());
	}
}