SELECT 
 "Company"."CompanyName", 
 "Chart"."AccountID" AS AccountNo, 
 "Chart"."AccountDescription" AS AccountName, 
CASE 
 WHEN "Chart"."AccountType" > '19' THEN 'I'
 WHEN "Chart"."AccountType" = '18' THEN 'R'
 ELSE 'B' END AS FSType, 
 CASE "Chart"."AccountType" 
    WHEN 0 THEN 'Cash' 
    WHEN 1 THEN 'Accounts Receivable' 
    WHEN 2 THEN 'Inventory' 
    WHEN 3 THEN 'Receivable Retainage' 
    WHEN 4 THEN 'Other Current Assets' 
    WHEN 5 THEN 'Fixed Assets' 
    WHEN 6 THEN 'Accumulated Depreciation' 
    WHEN 8 THEN 'Other Assets' 
    WHEN 10 THEN 'Accounts Payable' 
    WHEN 11 THEN 'Payable Retainage' 
    WHEN 12 THEN 'Other Current Liabilities' 
    WHEN 14 THEN 'Long Term Liabilities' 
    WHEN 16 THEN 'Equity-does not close' 
    WHEN 18 THEN 'Equity-Retained Earnings' 
    WHEN 19 THEN 'Equity-gets closed' 
    WHEN 21 THEN 'Income' 
    WHEN 23 THEN 'Cost of Sales' 
    WHEN 24 THEN 'Expenses' 
END AS AccTypeDescription, 
"Chart"."AccountType", 
CASE WHEN "JrnlRow"."Journal" = 0 THEN 'GEN'
     WHEN "JrnlRow"."Journal" = 1 THEN 'CRJ'
     WHEN "JrnlRow"."Journal" = 2 THEN 'CDJ'
     WHEN "JrnlRow"."Journal" = 3 THEN 'SJ'
     WHEN "JrnlRow"."Journal" = 4 THEN 'PJ'
     WHEN "JrnlRow"."Journal" = 5 THEN 'PRJ'
     WHEN "JrnlRow"."Journal" = 6 THEN 'COG'
     WHEN "JrnlRow"."Journal" = 7 THEN 'INAJ'
     WHEN "JrnlRow"."Journal" = 8 THEN 'ASB'
     WHEN "JrnlRow"."Journal" = 9 THEN ''
     WHEN "JrnlRow"."Journal" = 10 THEN 'PO'
     WHEN "JrnlRow"."Journal" = 11 THEN 'SO'
     WHEN "JrnlRow"."Journal" = 12 THEN 'QUO'
ELSE '' END as Journal,
COALESCE("JrnlRow"."RowDate","JrnlHdr"."Transactiondate") AS TransactionDate, 
CASE WHEN "JrnlHdr"."JrnlKey_Per" IS NULL THEN 0 
     WHEN "JrnlHdr"."JrnlKey_Per" >= 15 
     THEN CAST("JrnlHdr"."JrnlKey_Per" AS INT)-14 
     ELSE CAST("JrnlHdr"."JrnlKey_Per" AS INT)
END AS Period, 
COALESCE(RTRIM("JrnlHdr"."Reference"),"JrnlRow"."InvNumForThisTrx") AS Reference, 
COALESCE(RTRIM("JrnlHdr"."Description"),"JrnlRow"."RowDescription") AS Description, 
CAST(CASE WHEN ISNULL("JrnlHdr"."TrxIsPosted",1) = 1 THEN 'Yes' ELSE 'No' END as VARCHAR(3)) AS Posted, 

ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                  THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                             WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                             ELSE "JrnlRow"."Amount"
                        END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
        END),0) as NetChange,
0 AS BeginningBal,
CASE WHEN ((ISNULL(CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                    THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                               WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                               ELSE "JrnlRow"."Amount"
                          END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
            END,0)))>=0
     THEN ((ISNULL(CASE
            WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                     THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                               WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                               ELSE "JrnlRow"."Amount"
                          END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           END,0))) 
      ELSE 0 
 END as Debit,
CASE WHEN ((ISNULL(CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                     THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                               WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                               ELSE "JrnlRow"."Amount"
                          END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
            END,0)))<0
     THEN ((ISNULL(CASE
            WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
            WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                     THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                               WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                               ELSE "JrnlRow"."Amount"
                          END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
            END,0))) 
      ELSE 0 
