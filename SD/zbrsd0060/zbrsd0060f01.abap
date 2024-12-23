*&---------------------------------------------------------------------*
 *& Include     ZBRSD0060F01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Form GET_DATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DATA USING P_TYPE.

  DATA : RT_MAT  TYPE RANGE OF ZTBSD0080-MATCODE,
     RT_CTRY  TYPE RANGE OF ZTBSD0080-CTRYCODE,
     LV_DELFLG TYPE CHAR1,
     LV_WHERE TYPE STRING.

  IF PA_MAT IS NOT INITIAL.
   RT_MAT = VALUE #( ( SIGN = 'I'
             OPTION = 'EQ'
             LOW = PA_MAT ) ).
  ENDIF.

  IF PA_CTRY IS NOT INITIAL.
   RT_CTRY = VALUE #( ( SIGN = 'I'
             OPTION = 'EQ'
             LOW = PA_CTRY ) ).
  ENDIF.

* 라디오 버튼 적용시키기
  LV_WHERE = |A~DELFLG <> 'X'|.

  IF ALL = 'X'.
   LV_WHERE = |A~DELFLG LIKE '%'|.
  ELSEIF DELETED = 'X'.
   LV_WHERE = |A~DELFLG = 'X'|.
  ENDIF.

  IF P_TYPE <> 'INIT'.
   REFRESH GT_ALV_ZTBSD0080.
   APPEND GS_ALV_ZTBSD0080 TO GT_ALV_ZTBSD0080.
  ELSE.
   SELECT A~MANDT, A~MATCODE,A~CTRYCODE,A~PRICE,A~CURRENCY,A~DELFLG,A~STAMP_DATE_F,
      A~STAMP_TIME_F,A~STAMP_USER_F,A~STAMP_DATE_L,A~STAMP_TIME_L,A~STAMP_USER_L, C~CTRYNAME, B~MATNAME
   FROM ZTBSD0080 AS A JOIN ZTBMM1011 AS B ON A~MATCODE = B~MATCODE
   LEFT JOIN ZTBSD1040 AS C ON A~CTRYCODE = C~CTRYCODE
   INTO CORRESPONDING FIELDS OF TABLE @GT_ALV_ZTBSD0080
   WHERE A~MATCODE IN @RT_MAT
   AND A~CTRYCODE IN @RT_CTRY
   AND (LV_WHERE)
   ORDER BY A~MATCODE, A~CTRYCODE.
  ENDIF.

 

