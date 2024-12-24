
 *&---------------------------------------------------------------------*
 *& Form SET_LIST_BOX
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LIST_BOX.
* DB에 있는 연도 중복 제거 후 가져오기
  DATA : LT_DROPLIST TYPE VRM_VALUES,
     LS_DROPLIST TYPE VRM_VALUE.

* APPEND는 스택임
  SELECT DISTINCT
   SALESYEAR AS KEY,
   SALESYEAR AS TEXT
  FROM ZTBSD0010 INTO TABLE @LT_DROPLIST.

  PERFORM ERROR USING 'SELECT'.

  CALL FUNCTION 'VRM_SET_VALUES'
   EXPORTING
    ID   = 'GV_LIST'
    VALUES = LT_DROPLIST. " Listbox Data
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ALV_REFRESH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM ALV_REFRESH.
  CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
   EXCEPTIONS
    FINISHED = 1
    OTHERS  = 2.

  CALL METHOD GO_ALV2->REFRESH_TABLE_DISPLAY
   EXCEPTIONS
    FINISHED = 1
    OTHERS  = 2.

  PERFORM ERROR USING 'REFRESH_TABLE'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form RESET
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM RESET .  " 새로고침 버튼
  REFRESH: GT_ZTBSD0010, GT_ZTBSD0011, GT_MATDATA.
  CLEAR: GS_ZTBSD0010, GS_ZTBSD0011, GS_MATDATA.
  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_DATA_PROD
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_DATA_PROD USING SOPNUM.

  DATA: YAER_TODAY TYPE N LENGTH 4, " 기준 연도
     YEAR_CALC TYPE N LENGTH 4.

*  사실 판매계획연도 생성은 내년것만 가능하다
  YAER_TODAY = SY-DATUM+0(4) + 1.

* 만약 이미 내년 판매계획이 최종승인되어 있다면 내후년 계획을 세우도록 한다. 최종승인된 계획이 있는지 본다
  SELECT COUNT(*) FROM ZTBSD0010 AS A WHERE A~SALESYEAR EQ @YAER_TODAY AND A~APPR EQ 2 INTO @DATA(LS_ZCOUNT).

  YEAR_CALC = YAER_TODAY.
* 내년 계획이 이미 있어요
  IF LS_ZCOUNT NE 0.
   YEAR_CALC = YAER_TODAY + 1.
  ENDIF.

*  1. 저번 판매계획수량을 가지고 온다.
  PERFORM GET_MATDATA USING YAER_TODAY.

  REFRESH GT_ZTBSD0011.

* 국가코드를 이용해 국가명 가져오기
  SELECT SINGLE CTRYCODE, CTRYNAME FROM ZTBSD1040
   WHERE CTRYCODE = @ZTBSD0010-CTRYCODE INTO @DATA(LT_CTRY).

  LOOP AT GT_MATDATA INTO GS_MATDATA.
   GS_MATDATA-UNITCODE = 'EA'. " 수량단위는 완제품일 경우 EA로 통합
   GS_ZTBSD0011-SOPNUM = SOPNUM.
   GS_ZTBSD0011-CTRYNAME = LT_CTRY-CTRYNAME.

*   전년도 수량 * 1.01
   GS_MATDATA-AMOUNTPRD = CEIL( GS_MATDATA-AMOUNTPRD * AMOUNT_CS ).

*  제품 유형 타입 구해오기
   SELECT SINGLE * FROM ZTBMM1010 AS A
    WHERE A~MATCODE = @GS_MATDATA-MATCODE
    INTO @DATA(LS_MM).

*  판매수량 제한 걸기
   PERFORM MAX_SOPAMOUN_CHECK USING LS_MM-PRODTYPE CHANGING GS_MATDATA-AMOUNTPRD.

   MOVE-CORRESPONDING GS_MATDATA TO GS_ZTBSD0011.

   DATA LS_STYLE TYPE LVC_S_STYL.
   LS_STYLE-FIELDNAME = 'AMOUNTPRD'.
   LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   INSERT LS_STYLE INTO TABLE GS_ZTBSD0011-STTAB.

   GS_ZTBSD0011-SALESYR = YEAR_CALC.
   APPEND GS_ZTBSD0011 TO GT_ZTBSD0011.

   MOVE-CORRESPONDING GS_ZTBSD0011 TO GS_AMOUNT.
   APPEND GS_AMOUNT TO GT_AMOUNT.
   CLEAR : GS_ZTBSD0011, GS_AMOUNT.

  ENDLOOP.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_DATA_HEADER
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_DATA_HEADER.

