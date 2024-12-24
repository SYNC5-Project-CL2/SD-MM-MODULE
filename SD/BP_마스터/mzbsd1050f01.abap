*&---------------------------------------------------------------------*
 *& Include     MZBSD1050F01
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
* BP MASTER READ 조회하기

* 검색 조건 3개 스크린페인터에서 가져오기
  DATA: LT_BPCODE  TYPE RANGE OF ZSSD1050-BPCODE,
     LT_BPTCODE TYPE RANGE OF ZSSD1050-BPTCODE,
     LT_CTRYCODE TYPE RANGE OF ZSSD1050-CTRYCODE.

* where in으로 데이터 조건절 검색
  IF ZSSD1050-BPCODE IS NOT INITIAL.
   LT_BPCODE = VALUE #( ( SIGN = 'I'
               OPTION = 'EQ'
               LOW = ZSSD1050-BPCODE ) ).
  ENDIF.

  IF ZSSD1050-BPTCODE IS NOT INITIAL.
   LT_BPTCODE = VALUE #( ( SIGN = 'I'
               OPTION = 'EQ'
               LOW = ZSSD1050-BPTCODE ) ).
  ENDIF.

  IF ZSSD1050-CTRYCODE IS NOT INITIAL.
   LT_CTRYCODE = VALUE #( ( SIGN = 'I'
                OPTION = 'EQ'
                LOW = ZSSD1050-CTRYCODE ) ).
  ENDIF.

* 라디오 버튼 삭제 플래그 조건절 디폴트 : VALID
  DATA LV_DEL TYPE CHAR1 VALUE '%'.

  IF ZSSD1050-VALID = ABAP_TRUE.
   LV_DEL = ''.
  ELSEIF ZSSD1050-DELETED = ABAP_TRUE.
   LV_DEL = 'X'.
  ENDIF.

  IF P_TYPE <> 'INIT'.
   REFRESH GT_BPDATA.
   APPEND GS_BPDATA TO GT_BPDATA.
  ELSE.
*  CDS View를 생성해서 넣어줌
*  BP코드를 내림차순으로 정렬 후 조회한다.
   SELECT *
    FROM ZCDS_BP
    INTO CORRESPONDING FIELDS OF TABLE @GT_BPDATA
    WHERE BPCODE IN @LT_BPCODE AND
       BPTCODE IN @LT_BPTCODE AND
       CTRYCODE IN @LT_CTRYCODE AND
       DELFLG LIKE @LV_DEL
    ORDER BY BPCODE DESCENDING.
  ENDIF.

  PERFORM ERROR USING '조회'.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE_BP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
* BP코드 생성하기
 *&---------------------------------------------------------------------*
 FORM CREATE_BP.

  DATA LV_NUM TYPE CHAR10.

* NUMBER RANGE 완성
  PERFORM GET_NUMBER_RANGE CHANGING LV_NUM.

* 데이터 INSERT 시키기
  ZSBSD50-BPCODE = |BP{ LV_NUM }|.

* TIME STAMP 형식 데이터 넣어주기
  PERFORM ADD_USERID.
  ZSBSD50-STAMP_USER_F = GS_ZTBSD1030-EMPID.
  ZSBSD50-STAMP_DATE_F = SY-DATUM.
  ZSBSD50-STAMP_TIME_F = SY-UZEIT.
  ZSBSD50-DELFLG = ' '.

  MOVE-CORRESPONDING ZSBSD50 TO GS_BPDATA.

* 생성 하겠냐는 컨펌창 띄우기
  PERFORM CON_POPUP USING '생성' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  MOVE-CORRESPONDING GS_BPDATA TO GS_ZTBSD1050.
  MOVE-CORRESPONDING GS_BPDATA TO GS_ZTBSD1051.
  GS_ZTBSD1051-SPARS = SY-LANGU.

