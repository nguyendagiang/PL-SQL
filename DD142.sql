-- Start of DDL Script for Procedure SA.DD142
-- Generated 30/11/2005 03:22:46 PM from SA@SBANK

CREATE OR REPLACE 
PROCEDURE dd142 (FromDate IN Date, pToDate IN Date, pFromCust IN CHAR default '0000000000',pToCust IN  CHAR default '9999999999', pFromAcc IN CHAR default '0000000000000',pToAcc IN  CHAR default '9999999999999',Message CHAR DEFAULT 'EXCELLENCE IS OUR COMMITMENT',intOPTION IN number,pSUBBRID IN CHAR, RefCurdd142 IN OUT PKG_CR.RefCurType)
   
IS
--LAST MODIFIED: 10/05/2004
--11/07/05:giangnd: ko kiem tra custid phai thuoc branch
/*30/11/2005:giangnd them dk DORC. Warning: co the sai neu hoan thue cho khach hang tu tk GL*/
  vSubBrID varchar2(3);
  vFromDate Date;
  vToDate Date;
  vFromCust Char(10);
  vToCust Char(10);
  vFromAcc Char(13);
  vToAcc Char(13);
  VBUSDATE Date;
  VTMPDATE Date;
  VODDATE Date;
  strSQL varchar2(5000);
  vODSTS char(3);
BEGIN  
  if FromDate > pToDate then
    vFromDate:= pToDate;
    vToDate:=FromDate;
  else
    vFromDate:= FromDate;
    vToDate:=pToDate;  
  end if;  

  vFromCust:=replace(trim(pFromCust),'-','');
  vToCust:=replace(trim(pToCust),'-','');
  vFromAcc:=replace(trim(pFromAcc),'-','');
  vToAcc:=replace(trim(pToAcc),'-','');  
  
if intOption = 1 then
  vSubbrID:='___';
  if pFromCust='' then
     vFromCust:= '0000000000' ;
     vFromAcc:=  '0000000000000';
  end if;
  if pToCust = '' then
     vToCust:= '9999999999';
     vToAcc:=  '9999999999999';
  end if;
elsif intOption = 2 then
  vSubbrID:= Substr(pSubbrid,1,2)||'_';
  if pFromCust='' then
     vFromCust:= Substr(pSubbrid,1,2)||'000000000' ;
     vFromAcc:=  Substr(pSubbrid,1,2)||'000000000000' ;
  end if;
  if pToCust = '' then
     vToCust:= Substr(pSubbrid,1,2)||'999999999';
     vToAcc:=  Substr(pSubbrid,1,2)||'999999999999';
  end if;
else
  vSubbrID:=Substr(pSubbrid,1,3);
  if pFromCust='' then
     vFromCust:= pSubbrid||'00000000' ;
     vFromAcc:=  pSubbrid||'00000000000' ;
  end if; 
  if pToCust = '' then
     vToCust:= pSubbrid||'99999999';
     vToAcc:=  pSubbrid||'99999999999';
  end if;
end if;
--Them bien vtmpdate de xet truong hop vtodate < vbusdate
  SELECT SBDATE  INTO VBUSDATE FROM SBCLDR WHERE SBBUSDAY = '1';
  if VTODATE < VBUSDATE THEN
     VTMPDATE:=VBUSDATE;
  ELSE 
     VTMPDATE:=VTODATE;   
  --Them ngay 07/04/2004
  END IF;
  if vFromAcc=vToAcc then
        select odsts into vodsts from ddallmast where trim(acctno) = vfromacc;
        select nvl(max(txdate),'01/01/1900') into VODDATE from ddmastbod 
        where txdate between vfromdate and vtmpdate and trim(acctno)=vfromacc and odsts='A'; 
  end if;
  
  --Lam rieng cho truong hop OD 