* 국가코드를 이용해 국가명 가져오기
  SELECT SINGLE CTRYCODE, CTRYNAME FROM ZTBSD1040
   WHERE CTRYCODE = @ZTBSD0010-CTRYCODE INTO @DATA(LT_CTRY).

  PERFORM ERROR USING 'SELECT'.
  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_NUMBER_RANGE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- LV_NUM
 *&---------------------------------------------------------------------*
 FORM GET_NUMBER_RANGE USING NUM_TYPE CHANGING P_LV_NUM.
  CALL FUNCTION 'NUMBER_GET_NEXT'
   EXPORTING
    NR_RANGE_NR = '01'
    OBJECT   = NUM_TYPE
   IMPORTING
    NUMBER   = P_LV_NUM.

  PERFORM ERROR USING 'NUMBER_RANGE'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form MESSAGE_INFO
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM MESSAGE_INFO USING P_ROW.
  IF P_ROW = 'ROW'.
   MESSAGE S008 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'DELETE'.
   MESSAGE S014 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'ERROR'.
   MESSAGE S016 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'SUCCESS'.
   MESSAGE S019 DISPLAY LIKE 'S'.  " 데이터 성공
  ELSEIF P_ROW = 'NONE'.
   MESSAGE S023 DISPLAY LIKE 'I'.
  ELSEIF P_ROW = 'REQ'.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '000'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SOP_PLAN
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SOP_PLAN .
  PERFORM RESET.

* 필수값 입력 안했으면 경고창 띄워
  IF ZTBSD0010-CTRYCODE IS INITIAL.
   PERFORM MESSAGE_INFO USING 'REQ'.
   RETURN.
  ENDIF.

* 내년 계획 세우기
  DATA: YEAR_CALC TYPE N LENGTH 4.

  YEAR_CALC = SY-DATUM+0(4) + 1.
 *
* 만약 이미 내년 판매계획이 최종승인되어 있다면 내후년 계획을 세우도록 한다
  SELECT COUNT(*) FROM ZTBSD0010 AS A WHERE A~SALESYEAR EQ @YEAR_CALC AND A~APPR EQ 2 INTO @DATA(LS_ZCOUNT).

  IF LS_ZCOUNT <> 0.
   YEAR_CALC += 1.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '126'.
  ENDIF.

* Number Range 생성해보자
  DATA LV_NUM TYPE CHAR10.
  PERFORM GET_NUMBER_RANGE USING 'ZBBSD0010' CHANGING LV_NUM.

* 이미 생산이 진행중이면 리턴 및 판매계획 APPE 상태 2 최종승인으로 업데이트
  SELECT COUNT(*)
   FROM ZTBSD0010 AS A
   WHERE A~STATUS = 1
    AND A~SALESYEAR = @YEAR_CALC
   INTO @DATA(LV_CNT).

  IF LV_CNT <> 0.

   UPDATE ZTBSD0010
    SET APPR = 2
   WHERE STATUS = 1
    AND SALESYEAR = @YEAR_CALC
    AND APPR = 1.

   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '114' WITH YEAR_CALC.
   RETURN.
  ENDIF.

* TODO. 그냥 빈 테이블 생성 함.
  SELECT A~SOPNUM, A~SALESYEAR, A~SOPDATE, A~EMPID, B~AMOUNTPRD, B~UNITCODE, B~MATCODE, B~CTRYCODE
   FROM ZTBSD0010 AS A JOIN ZTBSD0011 AS B ON A~SOPNUM = B~SOPNUM
   INTO TABLE @DATA(LT_SOP).

  PERFORM ERROR USING 'SELECT'.

  REFRESH LT_SOP.
  DATA LS_SOP LIKE LINE OF LT_SOP.

* 리스트박스에 내년 연도 넣어주기
  GV_LIST = YEAR_CALC.

  PERFORM GET_EMPID.

  LS_SOP-SOPNUM = |SOP{ LV_NUM }|.
  LS_SOP-SALESYEAR = YEAR_CALC.
  LS_SOP-SOPDATE = SY-DATUM.
  LS_SOP-EMPID = GS_ZTBSD1030-EMPID.
  LS_SOP-CTRYCODE = ZTBSD0010-CTRYCODE.

