-- Start of DDL Script for Procedure SA.TF001
-- Generated 25/11/2005 11:37:45 from SA@SBANK.131.16

CREATE OR REPLACE 
PROCEDURE tf001 (pFromDate IN DATE,pToDate IN DATE,Trans_Status IN CHAR DEFAULT 'ALL', intOption IN Number,psubbrid IN CHAR,refcurtf001 IN OUT PKG_CR.RefCurType)
AS
   -- khai bao bien
   sts     CHAR(1);
   fdate   DATE;
   tdate   DATE;
   v_deltd char(1);
   v_SubBrID char(3);
BEGIN
   --SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
   IF pFromDate > pToDate
   THEN
      tdate := pFromdate;
      fdate := pTodate;
   ELSE
      tdate := pToDate;
      fdate := pFromDate;
   END IF;

   /*
   IF trim(Trans_Status) = 'ALL' THEN   
      sts := '_';
      v_deltd:='_';
   elsIF trim(Trans_Status) = '1' THEN
      sts := '_';
      v_deltd:='1';
   ELSE
      sts := LTRIM (RTRIM (Trans_Status));
      v_deltd:='_';
   END IF;
   */
   IF trim(Trans_Status) = 'ALL' THEN   
      sts := '_';
      v_deltd:='_';
   elsIF trim(Trans_Status) = '1' THEN
      sts := '_';
      v_deltd:='1';
   ELSE
      sts := LTRIM (RTRIM (Trans_Status));
      v_deltd:='0';
   END IF;
   if INTOPTION=1 then
        v_SubBrID:='___';
    elsif INTOPTION=2 then
        v_SubBrID:=substr(psubbrid,1,2) || '_';
    else
        v_SubBrID:=psubbrid;
    end if;
    

   OPEN refcurtf001 FOR
         SELECT a.wsname, a.txnum, a.txdate, d.custname, a.tltxcd,
                a.char01 AS ourref, b.txdesc AS txdesc,
                DECODE (
                   b.msg_amt,
                   1, a.num01,
                   2, a.num02,
                   3, a.num03,
                   4, a.num04,
                   5, a.num05,
                   6, a.num06,
                   7, a.num07,
                   8, a.num08,
                   9, a.num09,
                   10, a.num10,
                   11, a.num11,
                   12, a.num12,
                   13, a.num13,
                   14, a.num14,
                   15, a.num15,
                   16, a.num16,
                   17, a.num17,
                   18, a.num18,
                   19, a.num19,
                   20, a.num20,
                   0
                ) AS amt,(case when length(c.theirref)> 1 then c.theirref else ' ' End) BankRef,
                case when nvl(deltd,0)=1 then 'Deleted' else
                decode(a.status,
                '0','Unapproved',
                '2','Pending to approval',
                '4','Errors',
                '5','Completed',
                '6','Swift missing'
                ) end as status 
           FROM tllog a, tltxdesc b, tfmast c, cfmast d
          WHERE a.tltxcd = b.tltxcd
            AND a.char01 = c.ourref
            AND c.custid = d.custid
            AND a.tltxcd LIKE '88%'
            AND nvl(trim(a.deltd),'0') LIKE v_deltd
            AND b.txtype <> 'I'
            AND to_date(to_char(a.txdate,'dd/mm/yyyy'),'dd/mm/yyyy') >=to_date(to_char(fdate,'dd/mm/yyyy'),'dd/mm/yyyy') 
            AND to_date(to_char(a.txdate,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date(to_char(tdate,'dd/mm/yyyy'),'dd/mm/yyyy') 
            AND a.wsname NOT LIKE 'TFHOST'
            AND trim(a.status) like sts
            AND SUBSTR (a.txnum, 1, 3) like v_SubBrID
         UNION
         SELECT a.wsname, a.txnum, a.txdate, e.custname, a.tltxcd,
                a.char01 AS ourref, b.txdesc AS txdesc, VALUE AS amt,(case when length(d.theirref)> 1 then d.theirref else ' ' End) BankRef,
                case when nvl(deltd,0)=1 then 'Deleted' else
                decode(a.status,
                '0','Unapproved',
                '2','Pending to approval',
                '4','Errors',
                '5','Completed',
                '6','Swift missing'
                ) end as status
           FROM tllogall a, tltxdesc b, tllogallnum c, tfmast d, cfmast e
          WHERE a.tltxcd = b.tltxcd
            AND b.msg_amt = c.no
            AND a.txnum = c.txnum
            AND a.txdate = c.txdate
            AND a.char01 = d.ourref
            AND d.custid = e.custid
            AND a.tltxcd LIKE '88%'
            AND nvl(trim(a.deltd),'0') LIKE v_deltd
            AND b.txtype <> 'I'
            AND to_date(to_char(a.txdate,'dd/mm/yyyy'),'dd/mm/yyyy') >=to_date(to_char(fdate,'dd/mm/yyyy'),'dd/mm/yyyy') 
            AND to_date(to_char(a.txdate,'dd/mm/yyyy'),'dd/mm/yyyy')<=to_date(to_char(tdate,'dd/mm/yyyy'),'dd/mm/yyyy')
            AND a.wsname NOT LIKE 'TFHOST'
            AND trim(a.status) like sts
            AND SUBSTR (a.txnum, 1, 3) like v_SubBrID;

END ;
/



-- End of DDL Script for Procedure SA.TF001


