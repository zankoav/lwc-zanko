global class SoleProprietorSpark {

    public class Status {
        public Boolean isActing;        // признак действующего ИП
        public String text;             // текст статуса
        public Integer code;            // код статуса
    }

    public class Okved {
        public String code;             // код ОКВЭД
        public String name;             // наименование
        public Boolean isMain;          // признак основного ОКВЭД
    }

    public class Okato {
        public String code;             // код ОКАТО
        public String regionName;       // наименование региона
        public Integer regionCode;      // код региона
    }

    public class OkvedList {
        public List<Okved> okved;       // список ОКВЭД
    }

    public Decimal sparkID;             // идентификатор системы СПАРК
    public Status status;               // статус
    public String dateReg;              // дата регистрации
    public String fullNameRus;          // полное имя (на русском)
    public String inn;                  // ИНН
    public String ogrnip;               // ОГРНИП
    public String okpo;                 // ОКПО
    public Okato okato;                 // ОКАТО
    public String birthDate;            // дата рождения
    public String birthPlace;           // место рождения
    public OkvedList okvedList;         // список ОКВЭД

    public static SoleProprietorSpark parse(String json) {
        return (SoleProprietorSpark) System.JSON.deserialize(json, SoleProprietorSpark.class);
    }
}