* 판매운영계획 Header insert 부분
  MOVE-CORRESPONDING LS_SOP TO GS_ZTBSD0010.
  APPEND GS_ZTBSD0010 TO GT_ZTBSD0010.

* 판매운영계획 ITEM 넣는 부분
  PERFORM SET_DATA_PROD USING LS_SOP-SOPNUM.

  CLEAR : LS_SOP.

  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_EMPID
 *& Form GET_EMPID
 *&---------------------------------------------------------------------*
 FORM GET_EMPID.
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.
  READ TABLE GT_ZTBSD1030 INTO GS_ZTBSD1030 WITH KEY LOGID = SY-UNAME.
  PERFORM ERROR USING 'SELECT'.
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

  DATA DOMAIN TYPE CHAR10 VALUE '판매운영계획'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR       = | { DOMAIN } 문서 { P_VALUE } |
    TEXT_QUESTION     = | 해당 { DOMAIN } 문서를 { P_VALUE }하시겠습니까? |
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
 *& Form GET_MATDATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> YEAR
 *&---------------------------------------------------------------------*
 FORM GET_MATDATA USING YEAR.

  DATA : LS_ZTBSD0011 TYPE ZTBSD0011,
     LT_ZTBSD0011 TYPE TABLE OF ZTBSD0011.

* 전년도를 구해야 하기에 -1
  YEAR -= 1.

* 자재마스터에 있는 완제품(C)을 모두 가져온다 (ZTBMM1010)
* 자재마스터 이름을 가지고 온다 (ZTBMM1011)
* 판매운영계획에서 전년도 판매수량을 가지고 온다 ( 조건 : 생성하려는 국가(ZTBSD0010-CTRYCODE), 전년도 )
  SELECT DISTINCT D~SALESYEAR, C~MATCODE, B~MATNAME, C~AMOUNTPRD, A~PRODTYPE, C~CTRYCODE
   FROM ZTBMM1010 AS A
   INNER JOIN ZTBMM1011 AS B ON A~MATCODE EQ B~MATCODE
   LEFT JOIN ZTBSD0011 AS C ON A~MATCODE EQ C~MATCODE
   INNER JOIN ZTBSD0010 AS D ON C~SOPNUM = D~SOPNUM
   INTO CORRESPONDING FIELDS OF TABLE @GT_MATDATA
   WHERE D~SALESYEAR = @YEAR
    AND A~MATTYPE = 'C'
    AND C~CTRYCODE = @ZTBSD0010-CTRYCODE
   ORDER BY C~MATCODE.

  PERFORM ERROR USING 'SELECT'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SOP_READ
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SOP_READ.
  PERFORM RESET.

* 필수값 입력 안했으면 경고창 띄워
  IF GV_LIST IS INITIAL.
   PERFORM MESSAGE_INFO USING 'REQ'.
   RETURN.
  ENDIF.

* 연도에 맞는 데이터 끌고 오기 판매운영계획 Header
* 승인된거 먼저 보여주고 다음에 SOPNUM 내림차순으로
  SELECT A~SOPNUM, A~CTRYCODE, A~SALESYEAR, A~EMPID, A~APPR,
     A~STATUS, A~REJREASON, A~SOPDATE, B~CTRYNAME, C~EMPNAME
   FROM ZTBSD0010 AS A
   JOIN ZTBSD1040 AS B ON A~CTRYCODE = B~CTRYCODE
   JOIN ZTBSD1030 AS C ON A~EMPID = C~EMPID
   WHERE A~SALESYEAR = @GV_LIST
   ORDER BY A~APPR DESCENDING, A~SOPNUM DESCENDING
   INTO CORRESPONDING FIELDS OF TABLE @GT_ZTBSD0010.

  PERFORM ERROR USING 'SELECT'.

  PERFORM SET_STATUS.

  PERFORM ALV_REFRESH.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ON_DOUBLE_CLICK
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> ROW
 *&   --> COLUMN
 *&---------------------------------------------------------------------*
 FORM ON_DOUBLE_CLICK USING P_ROW_NO TYPE LVC_S_ROID.

