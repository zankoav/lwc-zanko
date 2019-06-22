public class E2EFormRuDeduplicationResult {
    public Account sfAccount { get; set; }
    public Opportunity sfOpportunity { get; set; }
    public Account e2eAccount { get; set; }
    public Contact e2eContact { get; set; }
    public Opportunity e2eOpportunity { get; set; }
    public String statusCode { get; set; }
    public Boolean innDuplication { get; set; }
    public Id formDataId { get; set; }

    public E2EFormRuDeduplicationResult() {
        this.statusCode = GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name();
        this.innDuplication = false;
    }

    public Map<String, String> getDeduplicationInfo() {
        String currentAccountId;
        String mainId = '';
        if (this.innDuplication == true) {
            currentAccountId = sfAccount.Id;
            if (this.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                mainId = sfAccount.Transit_ID_a__c;
            }
        } else {
            currentAccountId =  e2eAccount.Id;
            if (this.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
                mainId = sfAccount.Transit_ID_a__c;
            }
        }

        return new Map<String, String> {
                'accountId' => currentAccountId,
                'statusCode' => this.statusCode,
                'mainId' => mainId
        };
    }

    public String getDedupStatusInformation() {
        if (this.statusCode == GlobalUtils.DeduplicationStatus.E2EWithOutUpdate.name()) {
            return 'Е2Е - нет дубля';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.E2EProcess.name()) {
            return 'E2E ';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.Service.name()) {
            return 'Клиент Сервис';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.KO.name()) {
            return 'Клиент КО';
        } else if (this.statusCode == GlobalUtils.DeduplicationStatus.Inbound.name()) {
            if (this.innDuplication == true) {
                return 'Е2Е проверка (прикрепление e2e объектов)';
            } else {
                return 'Е2Е проверка (новый ИНН, дубля по email)';
            }
        }
        return 'status missing';
    }
}