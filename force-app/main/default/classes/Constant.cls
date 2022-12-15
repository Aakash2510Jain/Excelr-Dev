public class Constant {
    public static Id queueId = [select Id
                                from Group
                                where Name = 'Excelr Default Queue' and Type = 'Queue'].Id;
}