* 조회 탭이면 그냥 무시
  CHECK G_TABSTRIP-ACTIVETAB = 'TAB_R'.

* 더블클릭한 헤더 INDEX 이용해서데이터 가져오기 ( 판매운영계획 ITEM )
  READ TABLE GT_ZTBSD0010 INTO GS_ZTBSD0010 INDEX P_ROW_NO-ROW_ID.

* 자재명도 가져오기
  SELECT A~SOPNUM, A~CTRYCODE, A~MATCODE, B~MATNAME, A~AMOUNTPRD,
     A~UNITCODE, C~CTRYNAME, A~SALESYR
   FROM ZTBSD0011 AS A JOIN ZTBMM1011 AS B ON A~MATCODE = B~MATCODE
   JOIN ZTBSD1040 AS C ON A~CTRYCODE = C~CTRYCODE
   WHERE A~SOPNUM = @GS_ZTBSD0010-SOPNUM
   INTO CORRESPONDING FIELDS OF TABLE @GT_ZTBSD0011.

  LOOP AT GT_ZTBSD0011 INTO DATA(LS_DATA).
   DATA LS_STYLE TYPE LVC_S_STYL.
   LS_STYLE-FIELDNAME = 'AMOUNTPRD'.
   LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   INSERT LS_STYLE INTO TABLE GS_ZTBSD0011-STTAB.
  ENDLOOP.

  PERFORM ERROR USING 'SELECT'.

*  ALV1 ITEM 부분만 새로고침
  DATA LS_STABLE TYPE LVC_S_STBL.
  CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
   EXPORTING
    IS_STABLE = LS_STABLE.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_LAYOUT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LAYOUT_0100 .
  GS_LAYOUT-ZEBRA = ABAP_TRUE.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = '제품별 판매계획'.
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
  LS_FCAT-FIELDNAME = 'SOPNUM'.
  LS_FCAT-COLTEXT  = '판매계획운영번호'.
  LS_FCAT-COL_POS = 1.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYCODE'.
  LS_FCAT-COL_POS = 2.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYNAME'.
  LS_FCAT-COLTEXT  = '국가명'.
  LS_FCAT-COL_POS = 3.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATCODE'.
  LS_FCAT-COLTEXT  = '자재코드'.
  LS_FCAT-COL_POS = 4.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATNAME'.
  LS_FCAT-COLTEXT  = '완제품명'.
  LS_FCAT-COL_POS = 5.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'AMOUNTPRD'.
  LS_FCAT-COL_POS = 6.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'UNITCODE'.
  LS_FCAT-COLTEXT  = '단위'.
  LS_FCAT-COL_POS = 7.
  APPEND LS_FCAT TO GT_FCAT.

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
  GS_LAYOUT2-GRID_TITLE = '판매운영계획'.
  GS_LAYOUT2-EXCP_FNAME = 'EXCP'.
  GS_LAYOUT2-STYLEFNAME = 'STTAB'.
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
  LS_FCAT-COLTEXT  = '승인여부'.
  LS_FCAT-COL_POS = 1.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CHECK'.
  LS_FCAT-COL_POS = 2.
  LS_FCAT-COLTEXT = '최종승인'.
  LS_FCAT-JUST = 'C'.
  LS_FCAT-EDIT = ABAP_TRUE.
  LS_FCAT-CHECKBOX = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOPNUM'.
  LS_FCAT-COLTEXT  = '판매계획운영번호'.
  LS_FCAT-COL_POS = 3.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SALESYEAR'.
  LS_FCAT-COLTEXT  = '판매계획연도'.
  LS_FCAT-COL_POS = 4.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYCODE'.
  LS_FCAT-COLTEXT  = '국가코드'.
  LS_FCAT-COL_POS = 5.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYNAME'.
  LS_FCAT-COLTEXT  = '국가명'.
  LS_FCAT-COL_POS = 6.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPID'.
  LS_FCAT-COLTEXT  = '담당자'.
  LS_FCAT-COL_POS = 7.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPNAME'.
  LS_FCAT-COLTEXT  = '담당자명'.
  LS_FCAT-COL_POS = 8.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOP_STATUS_TXT'.
  LS_FCAT-COLTEXT = '판매운영계획 상태'.
  LS_FCAT-NO_OUT = ''.
  LS_FCAT-JUST = 'C'.
  LS_FCAT-COL_POS = 9.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'REJREASON'.
  LS_FCAT-JUST = 'C'.
  LS_FCAT-COLTEXT  = '반려사유'.
  LS_FCAT-COL_POS = 10.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SOPDATE'.
  LS_FCAT-COLTEXT  = '생성일'.
  LS_FCAT-COL_POS = 11.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'APPR'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STATUS'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_STATUS
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_STATUS .  " ALV 상태 업데이트 시키기
  LOOP AT GT_ZTBSD0010 INTO GS_ZTBSD0010.
   DATA LS_STYLE TYPE LVC_S_STYL.

