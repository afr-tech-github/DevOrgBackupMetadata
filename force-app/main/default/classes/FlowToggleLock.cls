public without sharing class FlowToggleLock {

	@InvocableMethod(label='Toggle Record Lock/Unlock' description='Toggle Record Lock/Unlock')
	public static void Execute (List<ToggleLockRequest> params) {
		List<Id> setLock = new List<Id>();
		List<Id> setUnlock = new List<Id>();

		for (ToggleLockRequest item : params) {
			if (item.IsLocking) {
				setLock.add(item.RecordId);
			}
			else {
				setUnlock.add(item.RecordId);
			}
		}

		Approval.lock(setLock);
		Approval.unlock(setUnlock);
	}

	public class ToggleLockRequest {
		@InvocableVariable
		public String RecordId;
		@InvocableVariable
		public Boolean IsLocking;
	}
}