--if trim(vodsts)='A' then
if VODDATE>=vfromdate and VODDATE<=vtmpdate then 
execute immediate ('Truncate table tmp_dd014');
   strsql:='insert into tmp_dd014
     SELECT A11.TXNO,A11.TXDATE,A22.ACCTNO,A1.AMT,''D'' AS DORC,A22.REF AS CHQNO FROM
     (select txdate,txno,sum(amt) as amt from gltrana where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND substr(acctno,4,1) = ''7''
     and NVL(DELTD,''0'') <> ''1''
     and dorc = ''C''
     group by txdate,txno
     UNION ALL
     select txdate,txno,amt from gltrana where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND ACCTNO like ''%45311%00007''
     and NVL(DELTD,''0'') <> ''1''
     and dorc = ''C''
     UNION ALL
     select txdate,txno,sum(amt)as amt from gltelt where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(acctno,4,1) = ''7''
     and NVL(DELTD,''0'') <> ''1''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     group by txdate,txno,substr(acctno,4,1)
     UNION ALL
     select txdate,txno,AMT from gltelt where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO like ''%45311%00007''
     and NVL(DELTD,''0'') <> ''1''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     )A1,
     (select txno,txdate from
     (SELECT TXNO,TXDATE FROM GLTRANA  WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO LIKE ''%45311%00007''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     union all
     SELECT TXNO,TXDATE FROM GLTRANA  WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(ACCTNO,4,1) = ''7''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     UNION ALL
     SELECT TXNO,TXDATE FROM GLTELT WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO LIKE ''%45311%00007''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     UNION ALL
     SELECT TXNO,TXDATE FROM GLTELT WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(ACCTNO,4,1) = ''7''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     ) group by txno,txdate
     having count(txno) >1
     )A11,
     (SELECT DISTINCT TXDATE,TXNO,ACCTNO,REF FROM DDALLTRAN,DDTX WHERE  TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND ACCTNO between '''||VFROMACC||''' AND '''||vToACC||'''
     AND DDALLTRAN.TXCD = DDTX.TXCD AND DDTX.FIELD = ''BALANCE'' and ddtx.dorc=''D'' 
     ) A22
     WHERE A1.TXDATE = A11.TXDATE AND A1.TXNO = A11.TXNO
     AND A1.TXDATE = A22.TXDATE AND A1.TXNO = A22.TXNO';

 execute immediate strSQL;
 --Tao Table tmp1_dd014 de lay du lieu ra thay vi lay ddalltran  
 --tmp1_dd014 la hop cua tmp_dd014 va ddalltran
 --Lay cac giao dich 5548 khong phai la tu dong
  --13/04/2005:giangnd lay them No.15 trong tllogallnum
  --16/11/05:giangnd: giao dich tra goc lai cho TK OD chi lay phan lai
 execute immediate ('Truncate table tmp1_dd014');
 execute immediate ('insert into tmp1_dd014
 SELECT A1.TXNO,A1.TXDATE,A1.ACCTNO,
 (CASE WHEN TRIM(DDTX.DORC) = ''D''THEN AMT-NVL(TOTALFEE,0) ELSE AMT+NVL(TOTALFEE,0) END) AMT,
 DDTX.DORC, A1.REF AS CHQNO  from 
 (SELECT acctno,amt,txdate,txno,ref,txcd FROM DDALLTRAN where  TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and acctno between '''||VFROMACC||''' AND '''||vToACC||'''
     AND SUBSTR(TRIM(TXNO),1,4) <> ''5548'' and substr(trim(txno),1,4) <> ''5502''
     and (txdate,txno) not in (select txdate,txnum from tllogall 
     where tltxcd like ''554%'' and  substr(trim(txnum),1,3) not like ''554%''  
     and trim(char01) in (select trim(acctno) from lnmast where lngrp=''OD''))
     
  union all  
  
  select A.acctno,B.amt,A.txdate,A.txno,A.ref,A.txcd from
	(select * from ddalltran where 
	TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and acctno between '''||VFROMACC||''' AND '''||vToACC||'''
	and trim(acctno) in 
	(select trim(acctno) from ddallmast where acctno between '''||VFROMACC||''' AND '''||vToACC||''' and substr(acctno,1,3) like '''||vsubbrid||''')
	and txno like ''5548%''
    and (txdate,txno) not in (select txdate,txnum from tllogall 
    where TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
	and tltxcd=''5548'' and trim(status) like ''D%'' ))A,
	(select sum(value) as amt,txdate,txnum from tllogallnum where 
	TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
	and txnum like ''5548%'' and no in (11,12,13,14,15) and value > 0 
    group by txdate,txnum)B
	where A.txdate = B.txdate and trim(A.txno) = trim(B.txnum)
    
    union all  
    select A.acctno,B.amt,A.txdate,A.txno,A.ref,A.txcd from
	(select * from ddalltran where acctno between '''||VFROMACC||''' AND '''||vToACC||'''
    and (txdate,txno) in (select txdate,txnum from tllogall 
    where TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
	and tltxcd like ''554%'' and  substr(trim(txno),1,3) not like ''554%''  
    and trim(char01) in (select trim(acctno) from lnmast where lngrp=''OD''))
    )A,
	(select sum(value) as amt,txdate,txnum from tllogallnum where 
	(txdate,txnum) in (select txdate,txnum from tllogall 
    where TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
    and TXDATE <= to_date('''|| to_char(VODDATE,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
	and tltxcd like ''554%'' and  substr(trim(txnum),1,3) not like ''554%''  
    and trim(char01) in (select trim(acctno) from lnmast where lngrp=''OD'')) 
    and no=10 and value > 0 
    group by txdate,txnum)B
	where A.txdate = B.txdate and trim(A.txno) = trim(B.txnum)  
     )A1
 left join
 (select txno,txdate,acctno,sum(AMT) TOTALFEE from tmp_dd014 group by txdate,txno,acctno)A2
 ON A1.TXNO = A2.TXNO AND A1.TXDATE = A2.TXDATE
 INNER JOIN (SELECT ACCTNO,STATUS,ODSTS FROM DDALLMAST WHERE SUBSTR(ACCTNO,1,3) LIKE '''||vsubbrid||''' AND acctno between '''||VFROMACC||''' AND '''||vToACC||''') OD
 	ON TRIM(A1.ACCTNO) = TRIM(OD.ACCTNO)
 INNER JOIN DDTX ON A1.TXCD = DDTX.TXCD AND TRIM(DDTX.FIELD) = ''BALANCE''
 AND AMT-NVL(TOTALFEE,0) <> 0 ');
 
 execute immediate ('insert into tmp1_dd014
 SELECT TXNO,TXDATE,ACCTNO,AMT,DORC,CHQNO FROM
( SELECT A1.TXNO,A1.TXDATE,A1.ACCTNO,
 (CASE WHEN TRIM(A1.DORC) = ''D''THEN AMT-NVL(TOTALFEE,0) ELSE AMT+NVL(TOTALFEE,0) END) AMT,
 DORC, A1.REF AS CHQNO  from 
 (       
     SELECT SUM(AMT) as AMT,ACCTNO,TXDATE,TXNO,REF,dorc FROM DDALLTRAN,DDTX where  TXDATE > to_date('''|| to_char(voddate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and acctno between '''||VFROMACC||''' AND '''||vToACC||'''   
     and substr(acctno,1,3) like '''||vsubbrid||'''          
     and DDALLTRAN.txcd = DDTX.txcd and trim(ddtx.field) = ''BALANCE''
     group by acctno,txdate,txno,ref,dorc
 )A1
 left join
 (select txno,txdate,acctno,sum(AMT) TOTALFEE from tmp_dd014 group by txdate,txno,acctno)A2
 ON (A1.TXNO = A2.TXNO AND A1.TXDATE = A2.TXDATE)) A
 WHERE AMT <> 0
 UNION ALL      
 SELECT TXNO,TXDATE,ACCTNO,AMT,trim(DORC),CHQNO FROM TMP_DD014 
 ORDER BY TXDATE,TXNO,AMT DESC'); 
 
 OPEN RefCurdd142 FOR
 	SELECT 	NVL(SUBSTR(TRIM(D.REMARK),12,13),' ') AS REMARK,A.ACCTNO, A.CHQNO,
  --TLLOGTEMP.CHQNO, 
  CASE WHEN  ((DORC = 'D' AND AMT>0) OR (DORC='C' AND AMT<0)) THEN AMT ELSE 0 END DEBIT,
		CASE WHEN  ((DORC = 'C' AND AMT>0) OR (DORC='D' AND AMT<0)) THEN AMT ELSE 0 END CREDIT,  
		A.TXNO AS TXNUM, TLLOGTEMP.TXDESC,TLLOGTEMP.TLTXCD, DORC,C.CUSTNAME,
   C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT AS ADDRESS,
     C.CUSTID,C.DISTRICT,A.TXDATE, D.BALANCE,--SBCURRENCY.CCYCD,  
  D.CCYCD,D.ACNAME,(D.BALANCE   - NVL(A.DELTA1,0)-D.ODBAL) OPNBLC,AMT,TXNO,
  SBBDSINFO.TAXCODE,SBBDSINFO.ADDRESS BDSADD,SBBDSINFO.BDSNAME,SBBDSINFO.FAX,SBBDSINFO.TEL,TXTIME
 	FROM
     (SELECT TMP1_DD014.*,A1.DELTA1 FROM TMP1_DD014
     LEFT JOIN
	 	 	(SELECT ACCTNO, SUM(CASE WHEN DORC = 'D' THEN -AMT ELSE AMT END)DELTA1
 			 FROM 	TMP1_DD014 WHERE TXDATE >= VFromDate AND TXDATE <= VTmpDate
			  GROUP BY ACCTNO) A1 ON (TMP1_DD014.ACCTNO = A1.ACCTNO)
     WHERE  TMP1_DD014.TXDATE BETWEEN VFROMDATE AND VTODATE) A,
  (SELECT TLTXCD,TXNUM,TXDATE,TXTIME,TXDESC FROM TLLOG WHERE  NVL(TLLOG.DELTD,'0')<> '1' AND TXDATE BETWEEN VFROMDATE AND VTODATE
   UNION ALL
   SELECT TLTXCD,TXNUM,TXDATE,TXTIME,TXDESC FROM TLLOGALL WHERE  NVL(TLLOGALL.DELTD,'0')<> '1' AND TXDATE BETWEEN VFROMDATE AND VTODATE ) TLLOGTEMP,
  (SELECT  ACCTNO,CUSTID,BALANCE,ODBAL,REMARK,ACNAME,SBCURRENCY.CCYCD  FROM DDALLMAST,SBCURRENCY 
              WHERE ACCTNO BETWEEN VFROMACC AND VTOACC AND CUSTID BETWEEN VFROMCUST AND VTOCUST
              AND DDALLMAST.CCYCD = SBCURRENCY.SHORTCD
              AND (STATUS <> 'C'  OR ((TRIM(STATUS) = 'C') AND CLSDATE BETWEEN VFROMDATE AND VTODATE)) --AND TRIM(ODSTS) = 'A'              
              AND SUBSTR(ACCTNO,1,3) LIKE VSUBBRID
              )D,SBBDSINFO, 
--  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND SUBSTR(CUSTID,1,3) LIKE VSUBBRID AND nvl(trim(TYPE),' ') <> '22')C
  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND nvl(trim(TYPE),' ') <> '22')C 
WHERE 
A.TXNO = TLLOGTEMP.TXNUM AND A.TXDATE= TLLOGTEMP.TXDATE
AND A.ACCTNO = D.ACCTNO
AND SUBSTR(D.ACCTNO,1,3) = SBBDSINFO.BDSID 
AND D.CUSTID = C.CUSTID   

--Lay thong tin tai khoan khong co giao dich.
UNION ALL

 	SELECT 	NVL(SUBSTR(TRIM(D.REMARK),12,13),' ') AS REMARK, D.ACCTNO, ' ' AS CHQNO, 
  0 AS DEBIT, 0 AS CREDIT,' ' AS TXNUM, 'Beginning Balance' AS TXDESC,' ' AS TLTXCD,' ' AS DORC, 	C.CUSTNAME,
-- C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT||SUBSTR('.                                                                                          ',1,100-LENGTH(TRIM(C.ADDRESS)||TRIM(C.ADDRESS2)||TRIM(C.DISTRICT))) || '.' AS ADDRESS ,
 C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT AS ADDRESS ,
     C.CUSTID,C.DISTRICT,TO_DATE('01/01/1900','DD/MM/YYYY') AS TXDATE, D.BALANCE,
  SBCURRENCY.CCYCD,D.ACNAME,(D.BALANCE - D.ODBAL-NVL(DELTA1,0))AS OPNBLC, 0 AS AMT, ' ' AS TXNO,
  SBBDSINFO.TAXCODE,SBBDSINFO.ADDRESS BDSADD,SBBDSINFO.BDSNAME,SBBDSINFO.FAX,SBBDSINFO.TEL,'00:00:00' as TXTIME
  FROM  
  SBBDSINFO, SBCURRENCY,
--  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND SUBSTR(CUSTID,1,3) LIKE VSUBBRID AND nvl(trim(TYPE),' ') <> '22')C,
  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND nvl(trim(TYPE),' ') <> '22')C,
  (SELECT  ACCTNO,CUSTID,BALANCE,ODBAL,REMARK,ACNAME,CCYCD  FROM DDALLMAST
              WHERE ACCTNO BETWEEN VFROMACC AND VTOACC AND CUSTID BETWEEN VFROMCUST AND VTOCUST
              AND SUBSTR(ACCTNO,1,3) LIKE VSUBBRID
              AND (STATUS <> 'C'  OR ((TRIM(STATUS) = 'C') AND CLSDATE BETWEEN VFROMDATE AND VTODATE)) --AND TRIM(ODSTS) = 'A' 
              )D
  LEFT JOIN 
 	(SELECT ACCTNO, SUM(CASE WHEN DORC = 'D' THEN -AMT ELSE AMT END)DELTA1
	 FROM 	TMP1_DD014 WHERE TXDATE >= VFromDate AND TXDATE <= VTmpDate
	 GROUP BY ACCTNO) A1 ON (D.ACCTNO = A1.ACCTNO)  
  WHERE     
  SUBSTR(D.ACCTNO,1,3) = SBBDSINFO.BDSID 
  AND D.CUSTID = C.CUSTID   
  AND SBCURRENCY.SHORTCD = D.CCYCD 
