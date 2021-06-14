SELECT 
 "Company"."CompanyName", 
 "Chart"."AccountID" AS AccountNo, 
 "Chart"."AccountDescription" AS AccountName, 
 CASE "Chart"."AccountType" 
    WHEN 21 THEN 'Income' 
    WHEN 23 THEN 'Cost of Sales' 
    WHEN 24 THEN 'Expenses' 
END AS AccTypeDescription, 
"Chart"."AccountType", 
"InventoryCosts"."RecordType",
ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                 THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                             THEN ISNULL(SUM("InventoryCosts"."TransAmount"),0) + ISNULL(SUM(ADJ."TransAmount"),0)
                             WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN SUM("InventoryCosts"."TransAmount") * -1
                             ELSE SUM("JrnlRow"."Amount")
                       END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN SUM("InventoryCosts"."OptQty")
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40,30) 
                 THEN CASE WHEN "InventoryCosts"."RecordType"= 30 THEN SUM("InventoryCosts"."OptAmount") * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
                          ELSE SUM("InventoryCosts"."TransAmount") * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
                          END
           ELSE
                SUM("InventoryCosts"."TransAmount") * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
       END),0) as Amount

FROM ((((((("Chart"
LEFT JOIN  "JrnlRow"
ON "Chart"."GLAcntNumber" = "JrnlRow"."GLAcntNumber")
LEFT JOIN "JrnlHdr"
ON "JrnlHdr"."PostOrder" = "JrnlRow"."PostOrder")
LEFT JOIN "InventoryCosts"
 ON "JrnlRow"."itemRecordNumber" = "InventoryCosts"."ItemRecNumber" AND "Jrnlrow"."RowDate" = "InventoryCosts"."TransDate" 
 AND "JrnlRow"."PostOrder" = "InventoryCosts"."PostOrderNumber" AND "JrnlRow"."RowNumber" = "InventoryCosts"."RowNumber"
 AND "InventoryCosts"."RecordType" <> 50)
 LEFT JOIN "Jobs"
ON "Jobs"."JobRecordNumber" = "JrnlRow"."JobRecordNumber") 
LEFT JOIN (SELECT IC2."ItemRecNumber"
                  ,IC2."TransDate"
                  ,IC2."Journaltype"
                  ,IC2."RecordType"
                  ,IC2."PostedFromHere"
                  ,IC2."TransAmount"
                  ,IC2."PostOrderNumber"
           FROM "InventoryCosts" IC2
           WHERE IC2."RecordType" = 40 AND IC2."Journaltype"=7 AND IC2."PostedFromHere" =1  
           )ADJ ON "JrnlRow"."ItemRecordNumber" = ADJ."ItemRecNumber" AND "Jrnlrow"."RowDate" = ADJ."TransDate" AND "JrnlRow"."PostOrder" = ADJ."PostOrderNumber"  AND "JrnlRow"."Journal"= ADJ."JournalType" )


INNER JOIN "Company"
  ON "Company"."CompanyName" = "Company"."CompanyName")
INNER JOIN "General_GL"
  ON "Company"."CompanyName" = "Company"."CompanyName" AND "General_GL"."AcctgModule" = 4)

WHERE (("JrnlRow"."RowDate">= '2019-01-01' AND "JrnlRow"."RowDate" <= '2019-03-31') OR "JrnlRow"."RowDate" IS NULL ) 
      AND "JrnlRow"."IncludeInGL" = 1
      AND "Chart"."AccountType" in (21,23,24)

GROUP BY  "Chart"."AccountID" ,AccTypeDescription, "Chart"."AccountType" ,  "Company"."CompanyName", "Chart"."AccountType" , "Chart"."AccountDescription" ,"JrnlRow"."IncludeInGL" , "JrnlRow"."Rowtype", InventoryCosts.RecordType, ADJ.RecordType

UNION ALL

SELECT
 "Company"."CompanyName", 
 "Chart"."AccountID" AS AccountNo, 
 "Chart"."AccountDescription" AS AccountName, 
 CASE "Chart"."AccountType" 
    WHEN 21 THEN 'Income' 
    WHEN 23 THEN 'Cost of Sales' 
    WHEN 24 THEN 'Expenses' 
END AS AccTypeDescription, 
"Chart"."AccountType", 
"InventoryCosts"."RecordType",
ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                  THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
           ELSE 0
        END),0) as Amount
FROM (((((("Chart"
LEFT JOIN  "JrnlRow"
ON "Chart"."GLAcntNumber" = "JrnlRow"."GLAcntNumber")
LEFT JOIN "JrnlHdr"
ON "JrnlHdr"."PostOrder" = "JrnlRow"."PostOrder")
LEFT JOIN "InventoryCosts"
 ON "JrnlRow"."ItemRecordNumber" = "InventoryCosts"."ItemRecNumber" AND "JrnlRow"."RowDate" = "InventoryCosts"."TransDate" )
  LEFT JOIN "Jobs"
ON "Jobs"."JobRecordNumber" = "JrnlRow"."JobRecordNumber") 
INNER JOIN "Company"
  ON "Company"."CompanyName" = "Company"."CompanyName")
INNER JOIN "General_GL"
  ON "Company"."CompanyName" = "Company"."CompanyName" AND "General_GL"."AcctgModule" = 4)

WHERE (("JrnlRow"."RowDate">= @stardate AND "JrnlRow"."RowDate" <= @enddate ) OR "JrnlRow"."RowDate" IS NULL ) 
      AND "JrnlRow"."IncludeInGL" = 1 AND "JrnlRow"."Journal" = 9 AND "InventoryCosts"."Recordtype" = 50  
GROUP BY  "Chart"."AccountID" ,AccTypeDescription, "Chart"."AccountType" ,  "Company"."CompanyName", "Chart"."AccountType" , "Chart"."AccountDescription" ,"JrnlRow"."IncludeInGL" , "JrnlRow"."Rowtype", InventoryCosts.RecordType, "JrnlRow"."Journal" ,"InventoryCosts"."OptQty" 