* 정규표현식으로 사업자 번호 확인하기
  DATA : V_PATTERN TYPE STRING,
     LV_SUCCESS TYPE C.
  V_PATTERN = '^\d{3}-\d{2}-\d{5}$'.

  DATA(LO_REGEX) = NEW CL_ABAP_REGEX( PATTERN = V_PATTERN ).
  DATA(MATCH) = LO_REGEX->CREATE_MATCHER( TEXT = GS_ZTBSD1050-BPNUM ).

  LV_SUCCESS = MATCH->MATCH( ).  " 정상이면 X , 비정상이면 INITT

  IF LV_SUCCESS <> 'X'.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '002' WITH '사업자번호'.
   MESSAGE S100 DISPLAY LIKE 'E' WITH 'REGEX'.
   RETURN.
  ENDIF.

  INSERT INTO ZTBSD1050 VALUES GS_ZTBSD1050.
  INSERT INTO ZTBSD1051 VALUES GS_ZTBSD1051.

  PERFORM GET_DATA USING 'CREATE'.
  PERFORM ALV_REFRESH.

  PERFORM ERROR USING '생성'.

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
  CLEAR: GS_ROW.
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
 *& Form UPDATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM UPDATE .
  CALL METHOD GO_ALV->GET_SELECTED_ROWS
   IMPORTING
    ET_ROW_NO = GT_ROW.

* 만약 행을 선택하지 않고 수정 버튼을 누른다면 경고창
  IF GT_ROW IS INITIAL.
   PERFORM POPUP_MSG USING 'ROW'.
   RETURN.
  ENDIF.

* 선택한 행에 맞는 데이터 들고와서 수정 팝업창에 띄우기
  READ TABLE GT_ROW INTO GS_ROW INDEX 1.
  READ TABLE GT_BPDATA INTO GS_BPDATA INDEX GS_ROW-ROW_ID.

  BANKCODE = GS_BPDATA-BANKCODE.

  MOVE-CORRESPONDING GS_BPDATA TO ZSBSD50.

*  만약 이미 삭제된 데이터라면 RETURN.
  IF GS_BPDATA-DELFLG = 'X'.
   PERFORM POPUP_MSG USING 'DELETE'.
   RETURN.
  ENDIF.

  CALL SCREEN 120
   STARTING AT 10 10.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form REFRESH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM REFRESH .
  IF SY-SUBRC = 0.
   PERFORM GET_DATA USING 'INIT'.
   PERFORM ALV_REFRESH.
   MESSAGE S095 DISPLAY LIKE 'S' WITH '조회'.
  ELSE.
   MESSAGE S094 DISPLAY LIKE 'E' WITH '조회'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form RESET
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM RESET .
* 새로고침 버튼을 누르면 ALV 화면도 초기화 , 라디오 버튼 및 입력필드도 초기화 시킨다.
  CLEAR: GT_BPDATA, ZSSD1050.
  PERFORM RADIO_RESET.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form radio_reset
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM RADIO_RESET .
  IF ZSSD1050-VALID IS INITIAL AND ZSSD1050-ALL IS INITIAL AND
   ZSSD1050-DELETED IS INITIAL.
   ZSSD1050-VALID = 'X'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form popup_msg
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> ROW
 *&---------------------------------------------------------------------*
 FORM POPUP_MSG USING P_ROW.
  IF P_ROW = 'ROW'.
   MESSAGE S008 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'DELETE'.
   MESSAGE S014 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'ERROR'.
   MESSAGE S016 DISPLAY LIKE 'E'.
  ELSEIF P_ROW = 'SUCCESS'.
   MESSAGE S095 DISPLAY LIKE 'S'.
  ELSEIF P_ROW = 'REQ'.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '000'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CON_POPUP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM CON_POPUP USING P_VALUE CHANGING LV_ANSWER.

  DATA DOMAIN TYPE CHAR10 VALUE 'BP'.

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

  IF SY-SUBRC <> 0.
   MESSAGE S016 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form delete
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM DELETE .

  CALL METHOD GO_ALV->GET_SELECTED_ROWS
   IMPORTING
    ET_ROW_NO = GT_ROW.

