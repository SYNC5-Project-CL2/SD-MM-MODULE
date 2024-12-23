*&---------------------------------------------------------------------*
 *& Include     ZBRSD0070F01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Form SET_LAYOUT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LAYOUT_0100 .
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = '송장 리스트'.
  GS_LAYOUT-EXCP_FNAME = 'EXCP'.
  GS_LAYOUT-EXCP_LED = 'X'.
  GS_LAYOUT-STYLEFNAME = 'STTAB'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_FIELDCAT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_FIELDCAT_0100 .

  DATA: LS_FCAT TYPE LVC_S_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EXCP'.
  LS_FCAT-COLTEXT  = '출고여부'.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CHECK'.
  LS_FCAT-COL_POS = 2.
  LS_FCAT-COLTEXT = '배송시작'.
  LS_FCAT-JUST = 'C'.
  LS_FCAT-EDIT = ABAP_TRUE.
  LS_FCAT-CHECKBOX = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DONUM'.
  LS_FCAT-COLTEXT  = '출하오더번호'.
  LS_FCAT-COL_POS  = 3.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SONUM'.
  LS_FCAT-COL_POS  = 4.
  LS_FCAT-COLTEXT  = '판매오더 번호'.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'BPCODE'.
  LS_FCAT-COLTEXT  = 'BP코드'.
  LS_FCAT-COL_POS  = 5.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'BPNAME'.
  LS_FCAT-COLTEXT  = 'BP명'.
  LS_FCAT-COL_POS  = 6.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SUPCODE'.
  LS_FCAT-COLTEXT  = '납품처코드'.
  LS_FCAT-COL_POS  = 7.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SUPNAME'.
  LS_FCAT-COLTEXT  = '납품처명'.
  LS_FCAT-COL_POS  = 8.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOP_STATUS'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOP_STATUS_TXT'.
  LS_FCAT-COLTEXT  = '판매오더 진행상태'.
  LS_FCAT-COL_POS  = 8.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPID'.
  LS_FCAT-COLTEXT  = '사원ID'.
  LS_FCAT-COL_POS  = 9.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPNAME'.
  LS_FCAT-COLTEXT  = '담당자명'.
  LS_FCAT-COL_POS  = 10.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'GIDATE'.
  LS_FCAT-COLTEXT  = '출고예정일'.
  LS_FCAT-COL_POS  = 11.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'GIDATECOMP'.
  LS_FCAT-COLTEXT  = '출고완료일'.
  LS_FCAT-COL_POS  = 12.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STATUS'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CURRENCY'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DODAT'.
  LS_FCAT-COLTEXT = '출하오더 생성일'.
  LS_FCAT-COL_POS = 13.
  APPEND LS_FCAT TO GT_FCAT.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_DISPLAY_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_DISPLAY_0100.

  CALL METHOD AVL_GRID_TOP->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
    I_BYPASSING_BUFFER = 'X'
    I_STRUCTURE_NAME  = 'ZTBSD0040'
    IS_LAYOUT     = GS_LAYOUT
   CHANGING
    IT_OUTTAB     = GT_ALV_ZTBSD0040
    IT_FIELDCATALOG  = GT_FCAT.

  CALL METHOD AVL_GRID_BOTTOM->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
    I_BYPASSING_BUFFER = 'X'
    I_STRUCTURE_NAME  = 'ZTBSD0060'
    IS_LAYOUT     = GS_LAYOUT2
   CHANGING
    IT_OUTTAB     = GT_ALV_ZTBSD0060
    IT_FIELDCATALOG  = GT_FCAT2.

  PERFORM ERROR USING 'SET_TABLE'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE_SPLIT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CREATE_SPLIT_0100 .

  CREATE OBJECT GO_SPLIT
   EXPORTING
    PARENT = GO_DOCK
    ROWS  = 2   " 몇 개의 행으로 나눌 것인지.
    COLUMNS = 1.   " 몇 개의 열로 나눌 것인지.

  GO_CON_TOP  = GO_SPLIT->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GO_CON_BOTTOM = GO_SPLIT->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

  CREATE OBJECT AVL_GRID_TOP
   EXPORTING
    I_PARENT = GO_CON_TOP.

  CREATE OBJECT AVL_GRID_BOTTOM
   EXPORTING
    I_PARENT = GO_CON_BOTTOM.

  PERFORM ERROR USING 'CREATE_SPLIT'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_LAYOUT2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LAYOUT2_0100 .
  GS_LAYOUT2-ZEBRA = 'X'.
  GS_LAYOUT2-CWIDTH_OPT = 'A'.
  GS_LAYOUT2-GRID_TITLE = '배송 리스트'.
  GS_LAYOUT2-EXCP_FNAME = 'EXCP'.
  GS_LAYOUT2-EXCP_LED = 'X'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_FIELDCAT2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_FIELDCAT2_0100 .

  DATA: LS_FCAT TYPE LVC_S_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EXCP'.
  LS_FCAT-COLTEXT  = '대금청구생성상태'.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELIVNUM'.
  LS_FCAT-COLTEXT  = '배송번호'.
  LS_FCAT-COL_POS = 1.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DONUM'.
  LS_FCAT-COLTEXT  = '출하오더번호'.
  LS_FCAT-COL_POS = 2.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SONUM'.
  LS_FCAT-COL_POS = 3.
  LS_FCAT-COLTEXT = '판매오더 번호'.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'BPCODE'.
  LS_FCAT-COLTEXT  = 'BP코드'.
  LS_FCAT-COL_POS = 4.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'BPNAME'.
  LS_FCAT-COLTEXT  = 'BP명'.
  LS_FCAT-COL_POS = 5.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SUPCODE'.
  LS_FCAT-COLTEXT  = '납품처코드'.
  LS_FCAT-COL_POS = 6.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SUPNAME'.
  LS_FCAT-COLTEXT  = '납품처명'.
  LS_FCAT-COL_POS = 7.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELIVCO'.
  LS_FCAT-COLTEXT  = '배송업체'.
  LS_FCAT-COL_POS = 8.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELIVFEE'.
  LS_FCAT-COLTEXT  = '배송비'.
  LS_FCAT-COL_POS = 9.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CURRENCY'.
  LS_FCAT-COLTEXT  = '화폐단위'.
  LS_FCAT-COL_POS = 10.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'TRANSPORT'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'TRANSPORT_TXT'.
  LS_FCAT-COLTEXT  = '배송방법'.
  LS_FCAT-COL_POS = 11.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOP_STATUS'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOP_STATUS_TXT'.
  LS_FCAT-COLTEXT  = '판매오더 진행상태'.
  LS_FCAT-COL_POS  = 12.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPID'.
  LS_FCAT-COLTEXT  = '사원ID'.
  LS_FCAT-COL_POS = 13.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPNAME'.
  LS_FCAT-COLTEXT  = '담당자명'.
  LS_FCAT-COL_POS = 14.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELIVSDAT'.
  LS_FCAT-COLTEXT  = '배송 시작일'.
  LS_FCAT-COL_POS = 15.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELIVFDAT'.
  LS_FCAT-COLTEXT  = '배송 완료일'.
  LS_FCAT-COL_POS = 16.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STATUS'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_DATA_SHP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DATA_SHP.

 \* 출하오더번호에 맞는거
  DATA : RT_DONUM TYPE RANGE OF ZTBSD0040-DONUM.

  IF PA_DONUM IS NOT INITIAL.
   RT_DONUM = VALUE #( ( SIGN = 'I'
              OPTION = 'EQ'
              LOW = PA_DONUM ) ).
  ENDIF.

 \* 송장 데이터 꺼내오기, 출고가 완료된거 즉 상태가 3미만인것만
  SELECT A~DONUM, A~SONUM, E~BPCODE, B~BPNAME,
     A~EMPID, D~EMPNAME, A~GIDATE, A~GIDATECOMP,
     A~STATUS, A~DODAT, E~STATUS AS SOP_STATUS, I~CURRENCY
   FROM ZTBSD0040 AS A
   JOIN ZTBSD0030 AS E ON A~SONUM = E~SONUM " 판매오더 진행상태
   JOIN ZTBSD1050 AS H ON E~BPCODE = H~BPCODE " BP코드 정보
   JOIN ZTBSD1040 AS I ON H~CTRYCODE = I~CTRYCODE " 화폐단위
   JOIN ZTBSD1051 AS B ON E~BPCODE = B~BPCODE " BP코드 정보
   LEFT JOIN ZTBSD1030 AS D ON A~EMPID = D~EMPID " 담당자 명
   INTO CORRESPONDING FIELDS OF TABLE @GT_ALV_ZTBSD0040
   WHERE A~DONUM IN @RT_DONUM " 출하오더번호
    AND A~DODAT IN @PA_DATE  " 출하오더 생성일
    AND E~STATUS < 3 " 배송시작 전 판매오더들만
   ORDER BY A~STATUS DESCENDING, A~DONUM DESCENDING.

 \* 납품처 정보를 위해
  SELECT * FROM ZTBSD1060 AS A INTO CORRESPONDING FIELDS OF TABLE @GT_ZTBSD1060.

  PERFORM SUBRC USING '조회'.

  PERFORM SET_STATUS_SHP. " 출고여부 상태 신호등 만들기

  PERFORM GET_DATA_DEL TABLES RT_DONUM. " 배송 리스트

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_STATUS
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_STATUS_SHP.

  LOOP AT GT_ALV_ZTBSD0040 INTO GS_ALV_ZTBSD0040.

 \*  CHECK BOX 넣기
   DATA LS_STYLE TYPE LVC_S_STYL.
   LS_STYLE-FIELDNAME = 'CHECK'.

 \*  출고여부
   GS_ALV_ZTBSD0040-EXCP = '1'. " RED 미완료
   LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

   IF GS_ALV_ZTBSD0040-STATUS = 1. " 완료상태라면
    GS_ALV_ZTBSD0040-EXCP = '3'. " GREEN
 \*   CHECK BOX도 넣어주자
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   ENDIF.

   INSERT LS_STYLE INTO TABLE GS_ALV_ZTBSD0040-STTAB.

 \*  FIXED VALUE 값 넣기
   DATA LS_STATUS TYPE CHAR1.

   PERFORM GET_DOMAIN_VAL TABLES GT_FX_SOPSTATUS USING 'ZDB_SOSTATUS'. " 판매오더 진행상태 Fixed Value.

   LS_STATUS = GS_ALV_ZTBSD0040-SOP_STATUS.
   READ TABLE GT_FX_SOPSTATUS WITH KEY DOMVALUE_L = LS_STATUS INTO DATA(LS_SOPSTATUS).
   GS_ALV_ZTBSD0040-SOP_STATUS_TXT = LS_SOPSTATUS-DDTEXT.

 \*  납품처 정보 넣기
   READ TABLE GT_ZTBSD1060 WITH KEY BPCODE = GS_ALV_ZTBSD0040-BPCODE INTO DATA(LS_SUPDOCE).
   GS_ALV_ZTBSD0040-SUPCODE = LS_SUPDOCE-SUPCODE.

   SELECT SINGLE A~SUPNAME FROM ZTBSD1061 AS A WHERE A~SUPCODE = @GS_ALV_ZTBSD0040-SUPCODE INTO @DATA(LS_SUPNAME).
   GS_ALV_ZTBSD0040-SUPNAME = LS_SUPNAME.
   PERFORM SUBRC USING '조회'.

   MODIFY GT_ALV_ZTBSD0040 FROM GS_ALV_ZTBSD0040.

  ENDLOOP.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_DATA_DEL
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DATA_DEL TABLES RT_DONUM.
 \* 배송 데이터 꺼내오기
  SELECT A~DELIVNUM, A~DONUM, A~SONUM, E~BPCODE, B~BPNAME,
     A~EMPID, D~EMPNAME, A~DELIVCO, A~DELIVFEE, A~TRANSPORT,
     A~DELIVSDAT, A~CURRENCY, A~DELIVFDAT, A~STATUS
   FROM ZTBSD0060 AS A
   JOIN ZTBSD0030 AS E ON A~SONUM = E~SONUM  " 판매오더 진행상태
   JOIN ZTBSD1051 AS B ON E~BPCODE = B~BPCODE " BP 정보
   LEFT JOIN ZTBSD1030 AS D ON A~EMPID = D~EMPID " 담당자 명
   LEFT JOIN ZTBSD0040 AS G ON A~DONUM = G~DONUM " 출하오더 날짜 검색 조건을 위해
   INTO CORRESPONDING FIELDS OF TABLE @GT_ALV_ZTBSD0060
   WHERE A~DONUM IN @RT_DONUM " 출하오더 번호
    AND G~DODAT IN @PA_DATE " 출하오더 생성일
    AND E~STATUS >= 3   " 배송이 시작된것만
   ORDER BY A~DELIVNUM DESCENDING.

  PERFORM SUBRC USING '조회'.

  PERFORM SET_STATUS_DEL. "대금청구상태, 배송방법

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_STATUS_DEL
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_STATUS_DEL.

  LOOP AT GT_ALV_ZTBSD0060 INTO GS_ALV_ZTBSD0060.

 \*  대금청구생성상태 값
   GS_ALV_ZTBSD0060-EXCP = '1'.   " 대금청구생성전 이라면 RED
   IF GS_ALV_ZTBSD0060-STATUS = 'B'.  " 대금청구생성완료 라면
    GS_ALV_ZTBSD0060-EXCP = '3'. " GREEN
   ENDIF.

 \*  FIXED VALUE 값 넣기
   DATA : LT_FX_TRANSPORT TYPE STANDARD TABLE OF DD07V,  " 배송방법 Fixed Value
      LS_STATUS    TYPE CHAR1.

   PERFORM GET_DOMAIN_VAL TABLES LT_FX_TRANSPORT USING 'ZDB_TRANSPORT'. " 배송방법 Fixed Value.

   LS_STATUS = GS_ALV_ZTBSD0060-TRANSPORT.
   READ TABLE LT_FX_TRANSPORT WITH KEY DOMVALUE_L = LS_STATUS INTO DATA(LS_TRANSPORT).
   GS_ALV_ZTBSD0060-TRANSPORT_TXT = LS_TRANSPORT-DDTEXT.

   LS_STATUS = GS_ALV_ZTBSD0040-SOP_STATUS.  " 판매오더 진행상태 Fixed Value 값
   READ TABLE GT_FX_SOPSTATUS WITH KEY DOMVALUE_L = LS_STATUS INTO DATA(LS_SOPSTATUS).
   GS_ALV_ZTBSD0060-SOP_STATUS_TXT = LS_SOPSTATUS-DDTEXT.

   MODIFY GT_ALV_ZTBSD0060 FROM GS_ALV_ZTBSD0060.

  ENDLOOP.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_DOMAIN_VAL
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DOMAIN_VAL TABLES LT_FX_TRANSPORT USING DOMAIN.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
   EXPORTING
    DOMNAME  = DOMAIN  " Domain 값을 넣으면 된다. "
    TEXT    = 'X'
   TABLES
    VALUES_TAB = LT_FX_TRANSPORT.  " SAP 안에 기본으로 있는 TABLE이다. 무조건 이거 써야 함

  PERFORM ERROR USING 'GET_DOMAIN_VALUES'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ERROR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM ERROR USING P_VALUE.
  IF SY-SUBRC = 4.
   MESSAGE S015 DISPLAY LIKE 'E' WITH P_VALUE. " 에러
  ENDIF.
  IF SY-SUBRC <> 0.
   MESSAGE S100 DISPLAY LIKE 'E' WITH P_VALUE. " 에러
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SUBRC
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM SUBRC USING P_VALUE.
  IF SY-SUBRC <> 0.
   MESSAGE S094 DISPLAY LIKE 'E' WITH P_VALUE.
  ELSE.
   MESSAGE S095 DISPLAY LIKE 'S' WITH P_VALUE.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CREATE. " 출고완료된 애들 여러개 선택 후 배송을 시작하기 위해서

  DATA: LT_ZTBSD0040 LIKE TABLE OF GS_ALV_ZTBSD0040.

 \*  CHECK = 'X'인 값 가져오기.
  LOOP AT GT_ALV_ZTBSD0040 INTO GS_ALV_ZTBSD0040 WHERE ( CHECK = 'X' ).
   APPEND GS_ALV_ZTBSD0040 TO LT_ZTBSD0040.
  ENDLOOP.

  IF LINES( LT_ZTBSD0040 ) = 0.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '123'.
   RETURN.
  ENDIF.

 \* 생성 하겠냐는 컨펌창 띄우기
  PERFORM CON_POPUP USING '생성' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  LOOP AT LT_ZTBSD0040 INTO DATA(LS_ZTBSD0040).
   CLEAR : GS_ALV_ZTBSD0060.
   MOVE-CORRESPONDING LS_ZTBSD0040 TO GS_ALV_ZTBSD0060.

 \*  Number Range 생성해보자
   DATA LV_NUM TYPE CHAR10.
   PERFORM GET_NUMBER_RANGE CHANGING LV_NUM.

 \*  사원ID 가져오기
   PERFORM GET_EMPID.

 \*  해외일 경우 SHIP (2) , 아니면 전부 트럭 (1)
 \*  미국, 독일 : TRANSPORT 2 , CURRENCY 2,000,000, 배송완료일 +3
 \*  중국 : TRANSPORT 2 , CURRENCY 1,000,000, 배송완료일 +2
 \*  국내 : TRANSPORT 1 , CURRENCY 500,000, 배송완료일 +1

   DATA: EXTERNAL LIKE BAPICURR-BAPICURR.

   CASE LS_ZTBSD0040-CURRENCY.
    WHEN 'KRW'.
     EXTERNAL = 500000.
     GS_ALV_ZTBSD0060-TRANSPORT = 1.
     GS_ALV_ZTBSD0060-DELIVFDAT = SY-DATUM + 1.
    WHEN 'CNY'.
     EXTERNAL = 1000000.
     GS_ALV_ZTBSD0060-TRANSPORT = 2.
     GS_ALV_ZTBSD0060-DELIVFDAT = SY-DATUM + 2.
    WHEN OTHERS.
     EXTERNAL = 2000000.
     GS_ALV_ZTBSD0060-TRANSPORT = 2.
     GS_ALV_ZTBSD0060-DELIVFDAT = SY-DATUM + 3.
   ENDCASE.

   PERFORM CAL_CURR CHANGING EXTERNAL.
   GS_ALV_ZTBSD0060-DELIVFEE = EXTERNAL.
   GS_ALV_ZTBSD0060 = VALUE #( BASE GS_ALV_ZTBSD0060 DELIVNUM = |DLV{ LV_NUM }|
                            DELIVCO = 'CJ'
                            EMPID = GS_ZTBSD1030-EMPID " 사원 ID
                            DELIVSDAT = SY-DATUM
                            CURRENCY = 'KRW' ).  " 배송 시작일


   GS_ALV_ZTBSD0060-STATUS = 'A'. " 대금청구상태 기본

   MOVE-CORRESPONDING GS_ALV_ZTBSD0060 TO ZTBSD0060.
   INSERT INTO ZTBSD0060 VALUES ZTBSD0060.

   UPDATE ZTBSD0030
    SET STATUS = 3  " 판매오더 진행상태 3(배송시작)으로 바꿀것
   WHERE SONUM = LS_ZTBSD0040-SONUM.

  ENDLOOP.

  PERFORM REFRESH.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ALV_REFRESH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM ALV_REFRESH .
  CALL METHOD AVL_GRID_TOP->REFRESH_TABLE_DISPLAY
   EXCEPTIONS
    FINISHED = 1
    OTHERS  = 2.

  CALL METHOD AVL_GRID_BOTTOM->REFRESH_TABLE_DISPLAY
   EXCEPTIONS
    FINISHED = 1
    OTHERS  = 2.

  PERFORM ERROR USING 'REFRESH_TABLE'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_NUMBER_RANGE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- LV_NUM
 *&---------------------------------------------------------------------*
 FORM GET_NUMBER_RANGE CHANGING P_LV_NUM.
  CALL FUNCTION 'NUMBER_GET_NEXT'
   EXPORTING
    NR_RANGE_NR = '01'
    OBJECT   = 'ZBBSD0060'
   IMPORTING
    NUMBER   = P_LV_NUM.

  PERFORM ERROR USING 'NUMBER_RANGE'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_EMPID
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_EMPID.
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.
  READ TABLE GT_ZTBSD1030 INTO GS_ZTBSD1030 WITH KEY LOGID = SY-UNAME.
  PERFORM ERROR USING '조회'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_REGISTER_EVENT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_REGISTER_EVENT_0100 .
  AVL_GRID_TOP->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER ).
  AVL_GRID_TOP->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CAL_CURR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- EXTERNAL
 *&---------------------------------------------------------------------*
 FORM CAL_CURR CHANGING EXTERNAL.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
   EXPORTING
    CURRENCY       = 'KRW'  "한국 통화로
    AMOUNT_EXTERNAL   = EXTERNAL
    MAX_NUMBER_OF_DIGITS = 15
   IMPORTING
    AMOUNT_INTERNAL   = EXTERNAL.

  PERFORM ERROR USING 'CURRENCY_CONV'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CON_POPUP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&   <-- LV_ANSWER
 *&---------------------------------------------------------------------*
 FORM CON_POPUP USING P_VALUE CHANGING LV_ANSWER.

  DATA DOMAIN TYPE CHAR10 VALUE '배송'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR       = | { DOMAIN } 문서 { P_VALUE } |
    TEXT_QUESTION     = | 해당 송장문서에 대한 { DOMAIN } 문서를 { P_VALUE }하시겠습니까? |
    TEXT_BUTTON_1     = 'YES'
    ICON_BUTTON_1     = 'ICON_OKAY'
    TEXT_BUTTON_2     = 'NO'
    ICON_BUTTON_2     = 'ICON_CANCEL'
    DEFAULT_BUTTON    = '1'
    DISPLAY_CANCEL_BUTTON = ''
   IMPORTING
    ANSWER        = LV_ANSWER.

  PERFORM ERROR USING 'POPUP'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form REFRESH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM REFRESH.
  PERFORM GET_DATA_SHP.
  PERFORM ALV_REFRESH.
 ENDFORM.