* 담당자명을 넣기 위해서
  REFRESH GT_ZTBSD1030.
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.

  LOOP AT GT_ALV_ZTBSD0080 INTO GS_ALV_ZTBSD0080.
   READ TABLE GT_ZTBSD1030 INTO DATA(LS_NAME) WITH KEY EMPID = GS_ALV_ZTBSD0080-STAMP_USER_F.
   GS_ALV_ZTBSD0080-EMPNAME_F = LS_NAME-EMPNAME.
   CLEAR LS_NAME.
   READ TABLE GT_ZTBSD1030 INTO DATA(LS_NAME2) WITH KEY EMPID = GS_ALV_ZTBSD0080-STAMP_USER_L.
   GS_ALV_ZTBSD0080-EMPNAME_L = LS_NAME2-EMPNAME.
   CLEAR LS_NAME2.
   MODIFY GT_ALV_ZTBSD0080 FROM GS_ALV_ZTBSD0080.
  ENDLOOP.

  PERFORM ERROR USING '조회'.
  CLEAR GS_ALV_ZTBSD0080.

  IF GO_ALV IS NOT INITIAL.
   PERFORM ALV_REFRESH.
  ENDIF.

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
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = '완제품판매가 조회'.
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
  LS_FCAT-FIELDNAME = 'MATCODE'.
  LS_FCAT-COLTEXT  = '자재번호'.
  LS_FCAT-COL_POS = 1.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATNAME'.
  LS_FCAT-COLTEXT  = '자재명'.
  LS_FCAT-COL_POS = 2.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYCODE'.
  LS_FCAT-COLTEXT  = '국가코드'.
  LS_FCAT-COL_POS = 3.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CTRYNAME'.
  LS_FCAT-COLTEXT  = '국가명'.
  LS_FCAT-COL_POS = 4.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'PRICE'.
  LS_FCAT-REF_TABLE = 'ZTBSD0080'.
  LS_FCAT-REF_FIELD = 'CURRENCY'.
  LS_FCAT-CFIELDNAME = 'WAERS'.
  LS_FCAT-COLTEXT  = '완제품 단가'.
  LS_FCAT-COL_POS = 5.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CURRENCY'.
  LS_FCAT-COLTEXT  = '화폐단위'.
  LS_FCAT-COL_POS = 6.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELFLG'.
  LS_FCAT-COLTEXT  = '삭제플래그'.
  LS_FCAT-CHECKBOX = 'X'.
  LS_FCAT-COL_POS = 7.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_DATE_F'.
  LS_FCAT-COLTEXT  = '최초 생성일'.
  LS_FCAT-COL_POS = 8.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_TIME_F'.
  LS_FCAT-COLTEXT  = '최초 생성시간'.
  LS_FCAT-COL_POS = 9.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_USER_F'.
  LS_FCAT-COLTEXT  = '최초 생성자'.
  LS_FCAT-COL_POS = 10.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPNAME_F'.
  LS_FCAT-COLTEXT  = '담당자명'.
  LS_FCAT-COL_POS = 11.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_DATE_L'.
  LS_FCAT-COLTEXT  = '최종 수정일'.
  LS_FCAT-COL_POS = 12.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_TIME_L'.
  LS_FCAT-COLTEXT  = '최종 수정시간'.
  LS_FCAT-COL_POS = 13.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'STAMP_USER_L'.
  LS_FCAT-COLTEXT  = '최종 수정자'.
  LS_FCAT-COL_POS = 14.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EMPNAME_L'.
  LS_FCAT-COLTEXT  = '담당자명'.
  LS_FCAT-COL_POS = 15.
  APPEND LS_FCAT TO GT_FCAT.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ERROR
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM ERROR USING P_VALUE.
  IF SY-SUBRC <> 0.
   MESSAGE S094 DISPLAY LIKE 'E' WITH P_VALUE.
   RETURN.
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
 FORM CREATE.

* 생성해보자
  MOVE-CORRESPONDING ZSSD0080 TO GS_ALV_ZTBSD0080.
  GS_ALV_ZTBSD0080-PRICE = PRICE.

  PERFORM GET_EMPID.
  GS_ALV_ZTBSD0080-DELFLG = ''.

* 만약에 생성이면 최종 생성 시간을 , 아니면 수정 시간을 넣어야 한다
  SELECT SINGLE *
   FROM ZTBSD0080 AS A
   WHERE A~MATCODE = @GS_ALV_ZTBSD0080-MATCODE
    AND A~CTRYCODE = @GS_ALV_ZTBSD0080-CTRYCODE
   INTO @DATA(LT_DATA).


  IF LT_DATA IS INITIAL.
   GS_ALV_ZTBSD0080 = VALUE #( BASE GS_ALV_ZTBSD0080 STAMP_USER_F = GS_ZTBSD1030-EMPID
                            STAMP_DATE_F = SY-DATUM
                            STAMP_TIME_F = SY-UZEIT ).
  ELSE. " 최종생성일도 같이 지워져서 넣어버림
   GS_ALV_ZTBSD0080 = VALUE #( BASE GS_ALV_ZTBSD0080 STAMP_USER_F = LT_DATA-STAMP_USER_F
                            STAMP_DATE_F = LT_DATA-STAMP_DATE_F
                            STAMP_TIME_F = LT_DATA-STAMP_TIME_F
                            STAMP_USER_L = GS_ZTBSD1030-EMPID
                            STAMP_DATE_L = SY-DATUM
                            STAMP_TIME_L = SY-UZEIT ).
  ENDIF.


  DATA: EXTERNAL LIKE BAPICURR-BAPICURR.
  EXTERNAL = PRICE.
  IF ZSSD0080-CURRENCY = 'KRW'.
   PERFORM CAL_CURR CHANGING EXTERNAL.
   GS_ALV_ZTBSD0080-PRICE = EXTERNAL.
  ENDIF.

  MOVE-CORRESPONDING GS_ALV_ZTBSD0080 TO ZTBSD0080.

  MODIFY ZTBSD0080 FROM ZTBSD0080.
  PERFORM ALV_REFRESH.