END as Credit
FROM (((((("Chart"
LEFT JOIN  "JrnlRow"
ON "Chart"."GLAcntNumber" = "JrnlRow"."GLAcntNumber")
LEFT JOIN "JrnlHdr"
ON "JrnlHdr"."PostOrder" = "JrnlRow"."PostOrder")
LEFT JOIN "InventoryCosts"
 ON "JrnlRow"."itemRecordNumber" = "InventoryCosts"."ItemRecNumber" AND "Jrnlrow"."RowDate" = "InventoryCosts"."TransDate" 
 AND "JrnlRow"."PostOrder" = "InventoryCosts"."PostOrderNumber" AND "JrnlRow"."RowNumber" = "InventoryCosts"."RowNumber"
 AND "InventoryCosts"."RecordType" <> 50)
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

WHERE (("JrnlRow"."RowDate">= @stardate AND "JrnlRow"."RowDate" <= @enddate ) OR "JrnlRow"."RowDate" IS NULL ) 
      AND "JrnlRow"."IncludeInGL" = 1
      AND (ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                  THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                             WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                             ELSE "JrnlRow"."Amount"
                        END)
           WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                 THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                 THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
           ELSE
                "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
        END),0))<>0    

UNION ALL

 SELECT 
 "Company"."CompanyName", 
 "Chart"."AccountID" AS AccountNo, 
 "Chart"."AccountDescription" AS AccountName, 
 CASE 
 WHEN "Chart"."AccountType" > '19' THEN 'I'
 WHEN "Chart"."AccountType" = '18' THEN 'R'
 ELSE 'B' END AS FSType, 
 CASE "Chart"."AccountType" 
    WHEN 0 THEN 'Cash' 
    WHEN 1 THEN 'Accounts Receivable' 
    WHEN 2 THEN 'Inventory' 
    WHEN 3 THEN 'Receivable Retainage' 
    WHEN 4 THEN 'Other Current Assets' 
    WHEN 5 THEN 'Fixed Assets' 
    WHEN 6 THEN 'Accumulated Depreciation' 
    WHEN 8 THEN 'Other Assets' 
    WHEN 10 THEN 'Accounts Payable' 
    WHEN 11 THEN 'Payable Retainage' 
    WHEN 12 THEN 'Other Current Liabilities' 
    WHEN 14 THEN 'Long Term Liabilities' 
    WHEN 16 THEN 'Equity-does not close' 
    WHEN 18 THEN 'Equity-Retained Earnings' 
    WHEN 19 THEN 'Equity-gets closed' 
    WHEN 21 THEN 'Income' 
    WHEN 23 THEN 'Cost of Sales' 
    WHEN 24 THEN 'Expenses' 
END AS AccTypeDescription, 
CAST("Chart"."AccountType" AS INT) AS AccountType, 
CASE WHEN "JrnlRow"."Journal" = 0 THEN 'GEN'
     WHEN "JrnlRow"."Journal" = 1 THEN 'CRJ'
     WHEN "JrnlRow"."Journal" = 2 THEN 'CDJ'
     WHEN "JrnlRow"."Journal" = 3 THEN 'SJ'
     WHEN "JrnlRow"."Journal" = 4 THEN 'PJ'
     WHEN "JrnlRow"."Journal" = 5 THEN 'PRJ'
     WHEN "JrnlRow"."Journal" = 6 THEN 'COG'
     WHEN "JrnlRow"."Journal" = 7 THEN 'INAJ'
     WHEN "JrnlRow"."Journal" = 8 THEN 'ASB'
     WHEN "JrnlRow"."Journal" = 9 THEN 'IN'
     WHEN "JrnlRow"."Journal" = 10 THEN 'PO'
     WHEN "JrnlRow"."Journal" = 11 THEN 'SO'
     WHEN "JrnlRow"."Journal" = 12 THEN 'QUO'
ELSE '' END as Journal, 
COALESCE("JrnlRow"."RowDate","JrnlHdr"."Transactiondate") AS TransactionDate, 
CASE WHEN "JrnlHdr"."JrnlKey_Per" IS NULL THEN 0 
     WHEN "JrnlHdr"."JrnlKey_Per" >= 15 
     THEN CAST("JrnlHdr"."JrnlKey_Per" AS INT)-14 
     ELSE CAST("JrnlHdr"."JrnlKey_Per" AS INT)
