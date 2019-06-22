/**
 * E2E Form params class for processes logic
 */
public class E2EFormParams {

    /* For analytics */
    public String utmCampaign { get; set; }                     // рекламная кампания
    public String utmContent { get; set; }                      // тип объявления
    public String utmMedium { get; set; }                       // тип трафика
    public String utmTerm { get; set; }                         // ключевое слово, которое инициировало показ объявления
    public String utmSource { get; set; }                       // рекламная система
    public String utmUrl { get; set; }                          // целевой url
    public String websitePageForm { get; set; }                 // полный url
    public String splitTesting { get;
        set{
            System.debug('SplitTesting setter ***');
            System.debug(value);
            System.debug(E2E_Split_Testing__c.getValues(value));
            if (value != null && value != '') {
                E2E_Split_Testing__c splitObject = E2E_Split_Testing__c.getValues(value);
                if (splitObject != null){
                    this.splitTesting = splitObject.Name;
                    this.productSplitTesting = splitObject.Target__c;
                } else {
                    this.splitTesting = '';
                    this.productSplitTesting = this.product;
                }
            } else {
                this.splitTesting = '';
                this.productSplitTesting = this.product;
            }
        }
    }                    // ABC-тест

    public String productSplitTesting { get; set; }                 // продукт для ABC-теста

    public Boolean sendToInbound {                              // признак отправки в Инбаунд
        get {
            if (this.sendToInbound == null) {
                return false;
            } else {
                return this.sendToInbound;
            }
        }

        set {
            if (value == true) {
                this.sendToInbound = true;
            }
        }
    }

    public String encodedURL { get; set; }                      // закодированный url
    public String generatedUrlWithHash { get; set; }            // полная ссылка с доменом и сгенерированным hash

    public Boolean isSoleProprietor { get; set; }               // признак, что клиент является ИП
    public String deduplicationStatus { get; set; }             // статус процесса дедубликации
    public String deduplicationStatusInfo { get; set; }         // расшифровка статуса дедубликации

    public String companyFullNameDadata { get; set; }           // полное название компании, которое приходит из Dadata
    public String bankNameShort { get; set; }                   // короткое название банка из Dadata
    public String bankAddress { get; set; }                     // адрес банка из Dadata
    public String bankTown { get; set; }                        // город банка из Dadata
    public String bankOkpo { get; set; }                        // окпо банка
    public String bankBic { get; set; }                         // БИК банка
    public Boolean isBankInformationInvalid { get; set; }         // Проверка совпадения "Наименования банка"/"БИК банка"/"КС банка" с данными из Dadata

    public String companyInn { get; set; }

    // SPARK params
    public Decimal sparkId { get; set; }                        // идентификатор компании из СПАРКа
    public String registrationDateSpark { get; set; }           // дата регистрации компании из СПАРКа
    public String mainCompanyFullNameSpark { get; set; }        // полное название компании из СПАРКа
    public String postCodeSpark { get; set; }                   // индекс из СПАРКа
    public String companyCountry { get; set; }                  // страна (в СПАРКе ее нет, дефолтно Россия)
    public String regionSpark { get; set; }                     // регион из СПАРКа
    public String citySpark { get; set; }                       // город из СПАРКа
    public String streetSpark { get; set; }                     // улица из СПАРКа
    public String buildingSpark { get; set; }                   // номер дома из СПАРКа
    public String housingSpark { get; set; }                    // корпус из СПАРКа
    public String blockSpark { get; set; }                      // строение из СПАРКа
    public String roomSpark { get; set; }                       // квартира/офис/помещение из СПАРКа
    public String legalAddressSpark { get; set; }               // полный адрес компании из СПАРКа
    public String opportunityLostReason { get; set; }           // причина потери возможности
    public String normName { get; set; }                        //  normName из спарка
    public String billingApartment { get; set; }                //

    public String ogrnSpark { get; set; }                       // ОГРН из СПАРКа
    public String ogrnipSpark { get; set; }                     // ОГРНИП (для ИП) из СПАРКа
    public String okpoSpark { get; set; }                       // ОКПО из СПАРКа
    public String kppSpark { get; set; }                        // КПП из СПАРКа
    public String executiveFio { get; set; }                    // ФИО руководителя из СПАРКа
    public String executivePosition { get; set; }               // должность руководителя из СПАРКа
    public String executiveId { get; set; }                     // Id контакта для руководителя

    public String soleProprietorFio {get; set;}                 // ФИО для ИП

    // SCORING params
    public String verifiedDecision { get; set; }                // тип решения проверки по ЧЧС в Скоринге
    public String verifiedDecisionCode { get; set; }            // код типа решения проверки по ЧЧС в Скоринге
    public String verifiedLimitation { get; set; }              // максимальный срок отсрочки платежа, если ответ на проверку «ограничение по отсрочке»
    public String scoringDecision { get; set; }                 // тип решения в Скоринге
    public String scoringDecisionCode { get; set; }             // код типа решения в Скоринге
    public Date scoringDate { get; set; }                       // дата скоринга