* 생성 된 데이터만 보여주자
  PERFORM GET_DATA USING 'CREATE'.

  PERFORM ERROR USING '생성'.
  CLEAR GS_ALV_ZTBSD0080.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_EMPID
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_EMPID .
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.
  READ TABLE GT_ZTBSD1030 INTO GS_ZTBSD1030 WITH KEY LOGID = SY-UNAME.
  PERFORM ERROR USING '조회'.
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

  DATA DOMAIN TYPE CHAR10 VALUE '완제품 판매가'.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR       = | { DOMAIN } 데이터 { P_VALUE } |
    TEXT_QUESTION     = | 해당 { DOMAIN } 데이터를 { P_VALUE }하시겠습니까? |
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
 *& Form CHECK_CREATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CHECK_CREATE .
* 생성 하겠냐는 컨펌창 띄우기
  PERFORM CON_POPUP USING '생성' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.
  CALL SCREEN 110
    STARTING AT 10 10.
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
  CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY
   EXCEPTIONS
    FINISHED = 1
    OTHERS  = 2.
  IF SY-SUBRC <> 0.
   MESSAGE S016 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form DELETE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CHECK_ROW USING P_VALUE.
  CALL METHOD GO_ALV->GET_SELECTED_ROWS
   IMPORTING
    ET_ROW_NO = GT_ROW.

* 만약 행을 선택하지 않고 삭제 버튼을 누른다면 경고창
  IF GT_ROW IS INITIAL.
   MESSAGE S008 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.

  READ TABLE GT_ROW INTO GS_ROW INDEX 1.
  READ TABLE GT_ALV_ZTBSD0080 INTO GS_ALV_ZTBSD0080 INDEX GS_ROW-ROW_ID.

* 만약 이미 삭제된 데이터라면 RETURN.
  IF GS_ALV_ZTBSD0080-DELFLG = 'X'.
   MESSAGE S014 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.

* 삭제/수정 하겠냐는 컨펌 팝업창 생성
  PERFORM CON_POPUP USING P_VALUE CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  IF P_VALUE = '수정'.
   MOVE-CORRESPONDING GS_ALV_ZTBSD0080 TO ZSSD0080.
   CALL SCREEN 120
    STARTING AT 10 10.
  ELSE.
   PERFORM UPDATE USING P_VALUE.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form UPDATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM UPDATE USING P_VALUE.

  IF P_VALUE = '삭제'.
   GS_ALV_ZTBSD0080-DELFLG = 'X'.
  ELSE.
*  정규표현식으로 단가 확인하기
   DATA: EXTERNAL  LIKE BAPICURR-BAPICURR,
      LV_SUCCESS TYPE C,
      V_PATTERN TYPE STRING.

   V_PATTERN = '[0-9]'.

   DATA(LO_REGEX) = NEW CL_ABAP_REGEX( PATTERN = V_PATTERN ).
   DATA(MATCH) = LO_REGEX->CREATE_MATCHER( TEXT = PRICE ).

   LV_SUCCESS = MATCH->MATCH( ).  " 정상이면 X , 비정상이면 INITT

   IF LV_SUCCESS <> 'X'.
    MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '002' WITH '판매단가'.
    MESSAGE S100 DISPLAY LIKE 'E' WITH 'REGEX'.
    RETURN.
   ENDIF.

*  다 통과되면 시작
   EXTERNAL = PRICE.
   IF ZSSD0080-CURRENCY = 'KRW'.
    PERFORM CAL_CURR CHANGING EXTERNAL.
   ENDIF.
   GS_ALV_ZTBSD0080-PRICE = EXTERNAL.
  ENDIF.

  MOVE-CORRESPONDING GS_ALV_ZTBSD0080 TO ZTBSD0080.
  MODIFY ZTBSD0080 FROM ZTBSD0080.
  PERFORM ALV_REFRESH.
  PERFORM GET_DATA USING 'UPDATE'.
  PERFORM ERROR USING P_VALUE.
  CLEAR GS_ALV_ZTBSD0080.
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