END AS Period, 
CAST('SysCost' as VARCHAR(7)) AS Reference, 
CAST('System Cost Adj' as VARCHAR(15)) AS Description, 
CAST(CASE WHEN ISNULL("JrnlHdr"."TrxIsPosted",1) = 1 THEN 'Yes' ELSE 'No' END as VARCHAR(3)) AS Posted, 
ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                  THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
           ELSE 0
        END),0) as NetChange,
0 AS BeginningBal,
CASE WHEN ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                  THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
           ELSE 0
          END),0)>=0
     THEN ISNULL((CASE WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
                       WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                             THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
                       ELSE 0
                   END),0) 
    ELSE 0 
END as Debit,
CASE WHEN ISNULL((CASE
           WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
           WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                  THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
           ELSE 0
          END),0)<0
     THEN ISNULL((CASE WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
                       WHEN "JrnlRow"."Journal" =9  AND "InventoryCosts"."RecordType" = 50
                             THEN "InventoryCosts"."OptQty" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
           
                       ELSE 0
                   END),0) 
      ELSE 0 
 END as Credit

FROM ((((("Chart"
LEFT JOIN  "JrnlRow"
ON "Chart"."GLAcntNumber" = "JrnlRow"."GLAcntNumber")
LEFT JOIN "JrnlHdr"
ON "JrnlHdr"."PostOrder" = "JrnlRow"."PostOrder")
LEFT JOIN "InventoryCosts"
 ON "JrnlRow"."ItemRecordNumber" = "InventoryCosts"."ItemRecNumber" AND "JrnlRow"."RowDate" = "InventoryCosts"."TransDate" )
INNER JOIN "Company"
  ON "Company"."CompanyName" = "Company"."CompanyName")
INNER JOIN "General_GL"
  ON "Company"."CompanyName" = "Company"."CompanyName" AND "General_GL"."AcctgModule" = 4)

WHERE (("JrnlRow"."RowDate">= @stardate AND "JrnlRow"."RowDate" <= @enddate ) OR "JrnlRow"."RowDate" IS NULL ) 
      AND "JrnlRow"."IncludeInGL" = 1 AND "JrnlRow"."Journal" = 9 AND "InventoryCosts"."Recordtype" = 50  
      
      UNION ALL

SELECT 
 "Company"."CompanyName", 
 "Chart"."AccountID" AS AccountNo, 
 "Chart"."AccountDescription" AS AccountName, 
 
 CASE 
     WHEN "Chart"."AccountType" > '19' THEN 'I'
     WHEN "Chart"."AccountType" = '18' THEN 'R'
     ELSE 'B' 
 END AS FSType, 
 CASE "Chart"."AccountType" 
                            WHEN 0 THEN 'Cash' 
                            WHEN 1 THEN 'Accounts Receivable' 
                            WHEN 2 THEN 'Inventory' 
                            WHEN 3 THEN 'Receivable Retainage' 
                            WHEN 4 THEN 'Other Current Assets' 
                            WHEN 5 THEN 'Fixed Assets' 
                            WHEN 6 THEN 'Accumulated Depreciation' 
                            WHEN 8 THEN 'Other Assets' 
                            WHEN 10 THEN 'Accounts Payable' 
                            WHEN 11 THEN 'Payable Retainage' 
                            WHEN 12 THEN 'Other Current Liabilities' 
                            WHEN 14 THEN 'Long Term Liabilities' 
                            WHEN 16 THEN 'Equity-does not close' 
                            WHEN 18 THEN 'Equity-Retained Earnings' 
                            WHEN 19 THEN 'Equity-gets closed' 
                            WHEN 21 THEN 'Income' 
                            WHEN 23 THEN 'Cost of Sales' 
                            WHEN 24 THEN 'Expenses' 
END AS AccTypeDescription, 
"Chart"."AccountType",
CAST('' as VARCHAR(1)) AS Journal, 
CONVERT( @enddate ,SQL_DATE,110) AS TransactionDate, 
CAST(0 AS INT) AS Period, 
CAST('Begin' as VARCHAR(5)) AS Reference, 
CAST('Beginning Balance' as VARCHAR(18)) AS Description, 
CAST('Yes' as VARCHAR(3)) AS Posted,
0 AS NetChange, 
"Chart"."Balance0Net" + ISNULL(BF."BFBal",0) as BeginningBal,
0 AS Debit,
0 AS Credit


