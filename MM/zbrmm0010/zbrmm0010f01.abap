*&---------------------------------------------------------------------*
 *& Form SET_LAYOUT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_LAYOUT_0100.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = '재고현황 리스트'.
  GS_LAYOUT-CTAB_FNAME = 'IT_COL'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_FIELDCAT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_FIELDCAT_0100.
  DATA: LS_FCAT TYPE LVC_S_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'WHCODE'.
  LS_FCAT-COLTEXT  = '창고코드'.
  LS_FCAT-COL_POS = 1.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'WHNAME'.
  LS_FCAT-COLTEXT  = '창고명'.
  LS_FCAT-COL_POS = 2.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATCODE'.
  LS_FCAT-COLTEXT  = '자재 번호'.
  LS_FCAT-COL_POS = 3.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATNAME'.
  LS_FCAT-COLTEXT  = '자재명'.
  LS_FCAT-COL_POS = 4.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATTYPE_TXT'.
  LS_FCAT-COLTEXT  = '자재유형이름'.
  LS_FCAT-COL_POS = 5.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATTYPE'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CURRSTOCK'.
  LS_FCAT-COLTEXT  = '현 재고 수량'.
  LS_FCAT-COL_POS = 6.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'UNITCODE1'.
  LS_FCAT-COLTEXT  = '단위'.
  LS_FCAT-COL_POS = 7.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SAFESTOCK'.
  LS_FCAT-COLTEXT  = '적정재고 수량'.
  LS_FCAT-COL_POS = 8.
  APPEND LS_FCAT TO GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'UNITCODE2'.
  LS_FCAT-COLTEXT  = '단위'.
  LS_FCAT-COL_POS = 9.
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
  CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
 *   Local Structure는 올 수 없다.
    I_STRUCTURE_NAME = 'ZTBMM0030'
    IS_LAYOUT    = GS_LAYOUT
   CHANGING
    IT_OUTTAB    = GT_ALV_ZTBMM0030
    IT_FIELDCATALOG = GT_FCAT.

  PERFORM ERROR USING 'SET_TABLE'.
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
 *& Form GET_DATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&---------------------------------------------------------------------*
 FORM GET_DATA_HEADER.
 * 재고현황 리스트 가져오기
  SELECT A~WHCODE, B~WHNAME, A~MATCODE, C~MATNAME, A~MATTYPE,
     A~CURRSTOCK, A~UNITCODE1, A~SAFESTOCK, A~UNITCODE2
   FROM ZTBMM0030 AS A
   JOIN ZTBMM1030 AS B ON A~WHCODE = B~WHCODE " 창고마스터 테이블
   JOIN ZTBMM1011 AS C ON A~MATCODE = C~MATCODE " 자재 Text 테이블
   WHERE A~MATTYPE = 'C'  " 재고현황 테이블에서 자재유형이 완제품만
   ORDER BY A~WHCODE, A~MATCODE
   INTO CORRESPONDING FIELDS OF TABLE @GT_ALV_ZTBMM0030.

  PERFORM SUBRC USING '조회'.

 * Fixed Value 가져오기
  PERFORM GET_DOMAIN_VAL TABLES GT_FX_MATTYPE USING 'ZDB_MATTYPE'. " 자재유형

  LOOP AT GT_ALV_ZTBMM0030 INTO GS_ALV_ZTBMM0030.

   DATA : LS_STYLE TYPE LVC_S_STYL,
      LS_STATUS TYPE CHAR1.

 *  제품유형 타입 Fixed Value 가져오기
   LS_STATUS = GS_ALV_ZTBMM0030-MATTYPE.
   READ TABLE GT_FX_MATTYPE WITH KEY DOMVALUE_L = LS_STATUS INTO DATA(LS_SOSTATUS).
   GS_ALV_ZTBMM0030-MATTYPE_TXT = LS_SOSTATUS-DDTEXT.

 *  창고별 제품 수량 잘 합산해서 가져오기 (DB View 사용)
   SELECT SUM( A~AMOUNTPRD ) AS AMOUNT
    FROM ZVBMM0011 AS A
    WHERE A~WHCODE = @GS_ALV_ZTBMM0030-WHCODE
     AND A~MATCODE = @GS_ALV_ZTBMM0030-MATCODE
    INTO @DATA(LS_AMOUNT).

   PERFORM SUBRC USING '조회'.

   GS_ALV_ZTBMM0030-CURRSTOCK = GS_ALV_ZTBMM0030-CURRSTOCK - LS_AMOUNT.

   MODIFY GT_ALV_ZTBMM0030 FROM GS_ALV_ZTBMM0030.
   PERFORM ERROR USING 'MODIFY'.

  ENDLOOP.

 * 일단 서브 창고 가져오기
  SELECT DISTINCT A~WHCODE, A~WHNAME
   FROM ZTBMM1030 AS A
   JOIN ZTBMM0030 AS B ON A~WHCODE = B~WHCODE
   WHERE A~WHTYPE = 'C'
   ORDER BY A~WHCODE
   INTO TABLE @DATA(LT_WHCODE).

  PERFORM SUBRC USING '조회'.

  READ TABLE LT_WHCODE WITH KEY WHCODE = PA_WH INTO DATA(LS_MAINWH). " MAIN 먼저 빼내고

  DELETE LT_WHCODE WHERE WHCODE = PA_WH.  " 메인 먼저 지워놓기

  READ TABLE LT_WHCODE INTO DATA(LS_WHCODE) INDEX 1.
  READ TABLE LT_WHCODE INTO DATA(LS_WHCODE2) INDEX 2.

 * 3개의 창고중 메인창고는 지우고 서브창고 두개만 가지고 와서 창고 이름과 매칭
  ZSBMM0011 = VALUE #( SUB_WHCODE1 = LS_WHCODE-WHCODE
            SUB_WHNAME1 = LS_WHCODE-WHNAME
            SUB_WHCODE2 = LS_WHCODE2-WHCODE
            SUB_WHNAME2 = LS_WHCODE2-WHNAME
            MAIN_WHCODE = LS_MAINWH-WHCODE
            MAIN_WHNAME = LS_MAINWH-WHNAME ).

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_DOMAIN_VAL
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DOMAIN_VAL TABLES P_ITAB USING P_VAL.

  CALL FUNCTION 'GET_DOMAIN_VALUES'
   EXPORTING
    DOMNAME  = P_VAL  " Domain 값을 넣으면 된다. "
    TEXT    = 'X'
   TABLES
    VALUES_TAB = P_ITAB.  " SAP 안에 기본으로 있는 TABLE이다. 무조건 이거 써야 함

  PERFORM ERROR USING 'GET_DOMAIN_VALUES'.

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
 *
  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'WHCODE'.
  LS_FCAT-COLTEXT  = '창고코드'.
  LS_FCAT-COL_POS  = 1.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'WHNAME'.
  LS_FCAT-COLTEXT  = '창고명'.
  LS_FCAT-COL_POS  = 2.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATCODE'.
  LS_FCAT-COLTEXT  = '자재번호'.
  LS_FCAT-COL_POS  = 3.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATNAME'.
  LS_FCAT-COLTEXT  = '자재명'.
  LS_FCAT-COL_POS  = 4.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'PRV_AMOUNT'.
  LS_FCAT-COLTEXT  = '이전수량'.
  LS_FCAT-DECIMALS_O = '0'.
  LS_FCAT-COL_POS  = 5.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MOVE_AMOUNT'.
  LS_FCAT-COLTEXT  = '이동수량'.
  LS_FCAT-DECIMALS_O = '0'.
  LS_FCAT-COL_POS  = 6.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'CURRSTOCK'.
  LS_FCAT-COLTEXT  = '현재수량'.
  LS_FCAT-COL_POS  = 7.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'MATTYPE'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'UNITCODE1'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'SAFESTOCK'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'UNITCODE2'.
  LS_FCAT-NO_OUT = ABAP_TRUE.
  APPEND LS_FCAT TO GT_FCAT2.

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
  GS_LAYOUT2-GRID_TITLE = '재고이동 내역'.
  GS_LAYOUT2-CTAB_FNAME = 'IT_COL'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_DISPLAY2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_DISPLAY2_0100 .
  CALL METHOD GO_ALV2->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
 *    Local Structure는 올 수 없다.
    I_STRUCTURE_NAME = 'ZTBMM0030'
    IS_LAYOUT    = GS_LAYOUT2
   CHANGING
    IT_OUTTAB    = GT_ALV_ZTBMM0031
    IT_FIELDCATALOG = GT_FCAT2.

  PERFORM ERROR USING 'SET_TABLE'.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SUBRC
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> SY_SUBRC
 *&---------------------------------------------------------------------*
 FORM SUBRC USING P_VALUE.
  IF SY-SUBRC <> 0.
   MESSAGE S094 DISPLAY LIKE 'E' WITH P_VALUE.
   RETURN.
  ELSE.
   MESSAGE S095 DISPLAY LIKE 'S' WITH P_VALUE.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form MOVE_BTN
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM MOVE_BTN. " 재고이동 버튼 클릭
 * 재고이동 버튼을 눌렀을 때, 수량이 잘 맞는지 체크 필요함
 * 입고 : ZSBMM0010-DEL_WH , 출고 : ZSBMM0010-STO_WH
 * 자재번호 : ZSBMM0010-MATCODE, 입력수량 : PRICE
 * UPDATE : ZBBMM0030

  IF ZSBMM0010-DEL_WH = ZSBMM0010-STO_WH.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '117'. " 입/출고 창고가 같다면 오류
   RETURN.
  ENDIF.

 * 2. 출고 창고 수량 체크
  READ TABLE GT_ALV_ZTBMM0030
   WITH KEY WHCODE = ZSBMM0010-STO_WH MATCODE = ZSBMM0010-MATCODE
   INTO GS_ALV_ZTBMM0030.

  IF GS_ALV_ZTBMM0030-CURRSTOCK IS INITIAL. " 출고 창고 수량이 0이면 에러
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '122'. " 출고 수량이 없어요
   RETURN.
  ENDIF.

 * 3. 예외 처리
  IF SCREEN_AMOUNT > GS_ALV_ZTBMM0030-CURRSTOCK.  " 입력 수량 > 출고 창고 수량
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '115'. " 출고 수량 많아요
   RETURN.
  ENDIF.

 * 재고이동 하겠냐는 팝업창
  DATA LV_ANSWER TYPE CHAR1.
  PERFORM CON_POPUP CHANGING LV_ANSWER.
  CHECK LV_ANSWER = '1'.

  DATA AMOUNT TYPE ZTBMM0030-CURRSTOCK.
  AMOUNT = SCREEN_AMOUNT.

 * 출고 재고수량 업데이트
  UPDATE ZTBMM0030
   SET CURRSTOCK = CURRSTOCK - AMOUNT
   WHERE MATCODE = ZSBMM0010-MATCODE
    AND WHCODE = ZSBMM0010-STO_WH
    AND MATTYPE = 'C'.

 * 입고 채고수량 업데이트
  UPDATE ZTBMM0030
   SET CURRSTOCK = CURRSTOCK + AMOUNT
   WHERE MATCODE = ZSBMM0010-MATCODE
    AND WHCODE = ZSBMM0010-DEL_WH
    AND MATTYPE = 'C'.

  MESSAGE S119 DISPLAY LIKE 'S'.

 * 내역 저장 후 화면 새로고침.
  PERFORM GET_DATA_HEADER_REFRESH.
  PERFORM ALV_REFRESH.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CON_POPUP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CON_POPUP CHANGING LV_ANSWER.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR       = | 재고이동 프로그램 |
    TEXT_QUESTION     = | 재고이동을 하시겠습니까? |
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
 *& Form CHECK_AMOUNT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CHECK_AMOUNT_DEL. " 스크린필터 입고 창고 업데이트

  DATA CURRSTOCK TYPE ZSBMM0011-MAIN_AMOUNT.
  CURRSTOCK = SCREEN_AMOUNT.

  IF ZSBMM0011-SUB_WHCODE1 = ZSBMM0010-DEL_WH.
   ZSBMM0011-SUB_AMOUNT1 = ZSBMM0011-SUB_AMOUNT1 + CURRSTOCK.
  ELSEIF ZSBMM0011-SUB_WHCODE2 = ZSBMM0010-DEL_WH.
   ZSBMM0011-SUB_AMOUNT2 = ZSBMM0011-SUB_AMOUNT2 + CURRSTOCK.
  ELSE.
   ZSBMM0011-MAIN_AMOUNT = ZSBMM0011-MAIN_AMOUNT + CURRSTOCK.
  ENDIF.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CHECK_AMOUNT_STO
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CHECK_AMOUNT_STO. " 스크린필터 출고 창고 업데이트

  DATA CURRSTOCK TYPE ZSBMM0011-MAIN_AMOUNT.
  CURRSTOCK = SCREEN_AMOUNT.

  IF ZSBMM0011-SUB_WHCODE1 = ZSBMM0010-STO_WH.
   ZSBMM0011-SUB_AMOUNT1 = ZSBMM0011-SUB_AMOUNT1 - CURRSTOCK.
  ELSEIF ZSBMM0011-SUB_WHCODE2 = ZSBMM0010-STO_WH.
   ZSBMM0011-SUB_AMOUNT2 = ZSBMM0011-SUB_AMOUNT2 - CURRSTOCK.
  ELSE.
   ZSBMM0011-MAIN_AMOUNT = ZSBMM0011-MAIN_AMOUNT - CURRSTOCK.
  ENDIF.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_DATA_HEADER_REFRESH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_DATA_HEADER_REFRESH.  " 재고현황 리스트 업데이트

  DATA : CURRSTOCK TYPE ZSBMM0011-MAIN_AMOUNT.

  CURRSTOCK = SCREEN_AMOUNT.

 * 재고현황 리스트 가져오기
  LOOP AT GT_ALV_ZTBMM0030 INTO GS_ALV_ZTBMM0030.

   CLEAR : GS_ALV_ZTBMM0030-IT_COL.

   DATA : LS_SCOL  TYPE LVC_S_SCOL. " 셀에 컬러 넣기

 *  바뀐 수량 다시 잘 가져와라
   IF GS_ALV_ZTBMM0030-WHCODE = ZSBMM0010-STO_WH AND GS_ALV_ZTBMM0030-MATCODE = ZSBMM0010-MATCODE.

    LS_SCOL = VALUE #( FNAME = 'CURRSTOCK'
             COLOR-INT = 0
             COLOR-INV = 0
             COLOR-COL = 6 ).
     
    GS_ALV_ZTBMM0030 = VALUE #( BASE GS_ALV_ZTBMM0030 MOVE_AMOUNT = CURRSTOCK
                             PRV_AMOUNT = GS_ALV_ZTBMM0030-CURRSTOCK
                             CURRSTOCK = GS_ALV_ZTBMM0030-CURRSTOCK - CURRSTOCK ).
     
    APPEND LS_SCOL TO GS_ALV_ZTBMM0030-IT_COL.
    INSERT GS_ALV_ZTBMM0030 INTO TABLE GT_ALV_ZTBMM0031.

   ENDIF.

   IF GS_ALV_ZTBMM0030-WHCODE = ZSBMM0010-DEL_WH AND GS_ALV_ZTBMM0030-MATCODE = ZSBMM0010-MATCODE.

    LS_SCOL = VALUE #( FNAME = 'CURRSTOCK'
             COLOR-INT = 0
             COLOR-INV = 0
             COLOR-COL = 5 ).
     
    GS_ALV_ZTBMM0030 = VALUE #( BASE GS_ALV_ZTBMM0030 MOVE_AMOUNT = CURRSTOCK
                             PRV_AMOUNT = GS_ALV_ZTBMM0030-CURRSTOCK
                             CURRSTOCK = GS_ALV_ZTBMM0030-CURRSTOCK + CURRSTOCK ).
     
    APPEND LS_SCOL TO GS_ALV_ZTBMM0030-IT_COL.
    INSERT GS_ALV_ZTBMM0030 INTO TABLE GT_ALV_ZTBMM0031.

   ENDIF.

   MODIFY GT_ALV_ZTBMM0030 FROM GS_ALV_ZTBMM0030.
   PERFORM ERROR USING 'MODIFY'.

  ENDLOOP.

  PERFORM CHECK_AMOUNT_DEL.
  PERFORM CHECK_AMOUNT_STO.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form RESET
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM RESET.
  REFRESH : GT_ALV_ZTBMM0031, GT_ALV_ZTBMM0030.
  CLEAR : ZSBMM0010, ZTBMM0030, GS_ALV_ZTBMM0030, SCREEN_AMOUNT.
  PERFORM ALV_REFRESH.
 ENDFORM.