* 만약 행을 선택하지 않고 삭제 버튼을 누른다면 경고창
  IF GT_ROW IS INITIAL.
   PERFORM POPUP_MSG USING 'ROW'.
   RETURN.
  ENDIF.

  READ TABLE GT_ROW INTO GS_ROW INDEX 1.
  READ TABLE GT_BPDATA INTO GS_BPDATA INDEX GS_ROW-ROW_ID.
  MOVE-CORRESPONDING GS_BPDATA TO ZSBSD50.

* 만약 이미 삭제된 데이터라면 RETURN.
  IF GS_BPDATA-DELFLG = 'X'.
   PERFORM POPUP_MSG USING 'DELETE'.
   RETURN.
  ENDIF.

* 삭제 하겠냐는 컨펌 팝업창 생성
  PERFORM CON_POPUP USING '삭제' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  PERFORM UPDATE_DATA USING '삭제'.
  PERFORM REFRESH.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form UPDATE_BP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM UPDATE_BP .
* 1. 해당 데이터를 수정할거냐?
  PERFORM CON_POPUP USING '수정' CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  PERFORM UPDATE_DATA USING '수정'.
  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form UPDATE_DATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM UPDATE_DATA USING P_TYPE.
* USER ID 가져오기
  PERFORM ADD_USERID.
  ZSBSD50-STAMP_USER_L = GS_ZTBSD1030-EMPID.
  ZSBSD50-STAMP_DATE_L = SY-DATUM.
  ZSBSD50-STAMP_TIME_L = SY-UZEIT.

  IF P_TYPE = '삭제'.
   ZSBSD50-DELFLG = 'X'.
  ENDIF.

  MOVE-CORRESPONDING ZSBSD50 TO GS_BPDATA.
  MOVE-CORRESPONDING GS_BPDATA TO GS_ZTBSD1050.
  MOVE-CORRESPONDING GS_BPDATA TO GS_ZTBSD1051.
  GS_ZTBSD1051-SPARS = SY-LANGU.

  UPDATE ZTBSD1050 FROM GS_ZTBSD1050.
  UPDATE ZTBSD1051 FROM GS_ZTBSD1051.
  MODIFY GT_BPDATA FROM GS_BPDATA INDEX GS_ROW-ROW_ID.

  PERFORM ALV_REFRESH.
  PERFORM GET_DATA USING 'UPDATE'.
  PERFORM ERROR USING P_TYPE.

  CLEAR : GS_BPDATA.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ADD_USERID
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM ADD_USERID .
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.
  READ TABLE GT_ZTBSD1030 INTO GS_ZTBSD1030 WITH KEY LOGID = SY-UNAME.
  PERFORM ERROR USING '조회'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_LAYOUT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LAYOUT .
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = 'BP 리스트'.
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
    OBJECT   = 'ZBBSD1050'
   IMPORTING
    NUMBER   = P_LV_NUM.
  IF SY-SUBRC <> 0.
   PERFORM POPUP_MSG USING 'ERROR'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE_BP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CALL_CREATE_BP .
  CALL SCREEN 110
   STARTING AT 10 10.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_FIELDCAT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_FIELDCAT.
  DATA: LS_FCAT TYPE LVC_S_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'DELFLG'.
  LS_FCAT-COLTEXT  = '삭제플래그'.
  LS_FCAT-CHECKBOX = 'X'.
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
 *& Form SET_LISTBOX
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LISTBOX . " 이 회사엔 은행이 KEB, IBK 두개뿐이라 넣어주는 것
  DATA : LS_DROPLIST TYPE VRM_VALUE,
     LT_DROPLIST TYPE VRM_VALUES.

  CLEAR: LS_DROPLIST.
  LS_DROPLIST-KEY = 'KEB'.
  LS_DROPLIST-TEXT = 'KEB'.
  APPEND LS_DROPLIST TO LT_DROPLIST.

  CLEAR: LS_DROPLIST.
  LS_DROPLIST-KEY = 'IBK'.
  LS_DROPLIST-TEXT = 'IBK'.
  APPEND LS_DROPLIST TO LT_DROPLIST.

  CALL FUNCTION 'VRM_SET_VALUES'
   EXPORTING
    ID   = 'BANKCODE'
    VALUES = LT_DROPLIST. " Listbox Data
 ENDFORM.
