SELECT DISTINCT
        @BOFISCALYEAR as StarDate,
        @SYSDATE  as EndDate,
    "LineItem"."CustomField1" 'Brand',
	"Company"."CompanyName" 'Company Name', 
	"LineItem"."ItemID" 'Item ID', 
	IF("LineItem"."ItemDescription" IS NULL, '<Blank>',"LineItem"."ItemDescription") 'Item Description', 
	"LineItem"."ItemID" + ' ' +IF("LineItem"."ItemDescription" IS NULL, '<Blank>',"LineItem"."ItemDescription")'Item ID_Description', 
	"LineItem"."Category" 'Item Type', 
	CASE ISNULL("LineItem"."ItemClass", -1)
		WHEN 0 THEN 'Non-stock item'
		WHEN 1 THEN 'Stock item'
		WHEN 2 THEN 'Description only'
		WHEN 3 THEN 'Assembly'
		WHEN 4 THEN 'Service'
		WHEN 5 THEN 'Labor'
		WHEN 6 THEN 'Activity item'
		WHEN 7 THEN 'Charge item'
		WHEN 8 THEN 'Master Stock item'
		WHEN 9 THEN 'Substock item'
		WHEN 10 THEN 'Serialized Stock item'
		WHEN 11 THEN 'Serialized Assembly'
		ELSE ''
	END 'Item Class', 
	CASE WHEN "LineItem"."ItemIsInactive" = 1 THEN 'Yes' ELSE 'No' END 'Inactive?', 
	CASE 
		WHEN @BOFISCALYEAR  =  ISNULL(General_GL.Periods27FrmDate,DATEADD(year,1,General_GL.Periods15FrmDate)) 
			THEN 
				IFNULL("LineItem"."SalesAmt15",0) 
				+ IFNULL("LineItem"."SalesAmt16",0) 
				+ IFNULL("LineItem"."SalesAmt17",0) 
				+ IFNULL("LineItem"."SalesAmt18",0) 
				+ IFNULL("LineItem"."SalesAmt19",0) 
				+ IFNULL("LineItem"."SalesAmt20",0) 
				+ IFNULL("LineItem"."SalesAmt21",0) 
				+ IFNULL("LineItem"."SalesAmt22",0) 
				+ IFNULL("LineItem"."SalesAmt23",0) 
				+ IFNULL("LineItem"."SalesAmt24",0) 
				+ IFNULL("LineItem"."SalesAmt25",0) 
				+ IFNULL("LineItem"."SalesAmt26",0) 
				+ IFNULL("LineItem"."SalesAmt27",0) 
		ELSE 
			IFNULL("LineItem"."SalesAmt1",0) 
			+ IFNULL("LineItem"."SalesAmt2",0) 
			+ IFNULL("LineItem"."SalesAmt3",0) 
			+ IFNULL("LineItem"."SalesAmt4",0) 
			+ IFNULL("LineItem"."SalesAmt5",0) 
			+ IFNULL("LineItem"."SalesAmt6",0) 
			+ IFNULL("LineItem"."SalesAmt7",0) 
			+ IFNULL("LineItem"."SalesAmt8",0) 
			+ IFNULL("LineItem"."SalesAmt9",0) 
			+ IFNULL("LineItem"."SalesAmt10",0) 
			+ IFNULL("LineItem"."SalesAmt11",0) 
			+ IFNULL("LineItem"."SalesAmt12",0) 
			+ IFNULL("LineItem"."SalesAmt13",0) 
	END 'Amount Sold Prior Year', 
	"Employee"."EmployeeID" 'Buyer ID', 
	"Chart"."AccountID" 'COGS Account', 
	"COGSPRYTD"."CogsPYr" 'Cost Of Goods Sold Prior Year', 
	CASE 
		WHEN "LineItem"."CostMethod" = 0 THEN 'Average'
		WHEN "LineItem"."CostMethod" = 1 THEN 'FIFO'
		WHEN "LineItem"."CostMethod" = 2 THEN 'LIFO'
		WHEN "LineItem"."CostMethod" = 3 THEN 'Specific Unit'
		ELSE ''  
	END 'Costing Method', 
	@BOFISCALYEAR  'Fiscal Year Start Date', 
	DATEADD(year,-1, @BOFISCALYEAR ) 'Fiscal Year Start Date Prior Year', 
	ICacc."AccountID" 'Inventory Account', 
	"LineItem"."CustomField1" 'Item Custom Field 1', 
	"LineItem"."CustomField2" 'Item Custom Field 2', 
	"LineItem"."CustomField3" 'Item Custom Field 3', 
	"LineItem"."CustomField4" 'Item Custom Field 4', 
	"LineItem"."CustomField5" 'Item Custom Field 5', 
	BuyInfo."PurchaseDate" 'Last Purchase Date', 
	CASE 
		WHEN "LineItem"."ItemClass" IN (0,4,5) THEN "LineItem"."LaborCost"
		WHEN "LineItem"."ItemClass" IN (1,3,9,10,11) THEN ISNULL("BuyInfo"."LastUnitCost","LineItem"."LaborCost")
		ELSE 0
	END 'Last Unit Cost', 
	"LineItem"."Location" 'Location', 
	IF("LineItem"."ItemClass" IN (1,3,9,10,11) ,"LineItem"."ReorderPoint", 0) 'Minimum Stock', 
	CASE WHEN @BOFISCALYEAR  =  ISNULL(General_GL.Periods27FrmDate,DATEADD(year,1,General_GL.Periods15FrmDate)) THEN "LineItem"."SalesQty15" + "LineItem"."SalesQty16" + "LineItem"."SalesQty17" + "LineItem"."SalesQty18" + "LineItem"."SalesQty19" + "LineItem"."SalesQty20" + "LineItem"."SalesQty21" + "LineItem"."SalesQty22" + "LineItem"."SalesQty23" + "LineItem"."SalesQty24" + "LineItem"."SalesQty25" + "LineItem"."SalesQty26" + "LineItem"."SalesQty27" ELSE "LineItem"."SalesQty1" + "LineItem"."SalesQty2" + "LineItem"."SalesQty3" + "LineItem"."SalesQty4" + "LineItem"."SalesQty5" + "LineItem"."SalesQty6" + "LineItem"."SalesQty7" + "LineItem"."SalesQty8" + "LineItem"."SalesQty9" + "LineItem"."SalesQty10" + "LineItem"."SalesQty11" + "LineItem"."SalesQty12" + "LineItem"."SalesQty13" END 'No of Units Sold Prior Year', 
	UnitsSoldYtd."StockQty" 'No of Units Sold YTD', 
	"LineItem"."Note" 'Note', 
	"LineItem"."PartNumber" 'Part Number', 
	"Vendors"."VendorID" 'Preferred Vendor', 
	"LineItem"."PriceLevel1Amount"  'Price Level 1', 
	"LineItem"."PriceLevel10Amount" 'Price Level 10', 
	"LineItem"."PriceLevel2Amount" 'Price Level 2', 
	"LineItem"."PriceLevel3Amount" 'Price Level 3', 
	"LineItem"."PriceLevel4Amount" 'Price Level 4', 
	"LineItem"."PriceLevel5Amount" 'Price Level 5', 
	"LineItem"."PriceLevel6Amount" 'Price Level 6', 
	"LineItem"."PriceLevel7Amount" 'Price Level 7', 
	"LineItem"."PriceLevel8Amount" 'Price Level 8', 
	"LineItem"."PriceLevel9Amount" 'Price Level 9', 
	"LineItem"."PurchaseDescription" 'Purchase Description', 
	PUnit."UMID" 'Purchasing U/M', 	"InventoryCosts"."Quantity" 'Qty on Hand', 
        "QTYOHLSTYR"."QtyLastYr" 'Qty on Hand Last Fiscal Year Start', 
	"QTYOHTHISYR"."QtyThisYr" 'Qty on Hand This Fiscal Year Start', 
        ( (IFNULL(QtyOnPOSO.QtyPO, 0) + IFNULL(QtyOnPS.QtyOnPs,0)) - ((IFNULL(QtyOnPOSO.QtySO, 0) + IFNULL(QtyOnPS.QtyOnSs,0)) ) + "InventoryCosts"."Quantity"   ) 'Qty Available',
	
	IFNULL(QtyOnPOSO.QtyPO, 0) 'Quantity on Purchase Orders', 
	IFNULL(QtyOnPOSO.QtySO, 0) 'Quantity on Sales Orders', 
        AmntOnPOSO.AmntSO as 'Amount on Sales Orders',
        AmntOnPOSO.AmntPO as 'Amount on Purchase Orders',
        IFNULL(QtyOnPS.QtyOnPs,0) 'Quantity on Purchases', 
	IFNULL(QtyOnPS.QtyOnSs,0) 'Quantity on Sales',
 "LineItem"."OrderQty" 'Reorder Quantity', 
	SalesAcc."AccountID" 'Sales Account', 
	"LineItem"."SalesDescription" 'Sales Description', 
	SUnit."UMID" 'Sales U/M', 
	"LineItem"."StockingUM" 'Stocking Unit', 
	"LineItem"."UPC_SKU" 'UPC/SKU', 
	"InventoryCosts"."TransAmount" 'Value of Current On Hand Stock Using Last Cost', 
	"InvCostsLastYear"."TransAmount" 'Value of On Hand Stock Last Fiscal Year', 
	"LineItem"."Weight" 'Weight', 
	"YtdSellAmt"."SellAmt" 'YTD Amount Sold', 
	"ThisYTD"."CogsYr" 'YTD Cost Of Goods Sold', 
	"YtdSellAmt"."SellAmt"- "ThisYTD"."CogsYr" 'YTD Gross Profit', 
	"ThisYTD"."BuyQty" 'YTD Quantity Purchased',
	"ICacc"."AccountDescription" AS "Inventory Account Description",
	"Chart"."AccountDescription" AS "COGS Account Description",
	"SalesAcc"."AccountDescription" AS "Sales Account Description",
	IF( "LineItem"."HasCommission" = 1,'Yes', 'No') AS "Subject to Commission",
	"SSPrimaryAttribDesc" AS "Primary Attribute",
	"SSSecondAttribDesc" AS "Secondary Attribute",
	ISNULL("AsmRev"."RevisionNumber",0) AS "Revision",
	"ThisYTD"."AdjustQty" AS "Adjustment Quantity",
	"ThisYTD"."AsmQty" AS "Assembly Quantity",
	SalesAcc."AccountID" 'Sales Account', 
	"LineItem"."SalesDescription" 'Sales Description', 
	SUnit."UMID" 'Sales U/M', 
	"LineItem"."StockingUM" 'Stocking Unit', 
	"LineItem"."UPC_SKU" 'UPC/SKU', 
	"InventoryCosts"."TransAmount" 'Value of Current On Hand Stock Using Last Cost', 
	"InvCostsLastYear"."TransAmount" 'Value of On Hand Stock Last Fiscal Year', 
	"LineItem"."Weight" 'Weight', 
	"YtdSellAmt"."SellAmt" 'YTD Amount Sold', 
	"ThisYTD"."CogsYr" 'YTD Cost Of Goods Sold', 
	"YtdSellAmt"."SellAmt"- "ThisYTD"."CogsYr" 'YTD Gross Profit', 
	"ThisYTD"."BuyQty" 'YTD Quantity Purchased',
	"ICacc"."AccountDescription" AS "Inventory Account Description",
	"Chart"."AccountDescription" AS "COGS Account Description",
	"SalesAcc"."AccountDescription" AS "Sales Account Description",
	IF( "LineItem"."HasCommission" = 1,'Yes', 'No') AS "Subject to Commission",
	"SSPrimaryAttribDesc" AS "Primary Attribute",
	"SSSecondAttribDesc" AS "Secondary Attribute",
	ISNULL("AsmRev"."RevisionNumber",0) AS "Revision",
	"ThisYTD"."AdjustQty" AS "Adjustment Quantity",
	"ThisYTD"."AsmQty" AS "Assembly Quantity",
         PAVG.AMOUMTAVG AS 'PURCHASE AVG'
