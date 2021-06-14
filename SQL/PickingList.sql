SELECT DISTINCT
                                    A.Reference as InvoiceNo,
                                    A.TransactionDate as InvoiceDate,
                                    C.CustomerID as IdCustomer,
                                    C.Customer_Bill_Name as BillTo,
                                    
                                    D.ItemID,
                                    D.UPC_SKU,
                                    D.SalesDescription,
                                    D.Weight,
                                    B.Amount,
B.Quantity,
CASE B.SalesTaxType WHEN 0 THEN ((B.Quantity * B.UnitCost) * (T.Rate/100)) 
ELSE 0
END AS Tax ,
B.SalesTaxType ,
                                    D.StockingUM as Unit,
                                    E.JobDescription,
                                    F.PhaseDescription,
                                    G.EmployeeID,
                                    G.EmployeeName,
                                    C.Customer_Type,
                                    D.CustomField1,
                                    D.CustomField2,
                                    D.customField3,
                                    D.CustomField4,
                                    D.CustomField5,
                                    (SELECT CompanyName FROM company) as Company,
                                    (SELECT DBN FROM company) as Database,
                                     B.RowDescription,
                                    B.UnitCost as UnitPrice,
                                    A.SalesTaxCode
                                     FROM JrnlHdr A
                                     INNER JOIN JrnlRow B ON A.PostOrder = B.PostOrder
                                     LEFT JOIN Jobs E ON E.JobRecordNumber = B.JobRecordNumber
                                     LEFT JOIN Phase F ON F.PhaseRecordNumber = B.PhaseRecordNumber
                                     LEFT JOIN Employee G on G.EmpRecordNumber = A.EmpRecordNumber
                                     INNER JOIN Customers C ON C.CustomerRecordNumber = B.CustomerRecordNumber
                                     INNER JOIN LineItem D ON D.ItemRecordNumber = B.ItemRecordNumber
LEFT JOIN (select TC.ID, SUM(Rate1) AS Rate
from Tax_Authority TA 
Left join  Tax_Code TC  ON TA.ID = TC.TaxAuthority1 or TA.ID = TC.TaxAuthority2 or TA.ID = TC.TaxAuthority3
GROUP BY TC.ID ) T on T.ID= A.SalesTaxCode

                                     WHERE A.JrnlKey_Journal in  ('3')
                                     AND B.RowType = '0'
                                     AND A.TransactionDate between @stardate and @enddate
                                     Order by A.Reference , B.RowNumber