*   신호등 UPDATE APPE 상신여부 0 미승인, 1 승인, 2 최종승인
   IF GS_ZTBSD0010-APPR = 1.
    GS_ZTBSD0010-EXCP = '2'.
   ELSEIF GS_ZTBSD0010-APPR = 2.
    GS_ZTBSD0010-EXCP = '3'. " GREEN
   ELSE.
    GS_ZTBSD0010-EXCP = '1'. " RED
   ENDIF.

*  진행 상태 STATUS 필요/진행중/취소/중단/완료
*   DOMVALUE_L TYPE이 C 임
   DATA : LS_STATUS TYPE CHAR1,
      GT_DD07V TYPE STANDARD TABLE OF DD07V.  " Fixed Value 가져오기 위함

*  Fixed Value 가져오기
   PERFORM GET_DOMAIN_VAL TABLES GT_DD07V.

   LS_STATUS = GS_ZTBSD0010-STATUS.

   READ TABLE GT_DD07V WITH KEY DOMVALUE_L = LS_STATUS INTO DATA(LS_DD07V).
*   Fixed Value 값 넣기
   GS_ZTBSD0010-SOP_STATUS_TXT = LS_DD07V-DDTEXT.

* APPR이 1일 경우에만 체크박스 활성화
   LS_STYLE-FIELDNAME = 'CHECK'.
   IF GS_ZTBSD0010-APPR = 1.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
   ELSE.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
   ENDIF.
   INSERT LS_STYLE INTO TABLE GS_ZTBSD0010-STTAB.

   CLEAR LS_STYLE.

*  반려사유가 있다면 버튼 아이콘 넣기
   LS_STYLE-FIELDNAME = 'REJREASON'.
   IF GS_ZTBSD0010-REJREASON IS NOT INITIAL.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
    GS_ZTBSD0010-REJREASON = ICON_DISPLAY_TEXT.
   ENDIF.

   INSERT LS_STYLE INTO TABLE GS_ZTBSD0010-STTAB.


   MODIFY GT_ZTBSD0010 FROM GS_ZTBSD0010.
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
 FORM GET_DOMAIN_VAL TABLES GT_DD07V.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
   EXPORTING
    DOMNAME  = 'ZDB_SOPSTATUS'  " Domain 값을 넣으면 된다. "
    TEXT    = 'X'
   TABLES
    VALUES_TAB = GT_DD07V.  " SAP 안에 기본으로 있는 TABLE이다. 무조건 이거 써야 함

  PERFORM ERROR USING 'GET_DOMAIN_VALUES'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SUBRC
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> SY_SUBRC
 *&---------------------------------------------------------------------*
 FORM SUBRC USING P_SY_SUBRC.
  IF SY-SUBRC = 0.
   COMMIT WORK.  " 변화 사항들을 저장한다. INSERT는 바로 DB에 반영되지 않음
   PERFORM MESSAGE_INFO USING 'SUCCESS'.
  ELSE.
   ROLLBACK WORK.
   PERFORM MESSAGE_INFO USING 'ERROR'. " 에러
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ON_BUTTON_CLICK
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> ES_ROW_NO
 *&---------------------------------------------------------------------*
 FORM ON_BUTTON_CLICK USING P_ROW_NO TYPE LVC_S_ROID.