    // MZK params
    public String requestNumMZK { get; set; }                   // номер заявки в МЗК (Модуль Заказа Карт)

    // Transit Cont Id
    public String transitContId { get; set; }                   // Cont Id который приходит из транзита

    // Promocode
    public String promocodeName { get; set; }                    // наименование промокода
    public String promocodeIdInTransit { get; set; }            // индификатор промокода в транзите

    // Contract
    public String contractPrefix { get; set; }                  // префикс договора (отправляется в транзит)
    public String contractCounter { get; set; }                 // номер договора (отправляется в транзит)
    public String invoicePrefix { get; set; }                   // Префикс номера счета
    public String invoiceCounter { get; set; }                  // Счетчик номера счета

    // Form process statuses
    public String contactDetails { get; set; }                  // пройден шаг Контактные данные
    public String sfDeduplication1 { get; set; }                // пройден 1 этап дедубликации
    public String sfDeduplication2 { get; set; }                // пройден 2 этап дедубликации
    public String getSparkData { get; set; }                    // получены данные из СПАРК
    public String checkedInBlackList { get; set; }              // пройдена проверка по ЧЧС
    public String scoringPassed { get; set; }                   // пройден Скорин
    public String sfDeduplication3 { get; set; }                // пройден 3 этап дедубликации
    public String sendCrmRequest { get; set; }                  // отправлена заявка в CRM
    public String companyDetails { get; set; }                  // пройден шаг Данные о компании
    public String cardOrderDetails { get; set; }                // пройден шаг Заказ карт
    public String legalDetails { get; set; }                    // пройден шаг Реквизитов компании
    public String paymentDetails { get; set; }                  // пройден шаг Платежных реквизитов
    public String getReport { get; set; }                       // получены шаблоны документов
    public String createContInTransit { get; set; }             // создан контрагент в Транзит
    public String sendMzkRequest { get; set; }                  // отправлена заявка в МЗК
    public String saveReport { get; set; }                      // документы были сохранены
    public Boolean isManualEntry { get; set; }                  // указатель на ручной ввод данных о компании
    public Boolean isNumberOfCardsLimit { get; set; }           // количество кард превышает лимит для inbound
    public Integer numberOfCardsEntered { get; set; }           // введенное количество карт

    // Other params
    public String legalAddressAdditionally { get; set; }        // дополнительная информация по юридическому адресу
    public String postalAddress { get; set; }                   // адрес для доставки
    public String postalAddressAdditionally { get; set; }       // дополнительная информация по адрес для доставки

    //formData Name
    public String formDataName {get; set;}

    public String promoCode {get; set;}
    public String product {get; set;}
    public String deviceType {get; set;}
    public String source {get; set;}
    public String sourcePP {get; set;}
    public String offer {get; set;}
    public String ipAddress {get; set;}

    public String numberOfTariffsDependency {get; set;}

    public E2EFormParams() {
        this.sparkId = null;
        this.mainCompanyFullNameSpark = '';
        this.bankNameShort = '';
        this.bankAddress = '';
        this.bankTown = '';
        this.bankOkpo = '';
        this.isBankInformationInvalid = false;
        this.verifiedDecisionCode = '';
        this.verifiedDecision = '';
        this.verifiedLimitation = '';
        this.scoringDecision = '';
        this.scoringDecisionCode = '';
        this.contactDetails = '';
        this.sfDeduplication1 = '';
        this.sfDeduplication2 = '';
        this.getSparkData = '';
        this.checkedInBlackList = '';
        this.scoringPassed = '';
        this.sfDeduplication3 = '';
        this.sendCrmRequest = '';
        this.companyDetails = '';
        this.cardOrderDetails = '';
        this.legalDetails = '';
        this.paymentDetails = '';
        this.getReport = '';
        this.createContInTransit = '';
        this.sendMzkRequest = '';
        this.saveReport = '';
        this.sendToInbound = false;
        this.isSoleProprietor = false;
        this.opportunityLostReason = '';
        this.isManualEntry = false;
        this.isNumberOfCardsLimit = false;
        this.numberOfCardsEntered = 0;

        this.companyInn = '';

        this.ogrnSpark = '';
        this.ogrnipSpark = '';
        this.okpoSpark = '';
        this.kppSpark = '';
        this.executiveFio = '';
        this.executivePosition = '';
        this.executiveId = null;

        this.formDataName = '';

        this.promoCode = '';
        this.product = '';
        this.deviceType = '';
        this.source = '';
        this.sourcePP = '';
        this.offer = '';
        this.ipAddress = '';

        this.numberOfTariffsDependency = '';
        this.websitePageForm = '';
        this.splitTesting = '';
        this.productSplitTesting = '';
    }
}