FROM ((("Chart"
INNER JOIN "Company"
  ON "Company"."CompanyName" = "Company"."CompanyName")
INNER JOIN "General_GL"
  ON "Company"."CompanyName" = "Company"."CompanyName" AND "General_GL"."AcctgModule" = 4)
LEFT JOIN (SELECT 
                 "Chart"."AccountID" AS AccID, 
                 SUM(ISNULL((CASE
                     WHEN "JrnlRow"."IncludeInGL" = 0  THEN 0 
                     WHEN "JrnlRow"."Rowtype" IN (0,3,4,5,6,10) AND ("InventoryCosts"."RecordType" IS NULL OR "InventoryCosts"."RecordType" IN (10,20,30,40))
                     THEN (CASE WHEN "Chart"."AccountType" = 2 AND ("InventoryCosts"."RecordType" = 40 OR ADJ."RecordType" = 40)
                               THEN ISNULL("InventoryCosts"."TransAmount",0) + ISNULL(ADJ."TransAmount",0)
                             WHEN "Chart"."AccountType" = 23 AND "InventoryCosts"."RecordType" = 40  THEN "InventoryCosts"."TransAmount" * -1
                             ELSE "JrnlRow"."Amount"
                        END)

                    WHEN "JrnlRow"."Rowtype" IN (7,8) THEN "InventoryCosts"."OptQty"
                    WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" = 10 THEN 0
                    WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType" IN (20,40) 
                         THEN "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
                    WHEN "JrnlRow"."Rowtype" NOT IN (0,3,4,5,6,10) AND "InventoryCosts"."RecordType"= 30 
                         THEN "InventoryCosts"."OptAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END)
                    ELSE
                       "InventoryCosts"."TransAmount" * (CASE WHEN "Chart"."AccountType" = 23 THEN -1 ELSE 1 END) 
                           END),0)
                      ) as BFBal


                 FROM (((((("Chart"
                 LEFT JOIN  "JrnlRow"
                  ON "Chart"."GLAcntNumber" = "JrnlRow"."GLAcntNumber")
                 LEFT JOIN "JrnlHdr"
                  ON "JrnlHdr"."PostOrder" = "JrnlRow"."PostOrder" )
                 LEFT JOIN "InventoryCosts"
                  ON "JrnlRow"."itemRecordNumber" = "InventoryCosts"."ItemRecNumber" 
                      AND "Jrnlrow"."RowDate" = "InventoryCosts"."TransDate" 
                      AND "JrnlRow"."PostOrder" = "InventoryCosts"."PostOrderNumber" 
                      AND "JrnlRow"."RowNumber" = "InventoryCosts"."RowNumber"
                      AND "InventoryCosts"."RecordType" <> 50)
                 LEFT JOIN (SELECT IC3."ItemRecNumber"
                                  ,IC3."TransDate"
                                  ,IC3."Journaltype"
                                  ,IC3."RecordType"
                                  ,IC3."PostedFromHere"
                                  ,IC3."TransAmount"
                                  ,IC3."PostOrderNumber"
                            FROM "InventoryCosts" IC3
                            WHERE IC3."RecordType" = 40 AND IC3."Journaltype"=7 AND IC3."PostedFromHere" =1 
                            )ADJ

                 ON "JrnlRow"."ItemRecordNumber" = ADJ."ItemRecNumber" AND "Jrnlrow"."RowDate" = ADJ."TransDate" 
                     AND "JrnlRow"."PostOrder" = ADJ."PostOrderNumber"  AND "JrnlRow"."Journal"= ADJ."JournalType" )

                 INNER JOIN "Company"
                  ON "Company"."CompanyName" = "Company"."CompanyName")
                 INNER JOIN "General_GL"
                  ON "Company"."CompanyName" = "Company"."CompanyName" AND "General_GL"."AcctgModule" = 4)

                WHERE ("JrnlRow"."RowDate">= "General_GL"."Periods1FrmDate" AND "JrnlRow"."RowDate" < @enddate AND "JrnlRow"."IncludeInGL" = 1 
                      AND (CASE WHEN "JrnlRow"."Journal" = 0 
                                THEN (CASE WHEN "JrnlRow"."DateCleared" IS NULL  
                                           THEN 1
                                           ELSE 0
                                        END)
                                ELSE 1
                            END) =1 
                           )
         
                 GROUP BY 
                 "Chart"."AccountID" 
                ) BF
 ON "Chart"."AccountID" = BF."AccID") 

ORDER BY "AccountNo","TransactionDate"