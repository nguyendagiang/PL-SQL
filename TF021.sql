-- Start of DDL Script for Procedure SA.TF021
-- Generated 1/12/2005 15:29:02 from SA@SBANK

CREATE OR REPLACE 
PROCEDURE tf021 (AtDate IN DATE,BGITEMS CHAR DEFAULT 'ALL',CURRENCY CHAR DEFAULT 'ALL', INTOPTION IN NUMBER,pSubBrID IN CHAR,vTF021RefCurType in out PKG_CR.RefCurType)
/*Maginal Deposit under Banker's Guarantee*/
--LAST MODIFIED BY GIANGND AT 30/11/2004: LAY SO TIEN KQ THUC TE(DDEMK), DO CHO PHEP KY QUY BANG LOAI TIEN KHAC
--26/09/05: cho phep back date
   AS
    vSUBBRID varchar2(3);
    vTxDate Date;
    V_CURR CHAR(3);
    V_ACTYPE CHAR(4);
    VBUSDATE date;
    
BEGIN
     
  SELECT SBDATE  INTO VBUSDATE FROM SBCLDR WHERE SBBUSDAY = '1';
  
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
  
  IF BGITEMS='ALL' THEN
    V_ACTYPE:='____';
  ELSE
    V_ACTYPE:='_' || BGITEMS;
  END IF;

  if AtDate < VBUSDATE THEN
  vTxDate:=AtDate+1;
  Open vTF021RefCurType For
    select CFmast.custname as Customer, TFMAST.ourref || SBCURRENCY.ccycd as BGNO, decode(trim(amt),null,0,amt)  as Amount,
           MRATE ||'%' as Deposit,'A/C NO:' || DDEMK.ACCTNO  as remark
    From 
    (SELECT REF AS OURREF, SUM(AMT) AMT,acctno 
    FROM DDEMKBOD
    where trim(emktype)='L'
    and TxDate = (select max(txdate) from ddemkbod where txdate<=vTxDate)
    GROUP BY REF,acctno) DDemk 
    LEFT JOIN
    TFmast
    ON DDEMK.OURREF=TFMAST.OURREF
    ,Cfmast, TFTYPE,SBCURRENCY
    where CFmast.custid = TFmast.custid
    AND substr(ddemk.acctno,7,2)=SBCURRENCY.SHORTCD
    AND TFMAST.actype=TFTYPE.actype
    AND TFTYPE.tfgrp='5'    
    and  TFMAST.actype LIKE V_ACTYPE
    AND SBCURRENCY.ccycd LIKE V_CURR
    and Substr(ddemk.ourref,1,3) like vSubBrID
    and amt<>0
    Order by  CFmast.custname;
    
ELSE 
    Open vTF021RefCurType For
    select CFmast.custname as Customer, TFMAST.ourref || SBCURRENCY.ccycd as BGNO, decode(trim(amt),null,0,amt)  as Amount,
           MRATE ||'%' as Deposit,'A/C NO:' || DDEMK.ACCTNO  as remark
    From 
    (SELECT REF AS OURREF, SUM(AMT) AMT,acctno 
    FROM DDEMK
    where trim(emktype)='L'    
    GROUP BY REF,acctno) DDemk 
    LEFT JOIN
    TFmast
    ON DDEMK.OURREF=TFMAST.OURREF
    ,Cfmast, TFTYPE,SBCURRENCY
    where CFmast.custid = TFmast.custid
    AND substr(ddemk.acctno,7,2)=SBCURRENCY.SHORTCD
    AND TFMAST.actype=TFTYPE.actype
    AND TFTYPE.tfgrp='5'    
    and  TFMAST.actype LIKE V_ACTYPE
    AND SBCURRENCY.ccycd LIKE V_CURR
    and Substr(ddemk.ourref,1,3) like vSubBrID
    and amt<>0
    Order by  CFmast.custname; 
END IF;      

END;
/



-- End of DDL Script for Procedure SA.TF021


