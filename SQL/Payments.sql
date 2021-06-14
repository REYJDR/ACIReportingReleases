SELECT
C.AccountType ,
jh.CustVendId as VendorID,
jh.Reference as CheckNo, 
jh.TransactionDate as Date,
jh.JrnlKey_Per as Period,
jr.Amount as AmountPaid,
V.Name,
jr2.invoice as Reference,
jr2.Amount as DetailAmount,
jr2.AccountID,
jr2.AccountDescription,
jr2.RowDescription, 
CASE jr2.AccountType 
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
CASE WHEN jr2.Journal = 0 THEN 'GEN'
    WHEN jr2.Journal = 1 THEN 'CRJ'
    WHEN jr2.Journal = 2 THEN 'CDJ'
    WHEN jr2.Journal = 3 THEN 'SJ'
    WHEN jr2.Journal = 4 THEN 'PJ'
    WHEN jr2.Journal = 5 THEN 'PRJ'
    WHEN jr2.Journal = 6 THEN 'COG'
    WHEN jr2.Journal = 7 THEN 'INAJ'
    WHEN jr2.Journal = 8 THEN 'ASB'
    WHEN jr2.Journal = 9 THEN 'IN'
    WHEN jr2.Journal = 10 THEN 'PO'
    WHEN jr2.Journal = 11 THEN 'SO'
    WHEN jr2.Journal = 12 THEN 'QUO'
ELSE '' END as Jrnl
FROM jrnlRow jr 
INNER JOIN JrnlHdr jh on jr.PostOrder = jh.PostOrder 
LEFT JOIN Vendors V  on jh.CustVendId = V.VendorRecordNumber
LEFT JOIN Chart C ON jr.GLAcntNumber = C.GLAcntNumber
LEFT JOIN (select 
            jr.Journal, 
            jr.PostOrder ,
            jh.Reference as invoice, 
            jh.TransactionDate as Date,
            jr.Amount,
            jr.LinkToAnotherTrx,
            jr.InvNumForThisTrx,
            jr.RowDescription,
            C.AccountID,
            C.AccountDescription,
            C.AccountType 
            FROM JrnlRow jr
            INNER JOIN JrnlHdr jh on jr.PostOrder = jh.PostOrder 
            INNER JOIN Chart c on c.GLAcntNumber = jr.GLAcntNumber where jr.RowType = 0  and jr.Journal IN (2,4)  ) jr2 on jr2.PostOrder = jr.LinkToAnotherTrx

WHERE jr.Journal IN (2,4) and jh.TransactionDate between @stardate and @enddate  and jr.LinkToAnotherTrx <> '' AND C.AccountType <> '0' 