ORDER BY CUSTID,REMARK, TXDATE,TXTIME,AMT DESC;
else
  execute immediate ('Truncate table tmp_dd014');
   strsql:='insert into tmp_dd014
     SELECT A11.TXNO,A11.TXDATE,A22.ACCTNO,A1.AMT,''D'' AS DORC,A22.REF AS CHQNO FROM
     (select txdate,txno,sum(amt) as amt from gltrana where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND substr(acctno,4,1) = ''7''
     and NVL(DELTD,''0'') <> ''1''
     and dorc = ''C''
     group by txdate,txno
     UNION ALL
     select txdate,txno,amt from gltrana where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND ACCTNO like ''%45311%00007''
     and NVL(DELTD,''0'') <> ''1''
     and dorc = ''C''
     UNION ALL
     select txdate,txno,sum(amt)as amt from gltelt where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(acctno,4,1) = ''7''
     and NVL(DELTD,''0'') <> ''1''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     group by txdate,txno,substr(acctno,4,1)
     UNION ALL
     select txdate,txno,AMT from gltelt where
     TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO like ''%45311%00007''
     and NVL(DELTD,''0'') <> ''1''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     )A1,
     (select txno,txdate from
     (SELECT TXNO,TXDATE FROM GLTRANA  WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO LIKE ''%45311%00007''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     union all
     SELECT TXNO,TXDATE FROM GLTRANA  WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(ACCTNO,4,1) = ''7''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     UNION ALL
     SELECT TXNO,TXDATE FROM GLTELT WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND ACCTNO LIKE ''%45311%00007''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     UNION ALL
     SELECT TXNO,TXDATE FROM GLTELT WHERE NVL(DELTD,''0'') <> ''1'' AND TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND substr(ACCTNO,4,1) = ''7''
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     and dorc = ''C''
     ) group by txno,txdate
     having count(txno) >1
     )A11,
     (SELECT DISTINCT TXDATE,TXNO,ACCTNO,DDTX.dorc,REF FROM DDALLTRAN,DDTX WHERE  TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     AND SUBSTR(ACCTNO,1,3)LIKE '''||vsubbrid||'''
     AND ACCTNO between '''||VFROMACC||''' AND '''||vToACC||'''
     AND DDALLTRAN.TXCD = DDTX.TXCD AND DDTX.FIELD = ''BALANCE'' and ddtx.dorc=''D''
     ) A22
     WHERE A1.TXDATE = A11.TXDATE AND A1.TXNO = A11.TXNO
     AND A1.TXDATE = A22.TXDATE AND A1.TXNO = A22.TXNO';

 execute immediate strSQL;
 --Tao Table tmp1_dd014 de lay du lieu ra thay vi lay ddalltran  
 --tmp1_dd014 la hop cua tmp_dd014 va ddalltran
 execute immediate ('Truncate table tmp1_dd014');
 execute immediate ('insert into tmp1_dd014
 SELECT TXNO,TXDATE,ACCTNO,AMT,DORC,CHQNO FROM
( SELECT A1.TXNO,A1.TXDATE,A1.ACCTNO,
 (CASE WHEN TRIM(A1.DORC) = ''D''THEN AMT-NVL(TOTALFEE,0) ELSE AMT+NVL(TOTALFEE,0) END) AMT,
 DORC, A1.REF AS CHQNO  from 
 (       
     SELECT SUM(AMT) as AMT,ACCTNO,TXDATE,TXNO,REF,dorc FROM DDALLTRAN,DDTX where  TXDATE >= to_date('''|| to_char(vfromdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and TXDATE <= to_date('''|| to_char(vtmpdate,'dd/mm/yyyy') ||''',''dd/mm/yyyy'')
     and acctno between '''||VFROMACC||''' AND '''||vToACC||'''   
     and substr(acctno,1,3) like '''||vsubbrid||'''          
     and DDALLTRAN.txcd = DDTX.txcd and trim(ddtx.field) = ''BALANCE''
     group by acctno,txdate,txno,ref,dorc
 )A1
 left join
 (select txno,txdate,acctno,sum(AMT) TOTALFEE from tmp_dd014 group by txdate,txno,acctno)A2
 ON (A1.TXNO = A2.TXNO AND A1.TXDATE = A2.TXDATE)) A
 WHERE AMT <> 0
 UNION ALL      
 SELECT TXNO,TXDATE,ACCTNO,AMT,trim(DORC),CHQNO FROM TMP_DD014 
 ORDER BY TXDATE,TXNO,AMT DESC'); 

 OPEN RefCurdd142 FOR
 	SELECT 	NVL(SUBSTR(TRIM(D.REMARK),12,13),' ') AS REMARK,A.ACCTNO, A.CHQNO,
  --TLLOGTEMP.CHQNO, 
  CASE WHEN  ((DORC = 'D' AND AMT>0) OR (DORC='C' AND AMT<0)) THEN AMT ELSE 0 END DEBIT,
		CASE WHEN  ((DORC = 'C' AND AMT>0) OR (DORC='D' AND AMT<0)) THEN AMT ELSE 0 END CREDIT,  
		A.TXNO AS TXNUM, TLLOGTEMP.TXDESC,TLLOGTEMP.TLTXCD, DORC, 	C.CUSTNAME,
-- C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT||SUBSTR('.                                                                                          ',1,100-LENGTH(TRIM(C.ADDRESS)||TRIM(C.ADDRESS2)||TRIM(C.DISTRICT))) || '.' AS ADDRESS,
 C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT AS ADDRESS,
 C.CUSTID,C.DISTRICT,A.TXDATE, D.BALANCE,--SBCURRENCY.CCYCD,
  D.CCYCD,D.ACNAME,(D.BALANCE   - NVL(A.DELTA1,0)-D.ODBAL) OPNBLC,AMT,TXNO,
  SBBDSINFO.TAXCODE,SBBDSINFO.ADDRESS BDSADD,SBBDSINFO.BDSNAME,SBBDSINFO.FAX,SBBDSINFO.TEL,TXTIME
 	FROM
     (SELECT TMP1_DD014.*,A1.DELTA1 FROM TMP1_DD014
     LEFT JOIN
	 	 	(SELECT ACCTNO, SUM(CASE WHEN DORC = 'D' THEN -AMT ELSE AMT END)DELTA1
 			 FROM 	TMP1_DD014 WHERE TXDATE >= VFromDate AND TXDATE <= VTmpDate
			  GROUP BY ACCTNO) A1 ON (TMP1_DD014.ACCTNO = A1.ACCTNO)
     WHERE  TMP1_DD014.TXDATE BETWEEN VFROMDATE AND VTODATE) A,
  (SELECT TLTXCD,TXNUM,TXDATE,TXTIME,TXDESC FROM TLLOG WHERE  NVL(TLLOG.DELTD,'0')<> '1' AND TXDATE BETWEEN VFROMDATE AND VTODATE
   UNION ALL
   SELECT TLTXCD,TXNUM,TXDATE,TXTIME,TXDESC FROM TLLOGALL WHERE  NVL(TLLOGALL.DELTD,'0')<> '1' AND TXDATE BETWEEN VFROMDATE AND VTODATE ) TLLOGTEMP,
  (SELECT  ACCTNO,CUSTID,BALANCE,ODBAL,REMARK,ACNAME,SBCURRENCY.CCYCD  FROM DDALLMAST,SBCURRENCY 
              WHERE ACCTNO BETWEEN VFROMACC AND VTOACC AND CUSTID BETWEEN VFROMCUST AND VTOCUST
              AND DDALLMAST.CCYCD = SBCURRENCY.SHORTCD
              AND (STATUS <> 'C'  OR ((STATUS = 'C') AND CLSDATE BETWEEN VFROMDATE AND VTODATE)) AND TRIM(ODSTS) <> 'A'
              AND TRIM(STATUS) <> 'R'             
              AND SUBSTR(ACCTNO,1,3) LIKE VSUBBRID
              )D,SBBDSINFO, 
--  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND SUBSTR(CUSTID,1,3) LIKE VSUBBRID AND nvl(TRIM(TYPE),' ') <> '22')C
  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND nvl(TRIM(TYPE),' ') <> '22')C 
WHERE 

A.TXNO = TLLOGTEMP.TXNUM AND A.TXDATE= TLLOGTEMP.TXDATE
AND A.ACCTNO = D.ACCTNO
AND SUBSTR(D.ACCTNO,1,3) = SBBDSINFO.BDSID 
AND D.CUSTID = C.CUSTID   

--Lay thong tin tai khoan khong co giao dich.
UNION ALL

 	SELECT 	NVL(SUBSTR(TRIM(D.REMARK),12,13),' ') AS REMARK, D.ACCTNO, ' ' AS CHQNO, 
  0 AS DEBIT, 0 AS CREDIT,' ' AS TXNUM, 'Beginning Balance' AS TXDESC,' ' AS TLTXCD,' ' AS DORC, 	C.CUSTNAME,
--C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT||SUBSTR('.                                                                                          ',1,100-LENGTH(TRIM(C.ADDRESS)||TRIM(C.ADDRESS2)||TRIM(C.DISTRICT))) || '.' AS ADDRESS ,
C.ADDRESS||' '||C.ADDRESS2||' '||C.SUB_DISTRICT AS ADDRESS ,
C.CUSTID,C.DISTRICT,TO_DATE('01/01/1900','DD/MM/YYYY') AS TXDATE, D.BALANCE,
  SBCURRENCY.CCYCD,D.ACNAME,(D.BALANCE - D.ODBAL-NVL(DELTA1,0))AS OPNBLC, 0 AS AMT, ' ' AS TXNO,
  SBBDSINFO.TAXCODE,SBBDSINFO.ADDRESS BDSADD,SBBDSINFO.BDSNAME,SBBDSINFO.FAX,SBBDSINFO.TEL,'00:00:00' as TXTIME
  FROM  
  SBBDSINFO, SBCURRENCY,
--  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND SUBSTR(CUSTID,1,3) LIKE VSUBBRID AND nvl(TRIM(TYPE),' ')<> '22')C,
  (SELECT CUSTID,CUSTNAME,ADDRESS,ADDRESS2,DISTRICT,SUB_DISTRICT FROM CFMAST WHERE CUSTID BETWEEN VFROMCUST AND VTOCUST AND nvl(TRIM(TYPE),' ')<> '22')C,
  (SELECT  ACCTNO,CUSTID,BALANCE,ODBAL,REMARK,ACNAME,CCYCD  FROM DDALLMAST
              WHERE ACCTNO BETWEEN VFROMACC AND VTOACC AND CUSTID BETWEEN VFROMCUST AND VTOCUST
              AND SUBSTR(ACCTNO,1,3) LIKE VSUBBRID
              AND TRIM(STATUS) <> 'R'             
              AND (STATUS <> 'C'  OR ((TRIM(STATUS) = 'C') AND CLSDATE BETWEEN VFROMDATE AND VTODATE)) AND TRIM(ODSTS) <> 'A')D
  LEFT JOIN 
 	(SELECT ACCTNO, SUM(CASE WHEN DORC = 'D' THEN -AMT ELSE AMT END)DELTA1
	 FROM 	TMP1_DD014 WHERE TXDATE >= VFromDate AND TXDATE <= VTmpDate
	 GROUP BY ACCTNO) A1 ON (D.ACCTNO = A1.ACCTNO)  
  WHERE     
  SUBSTR(D.ACCTNO,1,3) = SBBDSINFO.BDSID 
  AND D.CUSTID = C.CUSTID   
  AND SBCURRENCY.SHORTCD = D.CCYCD 
-- 	ORDER BY D.ACCTNO, A.TXDATE,A.TXNO;
--ORDER BY CUSTID,REMARK, TXDATE,TXNO,AMT DESC;
ORDER BY CUSTID,REMARK, TXDATE,TXTIME,AMT DESC;
end if;
END dd142;



-- End of DDL Script for Procedure NINHPTT.dd142
/



-- End of DDL Script for Procedure SA.DD142