FROM

	((((((((((((((((((

	"LineItem"
	LEFT JOIN 
		(
		SELECT "IC"."ItemRecNumber","IC"."TransDate","IC"."RecordType", "IC"."Quantity", "IC"."TransAmount"
		FROM "InventoryCosts" IC
		INNER JOIN  
			(
			SELECT "IC1"."ItemRecNumber",MAX("IC1"."TransDate")Transdate 
			FROM "InventoryCosts" IC1 
			WHERE  "IC1"."RecordType" = '50' AND "IC1"."TransDate" <= @SYSDATE 			
			GROUP BY "IC1"."ItemRecNumber"
			) ICMaxDate
		ON "IC"."ItemRecNumber" = "ICMaxDate"."ItemRecNumber" AND "IC"."RecordType" = '50' AND "ICMaxDate"."Transdate"="IC"."TransDate"
		) InventoryCosts
	ON "LineItem"."ItemRecordNumber" = "InventoryCosts"."ItemRecNumber" )
	INNER JOIN "Company" ON "Company"."CompanyName" = "Company"."CompanyName")
	INNER JOIN "General_GL" ON "General_GL"."AcctgModule" = 4)
	LEFT JOIN "UnitMeasure" SUnit ON "LineItem"."SalesUMGuid" = SUnit."UMGUID")
	LEFT JOIN "UnitMeasure" PUnit ON "LineItem"."PurchasingUMGuid" = PUnit."UMGUID")
	LEFT JOIN "Employee" ON "LineItem"."EmpRecordNumber" = "Employee"."EmpRecordNumber")
	LEFT JOIN "Vendors" ON "LineItem"."VendorRecordNumber" = "Vendors"."VendorRecordNumber")
	LEFT JOIN "Chart" ON "LineItem"."COGSAcctRecordNumber" ="Chart"."GLAcntNumber")
	LEFT JOIN "Chart" ICacc ON "LineItem"."InvAcctRecordNumber" = ICacc."GLAcntNumber")
	LEFT JOIN "Chart" SalesAcc ON "LineItem"."SaleAcctRecordNumber" = SalesAcc."GLAcntNumber")
	LEFT JOIN
	(
		SELECT 
			"BuyInfoMaxDate"."ItemRecNumber", 
			IF(ISNULL(BuyInfoInvCost."Quantity",0)=0, 0, CAST(BuyInfoInvCost."TransAmount" AS DOUBLE)/BuyInfoInvCost."Quantity") AS LastUnitCost,
			"BuyInfoInvCost"."TransDate" AS PurchaseDate
		FROM 
			(
			SELECT "ItemRecNumber", MAX("TransDate") AS MaxTransDate
			FROM "InventoryCosts"
			WHERE "RecordType" = 10 AND "Quantity" <> 0 AND "TransDate" <= @SYSDATE 
			GROUP BY "ItemRecNumber"
		) BuyInfoMaxDate
		INNER JOIN 
			(
			SELECT "IC8"."ItemRecNumber", "IC8"."TransDate", MAX("IC8"."PostOrderNumber") AS MaxPostOrderNumber
			FROM "InventoryCosts" IC8
			WHERE "IC8"."RecordType" = 10 AND "IC8"."Quantity" <> 0
			GROUP BY "IC8"."ItemRecNumber", "IC8"."TransDate"
			) BuyInfoTrx 
		ON 
			"BuyInfoMaxDate"."ItemRecNumber" = "BuyInfoTrx"."ItemRecNumber" 
			AND "BuyInfoMaxDate"."MaxTransDate" = "BuyInfoTrx"."TransDate"
		INNER JOIN 
			(
			SELECT "IC9"."ItemRecNumber", "IC9"."TransDate", "IC9"."PostOrderNumber", MAX("IC9".RowNumber) MaxRowNumber
			FROM "InventoryCosts" IC9
			WHERE "IC9"."RecordType" = 10 AND "IC9"."Quantity" <> 0
			GROUP BY "IC9"."ItemRecNumber", "IC9"."TransDate", "IC9"."PostOrderNumber"
			) BuyInfoTrxLine 
		ON 
			"BuyInfoTrxLine"."ItemRecNumber" = "BuyInfoTrx"."ItemRecNumber" 
			AND "BuyInfoTrxLine"."TransDate" = "BuyInfoTrx"."TransDate"
			AND "BuyInfoTrxLine"."PostOrderNumber" = "BuyInfoTrx"."MaxPostOrderNumber"				
		INNER JOIN "InventoryCosts" BuyInfoInvCost
		ON BuyInfoInvCost."RecordType" = 10 
			AND BuyInfoInvCost."ItemRecNumber" = "BuyInfoTrxLine"."ItemRecNumber" 
			AND BuyInfoInvCost."TransDate" = "BuyInfoTrxLine"."TransDate" 
			AND BuyInfoInvCost."PostOrderNumber" = "BuyInfoTrxLine"."PostOrderNumber"
			AND BuyInfoInvCost."RowNumber" = "BuyInfoTrxLine"."MaxRowNumber"
	) BuyInfo
	ON "BuyInfo"."ItemRecNumber" = "LineItem"."ItemRecordNumber" AND "LineItem"."ItemClass" IN (1,3,9,10,11)
	)
	LEFT JOIN 
		(
		SELECT SUM("JrnlRow"."StockingQuantity") StockQty,"JrnlRow"."ItemRecordNumber"
		FROM 
			 "JrnlHdr"
			Left JOIN "JrnlRow"
			ON "JrnlRow"."PostOrder" = "JrnlHdr"."PostOrder"  AND "JrnlRow"."RowType" = 0
		WHERE 
			"JrnlHdr"."JrnlKey_Partner" = 0 
			AND "JrnlHdr"."JrnlKey_Shadow" = 0 
			AND "JrnlHdr"."IsBegBal" = 0 
			AND "JrnlHdr"."JournalEx" IN (3,8,9,10)
			AND "JrnlHdr"."TransactionDate" >= @BOFISCALYEAR 
			AND "JrnlHdr"."TransactionDate" <= @SYSDATE 
		GROUP BY "JrnlRow"."ItemRecordNumber" 
		) UnitsSoldYtd
	ON "LineItem"."ItemRecordNumber" = "UnitsSoldYtd"."ItemRecordNumber")
	LEFT JOIN 
		(
		SELECT "IC4"."ItemRecNumber","IC4"."TransDate","IC4"."RecordType", "IC4"."Quantity" QtyLastYr
        FROM "InventoryCosts" IC4
        INNER JOIN  (SELECT "IC5"."ItemRecNumber",MAX("IC5"."TransDate")Transdate2 
        FROM "InventoryCosts" IC5 
        WHERE  "IC5"."RecordType" = '50'  AND "IC5"."TransDate" <  DATEADD(year,-1, @BOFISCALYEAR )
        GROUP BY "IC5"."ItemRecNumber")ICMaxDate2
        ON "IC4"."ItemRecNumber" = "ICMaxDate2"."ItemRecNumber" 
			AND "IC4"."RecordType" = '50' 
			AND "ICMaxDate2"."Transdate2"="IC4"."TransDate"
		) QTYOHLSTYR
	ON "LineItem"."ItemRecordNumber" = "QTYOHLSTYR"."ItemRecNumber" )

	LEFT JOIN 
		(
		SELECT "IC3"."ItemRecNumber","IC3"."TransDate","IC3"."RecordType", "IC3"."Quantity" QtyThisYr
        FROM "InventoryCosts" IC3
        INNER JOIN  (SELECT "IC2"."ItemRecNumber",MAX("IC2"."TransDate")Transdate1 
        FROM 
			"InventoryCosts" IC2 
        WHERE  
			"IC2"."RecordType" = '50'  AND "IC2"."TransDate" <  @BOFISCALYEAR 
        GROUP BY 
			"IC2"."ItemRecNumber")ICMaxDate1
        ON 
			"IC3"."ItemRecNumber" = "ICMaxDate1"."ItemRecNumber" 
			AND "IC3"."RecordType" = '50' 
			AND "ICMaxDate1"."Transdate1"="IC3"."TransDate"
		) QTYOHTHISYR
	ON "LineItem"."ItemRecordNumber" = "QTYOHTHISYR"."ItemRecNumber" )
	LEFT JOIN 
		(
		SELECT 
			"ROW"."ItemRecordNumber", 
			SUM( 
				IF (
					Journal = 10, 
					IFNULL("ROW"."StockingQuantity",0) - IFNULL("ROW"."StockingQtyReceived",0), 
					0
				)
			) QtyPO,
			SUM( 
				IF (
					Journal = 11, 
					IFNULL("ROW"."StockingQuantity",0) - IFNULL("ROW"."StockingQtyReceived",0), 
					0
				)
			) QtySO 
		FROM ( 
			"JrnlRow" ROW
			INNER JOIN "JrnlHdr" HDR
			ON "ROW"."PostOrder" = "HDR"."PostOrder" )
		WHERE 
			"HDR"."TrxIsPosted" = 1 
			AND ("HDR"."JournalEx" != 20 OR "HDR"."ProposalAccepted" = 1) 
			AND "HDR"."POSOIsClosed" = 0 
			AND "ROW"."Journal" in  (10 ,11)
			AND "ROW"."RowDate" <= @SYSDATE 
		GROUP BY "ROW"."ItemRecordNumber") QtyOnPOSO
	ON "LineItem"."ItemRecordNumber" = "QtyOnPOSO"."ItemRecordNumber")
	LEFT JOIN (
		SELECT
			ROW.ItemRecordNumber,
			SUM(IF (Journal = 4, StockingQuantity, 0)) as QtyOnPs,
			SUM(IF (Journal = 3, StockingQuantity, 0)) as QtyOnSs    		
		FROM
			JrnlRow ROW
			INNER JOIN JrnlHdr HDR
			ON ROW.PostOrder = HDR.PostOrder
			
					WHERE
			HDR.TrxIsPosted=1 AND (HDR.JournalEx IN (8, 10, 11))
			AND HDR.POSOIsClosed = 0 
			AND ROW.Journal IN (3, 4) AND ROW.RowType = 0 
			AND ROW.RowDate > @SYSDATE 
	   		GROUP BY
			ROW.ItemRecordNumber	
	) QtyOnPS
	ON LineItem.ItemRecordNumber = QtyOnPS.ItemRecordNumber
	
	LEFT JOIN 
		(
		SELECT "ITEMROWS2"."ItemRecordNumber",-SUM("ITEMROWS2"."Amount") SellAmt
		FROM "JrnlHdr" HDR4
		LEFT JOIN "JrnlRow" ITEMROWS2
		ON 
			"ITEMROWS2"."PostOrder" = "HDR4"."PostOrder" 
			AND "ITEMROWS2"."RowType"=0
		WHERE 
			"HDR4"."JrnlKey_Partner" = 0 
			AND "HDR4"."JrnlKey_Shadow" = 0 
			AND "HDR4"."IsBegBal" = 0
			AND "HDR4"."JournalEx" IN (3,8,9,10)
			AND "HDR4"."TransactionDate" >= @BOFISCALYEAR  
			AND "HDR4"."TransactionDate" <= @SYSDATE 
		GROUP BY "ITEMROWS2"."ItemRecordNumber" 
		) YTDSELLAMT
	ON "LineItem"."ItemRecordNumber" = "YTDSELLAMT"."ItemRecordNumber")
	
	LEFT JOIN 
		(
		SELECT "IC6"."ItemRecNumber",
		IFNULL( 
			-SUM(
				IF(
					"IC6"."JournalType" in (1,3),
					CAST("IC6"."TransAmount" AS DOUBLE) - IF("IC6"."Recordtype" = 30,"IC6"."OptAmount", 0), 
					0
				)
			),
			0
		) COGSYR,
		IFNULL( 
			SUM(IF("IC6"."JournalType" IN (2,4), CAST("IC6"."Quantity" AS DOUBLE), 0)),
			0
		) BuyQty,				
		IFNULL( 
			SUM(IF("IC6"."JournalType" =7, CAST("IC6"."Quantity" AS DOUBLE), 0)),
			0
		) AdjustQty,
		IFNULL( 
			SUM(IF("IC6"."JournalType" =8, CAST("IC6"."Quantity" AS DOUBLE), 0)),
			0
		) AsmQty
        FROM InventoryCosts IC6
        WHERE "IC6"."TransDate" >= @BOFISCALYEAR  AND "IC6"."TransDate" <= @SYSDATE 
        GROUP BY   "IC6"."ItemRecNumber" 
		) ThisYTD
	ON "LineItem"."ItemRecordNumber" = "ThisYTD"."ItemRecNumber")
	LEFT JOIN (
		SELECT "IC7"."ItemRecNumber",
		IFNULL(-SUM(CAST("IC7"."TransAmount" AS DOUBLE) - IF("IC7"."Recordtype" = 30,"IC7"."OptAmount", 0)),0) COGSPYR
        FROM InventoryCosts IC7
        WHERE "IC7"."JournalType" in (1,3)  AND "IC7"."TransDate" >= DATEADD(YEAR,-1,@BOFISCALYEAR )
		AND "IC7"."TransDate" <= DATEADD(DAY,-1,@BOFISCALYEAR )
        GROUP BY   "IC7"."ItemRecNumber" )COGSPRYTD
	ON "LineItem"."ItemRecordNumber" = "COGSPRYTD"."ItemRecNumber")
	
	LEFT JOIN 
		(
		SELECT "IC"."ItemRecNumber","IC"."TransDate","IC"."RecordType", "IC"."Quantity", "IC"."TransAmount"
		FROM "InventoryCosts" IC
		INNER JOIN  
			(
			SELECT "IC1"."ItemRecNumber",MAX("IC1"."TransDate")Transdate 
			FROM "InventoryCosts" IC1 
			WHERE  "IC1"."RecordType" = '50' AND "IC1"."TransDate" < DATEADD(year,-1,@BOFISCALYEAR )		
			GROUP BY "IC1"."ItemRecNumber"
			) ICMaxDate
		ON "IC"."ItemRecNumber" = "ICMaxDate"."ItemRecNumber" AND "IC"."RecordType" = '50' AND "ICMaxDate"."Transdate"="IC"."TransDate"
		) InvCostsLastYear
	ON "LineItem"."ItemRecordNumber" = "InvCostsLastYear"."ItemRecNumber"
	
	LEFT JOIN 
		(
			SELECT 
				"AssemblyRecordNo" AS "ItemRecordNumber", 
				MAX("RevisionNumber") AS "RevisionNumber" 
			FROM "BOMHist"
			GROUP BY AssemblyRecordNo
		) "AsmRev"
	ON "AsmRev"."ItemRecordNumber" = "LineItem"."ItemRecordNumber"

     LEFT JOIN 
		(SELECT 
			"ROW"."ItemRecordNumber", 
			SUM( 
				IF (
					Journal = 10, 
					IFNULL("ROW"."Amount",0) , 
					0
				)
			) AmntPO,
			SUM( 
				IF (
					Journal = 11, 
					IFNULL("ROW"."Amount",0), 
					0
				)
			) AmntSO 
		FROM ( 
			"JrnlRow" ROW
			INNER JOIN "JrnlHdr" HDR
			ON "ROW"."PostOrder" = "HDR"."PostOrder" )
		WHERE 
			"HDR"."TrxIsPosted" = 1 
			AND ("HDR"."JournalEx" != 20 OR "HDR"."ProposalAccepted" = 1) 
			AND "HDR"."POSOIsClosed" = 0 
			AND "ROW"."Journal" in  (10 ,11)
			AND "ROW"."RowDate" <= @SYSDATE 
		GROUP BY "ROW"."ItemRecordNumber") AmntOnPOSO
	ON "LineItem"."ItemRecordNumber" = "AmntOnPOSO"."ItemRecordNumber"
LEFT JOIN ( SELECT itemRecNumber , (sum(TransAmount)/ sum(Quantity)) AS 'AMOUMTAVG'
			FROM "InventoryCosts"
			WHERE "RecordType" = 10 AND "Quantity" <> 0 AND "TransDate" between @BOFISCALYEAR and  @SYSDATE 
			group by itemRecNumber ) PAVG ON PAVG.itemRecNumber = "LineItem"."ItemRecordNumber" 

WHERE 1 = 1

ORDER BY "LineItem"."ItemID"