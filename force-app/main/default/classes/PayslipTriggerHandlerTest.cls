@isTest
private class PayslipTriggerHandlerTest {
	private static Employee__c employee;
	private static PayrollOrder__c payOrder;
	private static HRStandard__c hrPolicy;
	static{
		hrPolicy = new HRStandard__c(
			salarytocontributesocialinsurance__c = 30000,
			SocialInsuracneRatioByEmployee__c = 8,
			HealthInsuranceRatioByEmployee__c = 2,
			UnemploymentFundRatioByEmployee__c = 1,
			Active__c = true);
        FlsService.doInsert(hrPolicy);
		employee = new Employee__c(
			CloHRMStandard__c = hrPolicy.Id,
			Birthday__c = Date.today()
		);
        FlsService.doInsert(employee);
		payOrder = new PayrollOrder__c(
			PayrollOrderName__c ='test');
        FlsService.doInsert(payOrder);
	}
	
	@isTest static void test_method_one() {
		Test.startTest();

		 PayrollSlip__c payslip = new PayrollSlip__c(
		 	EmployeeID__c = employee.Id,
		 	PayrollOrder__c = payOrder.Id,
			hrpolicy__c = hrPolicy.Id
			 );
        FlsService.doInsert(payslip);
		 system.assert(payslip != null);
		Test.stopTest();
	}
}