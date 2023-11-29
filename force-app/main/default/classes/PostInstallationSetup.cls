/**
 * This script is run as post-installation script to populate required configuration so that the application
 * can function properly.
 */
global with sharing class PostInstallationSetup implements InstallHandler {
    global void onInstall(InstallContext context) {
        List<SObject> objectsToInsert = new List<SObject>();

        if (context.previousVersion() == null) {
            objectsToInsert.addAll(populateContainerInfoMappings());
            objectsToInsert.addAll(popuplateInitialConfiguration());
        }

        //objectsToInsert.addAll(populatePermissionSetAssignments());
        objectsToInsert.addAll(populateTranslations());

        if (!objectsToInsert.isEmpty()) {
            FlsService.doInsert(objectsToInsert);
        }

        populateObjectIdsPrefix();
    }

    // private List<SObject> populatePermissionSetAssignments() {
    //     List<SObject> assignments = new List<SObject>();
        
    //     if (Test.isRunningTest()) {
    //         return assignments;
    //     }

    //     Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'AutomatedProcessPermission' AND NamespacePrefix = 'clofor_com_cfs' LIMIT 1].Id;
    //     Id assigneeId = [SELECT Id FROM User WHERE Name = 'Automated Process' LIMIT 1].Id;
        
    //     if ([SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetId AND AssigneeId = :assigneeId] == 0) {
    //         assignments.add(new PermissionSetAssignment(
    //             PermissionSetId = permissionSetId,
    //             AssigneeId = assigneeId
    //         ));
    //     }
        
    //     return assignments;
    // }

    private void populateObjectIdsPrefix() {
        Site_Custom_Settings__c settings = [SELECT VATInvoiceObjectIdPrefix__c, CashObjectIdPrefix__c, RouteObjectIdPrefix__c FROM clofor_com_cfs__Site_Custom_Settings__c LIMIT 1];
        Boolean hasUpdate = false;

        if (StringUtils.isEmpty(settings.VATInvoiceObjectIdPrefix__c)) {
            settings.VATInvoiceObjectIdPrefix__c = Util.getObjectTypeId(VAT_INVOICE__c.SObjectType.getDescribe().getName());
            hasUpdate = true;
        }

        if (StringUtils.isEmpty(settings.CashObjectIdPrefix__c)) {
            settings.CashObjectIdPrefix__c = Util.getObjectTypeId(CASH_BOOK__c.SObjectType.getDescribe().getName());
            hasUpdate = true;
        }

        if (StringUtils.isEmpty(settings.RouteObjectIdPrefix__c)) {
            settings.RouteObjectIdPrefix__c = Util.getObjectTypeId(Route__c.SObjectType.getDescribe().getName());
            hasUpdate = true;
        }

        if (hasUpdate) {
            FlsService.doupdate(settings);
        }
    }

    private List<SObject> populateContainerInfoMappings() {
        List<SObject> mappings = new List<SObject>();

        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M1', Type__c = '20\'DC-Flexitank', Code__c = 'SN : Others', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M2', Type__c = '20\'DC', Code__c = 'GP : Dry Container', Size__c = '22'));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M3', Type__c = '40\'DC', Code__c = 'GP : Dry Container', Size__c = '42'));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M4', Type__c = '40\'HC', Code__c = 'GP : Dry Container', Size__c = '45'));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M5', Type__c = '20\'REF', Code__c = 'RT : Reefer container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M6', Type__c = '40\'REF', Code__c = 'RT : Reefer container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M7', Type__c = '20\'OT', Code__c = 'UT : Open top container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M8', Type__c = '40\'OT', Code__c = 'UT : Open top container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M9', Type__c = '20\'FT', Code__c = 'PF : Flat rack container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M10', Type__c = '40\'FT', Code__c = 'PF : Flat rack container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M11', Type__c = '20\'PF', Code__c = 'PL : Platform container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M12', Type__c = '40\'PF', Code__c = 'PL : Platform container', Size__c = ''));
        mappings.add(new CONTAINER_INFO_MAPPINGS__c(Name = 'M13', Type__c = 'ISO', Code__c = 'ＴＮ : Tank container', Size__c = ''));

        return mappings;
    }
    
    /**
     * There are some custom pages where SF OOTB multiple languages feature does not support.
     * The initial set of translation includes: English, Japanese, Vietnamese, Korean and Chinese.
     */
    private List<SObject> populateTranslations() {
        // clear translations
        List<Translation__c> existingTranslations = [SELECT Id FROM Translation__c Limit 50000];
        FlsService.dodelete(existingTranslations);

        List<Translation__c> translations = new List<Translation__c>();
        translations.add(createTranslation('ALL','ALL','All','すべて','All','Tất cả','null','null','All'));
        translations.add(createTranslation('ALL','btn_close','Close','閉じる','닫기','Đóng','null','null','Close'));
        translations.add(createTranslation('ALL','BTN_GENERATE','Generate','作成','생성','Tạo','Generate','Generate','Generate'));
        translations.add(createTranslation('ALL','Cancel','Cancel','キャンセル','취소','Huỷ','Cancel','Cancel','Cancel'));
        translations.add(createTranslation('ALL','CONTAINER_NO_ATL_TEXT','A part of','A part of','A part of','A part of','A part of','A part of','A part of'));
        translations.add(createTranslation('ALL','HELPLINK','Help for this page','このページのヘルプ','이 페이지의 도움','Trợ giúp','null','null','Help for this page'));
        translations.add(createTranslation('ALL','INSUFFICIENT_PERMISSION','Insufficient permission.','十分な権限がありません。','권한이 없습니다.','Không có quyền truy cập','null','null','Insufficient permission.'));
        translations.add(createTranslation('ALL','language','Language','言語','언어','Ngôn ngữ','null','null','Language'));
        translations.add(createTranslation('ALL','LOAD_TITLE','Load','負荷','하중','Nạp','null','null','Load'));
        translations.add(createTranslation('ALL','Non-Tax(非課税)','NT','非課税','비과세','NT','NT','NT','NT'));
        translations.add(createTranslation('ALL','OBJECT_TITLE','Object','オブジェクト','목적','Thông tin','null','null','Object'));
        translations.add(createTranslation('ALL','OPERATION_SUCCESS','Operation has been done successfully','操作は正常に完了しました','작업이 성공적으로 완료되었습니다.','Thao tác đã thực hiện thành công','Operation has been done successfully','Operation has been done successfully','Operation has been done successfully'));
        translations.add(createTranslation('ALL','Reset','Reset','リセット','리셋','Khôi Phục','null','null','Reset'));
        translations.add(createTranslation('ALL','SAVE_TITLE','Save','溜める','구하다','Lưu','null','null','Save'));
        translations.add(createTranslation('ALL','Tax Free(免税)','TF','免税','면세','TF','TF','TF','TF'));
        translations.add(createTranslation('ALL','TAX(課税)','TAX','課税','과세','TAX','TAX','TAX','TAX'));
        translations.add(createTranslation('COPY_MBL_HBL','HBL_MBL_CONFIRMATION_MSG','Copy this record?','この混載レコードをコピーしますか？','이 콘솔 레코드를 복사하시겠습니까?','Bạn có muốn sao chép dữ liệu lô hàng?','Copy this record?','Copy this record?','Copy this record?'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_CONFIRMATION_MSG','Would you like to copy data to selected SHIPMENT ORDER record?','選択されたシッピング指示レコードにデータをコピーしますか？','선택하신 쉽핑오더레코드에 데이터를 복사하시겠습니까?','Bạn có muốn sao chép dữ liệu sang những Vận đơn thứ cấp được chọn không?','Would you like to copy data to selected SHIPMENT ORDER record?','Would you like to copy data to selected SHIPMENT ORDER record?','Would you like to copy data to selected SHIPMENT ORDER record?'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_COPY_BTN','Copy Data','データをコピーする','데이터 복사','Sao Chép','null','null','Copy Data'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_COPY_COMPLETED','Copying data from CONSOLIDATION Record to SHIPMENT ORDER Record completed','混載レコードからシッピング指示レコードレコードへのコピーを完了しました','콘솔레코드에서 쉽핑오더레코드로 데이터복제가 완료되었습니다.','Sao chép dữ liệu từ Hàng ghép tới Vận đơn chủ đã hoàn thành','null','null','Copying data from CONSOLIDATION Record to SHIPMENT ORDER Record completed'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_SUBTITLE1','CONSOLIDATION Details','混載の詳細','콘솔 상세내역','Chi tiết HÀNG GHÉP','null','null','CONSOLIDATION Details'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_SUBTITLE2','Select SHIPMENT ORDER records to copy data to','データを移行するシッピング指示レコードの選択','데이터 복사를 위한 쉽핑오더레코드를 선택해 주십시오.','Chọn VẬN ĐƠN THỨ CẤP tới dữ liệu sao chép','null','null','Select SHIPMENT ORDER records to copy data to'));
        translations.add(createTranslation('COPY_MBL_HBL','MBL_HBL_TITLE','COPY DATA TO H B/L - SHIPMENTS','H B/Lへのデータ移行','H B/L로 데이터 복사','SAO CHÉP DỮ LIỆU TỚI VẬN ĐƠN THỨ CẤP','null','null','COPY DATA TO H B/L - SHIPMENTS'));
        translations.add(createTranslation('COST_ALLOCATION','COST_ALLOCATION_MSG','Cost Allocation has been balanced successfully','H B/L案件への費用按分が正常に完了しました。','비용배분이 성공적으로 완료되었습니다.','Phân bổ chi phí đã hoàn tất','null','null','Cost Allocation has been balanced successfully'));
        translations.add(createTranslation('ERROR','CONTAINER_NOT_SET','The number of containers has not been set in H B/L-SHIPMENT. Please enter the number of container.','H B/L案件にコンテナ本数が入力されていません。ご確認の上、正しいコンテナ本数をご入力ください。','콘테이너수가 입력되어 있지 않습니다. 확인 후 콘테이너수를 입력하여 주시기 바랍니다.','Số lượng container chưa được cung cấp trong Vận đơn thứ cấp.','null','null','The number of containers has not been set in H B/L-SHIPMENT. Please enter the number of container.'));
        translations.add(createTranslation('ERROR','DUPLICATED_CONTAINER_NO','Duplicated Container No or Seal No has been entered. the Container No and Seal No must be unique in the same H B/L Shipment.','一つのH B/Lには重複しているコンテナ番号やSeal番号を入力することができません。','동일한 H B/L에서 중복된 콘테이너번호 및 SEAL번호를 등록 하실 수 없습니다.','Trùng Số container hoặc Số seal','null','null','Duplicated Container No or Seal No has been entered. the Container No and Seal No must be unique in the same H B/L Shipment.'));
        translations.add(createTranslation('ERROR','EXCEEDED_NUM_CONTAINERS','You cannot have more than 7 Container Types for one H B/L-SHIPMENT.','一つのFMS S/O レコードにおいて登録可能なコンテナタイプは 七つです。','하나의 FMS S/O 에 등록가능한 콘테이너 타입은 4가지 종류 입니다.','Bạn không thể có nhiều hơn 7 loại cont trong một FMS S/O','You cannot have more than 7 Container Types for one H B/L-SHIPMENT.','You cannot have more than 7 Container Types for one H B/L-SHIPMENT.','You cannot have more than 7 Container Types for one H B/L-SHIPMENT.'));
        translations.add(createTranslation('ERROR','INVALID_CONTAINER_NO','Container No is not valid. Please enter 11digits(4digit container ownership code+7digit container code)','入力されたデータが正しくありません。11桁の数字を入力してください。船会社のコードと4桁のコンテナコード7桁の組み合わせで再度入力してください','입력하신 데이터가 맞는지 다시한번 확인 하시길 바랍니다. 반드시 11자리를 입력하여여 합니다.  4자리: 콘테이너소유자코드(선사코드) 및 7자리:콘테이너 코드','Số container không hợp lệ. Số hợp lệ phải gồm 4 ký tự số và 7 ký tự chữ.','null','null','Container No is not valid. Please enter 11digits(4digit container ownership code+7digit container code)'));
        translations.add(createTranslation('ERROR','INVALID_EXPORT_PROCESS_TIME_ORDER','Please check the input date of the following date fields. The correct order is Pickup Date->Delivery Date->Permit Date->Cut Date->ETD->Transit ETD->ETA.','入力された日付が正しく順番どおりになっているかご確認ください。正しい順番は引取日->配送日->通関許可日->Cut->出港日->積替港での出港日->入港日','입력한 예정일이 맞는지 확인 하여 주시기 바랍니다. 바른 입력 순서는 픽업일->배송일->통관허가일->Cut->출항일->트랜진항에서의 출항일->입항일 순입니다.','Vui lòng kiểm trả ngày nhập vào của các mục sau đây. Trình tự đúng là Ngày Nhận -> Ngày Giao -> Ngày Khai báo -> Ngày Chốt -> ETD -> ETD Chuyển tiếp -> ETA','null','null','Please check the input date of the following date fields. The correct order is Pickup Date->Delivery Date->Permit Date->Cut Date->ETD->Transit ETD->ETA.'));
        translations.add(createTranslation('ERROR','INVALID_IMPORT_PROCESS_TIME_ORDER','Please check the input date of the following date fields. The correct order is ETD->Transit ETD->ETA->Permit Date->Pickup Date->Delivery Date.','入力された日付が正しく順番どおりになっているかご確認ください。正しい順番は出港日->積替港での出港日->入港日->通関許可日->引取日->配送日　になります。','입력하신 예정일이 맞는지 확인 하여 주시기 바랍니다. 맞는 순서는 출항일->트랜짓항에서늬 출항일->입항일->통관허가비->픽업일->배송일 순서입니다.','Vui lòng kiểm trả ngày nhập vào của các mục sau đây. Trình tự đúng là ETD -> ETD Chuyển tiếp -> ETA -> Ngày Khai báo -> Ngày Nhận -> Ngày Giao','null','null','Please check the input date of the following date fields. The correct order is ETD->Transit ETD->ETA->Permit Date->Pickup Date->Delivery Date.'));
        translations.add(createTranslation('ERROR','INVALID_RECORD_TYPE','The selected Record Type does not align with its H B/L-SHIPMENT Record Type','選択されたレコードタイプは必ずH B/Lのレコードタイプと一致する必要があります。選択されたレコードタイプを確認してください。','선택된 레코드타입이 H B/L의 레크드타입과 일치하지 않습니다. 선택하신 레코드 파입을 다시한번 확인 하여 주십시요.','Loại bản ghi không trùng khớp với loại bản ghi của Vận đơn thứ cấp.','null','null','The selected Record Type does not align with its H B/L-SHIPMENT Record Type'));
        translations.add(createTranslation('ERROR','LIMITED_DELIVERY_LOCATIONS','50 is the maximum number of delivery location in one H B/L','一つのシッピング指示に登録可能な配送先数は50か所です。','하나의쉽핑오더에 등록가능한 배송처는 50군데까지 입니다.','Số lượng tối đa cho địa điểm giao hàng là 50 trong một vận đơn thứ cấp','null','null','50 is the maximum number of delivery location in one H B/L'));
        translations.add(createTranslation('ERROR','NOT_ALLOWED_CREATE_LOCKED_HBL','You cannot create H B/L-SHIPMENT with locked record type. Please choose the record type besides Locked','ロックレコードタイプのレコードは作成できません。ロック以外のレコードタイプを選択してください。','잠금이라고 표기되어 있는 레코드타입의 신규 레코드 생성은 불가합니다. 잠금이 들어가 있지 않은 레코드타입을 선택하여 주시기 바랍니다.','Bạn không thể tạo Vận đơn thứ cấp bị khoá','null','null','You cannot create H B/L-SHIPMENT with locked record type. Please choose the record type besides Locked'));
        translations.add(createTranslation('ERROR','NOT_ALLOWED_EDIT_LOCKED_HBL','You are not allowed to unlock or update this shipment. please contact to System Administrator, Accounting Team, or Manager who are authorized to do it.','現在のアカウント権限では修正及びロック解除はできません。システム管理者、経理チーム、マネージャにロック解除を依頼してください。','지금 사용하고 계신 권한으로는 변경 및 잠금해제를 할수 없습니다. 시스템관리자, 경리팀, 또는 메너져에게 해제 의뢰를 하여 주시기 바랍니다.','Bạn không được phép mở khóa hoặc cập nhận đơn hàng này.Vui lòng liên hệ với Ban quản trị hệ thống, Kế Toán hoặc Quản lý người được ủy quyền.','null','null','You are not allowed to unlock or update this shipment. please contact to System Administrator, Accounting Team, or Manager who are authorized to do it.'));
        translations.add(createTranslation('ERROR','NOT_UNIQUE_CONTAINER','Container No and Seal No must be unique in one H B/L-SHIPMENT for all containers.','一つのH B/L案件の中でコンテナ番号およびシール番号が重複することはできません。','하나의 쉽핑오더에서는 동일한 콘테이너 번호 또는 SEAL번호를 선택 하실 수 없습니다.','Số container và Số seal phải duy nhất trong cùng một Vận đơn thứ cấp','null','null','Container No and Seal No must be unique in one H B/L-SHIPMENT for all containers.'));
        translations.add(createTranslation('ERROR','OVERLAPPED_EXCHANGE_RATE','The being defined period overlaps with another Exchange Rate at','すでに有効な為替が登録されています。重複している内容がないかご確認ください。','이미 등록된 유효한 환율이 있습니다. 중복된 내용이 없는지 확인 하여 주시기 바랍니다.','Tỉ giá đang được khai báo trùng lắp với một Tỉ giá đang tồn tại','null','null','The being defined period overlaps with another Exchange Rate at'));
        translations.add(createTranslation('ERROR','OVERLAPPED_TAX_RATIO','The being defined Tax Ratio is overlapped with existing Tax Ratio at','すでに有効な消費税率が登録されています。重複していないかご確認ください。','이미 등록되어 있는 유효한 소비세율이 있습니다. 중복된 내용이 없는지 확인 하시기 바랍니다.','Tỉ suất thuế trùng lắp với một Tỉ suất thuế đang tồn tại','null','null','The being defined Tax Ratio is overlapped with existing Tax Ratio at'));
        translations.add(createTranslation('ERROR','UNAVAILABLE_CURRENCY','The selected currency is not valid. Valid currencies are USD','通貨が有効ではありません。有効な通貨:USD','선택된 통화의 값이 유효하지 않습니다.  유효한 통화는 다음과 같습니다. USD','Loại tiền tệ không hợp lệ. Hợp lệ tiền tệ gồm có USD','null','null','The selected currency is not valid. Valid currencies are USD'));
        translations.add(createTranslation('Invoice','Advanced Payment','Advanced Payment','立替','대납','TRẢ TRƯỚC','Advanced Payment','Advanced Payment','Advanced Payment'));
        translations.add(createTranslation('Invoice','AIR','AIR','航空','항공','ĐƯỜNG KHÔNG','AIR','AIR','AIR'));
        translations.add(createTranslation('Invoice','B/L','B/L','B/L','B/L','B/L','null','null','B/L'));
        translations.add(createTranslation('Invoice','Case','Case','件','건','Kiện','Case','Case','Case'));
        translations.add(createTranslation('Invoice','CASH','CASH','現金','현금','Tiền mặt','null','null','CASH'));
        translations.add(createTranslation('Invoice','CASH/TRANSFER','CASH/TRANSFER','CASH/TRANSFER','CASH/TRANSFER','TM/CK','null','null','CASH/TRANSFER'));
        translations.add(createTranslation('Invoice','CBM','CBM','CBM','CBM','CBM','CBM','CBM','CBM'));
        translations.add(createTranslation('Invoice','CTN','CTN','CTN','CTN','CTN','CTN','CTN','CTN'));
        translations.add(createTranslation('Invoice','Day','Day','日','일','Ngày','Day','Day','Day'));
        translations.add(createTranslation('Invoice','KG','KG','KG','KG','KG','KG','KG','KG'));
        translations.add(createTranslation('Invoice','License','License','ライセンス','라이센스','Giấy Phép','License','License','License'));
        translations.add(createTranslation('Invoice','Certificate','Certificate','認定書','인증서','C.thư','Certificate','Certificate','Certificate'));
        translations.add(createTranslation('Invoice','R/TON','R/TON','R/TON','R/TON','R/TON','R/TON','R/TON','R/TON'));
        translations.add(createTranslation('Invoice','SEA','SEA','海上','해상','ĐƯỜNG BIỂN','SEA','SEA','SEA'));
        translations.add(createTranslation('Invoice','SEA&AIR','SEA & AIR','複合','복합','ĐƯỜNG BIỂN & HÀNG KHÔNG','SEA & AIR','SEA & AIR','SEA & AIR'));
        translations.add(createTranslation('Invoice','SEA&RAIL','SEA & RAIL','複合','복합','ĐƯỜNG BIỂN & TÀU HOẢ','SEA & RAIL','SEA & RAIL','SEA & RAIL'));
        translations.add(createTranslation('Invoice','Sheet','Sheet','枚','매','Tờ','Sheet','Sheet','Sheet'));
        translations.add(createTranslation('Invoice','Shipment','Shipment','Shipment','Shipment','Lô','Shipment','Shipment','Shipment'));
        translations.add(createTranslation('Invoice','TRANSFER','TRANSFER','TRANSFER','TRANSFER','Chuyển khoản','null','null','TRANSFER'));
        translations.add(createTranslation('Invoice','コンテナ','Container','コンテナ','콘테이너','Cont','null','null','Container'));
        translations.add(createTranslation('Invoice','免税','TF','免税','면세','TF','null','null','TF'));
        translations.add(createTranslation('Invoice','小切手','CHECK','小切手','어음','CHI PHIẾU','CHECK','CHECK','CHECK'));
        translations.add(createTranslation('Invoice','振込','TRANSFER','振込','계좌이체','CHUYỂN KHOẢN','TRANSFER','TRANSFER','TRANSFER'));
        translations.add(createTranslation('Invoice','本','Unit','本','대','Đơn Vị','Unit','Unit','Unit'));
        translations.add(createTranslation('Invoice','現金','CASH','現金','현금','TM','null','null','CASH'));
        translations.add(createTranslation('Invoice','立替','Advanced Payment','立替','대납','TRẢ TRƯỚC','null','null','Advanced Payment'));
        translations.add(createTranslation('Invoice','課税','TAX','課税','과세','TAX','TAX','TAX','TAX'));
        translations.add(createTranslation('Invoice','非課税','NT','非課税','비과세','NT','NT','NT','NT'));
   
    // Thong configured 20191004-start1
    
        translations.add(createTranslation('Invoice','件','Case','件','건','Kiện','Case','Case','Case'));
        translations.add(createTranslation('Invoice','Carton','Carton','Carton','Carton','Kiện','Carton','Carton','Carton'));
        translations.add(createTranslation('Invoice','Pallet','Pallet','Pallet','Pallet','Pallet','Pallet','Pallet','Pallet'));
        translations.add(createTranslation('Invoice','RTON','RTON','RTON','RTON','RTON','RTON','RTON','RTON'));
        translations.add(createTranslation('Invoice','Kg','Kg','Kg','Kg','Kg','Kg','Kg','Kg'));
        translations.add(createTranslation('Invoice','EA','EA','EA','EA','EA','EA','EA','EA'));
        translations.add(createTranslation('Invoice','Km','Km','Km','Km','Km','Km','Km','Km'));
        translations.add(createTranslation('Invoice','All','All','All','All','All','All','All','All'));
        translations.add(createTranslation('Invoice','20\'All','20\'All','20\'All','20\'All','20\'All','20\'All','20\'All','20\'All'));
        translations.add(createTranslation('Invoice','40\'All','40\'All','40\'All','40\'All','40\'All','40\'All','40\'All','40\'All'));
        translations.add(createTranslation('Invoice','20\'DC','20\'DC','20\'DC','20\'DC','20\'DC','20\'DC','20\'DC','20\'DC'));
        translations.add(createTranslation('Invoice','2*20\'DC','2*20\'DC','2*20\'DC','2*20\'DC','2*20\'DC','2*20\'DC','2*20\'DC','2*20\'DC'));
        translations.add(createTranslation('Invoice','40\'DC','40\'DC','40\'DC','40\'DC','40\'DC','40\'DC','40\'DC','40\'DC'));
        translations.add(createTranslation('Invoice','45\'DC','45\'DC','45\'DC','45\'DC','45\'DC','45\'DC','45\'DC','45\'DC'));
        translations.add(createTranslation('Invoice','40\'HC','40\'HC','40\'HC','40\'HC','40\'HC','40\'HC','40\'HC','40\'HC'));
        translations.add(createTranslation('Invoice','45\'HC','45\'HC','45\'HC','45\'HC','45\'HC','45\'HC','45\'HC','45\'HC'));
        translations.add(createTranslation('Invoice','20\'RF','20\'RF','20\'RF','20\'RF','20\'RF','20\'RF','20\'RF','20\'RF'));
        translations.add(createTranslation('Invoice','40\'RF','40\'RF','40\'RF','40\'RF','40\'RF','40\'RF','40\'RF','40\'RF'));
        translations.add(createTranslation('Invoice','45\'RF','45\'RF','45\'RF','45\'RF','45\'RF','45\'RF','45\'RF','45\'RF'));
        translations.add(createTranslation('Invoice','20\'OT','20\'OT','20\'OT','20\'OT','20\'OT','20\'OT','20\'OT','20\'OT'));
        translations.add(createTranslation('Invoice','40\'OT','40\'OT','40\'OT','40\'OT','40\'OT','40\'OT','40\'OT','40\'OT'));
        translations.add(createTranslation('Invoice','45\'OT','45\'OT','45\'OT','45\'OT','45\'OT','45\'OT','45\'OT','45\'OT'));
        translations.add(createTranslation('Invoice','20\'FR','20\'FR','20\'FR','20\'FR','20\'FR','20\'FR','20\'FR','20\'FR'));
        translations.add(createTranslation('Invoice','40\'FR','40\'FR','40\'FR','40\'FR','40\'FR','40\'FR','40\'FR','40\'FR'));
        translations.add(createTranslation('Invoice','Bulk','Bulk','Bulk','Bulk','Bulk','Bulk','Bulk','Bulk'));
        translations.add(createTranslation('Invoice','ISO','ISO','ISO','ISO','ISO','ISO','ISO','ISO'));
        translations.add(createTranslation('Invoice','20\'IMO','20\'IMO','20\'IMO','20\'IMO','20\'IMO','20\'IMO','20\'IMO','20\'IMO'));
        translations.add(createTranslation('Invoice','40\'IMO','40\'IMO','40\'IMO','40\'IMO','40\'IMO','40\'IMO','40\'IMO','40\'IMO'));
        translations.add(createTranslation('Invoice','45\'IMO','45\'IMO','45\'IMO','45\'IMO','45\'IMO','45\'IMO','45\'IMO','45\'IMO'));
        translations.add(createTranslation('Invoice','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi','20\'DC-Flexi'));

    
    // Thong configured 20191004-end

    // QuanDo configured 20220225 -start
        // translations.add(createTranslation('Invoice','Bale','Bale','Bale','Bale','Bale','Bale','Bale','Bale'));
        // translations.add(createTranslation('Invoice','Bale,compressed','Bale,compressed','Bale,compressed','Bale,compressed','Bale,compressed','Bale,compressed','Bale,compressed','Bale,compressed'));
        // translations.add(createTranslation('Invoice','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed','Bale,non-compressed'));
        // translations.add(createTranslation('Invoice','Bar','Bar','Bar','Bar','Bar','Bar','Bar','Bar'));
        // translations.add(createTranslation('Invoice','Barrel','Barrel','Barrel','Barrel','Barrel','Barrel','Barrel','Barrel'));
        // translations.add(createTranslation('Invoice','Basket','Basket','Basket','Basket','Basket','Basket','Basket','Basket'));
        // translations.add(createTranslation('Invoice','Box','Box','Box','Box','Box','Box','Box','Box'));
        // translations.add(createTranslation('Invoice','Bulk, gas','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）','	Bulk, gas（at 1031mber and 15℃）'));
        // translations.add(createTranslation('Invoice','Bulk, liguefied gas','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）','Bulk, liguefied gas（at abnomal temperature/pressure）'));
        // translations.add(createTranslation('Invoice','Bulk, liquid','Bulk, liquid','Bulk, liquid','Bulk, liquid','Bulk, liquid','Bulk, liquid','Bulk, liquid','Bulk, liquid'));
        // translations.add(createTranslation('Invoice','Bulk, solid, fineparticles','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）','Bulk, solid, fineparticles(powders）'));
        // translations.add(createTranslation('Invoice','Bulk, solid, granular particles','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）','Bulk, solid, granular particles(grains）'));
        // translations.add(createTranslation('Invoice','Bulk, solid, large particles','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）','Bulk, solid, large particles(nodules）'));
        // translations.add(createTranslation('Invoice','Bundle','Bundle','Bundle','Bundle','Bundle','Bundle','Bundle','Bundle'));
        // translations.add(createTranslation('Invoice','Cage','Cage','Cage','Cage','Cage','Cage','Cage','Cage'));
        // translations.add(createTranslation('Invoice','Can,cylindrical','Can,cylindrical','Can,cylindrical','Can,cylindrical','Can,cylindrical','Can,cylindrical','Can,cylindrical','Can,cylindrical'));
        // translations.add(createTranslation('Invoice','Can,rectangular','Can,rectangular','Can,rectangular','Can,rectangular','Can,rectangular','Can,rectangular','Can,rectangular','Can,rectangular'));
        // translations.add(createTranslation('Invoice','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected','Carboy,non-protected'));
        // translations.add(createTranslation('Invoice','Carboy,protected','Carboy,protected','Carboy,protected','Carboy,protected','Carboy,protected','Carboy,protected','Carboy,protected','Carboy,protected'));
        // translations.add(createTranslation('Invoice','Cask','Cask','Cask','Cask','Cask','Cask','Cask','Cask'));
        // translations.add(createTranslation('Invoice','CDS','CDS','CDS','CDS','CDS','CDS','CDS','CDS'));
        // translations.add(createTranslation('Invoice','Charter','Charter','Charter','Charter','Charter','Charter','Charter','Charter'));
        // translations.add(createTranslation('Invoice','Chest','Chest','Chest','Chest','Chest','Chest','Chest','Chest'));
        // translations.add(createTranslation('Invoice','Coil','Coil','Coil','Coil','Coil','Coil','Coil','Coil'));
        // translations.add(createTranslation('Invoice','Crate','Crate','Crate','Crate','Crate','Crate','Crate','Crate'));
        // translations.add(createTranslation('Invoice','Cylinder','Cylinder','Cylinder','Cylinder','Cylinder','Cylinder','Cylinder','Cylinder'));
        // translations.add(createTranslation('Invoice','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected','DemiJohn,non-protected'));
        // translations.add(createTranslation('Invoice','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected','DemiJohn, protected'));
        // translations.add(createTranslation('Invoice','Drum','Drum','Drum','Drum','Drum','Drum','Drum','Drum'));
        // translations.add(createTranslation('Invoice','Fibre Drum','Fibre Drum','Fibre Drum','Fibre Drum','Fibre Drum','Fibre Drum','Fibre Drum','Fibre Drum'));
        // translations.add(createTranslation('Invoice','Flask','Flask','Flask','Flask','Flask','Flask','Flask','Flask'));
        // translations.add(createTranslation('Invoice','Flexible Container','Flexible Container','Flexible Container','Flexible Container','Flexible Container','Flexible Container','Flexible Container','Flexible Container'));
        // translations.add(createTranslation('Invoice','Frame','Frame','Frame','Frame','Frame','Frame','Frame','Frame'));
        // translations.add(createTranslation('Invoice','g','g','g','g','g','g','g','g'));
        // translations.add(createTranslation('Invoice','HEAD','HEAD','HEAD','HEAD','HEAD','HEAD','HEAD','HEAD'));
        // translations.add(createTranslation('Invoice','Hogeshead','Hogeshead','Hogeshead','Hogeshead','Hogeshead','Hogeshead','Hogeshead','Hogeshead'));
        // translations.add(createTranslation('Invoice','Ingot','Ingot','Ingot','Ingot','Ingot','Ingot','Ingot','Ingot'));
        // translations.add(createTranslation('Invoice','Jar','Jar','Jar','Jar','Jar','Jar','Jar','Jar'));
        // translations.add(createTranslation('Invoice','Keg','Keg','Keg','Keg','Keg','Keg','Keg','Keg'));
        // translations.add(createTranslation('Invoice','Log','Log','Log','Log','Log','Log','Log','Log'));
        // translations.add(createTranslation('Invoice','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss','Logs, in bundle/bunch/truss'));
        // translations.add(createTranslation('Invoice','Mat','Mat','Mat','Mat','Mat','Mat','Mat','Mat'));
        // translations.add(createTranslation('Invoice','Net','Net','Net','Net','Net','Net','Net','Net'));
        // translations.add(createTranslation('Invoice','Other','Other','Other','Other','Other','Other','Other','Other'));
        // translations.add(createTranslation('Invoice','Pallet & Package','Pallet & Package','Pallet & Package','Pallet & Package','Pallet & Package','Pallet & Package','Pallet & Package','Pallet & Package'));
        // translations.add(createTranslation('Invoice','Pail','Pail','Pail','Pail','Pail','Pail','Pail','Pail'));
        // translations.add(createTranslation('Invoice','Pack','Pack','Pack','Pack','Pack','Pack','Pack','Pack'));
        // translations.add(createTranslation('Invoice','Parcel','Parcel','Parcel','Parcel','Parcel','Parcel','Parcel','Parcel'));
        // translations.add(createTranslation('Invoice','Pen','Pen','Pen','Pen','Pen','Pen','Pen','Pen'));
        // translations.add(createTranslation('Invoice','Pipe','Pipe','Pipe','Pipe','Pipe','Pipe','Pipe','Pipe'));
        // translations.add(createTranslation('Invoice','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss','Pipes, in bundle/bunch/truss'));
        // translations.add(createTranslation('Invoice','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss','Planks, in bundle/bunch/truss'));
        // translations.add(createTranslation('Invoice','Plate','Plate','Plate','Plate','Plate','Plate','Plate','Plate'));
        // translations.add(createTranslation('Invoice','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss','Plates, in bundle/bunch/truss'));
        // translations.add(createTranslation('Invoice','Reel','Reel','Reel','Reel','Reel','Reel','Reel','Reel'));
        // translations.add(createTranslation('Invoice','Roll','Roll','Roll','Roll','Roll','Roll','Roll','Roll'));
        // translations.add(createTranslation('Invoice','Sack','Sack','Sack','Sack','Sack','Sack','Sack','Sack'));
        // translations.add(createTranslation('Invoice','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss','Sheet,in bundle/bunch/truss'));
        // translations.add(createTranslation('Invoice','Skeleton Case','Skeleton Case','Skeleton Case','Skeleton Case','Skeleton Case','Skeleton Case','Skeleton Case','Skeleton Case'));
        // translations.add(createTranslation('Invoice','Skid','Skid','Skid','Skid','Skid','Skid','Skid','Skid'));
        // translations.add(createTranslation('Invoice','Slab','Slab','Slab','Slab','Slab','Slab','Slab','Slab'));
        // translations.add(createTranslation('Invoice','Steel Case','Steel Case','Steel Case','Steel Case','Steel Case','Steel Case','Steel Case','Steel Case'));
        // translations.add(createTranslation('Invoice','Steel Envelop','Steel Envelop','Steel Envelop','Steel Envelop','Steel Envelop','Steel Envelop','Steel Envelop','Steel Envelop'));
        // translations.add(createTranslation('Invoice','Tierce','Tierce','Tierce','Tierce','Tierce','Tierce','Tierce','Tierce'));
        // translations.add(createTranslation('Invoice','Tin','Tin','Tin','Tin','Tin','Tin','Tin','Tin'));
        // translations.add(createTranslation('Invoice','Tray','Tray','Tray','Tray','Tray','Tray','Tray','Tray'));
        // translations.add(createTranslation('Invoice','Tub','Tub','Tub','Tub','Tub','Tub','Tub','Tub'));
        // translations.add(createTranslation('Invoice','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged','Unpacked or unpackaged'));
        // translations.add(createTranslation('Invoice','Vanpack','Vanpack','Vanpack','Vanpack','Vanpack','Vanpack','Vanpack','Vanpack'));
        // translations.add(createTranslation('Invoice','Vat','Vat','Vat','Vat','Vat','Vat','Vat','Vat'));
        // translations.add(createTranslation('Invoice','Wooden Box','Wooden Box','Wooden Box','Wooden Box','Wooden Box','Wooden Box','Wooden Box','Wooden Box'));
        // translations.add(createTranslation('Invoice','Wooden Case','Wooden Case','Wooden Case','Wooden Case','Wooden Case','Wooden Case','Wooden Case','Wooden Case'));
        // translations.add(createTranslation('Invoice','Wooden Drum','Wooden Drum','Wooden Drum','Wooden Drum','Wooden Drum','Wooden Drum','Wooden Drum','Wooden Drum'));
        // translations.add(createTranslation('Invoice','Wooden Pallet','Wooden Pallet','Wooden Pallet','Wooden Pallet','Wooden Pallet','Wooden Pallet','Wooden Pallet','Wooden Pallet'));

    // QuanDo configured 20220225 -end
    
    // kwon configured 20181205-start
          
        translations.add(createTranslation('Invoice','AIR&INLAND','AIR & INLAND','複合(航空・陸上)','복합운송(항공및육송)','ĐƯỜNG KHÔNG & NỘI ĐỊA','AIR & INLAND','AIR & INLAND','AIR & INLAND'));
        translations.add(createTranslation('Invoice','AIR&RAIL','AIR & RAIL','複合(航空・鉄路)','복합운송(항공및철도)','ĐƯỜNG KHÔNG VÀ ĐƯỜNG SẮT','AIR & RAIL','AIR & RAIL','AIR & RAIL'));
        translations.add(createTranslation('Invoice','RIVER','RIVER','川','강','ĐƯỜNG SÔNG','RIVER','RIVER','RIVER'));
        translations.add(createTranslation('Invoice','Container','Container','コンテナ','콘테이너','Cont','Container','Container','Container'));
        translations.add(createTranslation('Invoice','Bill','Bill','請求書','청구서','Lô','Bill','Bill','Bill'));
        translations.add(createTranslation('Invoice','Time','Time','時間','시간','Lần','Time','Time','Time'));
        translations.add(createTranslation('Invoice','Set','Set','セット','셋트','Bộ','Set','Set','Set'));
        translations.add(createTranslation('Invoice','Piece','Piece','ピース','피스','Cái','Piece','Piece','Piece'));               
        translations.add(createTranslation('Invoice','Packet','Packet','パケット','패킷','Kiện (Bưu phẩm)','Packet','Packet','Packet'));               
        translations.add(createTranslation('Invoice','Package','Package','パッケージ ','패키지','Kiện','Package','Package','Package'));               
        translations.add(createTranslation('Invoice','Tax-Free','TF','免税','면세','TF','TF','TF','TF'));
        translations.add(createTranslation('Invoice','Tax Free','TF','免税','면세','TF','TF','TF','TF'));
        translations.add(createTranslation('Invoice','TAX-FREE','TF','免税','면세','TF','TF','TF','TF'));
        translations.add(createTranslation('Invoice','TAX FREE','TF','免税','면세','TF','TF','TF','TF'));
        translations.add(createTranslation('Invoice','CHECK','Check','小切手','어음','Chi Phiếu','Check','Check','Check'));
        translations.add(createTranslation('Invoice','Unit','Unit','本','대','Đơn Vị','Unit','Unit','Unit'));
        translations.add(createTranslation('Invoice','TAX','TAX','課税','과세','TAX','TAX','TAX','TAX'));
        translations.add(createTranslation('Invoice','Non-Tax','NT','非課税','비과세','NT','NT','NT','NT'));
        translations.add(createTranslation('Invoice','Non Tax','NT','非課税','비과세','NT','NT','NT','NT'));
        translations.add(createTranslation('Invoice','NON-TAX','NT','非課税','비과세','NT','NT','NT','NT'));
        translations.add(createTranslation('Invoice','NON TAX','NT','非課税','비과세','NT','NT','NT','NT'));
        translations.add(createTranslation('Invoice','日','Day','日','일','Ngày','Day','Day','Day'));
        translations.add(createTranslation('Profit_Sheet','Profit_Sheet','PROFIT SHEET','プロフィットシート','프로핏시트','BẢNG LỢI NHUẬN','PROFIT SHEET','PROFIT SHEET','PROFIT SHEET'));
        translations.add(createTranslation('Profit_Sheet','Percentage_Revenue','Percentage of Revenue','売り上げに対する一般費用の割合','매출 대비 일반비용 비율','Tỷ lệ phần trăm doanh thu','Percentage of Revenue','Percentage of Revenue','Percentage of Revenue'));
        translations.add(createTranslation('Profit_Sheet','Percentage_Profit','Percentage of Profit','プロフィットに対する一般費用の割合','프로핏 대비 일반비용 비율','Tỷ lệ phần trăm lợi nhuận','Percentage of Profit','Percentage of Profit','Percentage of Profit'));
        translations.add(createTranslation('Profit_Sheet','On_Behalf_Of_Our_Company','On Behalf Of Our Company','業者からの立替を含む','업체로부터의 대납 포함하기','Khoản Chi hộ Công ty','On Behalf Of Our Company','On Behalf Of Our Company','On Behalf Of Our Company'));
        translations.add(createTranslation('Profit_Sheet','On_Behalf_Of_Custome','On Behalf Of Customer','立替を含む','고객사를 위한 대납 포함하기','Khoản Chi hộ Khách hàng','On Behalf Of Customer','On Behalf Of Customer','On Behalf Of Customer'));
        translations.add(createTranslation('Profit_Sheet','Kickback_Include','Kickback Include','キックバックを含む','리베이트 포함하기','Bao gồm Kickback','Kickback Include','Kickback Include','Kickback Include'));
        translations.add(createTranslation('Profit_Sheet','How_to_Use','How to Use: Check or Input number to add it into Profit Sheet','利用方法','사용방법','Cách sử dụng: Tick chọn hoặc Nhập số để thêm vào Bảng lợi nhuận','How to Use: Check or Input number to add it into Profit Sheet','How to Use: Check or Input number to add it into Profit Sheet','How to Use: Check or Input number to add it into Profit Sheet'));
        translations.add(createTranslation('Profit_Sheet','Comprehensive','Comprehensive Profit Sheet','Comprehensive Profit Sheet','프로핏 분석','Bảng lợi nhuận toàn diện','Comprehensive Profit Sheet','Comprehensive Profit Sheet','Comprehensive Profit Sheet'));
         
    // kwon configured 20181205-end  
             
        translations.add(createTranslation('InvoiceSelection','btn_generate','Generate','作成','생성','Kết xuất','null','null','Generate'));
        translations.add(createTranslation('InvoiceSelection','chk_attachment','Create Attachment','添付ファイル作成','첨부파일생성','Tạo file đính kèm','Create Attachment','Create Attachment','Create Attachment'));
        translations.add(createTranslation('InvoiceSelection','customer_selection','Customer/Partner','お客様 / パートナー','고객사 / 파트너','Khách hàng/Đối tác','Customer/Partner','Customer/Partner','Customer/Partner'));
        translations.add(createTranslation('InvoiceSelection','DELIVERY_REPORT_SELECTION','SELECT DELIVERY LOCATION','配送依頼書選択','배송의뢰서선택','CHỌN ĐỊA ĐIỂM','SELECT DELIVERY LOCATION','SELECT DELIVERY LOCATION','SELECT DELIVERY LOCATION'));
        translations.add(createTranslation('InvoiceSelection','DELIVERY_REPORT_TITLE','CARGO DELIVERY','配送依頼書名','배송의뢰서명','MẪU YÊU CẦU GIAO/NHẬN','CARGO DELIVERY','CARGO DELIVERY','CARGO DELIVERY'));
        translations.add(createTranslation('InvoiceSelection','DraftTaxInvoice','DRAFT VAT INVOICE','ドラフト VAT INVOICE','인쇄확인용세금계산서','DRAFT VAT INVOICE','DRAFT VAT INVOICE','DRAFT VAT INVOICE','DRAFT VAT INVOICE'));
        translations.add(createTranslation('InvoiceSelection','DraftTaxInvoiceCombined','DRAFT TAX INVOICE(COMBINED)','ドラフト VAT INVOICE(統合)','인쇄확인용세금계산서(통합)','DRAFT TAX INVOICE(COMBINED)','DRAFT VAT INVOICE(COMBINED)','DRAFT VAT INVOICE(COMBINED)','DRAFT VAT INVOICE(COMBINED)'));
        translations.add(createTranslation('InvoiceSelection','GROUPED_BY_FORWARDING','COMBINED TO SHIPMENT ORDER','シッピング指示毎に統合','쉽핑오더별 통합','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER','COMBINED TO SHIPMENT ORDER'));
        translations.add(createTranslation('InvoiceSelection','GROUPED_BY_INVOICING','EACH INVOICING','請求明細毎に表示','각 청구상세별 표기','EACH INVOICING','GROUPED BY INVOICING','GROUPED BY INVOICING','GROUPED BY INVOICING'));
        translations.add(createTranslation('InvoiceSelection','GROUP_BY_CATEGORY','COMBINED TO PRICING SUB-CATEGORY','プライシング小分類毎に統合','프라이싱 소분류별 통합','COMBINED TO PRICING SUB-CATEGORY','GROUP BY SUB-CATEGORY','GROUP BY SUB-CATEGORY','GROUP BY SUB-CATEGORY'));
        translations.add(createTranslation('InvoiceSelection','invoice','Invoice','請求書','청구서','Báo cáo','Invoice','Invoice','Invoice'));
        translations.add(createTranslation('InvoiceSelection','location','Location','位置','위치','Địa điểm','Location','Location','Location'));
        translations.add(createTranslation('InvoiceSelection','NO_CUSTOMER_SELECTION','You have not selected any customer/partner or no customer/partner is applicable','印刷されたいお客様又はパートナー社をお選びください。','인쇄를 원하는 고객사/파트너사를 선택하여 주십시요','Bạn chưa chọn khách hàng hoặc không có khách hàng nào hợp lệ','You have not selected any customer/partner or no customer/partner is applicable','You have not selected any customer/partner or no customer/partner is applicable','You have not selected any customer/partner or no customer/partner is applicable'));
        translations.add(createTranslation('InvoiceSelection','no_report_selection','You have not selected any report or no report is applicable.','正しいレポートを選択してください。','레프트를 선택하여 주십시요.','Bạn chưa chọn báo cáo hoặc không có báo cáo nào hợp lệ.','You have not selected any report or no report is applicable.','You have not selected any report or no report is applicable.','You have not selected any report or no report is applicable.'));
        translations.add(createTranslation('InvoiceSelection','OfficialInvoice','DEBIT NOTE','DEBIT NOTE','DEBIT NOTE','DEBIT NOTE','DEBIT NOTE','DEBIT NOTE','DEBIT NOTE'));
        translations.add(createTranslation('InvoiceSelection','OfficialInvoiceCombined','DEBIT NOTE(COMBINED)','DEBIT NOTE(統合)','DEBIT NOTE(통합)','DEBIT NOTE(COMBINED)','DEBIT NOTE(COMBINED)','DEBIT NOTE(COMBINED)','DEBIT NOTE(COMBINED)'));
        translations.add(createTranslation('InvoiceSelection','PreprintedInvoice','ORIGINAL VAT INVOICE','オリジナルVAT INVOICE','원본용세금계산서','ORIGINAL VAT INVOICE','ORIGINAL VAT INVOICE','ORIGINAL VAT INVOICE','ORIGINAL VAT INVOICE'));
        translations.add(createTranslation('InvoiceSelection','PreprintedInvoiceCombined','ORIGINAL VAT INVOICE(COMBINED)','オリジナルVAT INVOICE(統合)','원본용세금계산서(통합)','ORIGINAL VAT INVOICE(COMBINED)','ORIGINAL VAT INVOICE(COMBINED)','ORIGINAL VAT INVOICE(COMBINED)','ORIGINAL VAT INVOICE(COMBINED)'));
        translations.add(createTranslation('InvoiceSelection','section_1_title','Select Language & Invoice/Quotation','言語＆請求書を選択','언어 및 청구서 선택','Lực chọn ngôn ngữ & Báo cáo','Select Language & Invoice/Quotation','Select Language & Invoice/Quotation','Select Language & Invoice/Quotation'));
        translations.add(createTranslation('InvoiceSelection','section_2_title','Attachment','添付','첨부','File đính kèm','Attachment','Attachment','Attachment'));
        translations.add(createTranslation('InvoiceSelection','SUMMARY','COMBINED TO 1 SUMMARY','一つに統合','하나로 통합','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY','COMBINED TO 1 SUMMARY'));
        translations.add(createTranslation('InvoiceSelection','title','INVOICE/QUOTATION','請求書 / 見積書','타이틀 / 견적서','HOÁ ĐƠN/BÁO GIÁ','INVOICE/QUOTATION','INVOICE/QUOTATION','INVOICE/QUOTATION'));
        translations.add(createTranslation('MassiveUpdate','BROWSE_FILE','Browser File to Upload','ファイルを参照','업로드할 파일 찾기','Chọn tệp tin','null','null','Browser File to Upload'));
        translations.add(createTranslation('MassiveUpdate','COPY_CONTAINER_ID_BTN','Copy Container ID','コンテナ IDコピー','콘테이너ID복사하기','Sao Chép Container ID','Copy Container ID','Copy Container ID','Copy Container ID'));
        translations.add(createTranslation('MassiveUpdate','COPY_DATA_BTN','Copy Data','データコピー','데이터복사하기','Sao Chép Dữ Liệu','Copy Data','Copy Data','Copy Data'));
        translations.add(createTranslation('MassiveUpdate','MASSIVE_CREATION','MASSIVE NEW','一括新規登録','일괄신규등록','TẠO MỚI HÀNG LOẠT','null','null','MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASSIVE_UPDATE','MASSIVE UPDATE','一括更新','일괄갱신','CẬP NHẬT HÀNG LOẠT','MASSIVE UPDATE','MASSIVE UPDATE','MASSIVE UPDATE'));
        translations.add(createTranslation('MassiveUpdate','MASS_CARGO_CREATION','CARGO DELIVERY MASSIVE NEW','配送情報一括新規登録','배송정보 일괄신규등록','TẠO MỚI ĐIỂM GIAO HÀNG','null','null','CARGO DELIVERY MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASS_CARGO_TITLE','CARGO DELIVERY MASSIVE UPDATE','配送情報一括更新','배송정보 일괄갱신','CẬP NHẬT ĐIỂM GIAO HÀNG','null','null','CARGO DELIVERY MASSIVE UPDATE'));
        translations.add(createTranslation('MassiveUpdate','MASS_CONSOL_CREATION','CONSOL BUYING MASSIVE NEW','混載-仕入一括新規登録','콘솔지불정보 일괄신규등록','TẠO MỚI VẬN ĐƠN CHỦ-GIÁ MUA','null','null','CONSOL BUYING MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASS_CONSOL_TITLE','CONSOL BUYING MASSIVE UPDATE','混載-仕入一括更新','콘솔지불정보 일괄갱신','CẬP NHẬT VẬN ĐƠN CHỦ-GIÁ MUA','null','null','CONSOL BUYING MASSIVE UPDATE'));
        translations.add(createTranslation('MassiveUpdate','MASS_EXRATE_TITLE','EXCHANGE RATE MASSIVE UPDATE','為替一括更新','환율 일괄갱신','CẬP NHẬT TỈ GIÁ','null','null','null'));
        translations.add(createTranslation('MassiveUpdate','MASS_INVAT_CREATION','INVOICING & VAT MASS NEW','請求明細及びVAT請求書を一括登録する','청구상세와 세금계산서 일괄등록하기','TẠO MỚI KẾT NỐI CHI PHÍ VÀ HÓA ĐƠN VAT','INVOICING & VAT MASSIVE NEW','INVOICING & VAT MASSIVE NEW','INVOICING & VAT MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASS_LOCATION_CREATION','LOAD/UNLOAD MASSIVE NEW','荷積み・荷下ろし一括新規登録','적재/적하정보 일괄신규등록','TẠO MỚI ĐÓNG VÀ DỠ HÀNG','null','null','LOAD/UNLOAD MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASS_LOCATION_TITLE','LOAD/UNLOAD MASSIVE UPDATE','荷積み・荷下ろし一括更新','적재/적하정보 일괄갱신','CẬP NHẬT ĐÓNG VÀ DỠ HÀNG','null','null','LOAD/UNLOAD MASSIVE UPDATE'));
        translations.add(createTranslation('MassiveUpdate','MASS_NUM_RECORDS','Number of Records','レコード数','레코드 건수','Số Bản Ghi','null','null','Number of Records'));
        translations.add(createTranslation('MassiveUpdate','MASS_PI_CREATION','PURCHASING INVOICE MASSIVE NEW','発注請求書一括新規登録','구매청구서정보 일괄신규등록','TẠO MỚI HOÁ ĐƠN THU MUA','null','null','PURCHASING INVOICE MASSIVE NEW'));
        translations.add(createTranslation('MassiveUpdate','MASS_PI_TITLE','PURCHASING INVOICE MASSIVE UPDATE','発注請求書一括更新','구매청구서정보 일괄갱신','CẬP NHẬT HOÁ ĐƠN THU MUA','null','null','PURCHASING INVOICE MASSIVE UPDATE'));
        translations.add(createTranslation('MassiveUpdate','MASS_SHIPMENTVAT_CREATION','SHIPMENT & VAT MASS NEW','シッピング指示及びVAT請求書を一括登録する','쉽핑오더 및 세금계산서를 일괄등록하기','TẠO MỚI LIÊN KẾT VẬN ĐƠN VÀ HOÁ ĐƠN VAT','null','null','SHIPMENT & VAT MASS NEW'));
        translations.add(createTranslation('MassiveUpdate','PAYABLE_PROCESSING','PAYABLE PROCESSING','支払処理','지불처리','XỬ LÝ KHOẢN PHẢI TRẢ','PAYABLE PROCESSING','PAYABLE PROCESSING','PAYABLE PROCESSING'));
        translations.add(createTranslation('MassiveUpdate','RECEIVABLE_PROCESSING','RECEIVABLE PROCESSING','入金処理','입금처리','XỬ LÝ KHOẢN PHẢI THU','RECEIVABLE PROCESSING','RECEIVABLE PROCESSING','RECEIVABLE PROCESSING'));
        translations.add(createTranslation('MassiveUpdate','SUM_AMT_PAID_BUYING','TOTAL AMOUNT PAID-BUYING','合計支払額','합계지급액','TỔNG TIỀN MUA HÀNG PHẢI TRẢ','TOTAL AMOUNT PAID-BUYING','TOTAL AMOUNT PAID-BUYING','TOTAL AMOUNT PAID-BUYING'));
        translations.add(createTranslation('MassiveUpdate','SUM_AMT_RECEIVED_FROM_CUSTOMER','TOTAL AMOUNT RECEIVED FROM CUSTOMER','合計入金額','합계입금액','TỔNG TIỀN NHẬN TỪ KHÁCH HÀNG','TOTAL AMOUNT OF AMOUNT RECEIVED FROM CUSTOMERTOTAL AMOUNT RECEIVED FROM CUSTOMER','TOTAL AMOUNT RECEIVED FROM CUSTOMER','TOTAL AMOUNT RECEIVED FROM CUSTOMER'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_AMOUNT_BUYING_INCL_TAX','TOTAL AMOUNT BUYING INCLUDING TAX','消費税込み仕入金額','소비세포함 매입금액','TỔNG GIÁ MUA BAO GỒM THUẾ','TOTAL AMOUNT BUYING INCLUDING TAX','TOTAL AMOUNT BUYING INCLUDING TAX','TOTAL AMOUNT BUYING INCLUDING TAX'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_AMOUNT_OF_TAX_BUYING','TOTAL AMOUNT OF TAX-BUYING','仕入消費税額','매입소비세액','TỔNG SỐ TIỀN THUẾ-MUA','TOTAL AMOUNT OF TAX-BUYING','TOTAL AMOUNT OF TAX-BUYING','TOTAL AMOUNT OF TAX-BUYING'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_AMOUNT_OF_TAX_SELLING','TOTAL AMOUNT OF TAX-SELLING','販売消費税額','판매소비세액','TỔNG SỐ TIỀN THUẾ-BÁN','TOTAL AMOUNT OF TAX-SELLING','TOTAL AMOUNT OF TAX-SELLING','TOTAL AMOUNT OF TAX-SELLING'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_AMOUNT_SELLING_INCL_TAX','TOTAL AMOUNT SELLING INCLUDING TAX','合計消費税込み販売金額','소비세포함 판매금액','TỔNG GIÁ BÁN BAO GỒM THUẾ','TOTAL AMOUNT SELLING INCLUDING TAX','TOTAL AMOUNT SELLING INCLUDING TAX','TOTAL AMOUNT SELLING INCLUDING TAX'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_TOTAL_AMOUNT_OF_BUYING','TOTAL AMOUNT OF BUYING','合計仕入金額','합계 매입금액','TỐNG GIÁ MUA','TOTAL AMOUNT OF BUYING','TOTAL AMOUNT OF BUYING','TOTAL AMOUNT OF BUYING'));
        translations.add(createTranslation('MassiveUpdate','SUM_OF_TOTAL_AMOUNT_OF_SELLING','TOTAL AMOUNT OF SELLING','合計販売金額','합계 판매금액','TỐNG GIÁ BÁN','TOTAL AMOUNT OF SELLING','TOTAL AMOUNT OF SELLING','TOTAL AMOUNT OF SELLING'));
        translations.add(createTranslation('MassiveUpdate','SUM_UNPAID_BALANCE_BUYING','TOTAL AMOUNT OF UNPAID BALANCE OF BUYING','合計未支払残高','합계미지급잔액','TỔNG TIỀN CHÊNH LỆCH PHẢI TRẢ','TOTAL AMOUNT OF UNPAID BALANCE OF BUYING','TOTAL AMOUNT OF UNPAID BALANCE OF BUYING','TOTAL AMOUNT OF UNPAID BALANCE OF BUYING'));
        translations.add(createTranslation('MassiveUpdate','SUM_UNRECEIVED_BALANCE_SELLING','TOTAL AMOUNT OF UNRECEIVED BALANCE OF SELLING','合計未入金残高','합계미입금잔액','TỔNG TIỀN CHÊNH LỆCH PHẢI THU','TOTAL AMOUNT OF UNRECEIVED BALANCE OF SELLING','TOTAL AMOUNT OF UNRECEIVED BALANCE OF SELLING','TOTAL AMOUNT OF UNRECEIVED BALANCE OF SELLING'));
        translations.add(createTranslation('MassiveUpdate','UPDATE_BUYING_FIGURE','UPDATE BUYING FIGURES','仕入データ更新','매입데이터갱신','CẬP NHẬT THÔNG SỐ MUA','UPDATE BUYING FIGURES','UPDATE BUYING FIGURES','UPDATE BUYING FIGURES'));
        translations.add(createTranslation('MassiveUpdate','UPDATE_OPTIONS','UPDATE OPTION','更新分類選択','갱신분류선택','TUỲ CHỌN CẬP NHẬT','UPDATE OPTION','UPDATE OPTION','UPDATE OPTION'));
        translations.add(createTranslation('MassiveUpdate','UPDATE_SELLING_FIGURE','UPDATE INVOICING FIGURES','請求入データ更新','청구데이터갱신','CẬP NHẬT THÔNG SỐ BÁN','UPDATE SELLING FIGURE','UPDATE SELLING FIGURE','UPDATE INVOICING FIGURES'));
        translations.add(createTranslation('NavigationFlow','NF_100','Ocean Export','海上輸出','해상수출','Thông Quan Xuất Khẩu Đường Biển','Ocean Export','Ocean Export','Ocean Export'));
        translations.add(createTranslation('NavigationFlow','NF_101','Air Import','航空輸入','항공수입','Thông Quan Nhập Khẩu Đường Không','Air Import','Air Import','Air Import'));
        translations.add(createTranslation('NavigationFlow','NF_102','Inland Import','内陸輸入','육상수입','Nhập Khẩu Đường Bộ','Inland Import','Inland Import','Inland Import'));
        translations.add(createTranslation('NavigationFlow','NF_103','Inbound Charter','インバウンドチャーター便','인바운드독차트럭','Xe tải trọn gói cho nhập khẩu','Inbound Charter','Inbound Charter','Inbound Charter'));
        translations.add(createTranslation('NavigationFlow','NF_104','Outbound Charter','アウトバウンドチャーター便','아웃바운드독차트럭','Xe Tải trọn gói cho xuất khẩu','Outbound Charter','Outbound Charter','Outbound Charter'));
        translations.add(createTranslation('NavigationFlow','NF_105','Inbound Consol','インバウンド混載便','인바운드콘솔트럭','Xe Tải Chở Hàng Lẻ Nhập Khẩu','Inbound Consol','Inbound Consol','Inbound Consol'));
        translations.add(createTranslation('NavigationFlow','NF_106','Outbound Consol','アウトバウンド混載便','아웃바운드콘솔트럭','Xe Tải Chở Hàng Lẻ Xuất Khẩu','Outbound Consol','Outbound Consol','Outbound Consol'));
        translations.add(createTranslation('NavigationFlow','NF_107','Inbound Full Container','インバウンドコンテナトラック','인바운드콘테이너트럭','Xe Tải Nguyên Cont Chở Hàng Nhập','Inbound Full Container','Inbound Full Container','Inbound Full Container'));
        translations.add(createTranslation('NavigationFlow','NF_108','Outbound Full Container','アウトバウンドコンテナトラック','아웃바운드콘테이너트럭','Xe Tải Nguyên Cont Chở Hàng Xuất','Outbound Full Container','Outbound Full Container','Outbound Full Container'));
        translations.add(createTranslation('NavigationFlow','NF_109','Cross-Border','越境輸送','크로스보더','Cross-Border','null','null','Cross-Border'));
        translations.add(createTranslation('NavigationFlow','NF_10_1','CloSCM Initial Setting','CloSCM 初期設定','CloSCM 초기설정','Cài Đặt CloSCM','null','null','CloSCM Initial Setting'));
        translations.add(createTranslation('NavigationFlow','NF_10_2','Initial Setup information','初期設定のために必要な情報','초기설정에 필요한 정보','Thông Tin Cài Đặt Ban Đầu','null','null','Initial Setup information'));
        translations.add(createTranslation('NavigationFlow','NF_10_3','VAT Ratio','消費税率','소비세율','Tỉ Suất Thuế Giá Trị Gia Tăng','null','null','VAT Ratio'));
        translations.add(createTranslation('NavigationFlow','NF_10_4','Exchange Rate','為替','환율','Tỉ Giá','null','null','Exchange Rate'));
        translations.add(createTranslation('NavigationFlow','NF_10_5','CFS/CY/DEPOT','CFS・CY・DEPOT','CFS/CY/DEPOT','Kho CFS/ CY/DEPOT','null','null','CFS/CY/DEPOT'));
        translations.add(createTranslation('NavigationFlow','NF_110','Bank Account','銀行口座','은행계좌','Tài Khoản Ngân Hàng','null','null','Bank Account'));
        translations.add(createTranslation('NavigationFlow','NF_111','Training','トレーニング','트래이닝','Đào tạo','null','null','Training'));
        translations.add(createTranslation('NavigationFlow','NF_112','Transit','積替','환적','Quá Cảnh','null','null','Transit'));
        translations.add(createTranslation('NavigationFlow','NF_113','Profit Loss Statement','損益計算書','손익계산서','Báo Cáo Lợi Nhuận','null','null','Profit Loss Statement'));
        translations.add(createTranslation('NavigationFlow','NF_114','Define SOP & Timeline','標準運用プロセス・タイムライン設定','표준운영프로세스및타임라인설정','SOP và Thời Gian','null','null','Define SOP & Timeline'));
        translations.add(createTranslation('NavigationFlow','NF_115','Cash Flow Statement','キャッシュフロー','캐시플로','Báo Cáo Lưu Chuyển Tiền','null','null','Cash Flow Statement'));
        translations.add(createTranslation('NavigationFlow','NF_116','People','すべての人','모든 사용자','Mọi Người','null','null','People'));
        translations.add(createTranslation('NavigationFlow','NF_117','Group','グループ','그룹','Hội Nhóm','null','null','Group'));
        translations.add(createTranslation('NavigationFlow','NF_118','Translate','翻訳','번역','Thông Dịch','null','null','Translate'));
        translations.add(createTranslation('NavigationFlow','NF_119','Inland Import','内陸輸入通関','육상수입','Nhập Khẩu Đường Bộ','Inland Import','Inland Import','Inland Import'));
        translations.add(createTranslation('NavigationFlow','NF_11_1','Health Check','設定状態チェック','설정상태 확인','Kiểm tra hệ thống','null','null','Health Check'));
        translations.add(createTranslation('NavigationFlow','NF_11_10','Server Status','サーバー状況とメンテナンス','서버상태 및 유지 보수','Tình trạng Máy chủ','null','null','Server Status'));
        translations.add(createTranslation('NavigationFlow','NF_11_11','Data Center Security','データセンターセキュリティ','데이터센터보안','Bảo mật Cơ Sở Dữ Liệu','null','null','Data Center Security'));
        translations.add(createTranslation('NavigationFlow','NF_11_12','Compliance','コンプライアンス','컴플라이언스','Thoả thuận','null','null','Compliance'));
        translations.add(createTranslation('NavigationFlow','NF_11_13','Storage Usage','ディスク使用量','스토리지사용량','Dung lượng sử dụng','null','null','Storage Usage'));
        translations.add(createTranslation('NavigationFlow','NF_11_2','Password Policies','パスワードポリシー','암호 정책','Các Chính Sách Mật Khẩu','null','null','Password Policies'));
        translations.add(createTranslation('NavigationFlow','NF_11_3','Login History','ログイン履歴','로그인 내역','Lịch Sử Đăng Nhập','null','null','Login History'));
        translations.add(createTranslation('NavigationFlow','NF_11_4','Session Security','セッションの設定','세션 설정','Bảo Mật Dữ Liệu','null','null','Session Security'));
        translations.add(createTranslation('NavigationFlow','NF_11_5','User Session','ユーザセッション情報','사용자 세션 정보','Phiên làm việc','null','null','User Session'));
        translations.add(createTranslation('NavigationFlow','NF_11_6','Network Access','ネットワークアクセス','네트워크 액세스','Truy Cập Mạng','null','null','Network Access'));
        translations.add(createTranslation('NavigationFlow','NF_11_7','My Domain','ドメイン','내 도메인','Tên miền','null','null','My Domain'));
        translations.add(createTranslation('NavigationFlow','NF_11_8','Backup','バックアップ','백업','Sao lưu','null','null','Backup'));
        translations.add(createTranslation('NavigationFlow','NF_11_9','Verification History','ID 検証履歴','ID 확인 내역','Lịch Sử Xác Nhận Nhận Dạng','null','null','Verification History'));
        translations.add(createTranslation('NavigationFlow','NF_120','Inland Export','内陸輸出','내륙수출','Xuất Khẩu Đường Bộ','Inland Export','Inland Export','Inland Export'));
        translations.add(createTranslation('NavigationFlow','NF_121','Log Time','打刻','출퇴근시간','THỜI GIAN ĐĂNG NHẬP','Log Time','Log Time','Log Time'));
        translations.add(createTranslation('NavigationFlow','NF_122','HR Policy','人事管理標準','인사관리표준','CHÍNH SÁCH HR','HR Policy','HR Policy','HR Policy'));
        translations.add(createTranslation('NavigationFlow','NF_123','Employee Management','従業員管理','임직원관리','QUẢN LÝ NHÂN VIÊN','Employee Management','Employee Management','Employee Management'));
        translations.add(createTranslation('NavigationFlow','NF_124','Payroll Order','給料支払指示','급여지불결의','MÃ LƯƠNG','Payroll Order','Payroll Order','Payroll Order'));
        translations.add(createTranslation('NavigationFlow','NF_125','Payroll Slip','給料明細','급여지불상세','CHI TIẾT LƯƠNG','Payroll Slip','Payroll Slip','Payroll Slip'));
        translations.add(createTranslation('NavigationFlow','NF_126','H/S/UMEN Insurance','従業員保険','임직원보험','MÃ BẢO HIỂM','H/S/UMEN Insurance','H/S/UMEN Insurance','H/S/UMEN Insurance'));
        translations.add(createTranslation('NavigationFlow','NF_127','PIT','所得税','소득세','THUẾ THU NHẬP CÁ NHÂN','PIT','PIT','PIT'));
        translations.add(createTranslation('NavigationFlow','NF_128','Time Entry','打刻記録','출퇴근시간이력','THỜI GIAN ĐĂNG NHẬP','Time Entry','Time Entry','Time Entry'));
        translations.add(createTranslation('NavigationFlow','NF_129','Partnership/Agent Program','パートナー・代理店プログラム','파트너/대리점프로그램','Chương Trình Cho Đối Tác','Partnership/Agent Program','Partnership/Agent Program','Partnership/Agent Program'));
        translations.add(createTranslation('NavigationFlow','NF_12_1','AC Code','会計コード','회계코드','Mã Số Kế Toán','null','null','AC Code'));
        translations.add(createTranslation('NavigationFlow','NF_12_2','HS Code','HSコード','HS코드','Mã HS','null','null','HS Code'));
        translations.add(createTranslation('NavigationFlow','NF_12_3','Carrier Code','船社コード','선사코드','Mã Tàu','null','null','Carrier Code'));
        translations.add(createTranslation('NavigationFlow','NF_12_4','Port Code','ポートコード','포트코드','Mã Cảng','null','null','Port Code'));
        translations.add(createTranslation('NavigationFlow','NF_12_5','Manifest Code','マニフェストコード','매니페스트코드','Mã Manifest','null','null','Manifest Code'));
        translations.add(createTranslation('NavigationFlow','NF_130','Roles','ロール','역할','Vai Trò','Roles','Roles','Roles'));
        translations.add(createTranslation('NavigationFlow','NF_131','Data and File Storage Limits','データストレージとファイルストレージの制限','데이터 및 파일 스토리지 용량','Giới Hạn Lưu Trữ Dữ Liệu và File','Data and File Storage Limits','Data and File Storage Limits','Data and File Storage Limits'));
        translations.add(createTranslation('NavigationFlow','NF_132','Grant Account Login Access','アカウントログインアクセスの許可','계정 로그인 액세스 권한 부여','Cấp Tài Khoản Truy Cập','Grant Account Login Access','Grant Account Login Access','Grant Account Login Access'));
        translations.add(createTranslation('NavigationFlow','NF_133','Kickback','レベート','리베이트','Tiền Hoa Hồng','Kickback','Kickback','Kickback'));
        translations.add(createTranslation('NavigationFlow','NF_134','AIR','エア','에어(항공)','HÀNG KHÔNG','AIR','AIR','AIR'));
        translations.add(createTranslation('NavigationFlow','NF_135','CONSOLIDATION COST ALLOCATION','混載費用按分','콘솔 비용 안분','PHÂN BỔ CHI PHÍ GHÉP HÀNG','CONSOLIDATION COST ALLOCATION','CONSOLIDATION COST ALLOCATION','CONSOLIDATION COST ALLOCATION'));
        translations.add(createTranslation('NavigationFlow','NF_136','CUSTOMS CLEARANCE','通関','통관','THÔNG QUAN','CUSTOMS CLEARANCE','CUSTOMS CLEARANCE','CUSTOMS CLEARANCE'));
        translations.add(createTranslation('NavigationFlow','NF_137','EMPTY','空コンテナ','빈콘테이너','CÔNG RỖNG','EMPTY','EMPTY','EMPTY'));
        translations.add(createTranslation('NavigationFlow','NF_138','FCL','FCL','FCL','FCL','FCL','FCL','FCL'));
        translations.add(createTranslation('NavigationFlow','NF_139','FULL CONTAINER TRUCKING(CONTAINER DRAYAGE)','ドレー','컨테이너 도레지 운송','CÔNG ĐẦY','FULL CONTAINER TRUCKING(CONTAINER DRAYAGE)','FULL CONTAINER TRUCKING(CONTAINER DRAYAGE)','FULL CONTAINER TRUCKING(CONTAINER DRAYAGE)'));
        translations.add(createTranslation('NavigationFlow','NF_13_1','Customer/Partner','顧客・パートナー・その他','고객/파트너/그 외','Khách Hàng/Đối Tác/Bên Thứ 3','null','null','Customer/Partner'));
        translations.add(createTranslation('NavigationFlow','NF_13_2','Carrier Link','船社リンク','선사링크','Hãng Tàu','null','null','Carrier Link'));
        translations.add(createTranslation('NavigationFlow','NF_13_3','Contact','連絡先','연락처','Người Liên Hệ','null','null','Contact'));
        translations.add(createTranslation('NavigationFlow','NF_13_4','Quote','見積','견적','Báo Giá','null','null','Quote'));
        translations.add(createTranslation('NavigationFlow','NF_140','LCL','LCL','LCL','LCL','LCL','LCL','LCL'));
        translations.add(createTranslation('NavigationFlow','NF_141','TRUCKING','トラッキング','트럭 운송','XE TẢI','TRUCKING','TRUCKING','TRUCKING'));
        translations.add(createTranslation('NavigationFlow','NF_142','WAREHOUSING','倉庫','창고','KHO HÀNG','WAREHOUSING','WAREHOUSING','WAREHOUSING'));
        translations.add(createTranslation('NavigationFlow','NF_143','CASH IN','現金入金','현금입금','THU TIỀN MẶT','CASH IN','CASH IN','CASH IN'));
        translations.add(createTranslation('NavigationFlow','NF_144','CASH OUT','現金出金','현금출금','RÚT TIỀN MẶT','CASH OUT','CASH OUT','CASH OUT'));
        translations.add(createTranslation('NavigationFlow','NF_146','ExRate Mass Update','為替一括更新','환율 일괄갱신','Cập Nhật Tỉ Giá','ExRate Mass Update','ExRate Mass Update','ExRate Mass Update'));
        translations.add(createTranslation('NavigationFlow','NF_147','FULL CONTAINER CHASSI','コンテナトラックシャシー','콘테이너트럭(샤시)','RỜ MÓC CONTAINER','FULL CONTAINER CHASSI','FULL CONTAINER CHASSI','FULL CONTAINER CHASSI'));
        translations.add(createTranslation('NavigationFlow','NF_148','FULL CONTAINER TRUCK','コンテナトラックヘッド','콘테이너트럭(헤드)','ĐẦU KÉO CONTAINER','FULL CONTAINER TRUCK','FULL CONTAINER TRUCK','FULL CONTAINER TRUCK'));
        translations.add(createTranslation('NavigationFlow','NF_149','TRUCK','トラック','트럭','XE TẢI','TRUCK','TRUCK','TRUCK'));
        translations.add(createTranslation('NavigationFlow','NF_14_1','Ocean Import','海上輸入','해상수입','Nhập Khẩu Đường Biển','null','null','Ocean Import'));
        translations.add(createTranslation('NavigationFlow','NF_14_10','Delivery','配送','배송','Giao Hàng','null','null','Delivery'));
        translations.add(createTranslation('NavigationFlow','NF_14_11','Invoicing','請求・仕入','청구/지불','Hóa Đơn','null','null','Invoicing'));
        translations.add(createTranslation('NavigationFlow','NF_14_2','Ocean Export','海上輸出','해상수출','Xuất Khẩu Đường Biển','null','null','Ocean Export'));
        translations.add(createTranslation('NavigationFlow','NF_14_3','Air Import','航空輸入','항공수입','Nhập Khẩu Đường Không','null','null','Air Import'));
        translations.add(createTranslation('NavigationFlow','NF_14_4','Air Export','航空輸出','항공수출','Xuất Khẩu Đường Không','Air export','Air Export','Air Export'));
        translations.add(createTranslation('NavigationFlow','NF_14_5','Domestic Transportation','国内運送','국내운송','Vận Tải Nội Địa','null','null','Domestic Transportation'));
        translations.add(createTranslation('NavigationFlow','NF_14_6','SHIPMENT ORDER','シッピング指示','쉽핑오더','Yêu Cầu Lô Hàng','null','null','SHIPMENT ORDER'));
        translations.add(createTranslation('NavigationFlow','NF_14_7','Container','コンテナ','콘테이너','Thông Tin Container','null','null','Container'));
        translations.add(createTranslation('NavigationFlow','NF_14_8','Data Loader','データローダ','데이터일괄업로드','Truyền Tải Dữ Liệu','null','null','Data Loader'));
        translations.add(createTranslation('NavigationFlow','NF_14_9','Customs Clearance','通関','통관','Thủ Tục Thông Quan','null','null','Customs Clearance'));
        translations.add(createTranslation('NavigationFlow','NF_150','File Converter','ファイル変換器','파일변환기','CHUYỂN ĐỔI FILE','File Converter','File Converter','File Converter'));
        translations.add(createTranslation('NavigationFlow','NF_151','CASH TRANSACTION','口座から現金引き出し','통장으로부터 현금 출금','GIAO DỊCH TIỀN MẶT','CASH TRANSACTION','CASH TRANSACTION','CASH TRANSACTION'));
        translations.add(createTranslation('NavigationFlow','NF_15_1','VAT Invoice','VAT請求書','세금계산서','Hóa Đơn VAT','null','null','VAT Invoice'));
        translations.add(createTranslation('NavigationFlow','NF_15_2','Outstanding Statement','ステートメント','스테이트먼트','Công Nợ','null','null','Statement'));
        translations.add(createTranslation('NavigationFlow','NF_15_3','Revenue Receivable','売上未収金','매출미수금','Doanh Thu Cần Thu','null','null','Revenue Receivable'));
        translations.add(createTranslation('NavigationFlow','NF_15_4','Sales Cost Payable','仕入未支払金','매입미지불금','Chi Phí Cần Trả','null','null','Sales Cost Payable'));
        translations.add(createTranslation('NavigationFlow','NF_15_5','Pricing','プライシング','프라이싱','Cước Dịch Vụ','null','null','Pricing'));
        translations.add(createTranslation('NavigationFlow','NF_15_6','Cash','現金','현금','Tiền Mặt','null','null','Cash'));
        translations.add(createTranslation('NavigationFlow','NF_15_7','Bank Balance','口座残高','통장잔액','Cân Đối Quỹ Ngân Hàng','null','null','Bank Balance'));
        translations.add(createTranslation('NavigationFlow','NF_16_1','Route & Load/Unload','ルートと荷積み・荷下ろし','루트 및 상차・하차','Tuyến Đường Và Đóng/Dỡ Hàng','null','null','Route & Load/Unload'));
        translations.add(createTranslation('NavigationFlow','NF_16_2','Truck & Fleet','トラック・車両','트럭・장비','Xe Và Tàu','null','null','Truck & Fleet'));
        translations.add(createTranslation('NavigationFlow','NF_16_3','Driver','運転手・作業員','운전수・작업요원','Tài Xế','null','null','Driver'));
        translations.add(createTranslation('NavigationFlow','NF_16_4','Maintenance & Repair','メンテナンス・修理','유지보수・수리','Bảo Trì Và Sửa Chữa','null','null','Maintenance & Repair'));
        translations.add(createTranslation('NavigationFlow','NF_17_1','Dashboard','ダッシュボード','대시보드','Tổng Hợp Báo Cáo','null','null','Dashboard'));
        translations.add(createTranslation('NavigationFlow','NF_17_2','Report','レポート','보고서','Báo Cáo','null','null','Report'));
        translations.add(createTranslation('NavigationFlow','NF_17_3','Approval Process','承認プロセス','승인 프로세스','Quá Trình Phê Duyệt','null','null','Approval Process'));
        translations.add(createTranslation('NavigationFlow','NF_17_4','Workflow Rules','ワークフロールール','워크플로 규칙','Tất Cả Các Quy Tắc Dòng Công Việc','null','null','Workflow Rules'));
        translations.add(createTranslation('NavigationFlow','NF_17_5','Documents','印刷テンプレート','인쇄 템플릿','Mẫu Mail Đồng Bộ Hóa','null','null','Documents'));
        translations.add(createTranslation('NavigationFlow','NF_17_6','Internal Email Template','社内メールテンプレート','회사이메일 템플릿','Các Khuôn Mẫu Email','null','null','Internal Email Template'));
        translations.add(createTranslation('NavigationFlow','NF_17_7','Printed Document','ドキュメント','문서','Trang Chủ','null','null','Printed Document'));
        translations.add(createTranslation('NavigationFlow','NF_17_8','Chatter','Chatter','Chatter','Chatter','null','null','Chatter'));
        translations.add(createTranslation('NavigationFlow','NF_1_1','Master Subscription Agreement','マスターサブスクリプション契約','마스터라이센스계약서','Master Subscription Agreement','null','null','Master Subscription Agreement'));
        translations.add(createTranslation('NavigationFlow','NF_1_2','SFDC Service Agreement','SFDCサービス契約書','SFDC서비스계약서','SFDC Service Agreement','null','null','SFDC Service Agreement'));
        translations.add(createTranslation('NavigationFlow','NF_2_1','New Release','新規リリース','버전업그레이드','Phiên Bản Mới','null','null','New Release'));
        translations.add(createTranslation('NavigationFlow','NF_2_2','User & Video Manual','ユーザー・ビデオマニュアル','유저/비디오 매뉴얼','Hướng Dẫn','null','null','SOP & User Manual'));
        translations.add(createTranslation('NavigationFlow','NF_2_3','User Voice','ユーザー様の声','고객님의 목소리','Ý kiến từ người dùng','null','null','Video Manual'));
        translations.add(createTranslation('NavigationFlow','NF_2_4','Scenario Based Learning','練習用シナリオ','연습시나리오','Thực Hành Giả Lập','null','null','Scenario Based Learning'));
        translations.add(createTranslation('NavigationFlow','NF_2_5','Idea & Opinion','アイデア','아이디어','Ý Kiến và Ý Tưởng','null','null','Idea & Opinion'));
        translations.add(createTranslation('NavigationFlow','NF_3_1','Khmer Font','カンボジア語フォント','캄보디아어 폰트','Khmer Font','null','null','Khmer Font'));
        translations.add(createTranslation('NavigationFlow','NF_3_2','Vietnamese Font','ベトナム語フォント','베트남어 폰트','Vietnamese Font','null','null','Vietnamese Font'));
        translations.add(createTranslation('NavigationFlow','NF_3_3','Data Upload Template','データ読み込みテンプレート','데이터일괄업로드템플릿','Truyền Tải Biểu Mẫu','null','null','Data Upload Template'));
        translations.add(createTranslation('NavigationFlow','NF_4_1','Personal Information','個人情報','개인 정보','Thông Tin Cá Nhân','null','null','Personal Information'));
        translations.add(createTranslation('NavigationFlow','NF_4_2','Reset Password','パスワード変更','암호 변경','Thay Đổi Mật Khẩu','null','null','Reset Password'));
        translations.add(createTranslation('NavigationFlow','NF_4_3','Tab','タブ','탭','Tùy Chỉnh Tab','null','null','Tab'));
        translations.add(createTranslation('NavigationFlow','NF_4_4','Home','ホームページ','홈 페이지','Trang Chủ','null','null','Home'));
        translations.add(createTranslation('NavigationFlow','NF_4_5','Email Setting','メール設定','메일설정','Cài Đặt Email','null','null','Email Setting'));
        translations.add(createTranslation('NavigationFlow','NF_4_6','Chatter Email','メール通知','이메일 알림','Email Thông Báo','null','null','Chatter Email'));
        translations.add(createTranslation('NavigationFlow','NF_4_7','My Email Template','私のメールテンプレート','내 이메일 템플릿','Mẫu Email','null','null','My Email Template'));
        translations.add(createTranslation('NavigationFlow','NF_4_8','Chatter Feeds','フィード','피드','Chatter Feeds','null','null','Chatter Feeds'));
        translations.add(createTranslation('NavigationFlow','NF_4_9','Email To CloSCM','メール to CloSCM','내 Email to CloSCM','Email đến CloSCM','null','null','Email To CloSCM'));
        translations.add(createTranslation('NavigationFlow','NF_5_1','Users','ユーザ','모든 사용자','Người Dùng','null','null','Users'));
        translations.add(createTranslation('NavigationFlow','NF_5_2','Profiles','プロファイル','프로필','Hồ Sơ','null','null','Profiles'));
        translations.add(createTranslation('NavigationFlow','NF_5_3','Company Info','組織情報','회사 정보','Thông Tin Công Ty','null','null','Company Info'));
        translations.add(createTranslation('NavigationFlow','NF_5_4','Fiscal Year','会計年度期首月','조직 회계 연도 편집','Năm Tài Chính','null','null','Fiscal Year'));
        translations.add(createTranslation('NavigationFlow','NF_5_5','Business Hours','営業時間','조직 업무 시간','Thời gian làm việc','null','null','Business Hours'));
        translations.add(createTranslation('NavigationFlow','NF_5_6','Holidays','休日','휴일','Ngày Lễ','null','null','Holidays'));
        translations.add(createTranslation('NavigationFlow','NF_6_1','CloTra(Web Tracking Module)','CloTra(Webトラッキングモジュール)','CloTra(웹화물추적모듈)','Theo Dõi Lô Hàng','null','null','CloTra(Web Tracking Module)'));
        translations.add(createTranslation('NavigationFlow','NF_6_2','Search Link','検索','검색하기','Kết Quả Tìm Kiếm','null','null','Search Link'));
        translations.add(createTranslation('NavigationFlow','NF_7_1','Filing for JP24 Advanced Filing','JP24時間事前申告','일본24시간사전신고하기','CloFil(PLISM)','null','null','Filing for JP24 Advanced Filing'));
        translations.add(createTranslation('NavigationFlow','NF_7_2','Advanced Filing System','税関事前申告ファイリングシステム','세관사전신고파일링시스템','Hệ Thống Khai Báo Hải Quan Nâng Cao','null','null','Advanced Filing System'));
        translations.add(createTranslation('NavigationFlow','NF_8_1','Purchasing Order','発注','구매주문서','Đơn Đặt Hàng','null','null','Purchasing Order'));
        translations.add(createTranslation('NavigationFlow','NF_8_2','Purchasing Invoice','発注請求書','구매청구서','Hóa Đơn Thu Mua','null','null','Purchasing Invoice'));
        translations.add(createTranslation('NavigationFlow','NF_8_3','Resources','リソース','리소스','Hệ Thống','null','null','Resources'));
        translations.add(createTranslation('NavigationFlow','NF_8_4','Expense Payable','一般費用未支払金','판관비미지불금','Chi Phí Cần Trả','null','null','Expense Payable'));
        translations.add(createTranslation('NavigationFlow','NF_93','Language & Time Zone','言語とタイムゾーン','언어 및 표준 시간대','Ngôn Ngữ & Múi Giờ','null','null','Language & Time Zone'));
        translations.add(createTranslation('NavigationFlow','NF_94','Backup & Business Continuity Planning','バックアップと事業継続計画','백업 및 업무계속계획','Kế Hoạch Sao Lưu','null','null','Backup & Business Continuity Planning'));
        translations.add(createTranslation('NavigationFlow','NF_95','List Price','リストプライス（定価）','리스트프라이스(정가)','Danh Sách Giá','null','null','List Price'));
        translations.add(createTranslation('NavigationFlow','NF_96','Special Offer','ディスカウントキャンペーン','디스카운트캠페인','Đề Nghị Đặc Biệt','null','null','Special Offer'));
        translations.add(createTranslation('NavigationFlow','NF_97','File','ファイル','파일','File','null','null','File'));
        translations.add(createTranslation('NavigationFlow','NF_98','Process Schema','業務プロセススキーマ','업무프로세스플로','Giản Đồ','null','null','Process Schema'));
        translations.add(createTranslation('NavigationFlow','NF_99','Ocean Import','海上輸入','해상수입','Nhập khẩu đường biển','Ocean Import','Ocean Import','Ocean Import'));
        translations.add(createTranslation('NavigationFlow','NF_9_1','Consolidation','混載','콘솔','Hàng Ghép','null','null','Consolidation'));
        translations.add(createTranslation('NavigationFlow','NF_9_2','Consolidation Buying','混載-仕入','콘솔-지불','Gom Hàng','null','null','Consolidation Buying'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_1','CloTra-Cargo Tracking Module & Searching','CloTra-WEBカーゴトラッキングモジュール と 検索','CloTra-웹화물추적모듈 및 검색엔진','CloTra-Module Tìm Kiếm và Theo Dõi','null','null','CloTra-Cargo Tracking Module & Searching'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_10','CloSCM Package-Customization','CloSCMパッケージ-カスタマイズ','CloSCM패키지-커스터마이즈','CloSCM-Module Quản Lý và Tùy Chỉnh','null','null','CloSCM Package-Customization'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_11','CloSCM Package-Setup','CloSCMパッケージ-設定','CloSCM 패키지-설정','CloSCM-Module Cài Đặt','null','null','CloSCM Package-Setup'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_12','CloSCM Package-Code','CloSCMパッケージ-コード管理','CloSCM 패키지-코드관리','CloSCM-Module Quản Lý Mã','null','null','CloSCM Package-Code'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_13','New Release & Tutorial/Scenario for Self-Learning','新規リリースとチュートリアル・練習用シナリオ','버전업그레이드 및 학습자료/연습시나리오','Phiên Bản Mới & Hướng Dẫn','null','null','New Release & Tutorial/Scenario for Self-Learning'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_14','AFR Services & Contracts','AFR サービスと契約','AFR 제공서비스 및 계약','Dịch Vụ AFR và Hợp Đồng','null','null','AFR Services & Contracts'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_15','Consulting/Advisory Service & Best Practice','コンサルティングとベスト事例紹介','컨설팅 및 모범사례소개','Dịch Vụ Tư Vấn và Thực Hành','null','null','Consulting/Advisory Service & Best Practice'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_16','PC Setup & Data Upload Template','PC設定とデータ読み込みテンプレート','PC 설정 및 데이터일괄업로드템플릿','Cài Đặt và Upload Biểu Mẫu','null','null','PC Setup & Data Upload Template'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_17','My Setup','私の環境設定','내 환경설정','Cài Đặt Của Tôi','null','null','My Setup'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_18','Operation Management','組織オペレーション管理','조직운영관리','Quản Lý Vận Hành','null','null','Operation Management'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_19','Organization Governance & Monitoring','組織統制とモニターリング','조직통제 및 모니터링','Quản Trị Tổ Chức','null','null','Organization Governance & Monitoring'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_2','CloFor-Forwarding Module','CloFor-フォワーディングモジュール','AFR CloFor-포워딩모듈','CloFor-Module Giao Nhận Hàng Hóa','null','null','CloFor-Forwarding Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_20','CloCha-Chatter Module','CloCha-チャットモジュール','CloCha-채팅모듈','CloCha-Module Chatter','null','null','CloCha-Chatter Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_21','CloFin-Cloud Financial Report Module','CloFin-財務報告書モジュール','CloFin-재무보고서모듈','CloFin- Module Báo Cáo Tài Chính','null','null','CloFin-Cloud Financial Report Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_22','CloHRM-Human Resource Module','CloHRM-人事管理モジュール','CloHRM-인사관리모듈','CloHRM-Module QUẢN LÝ NHÂN SỰ','CloHRM','CloHRM','CloHRM-Human Resource Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_3','CloLog-Logistic Module','CloLog-ロジステックモジュール','CloLog-로지스틱모듈','CloLog-Module Hậu Cần','null','null','CloLog-Logistic Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_4','CloCon-Consolidation Module','CloCon-コンソールモジュール','CloCon-콘솔모듈','CloCon-Module Hàng Ghép','null','null','CloCon-Consolidation Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_5','CloTruck-Truck Module','CloTruck-トラックモジュール','CloTruck-트럭모듈','CloTruck-Module Vận Tải','null','null','CloTruck-Truck Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_6','CloFil-JP24H AFR Module','CloFil-日本税関24時間前申告モジュール','CloFil-일본세관24시간사전신고모듈','ClofFil-Module Khai Báo Hải Quan Nâng Cao','null','null','CloFil-JP24H AFR Module'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_7','CloAcc-Accounting Module:Revenues & Cost of Sales','CloAcc-会計モジュール:売上と仕入','CloAcc-회계모듈:매출 및 매입','CloAcc-Module Kế Toán-Lợi Nhuận và Chi Phí','null','null','CloAcc-Accounting Module:Revenues & Cost of Sales'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_8','CloAcc-Accounting Module-Purchasing/Expenses & Management','CloAcc-会計モジュール:発注・費用と一般管理','CloAcc-회계모듈:구매/판관비 및 전반관리','CloAcc-Module Kế Toán-Mua Bán/Chi Phí và Quản lý','null','null','CloAcc-Accounting Module-Purchasing/Expenses & Management'));
        translations.add(createTranslation('NavigationFlow','NF_PRB_9','CloCRM-Cust/Ptnr Relationship Module & Quotation','CloCRM-顧客・取引先理モジュールと見積','CloCRM-고객/거래처 관리모듈','CloCRM-Module Quản Lý Khách Hàng & Báo Giá','null','null','CloCRM-Cust/Ptnr Relationship Module & Quotation'));
        translations.add(createTranslation('OutstandingStatementReport','Bank_Settled_Date','REFERENCE DATA（BANK SETTLED DATE）','基準日（支払日：銀行口座基準）','기준일','Ngày chuyển khoản','null','null','REFERENCE DATA（BANK SETTLED DATE）'));
        translations.add(createTranslation('OutstandingStatementReport','ETD','ETD','ETD','ETD','Ngày dự kiến khởi hành (ETD)','ETD','ETD','ETD'));
        translations.add(createTranslation('OutstandingStatementReport','Export_to_excel','Export to excel','エクセルでエクスポート','엑셀파일로 다운로드','Xuất ra Excel','null','null','Export to excel'));
        translations.add(createTranslation('OutstandingStatementReport','From','From','From','From','Từ','From','From','From'));
        translations.add(createTranslation('OutstandingStatementReport','F_AMOUNT_SELLING','AMOUNT SELLING','案件消費税込み販売金額(標準通貨)','안건 소비세포함 판매금액','Tổng giá bán bằng nội tệ đã gồm thuế','null','null','AMOUNT SELLING'));
        translations.add(createTranslation('OutstandingStatementReport','F_DUE_DATE_OF_ADVANCE_PAYMENT','DUE DATE OF ADVANCE PAYMENT','立替金支払日','입체금지불일','Ngày thanh toán chi phí trả trước','null','null','DUE DATE OF ADVANCE PAYMENT'));
        translations.add(createTranslation('OutstandingStatementReport','F_DUE_DATE_OF_DUTY_PAYMENT_TAX','DUE DATE OF DUTY PAYMENT-TAX','立替金入金期限','대납입금기한','Ngày được nợ thuế','null','null','DUE DATE OF DUTY PAYMENT-TAX'));
        translations.add(createTranslation('OutstandingStatementReport','F_DUE_DATE_OF_PAYMENT','DUE DATE OF PAYMENT','諸請求支払日','청구지불일','Thời gian nợ','null','null','DUE DATE OF PAYMENT'));
        translations.add(createTranslation('OutstandingStatementReport','F_DUE_DATE_OF_PAYMENT_EXCLUDE_TAX','DUE DATE OF PAYMENT-EXCLUDE TAX','諸請求入金期限','청구입금기한(대납금 이외)','Ngày phát sinh hóa đơn nợ-chưa gồm thuế','null','null','DUE DATE OF PAYMENT-EXCLUDE TAX'));
        translations.add(createTranslation('OutstandingStatementReport','F_EXPECTED_DELIVERY_DATE','EXPECTED DELIVERY DATE','配送予定日','배송일','Dự kiến ngày giao hàng','null','null','EXPECTED DELIVERY DATE'));
        translations.add(createTranslation('OutstandingStatementReport','F_QUANTITY','QUANTITY','数量','수량','Số lượng','null','null','QUANTITY'));
        translations.add(createTranslation('OutstandingStatementReport','F_UNPAID_BALANCE','UNPAID BALANCE','案件入金残高','안건 입금잔고','Còn lại phải thu tiền bán cước','null','null','UNPAID BALANCE'));
        translations.add(createTranslation('OutstandingStatementReport','Generate_Report','Generate Report','レポートの生成','레포트 생성','Xuất báo cáo','null','null','Generate Report'));
        translations.add(createTranslation('OutstandingStatementReport','Outstanding_Statement','Outstanding Statement','集計表','집계표','Tình trạng công nợ','null','null','Outstanding Statement'));
        translations.add(createTranslation('OutstandingStatementReport','PDF 立替','ADVANCED PAYMENT','立替','대납비용청구','Trả trước','Advanced Payment','Advanced Payment','ADVANCED PAYMENT'));
        translations.add(createTranslation('OutstandingStatementReport','Report','Report','レポート','레포트','Báo cáo','null','null','Report'));
        translations.add(createTranslation('OutstandingStatementReport','Sales_accounted_date','REFERENCE DATE (SALES ACCOUNTED DATE）','基準日(計上日）','실적기준일','Ngày ghi (SALES ACCOUNTED DATE）','null','null','REFERENCE DATE (SALES ACCOUNTED DATE）'));
        translations.add(createTranslation('OutstandingStatementReport','Select_Report','Select Report','レポートの選択','레포트 선택','Chọn loại báo cáo','null','null','Select Report'));
        translations.add(createTranslation('OutstandingStatementReport','Time_Frame','Time Frame','タイムフレーム','타임 프레임','Khoảng thời gian','null','null','Time Frame'));
        translations.add(createTranslation('OutstandingStatementReport','To','To','To','To','Tới','To','To','To'));
        translations.add(createTranslation('OutstandingStatementReport','合計','Total','合計','합계','Tổng','Total','Total','Total'));
        translations.add(createTranslation('OutstandingStatementReport','請請求','PAYMENT EXCLUDE TAX','請請求','세금외청구','Thanh toán chưa thuế','null','null','PAYMENT EXCLUDE TAX'));
        translations.add(createTranslation('ProgressBar','PR_1','BOOKING','ブッキング','부킹','ĐẶT CHUYẾN','BOOKING','BOOKING','BOOKING'));
        translations.add(createTranslation('ProgressBar','PR_10','OUTBOUND FORWARDING','アウトバウンドフォワーディング','아웃바운드포워딩','CHỨNG TỪ XUẤT','OUTBOUND DOCUMENTATION','OUTBOUND DOCUMENTATION','OUTBOUND DOCUMENTATION'));
        translations.add(createTranslation('ProgressBar','PR_11','INBOUND FORWARDING','インバウンドフォワーディング','인바운드포워딩','CHỨNG TỪ NHẬP','INBOUND DOCUMENTATION','INBOUND DOCUMENTATION','INBOUND DOCUMENTATION'));
        translations.add(createTranslation('ProgressBar','PR_12','AP','支払','지불','AP','AP','AP','AP'));
        translations.add(createTranslation('ProgressBar','PR_13','COMPLETED','完了','완료','HOÀN THÀNH','COMPLETED','COMPLETED','COMPLETED'));
        translations.add(createTranslation('ProgressBar','PR_2','IMPORT FORWARDING','輸入フォワーディング','수입포워딩','CHỨNG TỪ HÀNG NHẬP','IMPORT DOCUMENTATION','IMPORT DOCUMENTATION','IMPORT DOCUMENTATION'));
        translations.add(createTranslation('ProgressBar','PR_3','IMPORT CUST. CLEARANCE','輸入通関','수입통관','KHAI QUAN HÀNG NHẬP','IMPORT CUST. CLEARANCE','IMPORT CUST. CLEARANCE','IMPORT CUST. CLEARANCE'));
        translations.add(createTranslation('ProgressBar','PR_4','DELIVERY','配送','배송','GIAO HÀNG','DELIVERY','DELIVERY','DELIVERY'));
        translations.add(createTranslation('ProgressBar','PR_5','INVOICE','請求','청구','CHI PHÍ','INVOICE','INVOICE','INVOICE'));
        translations.add(createTranslation('ProgressBar','PR_6','EXPORT FORWARDING','輸出フォワーディング','수출포워딩','CHỨNG TỪ HÀNG XUẤT','EXPORT DOCUMENTATION','EXPORT DOCUMENTATION','EXPORT DOCUMENTATION'));
        translations.add(createTranslation('ProgressBar','PR_7','PICKUP','引取','픽업','NHẬN HÀNG','PICKUP','PICKUP','PICKUP'));
        translations.add(createTranslation('ProgressBar','PR_8','EXPORT CUST. CLEARANCE','輸出通関','수출통관','KHAI QUAN HÀNG XUẤT','EXPORT CUST. CLEARANCE','EXPORT CUST. CLEARANCE','EXPORT CUST. CLEARANCE'));
        translations.add(createTranslation('ProgressBar','PR_9','AR','入金','입금','AR','AR','AR','AR'));
        
        // Thong configured 20190330-start
        
        translations.add(createTranslation('ProgressBar','PR_14','REVENUE','売上','매출','DOANH THU','REVENUE','REVENUE','REVENUE'));
        translations.add(createTranslation('ProgressBar','PR_15','COST','仕入','매입','CHI PHÍ','COST','COST','COST'));
        
        // Thong configured 20190330-end
        
        translations.add(createTranslation('TRUCKING','DUPLICATED_SEQUENCE_NUMBER','Duplicated SEQUENCE NUMBER','運行順番が重複しています。','중복된 일련번호입니다.','Lỗi trùng Số Thứ Tự','null','null','Duplicated SEQUENCE NUMBER'));
        translations.add(createTranslation('TRUCKING','NEGATIVE_NUMBER','Measurement and Weight cannot be negative','容積および重量は負の数字になってはなりません。','측정과 무게는 마이너스일 수 없습니다.','Giá trị đo lường và trọng lượng không được nhập giá trị nhỏ hơn 0','null','null','Measurement and Weight cannot be negative'));
        translations.add(createTranslation('TRUCKING','REQUIRED_ROUTE','ROUTE & LOAD must be set','ルート&荷積みの入力が必要です。','루트가 설정되어야 합니다.','Yêu cầu nhập Tuyến Đường & Địa điểm xếp dở hàng hoá.','null','null','ROUTE & LOAD must be set'));
        translations.add(createTranslation('TRUCKING','REQUIRED_SEQUENCE_NUMBER','SEQUENCE NUMBER is required.','運行順番の入力が必要です。','일련번호가 필요합니다.','Yêu cầu nhập Số Thứ Tự','null','null','SEQUENCE NUMBER is required.'));
        translations.add(createTranslation('VAT_Invoice','DIFF_TAX_RATIO','Please Choose new INVOICING that have the same TAX RATIO. For Example, 2 different INVOICING have 0.00%, 10.00% can not be selected in one VAT INVOICE.','一つのVAT請求書に二つの異なる消費税率(販売)を持った請求・仕入を選択することができません。同じ消費税率(販売)の請求・仕入を選択してください。例：0.00%の請求・仕入と10.00%の請求・仕入を一緒に選択することができません。','세금계산서별 2개이상의 소비세율(판매)를 선택 하실 수 없습니다. 동일한 소비세율(판매)의 청구/지불를 선택하여 주십시요. 예: 소비세율(판매)가 0.00%의 청구/지불과 10.00%의 청구/지불을 동일한 세금계산서에 선택 하 실 수 없습니다.','Trong một HÓA ĐƠN VAT, TÍ SUẤT THUẾ BÁN phải giống nhau. Vui lòng chọn giá có tỉ suất thuế giống nhau. Ví dụ, 2 giá có tỉ suất thuế 0% và 10% không thể chọn cùng với nhau.','Please Choose new INVOICING that have the same TAX RATIO. For Example, 2 different INVOICING have 0.00%, 10.00% can not be selected in one VAT INVOICE.','Please Choose new INVOICING that have the same TAX RATIO. For Example, 2 different INVOICING have 0.00%, 10.00% can not be selected in one VAT INVOICE.','In one VAT INVOICE, SELLING TAX RATIO must be the same. Please Choose new INVOICING that have the same TAX RATIO. For Example, 2 different INVOICING have 0.00%, 10.00% can not be selected in one VAT INVOICE.'));

        return translations;
    }

    private Translation__c createTranslation(String context, String name, String en, String ja, String ko,
            String vi, String kh, String zhCN, String zhTW) {
        Translation__c translation = new Translation__c();
        translation.Name = name;
        translation.Active__c = true;
        translation.Context__c = context;
        translation.en_US__c = en;
        translation.ja__c = ja;
        translation.vi__c = vi;
        translation.ko__c = ko;
        translation.kh__c = kh;
        translation.zh_CN__c = zhCN;
        translation.zh_TW__c = zhTW;

        return translation;
    }
    
    /**
     * There are number of configuration which are specific to subscriber's organization such as Company Name,
     * Logo, Address, Telephone, Email, etc. However, these configurations are required so that the app can
     * function properly. Pre-populate with dummy data and have a VF page for subscriber to correct them after
     * completed installation.
     */
    private List<SObject> popuplateInitialConfiguration() {
        Site_Custom_Settings__c initialSetting = new Site_Custom_Settings__c();
        initialSetting.Company_Name__c = 'Your Company Name';
        initialSetting.Company_Phone__c = '123456789';
        initialSetting.Company_Fax__c = '123456789';
        initialSetting.Ocean_HBL_No_Prefix__c = 'OCEAN';
        initialSetting.Air_HBL_No_Prefix__c = 'AIR';
        initialSetting.Company_Country__c = 'JAPAN';
        initialSetting.Ferry_SLA__c = 120;
        initialSetting.Container_Vessel_SLA__c = 480;
        initialSetting.Local_Currency__c = 'JPY';
        initialSetting.VATInvoiceObjectIdPrefix__c = Util.getObjectTypeId(VAT_INVOICE__c.SObjectType.getDescribe().getName());

        return new List<Site_Custom_Settings__c>{
                initialSetting
        };
    }
}