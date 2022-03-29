-- Start of DDL Script for Procedure SA.GL015
-- Generated 30/11/2005 11:45:39 AM from SA@SBANK_THUYTTD

CREATE OR REPLACE 
PROCEDURE gl015(pFromDate date,pToDate date,CURRENCY IN VARCHAR2,INTOPTION IN NUMBER, pSubBrID IN VARCHAR2, GL_CUR IN OUT PKG_CR.REFCURTYPE)
AS
   vSUBBRID varchar2(3);
   vCURRENCY Varchar2(3);
   vBusdate Date;
   vratebcy number;
   vratelcy number;
   UsdToVND number;
   MYRTOVND number;
   vOndate date;

BEGIN
  if INTOPTION=1 then
    vSubBrID:='___';
  elsif INTOPTION=2 then
    vSubBrID:=SubStr(pSubBrID,1,2) || '_';
  else
    vSubBrID:=pSubBrID;
  end if;
  if Length(CURRENCY)<3 or trim(CURRENCY) = 'ALL'then
    vCURRENCY:='___';
  elsif Length(CURRENCY)>3 then
    vCURRENCY:=SUBSTR(CURRENCY,1,3);
  else
    vCURRENCY:=CURRENCY;
  end if;
  vOndate := last_day(pToDate);
--  lay ti gia quy doi

     select ratelcy into UsdToVND
        From
            (select sbfxrtmnt.ccycd,max(edate) edate
            from sbfxrtmnt , sbcurrency
            where ratenum = 1  and To_date(To_char(edate,'DD/MM/YYYY'),'DD/MM/YYYY') <= vOndate--To_date(To_char(vOndate,'DD/MM/YYYY'),'DD/MM/YYYY')
            and sbfxrtmnt.ccycd = sbcurrency.shortcd and sbcurrency.ccycd like 'USD'
            group by sbfxrtmnt.ccycd) A,
            sbfxrtmnt B
        where A.ccycd = B.ccycd
        and   A.edate = b.edate;

    select ratelcy into MYRTOVND
        From
            (select sbfxrtmnt.ccycd,max(edate) edate
            from sbfxrtmnt , sbcurrency
            where ratenum = 1  and To_date(To_char(edate,'DD/MM/YYYY'),'DD/MM/YYYY') <= vOndate--To_date(To_char(vOndate,'DD/MM/YYYY'),'DD/MM/YYYY')
            and sbfxrtmnt.ccycd = sbcurrency.shortcd and sbcurrency.ccycd like 'MYR'
            group by sbfxrtmnt.ccycd) A,
            sbfxrtmnt B
        where A.ccycd = B.ccycd
        and   A.edate = b.edate;
    open GL_CUR for
        select TRANSTYPE,CUSTNAME,lngrp, round(sum(VND),0) VND, round(sum(USD),2) USD, Round(sum(MYR),2) MYR
        From
        (
        select (case when FIELD = 'RLSAMT' then 'Release/Utilisation' else'Redemption/Repayment' end) TRANSTYPE,
                CUSTNAME,a.lngrp,(C.AMT*F.ratelcy) VND,(C.AMT*F.ratelcy/UsdToVND) USD,(C.AMT*F.ratelcy/MYRTOVND) MYR
        FROM LNMAST A,
               LNTRANA C,
               (select * from LNTX where UPPER(FIELD) in ('RLSAMT','PRINPAID')) D,
               CFMAST E,
               (select  A.ccycd,B.ratelcy
                From
                    (select sbfxrtmnt.ccycd,max(edate) edate
                    from sbfxrtmnt , sbcurrency
                    where ratenum = 1  and To_date(To_char(edate,'DD/MM/YYYY'),'DD/MM/YYYY') <= To_date(To_char(vOndate,'DD/MM/YYYY'),'DD/MM/YYYY')
                    and sbfxrtmnt.ccycd = sbcurrency.shortcd
                    group by sbfxrtmnt.ccycd) A,
                    sbfxrtmnt B
                where A.ccycd = B.ccycd
                and   A.edate = b.edate) F,sbcurrency G
        WHERE D.TXCD = C.TXCD
            AND A.ACCTNO = C.ACCTNO  and substr(A.ACCTNO,1,3) like vSubBrID
            AND A.CUSTID = E.CUSTID  and nvl(c.deltd,0) <> 1
            AND to_date(TO_CHAR(C.TXDATE,'dd/MM/YYYY'),'dd/MM/YYYY') between to_date(TO_CHAR(pFromDate,'dd/MM/YYYY'),'dd/MM/YYYY') and to_date(TO_CHAR(pToDate,'dd/MM/YYYY'),'dd/MM/YYYY')
            and A.ccycd = F.ccycd and A.ccycd = G.shortcd
            and G.ccycd like vCURRENCY
        ) L
        group by TRANSTYPE,CUSTNAME,lngrp
        order by TRANSTYPE,lngrp,CUSTNAME;



 END;
/



-- End of DDL Script for Procedure SA.GL015

