-- Start of DDL Script for Procedure SA.TF015
-- Generated 30/11/2005 11:31:37 from SA@SBANK

CREATE OR REPLACE 
PROCEDURE tf015 (AtDate IN DATE, CURRENCY CHAR DEFAULT 'ALL', INTOPTION IN NUMBER,pSubBrID IN CHAR,vTF015RefCurType in out PKG_CR.RefCurType)
   AS
    vSUBBRID varchar2(3);
    TxDate Date;
    V_CURR CHAR(3);
BEGIN
  TxDate:=AtDate;  
  If INTOPTION=1 then
    vSubBrID:='___';    
  Elsif INTOPTION=2 then
    vSubBrID:=SubStr(pSubBrID,1,2) || '_';
  Else
    vSubBrID:=pSubBrID;  
  End if;
  
  IF CURRENCY='ALL' THEN 
    V_CURR:='___';    
  ELSE
    V_CURR:=CURRENCY;  
  END IF;
  
  Open vTF015RefCurType For      
      select Distinct CFmast.custname,tfBill.ourref,SBCURRENCY.ccycd,NVL(BAMT,0) AMOUT,
             decode(bfamt,0,bamt- brl,bfamt-brl) AS Outstanding,
             Bissdt as DateRelease,
             beprdt as DueDate
        from cfmast,tfbill,SBCURRENCY,
             (select unique ourref ,custid,ccycd,lastdate 
              from tfmast 
              where actype = '0520') A
        where Cfmast.custid = A.CustID
        And   tfbill.ourref = A.ourref
        and   SBCURRENCY.shortcd = A.ccycd 
        AND   SBCURRENCY.ccycd LIKE V_CURR
        and   SubSTR(tfBill.ourref,1,3) like vSubBrID
        And   A.Lastdate <= TxDate
        --and decode(bfamt,0,bamt- brl,bfamt-brl)>0
        order by SBCURRENCY.ccycd,CFmast.custname;

END;
/



-- End of DDL Script for Procedure SA.TF015