* IDX로 데이터 가져오기
  READ TABLE GT_ZTBSD0010 INTO GS_ZTBSD0010 INDEX P_ROW_NO-ROW_ID.

  SELECT SINGLE A~REJREASON
   FROM ZTBSD0010 AS A
   WHERE A~SOPNUM = @GS_ZTBSD0010-SOPNUM
   INTO @DATA(LS_ZTBSD0010).

  PERFORM ERROR USING 'SELECT'.

  IF LS_ZTBSD0010 IS INITIAL.
   PERFORM MESSAGE_INFO USING 'NONE'.
   RETURN.
  ENDIF.

  " 반려 사유 적힌 팝업창 띄우기
  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
   EXPORTING
    TITEL   = '반려 사유'
    TEXTLINE1 = LS_ZTBSD0010.

  PERFORM ERROR USING 'POPUP'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ERROR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> SY_SUBRC
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
 *& Form SET_REGISTER_EVENT2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_REGISTER_EVENT2_0100 .
  GO_ALV2->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER ).
  GO_ALV2->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CREATE.

*  판매계획 생성 버튼 클릭, TAB이 잘못 와 있다면 돌려놓기
  IF G_TABSTRIP-ACTIVETAB <> 'TAB_C'.
   G_TABSTRIP-ACTIVETAB = 'TAB_C'.
  ENDIF.

*  필수값 입력 안했으면 경고창 띄워
  IF ZTBSD0010-CTRYCODE IS INITIAL.
   PERFORM MESSAGE_INFO USING 'REQ'.
   RETURN.
  ENDIF.

* 계획 세우기를 하지 않았다면 경고
  DATA LS_CHECK_CTRYCODE TYPE ZTBSD0011-CTRYCODE.
  LOOP AT GT_ZTBSD0011 INTO GS_ZTBSD0011 FROM 1.
   LS_CHECK_CTRYCODE = GS_ZTBSD0011-CTRYCODE .
  ENDLOOP.

  IF ZTBSD0010-CTRYCODE <> LS_CHECK_CTRYCODE.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '124'.
   PERFORM CHECK_INPUT. " 편집모드로 돌려놓기
   RETURN.
  ENDIF.

* 생성 하겠냐는 컨펌창 띄우기
  PERFORM CON_POPUP USING '생성' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  IF GT_ZTBSD0010 IS INITIAL.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '113'.
   RETURN.
  ENDIF.

* 판매운영계획 Header 넣기
  LOOP AT GT_ZTBSD0010 INTO GS_ZTBSD0010.
   MOVE-CORRESPONDING GS_ZTBSD0010 TO ZTBSD0010.
   INSERT ZTBSD0010 FROM ZTBSD0010.
  ENDLOOP.

* 판매운영계획 Item 넣기
  LOOP AT GT_ZTBSD0011 INTO GS_ZTBSD0011.
   MOVE-CORRESPONDING GS_ZTBSD0011 TO ZTBSD0011.
   INSERT ZTBSD0011 FROM ZTBSD0011.
  ENDLOOP.

  PERFORM SUBRC USING SY-SUBRC.
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
  GO_ALV->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER ).
  GO_ALV->REGISTER_EDIT_EVENT( EXPORTING I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED ).
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ALV_ITEM
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> LS_MODI_ROW_ID
 *&---------------------------------------------------------------------*
 FORM ALV_ITEM USING LS_MODI_ROW_ID.
* 더블클릭한 헤더 INDEX 이용해서데이터 가져오기 ( 판매운영계획 ITEM )
  REFRESH GT_ZTBSD0011.
  READ TABLE GT_ZTBSD0010 INTO GS_ZTBSD0010 INDEX LS_MODI_ROW_ID.

* 자재명도 가져오기
  SELECT A~SOPNUM, A~CTRYCODE, A~MATCODE, B~MATNAME, A~AMOUNTPRD, A~UNITCODE, C~CTRYNAME
   FROM ZTBSD0011 AS A JOIN ZTBMM1011 AS B ON A~MATCODE = B~MATCODE
   JOIN ZTBSD1040 AS C ON A~CTRYCODE = C~CTRYCODE
   WHERE A~SOPNUM = @GS_ZTBSD0010-SOPNUM
   INTO CORRESPONDING FIELDS OF TABLE @GT_ZTBSD0011.

  PERFORM ERROR USING 'SELECT'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form MAX_SOPAMOUN_CHECK
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> LS_MM_PRODTYPE
 *&   <-- GS_MATDATA_AMOUNTPRD
 *&---------------------------------------------------------------------*
 FORM MAX_SOPAMOUN_CHECK USING GS_MATDATA_PRODTYPE
             CHANGING GS_MATDATA_AMOUNT.

  DATA: MAX_AMOUNT TYPE I.

  IF GS_MATDATA-PRODTYPE = 'CAN'.
   MAX_AMOUNT = MAX_CAN / 4.
  ELSEIF GS_MATDATA-PRODTYPE = 'GLA'.
   MAX_AMOUNT = MAX_GLASS / 4.
  ELSE.
   MAX_AMOUNT = MAX_PET / 4.
  ENDIF.

