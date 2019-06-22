/**
 * Created by Nikita.Mikhailov on 14.01.2019.
 */

public with sharing class GFNI_BankAccount {
    public String DDEffectiveDate {
        get {
            return String.isNotBlank(this.DDEffectiveDate) ? this.DDEffectiveDate.toUpperCase() : this.DDEffectiveDate;
        }
        set;
    }
    public String SwiftCode {
        get {
            return String.isNotBlank(this.SwiftCode) ? this.SwiftCode.toUpperCase() : this.SwiftCode;
        }
        set;
    }
    public String IBAN {
        get {
            return String.isNotBlank(this.IBAN) ? this.IBAN.toUpperCase() : this.IBAN;
        }
        set;
    }
    public String DDDRefNo {
        get {
            return String.isNotBlank(this.DDDRefNo) ? this.DDDRefNo.toUpperCase() : this.DDDRefNo;
        }
        set;
    }
    public Integer DDMandateTypeId { get; set; }
}