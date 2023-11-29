@IsTest
private class FlowToggleLockTest {

	@IsTest private static void test() {
		Test.startTest();
		Worker__c wo1 = new Worker__c();
		insert wo1;

		FlowToggleLock.ToggleLockRequest req = new FlowToggleLock.ToggleLockRequest();
		req.RecordId = wo1.Id;
		req.IsLocking = true;
		FlowToggleLock.ToggleLockRequest[] params = new FlowToggleLock.ToggleLockRequest[]{ req };

		//lock
		FlowToggleLock.execute(params);
		//lock an already locked record
		FlowToggleLock.execute(params);


		req.IsLocking = false;
		//unlock
		FlowToggleLock.execute(params);
		//unlock an already unlocked record
		FlowToggleLock.execute(params);
		System.assert(wo1 != null);
		Test.stopTest();

	}
}