*  최대 생산량을 넘을 경우 최대 생산량 까지만
  IF GS_MATDATA-AMOUNTPRD > MAX_AMOUNT.
   GS_MATDATA-AMOUNTPRD = MAX_AMOUNT.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ON_DATA_CHANGED_FINISHED
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> E_MODIFIED
 *&   --> ET_GOOD_CELLS
 *&---------------------------------------------------------------------*
 FORM ON_DATA_CHANGED_FINISHED USING E_MODIFIED
                    ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA : LS_MODI TYPE LVC_S_MODI.
  CHECK E_MODIFIED IS NOT INITIAL.
  LS_MODI = VALUE #( ET_GOOD_CELLS[ 1 ] ).

  IF LS_MODI-FIELDNAME <> 'AMOUNTPRD'.
   RETURN.
  ENDIF.

  READ TABLE GT_ZTBSD0011 INTO GS_ZTBSD0011 INDEX LS_MODI-ROW_ID.
  READ TABLE GT_AMOUNT INTO GS_AMOUNT INDEX LS_MODI-ROW_ID.

  IF GS_AMOUNT-AMOUNTPRD < LS_MODI-VALUE.
   GS_ZTBSD0011-AMOUNTPRD = GS_AMOUNT-AMOUNTPRD.
   MESSAGE S104 DISPLAY LIKE 'W' WITH GS_AMOUNT-AMOUNTPRD. " 수량 제한 경고창
  ELSE.
   GS_ZTBSD0011-AMOUNTPRD = LS_MODI-VALUE.
  ENDIF.

  MODIFY GT_ZTBSD0011 FROM GS_ZTBSD0011 INDEX LS_MODI-ROW_ID.

  PERFORM ALV_REFRESH.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ON_TOOLBAR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> E_OBJECT
 *&   --> E_INTERACTIVE
 *&   --> SENDER
 *&---------------------------------------------------------------------*
 FORM ON_TOOLBAR USING PO_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET.

  DATA LS_TOOLBAR LIKE LINE OF PO_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = 3. " 구분자(SEPARATOR)
  APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = 0.
  LS_TOOLBAR-FUNCTION = 'APPR_BTN'.
  LS_TOOLBAR-TEXT = ' 최종승인 '.
  LS_TOOLBAR-ICON = ICON_CHECKED.
  APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = 3. " 구분자(SEPARATOR)
  APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.

  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-BUTN_TYPE = 0.
  LS_TOOLBAR-FUNCTION = 'REFRESH'.
  LS_TOOLBAR-TEXT = ' 새로고침 '.
  LS_TOOLBAR-ICON = ICON_REFRESH.
  APPEND LS_TOOLBAR TO PO_OBJECT->MT_TOOLBAR.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form APPR_BTN
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM APPR_BTN.  " 최종 승인 버튼

  DATA : LT_ZTBSD0010 LIKE TABLE OF GS_ZTBSD0010,
     LS_MSG    TYPE CHAR3,
     YEAR2    TYPE N LENGTH 4,
     YEARS    TYPE N LENGTH 4,
     LV_NUM    TYPE N.

* CHECK = 'X'인 값 가져오기
  LOOP AT GT_ZTBSD0010 INTO GS_ZTBSD0010 WHERE ( CHECK = ABAP_TRUE ).
   APPEND GS_ZTBSD0010 TO LT_ZTBSD0010.
  ENDLOOP.

* 이미 APPR이 2 라면 RETURN
  LOOP AT LT_ZTBSD0010 INTO DATA(LS_DATA) WHERE ( APPR = 2 ).
   LV_NUM += 1.
  ENDLOOP.

  READ TABLE LT_ZTBSD0010 INTO DATA(WA_B2) INDEX 1.

  YEAR2 = WA_B2-SALESYEAR.

  IF LV_NUM <> 0.
   LS_MSG = '109'.
  ELSEIF LT_ZTBSD0010 IS INITIAL. " 선택한게 없을 경우
   LS_MSG = '110'.
  ELSEIF LINES( LT_ZTBSD0010 ) <> 4."총 4개 인지 확인
   LS_MSG = '111'.
  ENDIF.


  IF LS_MSG IS NOT INITIAL.
   PERFORM W_POP_ERROR USING LS_MSG YEAR2+0(4).
   RETURN.
  ENDIF.

  READ TABLE LT_ZTBSD0010 INDEX 1 INTO DATA(LS_ONE).
  LV_NUM = 0.
  YEARS = LS_ONE-SALESYEAR.
* 연도가 서로 다르지 않은지 확인
  LOOP AT LT_ZTBSD0010 INTO DATA(LS_DATA2).
   IF YEARS NE LS_DATA2-SALESYEAR.
    LV_NUM += 1.
    LS_MSG = '125'.
   ENDIF.
   YEARS = LS_DATA2-SALESYEAR.
  ENDLOOP.

  IF LS_MSG IS NOT INITIAL.
   PERFORM W_POP_ERROR USING LS_MSG YEAR2+0(4).
   RETURN.
  ENDIF.

*  중복된 국가가 있는지 체크
  LOOP AT LT_ZTBSD0010 ASSIGNING FIELD-SYMBOL(<WA>) GROUP BY ( KEY = <WA>-CTRYCODE
                                COUNT = GROUP SIZE ) INTO DATA(GROUP).
   IF GROUP-COUNT > 1.
    LS_MSG = '112'.
    PERFORM W_POP_ERROR USING LS_MSG YEAR2+0(4).
    RETURN.
   ENDIF.
  ENDLOOP.

  PERFORM CON_POPUP USING '최종승인' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  LOOP AT LT_ZTBSD0010 INTO DATA(LS_HEADER).
*  APPR 상태 값 2로 바꾸기
   UPDATE ZTBSD0010 SET APPR = 2 WHERE SOPNUM = LS_HEADER-SOPNUM.
  ENDLOOP.

  PERFORM SOP_READ.
  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form W_POP_ERROR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> LS_TXT
 *&---------------------------------------------------------------------*
 FORM W_POP_ERROR USING MSG YEAR2.
  IF MSG = '109'.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER MSG WITH YEAR2.
  ELSE.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER MSG.
  ENDIF.
  PERFORM ERROR USING 'ZCOMMON_MSG'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CHECK_INPUT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CHECK_INPUT .
  DATA LV_CHECK TYPE I.

  LV_CHECK = GO_ALV->IS_READY_FOR_INPUT( ).

  CASE LV_CHECK.
   WHEN 0. " 조회모드일때 "
    CALL METHOD GO_ALV->SET_READY_FOR_INPUT " 조회모드 -> 편집모드 "
     EXPORTING
      I_READY_FOR_INPUT = 1. " Edit 활성화 "

   WHEN 1. " 편집모드일때 "
    CALL METHOD GO_ALV->SET_READY_FOR_INPUT " 편집모드 -> 조회모드 "
     EXPORTING
      I_READY_FOR_INPUT = 0. " Edit 비활성화 "
  ENDCASE.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form HANDLE_USER_COMMAND
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> E_UCOMM
 *&   --> SENDER
 *&---------------------------------------------------------------------*
 FORM HANDLE_USER_COMMAND USING E_UCOMM TYPE SY-UCOMM
                E_GRID TYPE REF TO CL_GUI_ALV_GRID.

  IF G_TABSTRIP-ACTIVETAB <> 'TAB_R'.  " 생성 탭에 있다면 에러 메시지
   MESSAGE S103 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.

  CASE E_GRID.
   WHEN GO_ALV2.
    CASE E_UCOMM.
     WHEN 'APPR_BTN'.   " 최종승인 버튼
      PERFORM APPR_BTN.
     WHEN 'REFRESH'.    " 새로고침 버튼
      PERFORM REFRESH_BTN.
     WHEN OTHERS.
    ENDCASE.
  ENDCASE.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form REFRESH_BTN
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM REFRESH_BTN .
  PERFORM SOP_READ.
  PERFORM ALV_REFRESH.
 ENDFORM.
