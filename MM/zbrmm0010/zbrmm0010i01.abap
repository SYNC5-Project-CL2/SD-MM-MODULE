*&---------------------------------------------------------------------*
 *& Include     ZBRMM0010I01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *&   Module EXIT INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE EXIT INPUT.
  CASE OK_CODE.
   WHEN 'EXIT'.
    LEAVE PROGRAM.
   WHEN 'CANCEL' OR 'BACK'.
    LEAVE TO SCREEN 0.
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module USER_COMMAND_0100 INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE USER_COMMAND_0100 INPUT.
  CASE OK_CODE.
   WHEN 'MOVE_BTN'.
    PERFORM MOVE_BTN. " 재고이동 버튼 클릭
   WHEN 'RESET'.
    PERFORM RESET.
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module CHECK_MATCODE INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE CHECK_MATCODE INPUT.

  IF ZSBMM0010-MATCODE IS INITIAL.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '000'.  " 필수값
   RETURN.
  ENDIF.

  PERFORM SCREEN_AMOUNT.

 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Form SCREEN_AMOUNT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SCREEN_AMOUNT .

 \* 창고명 : SUB_WHCODE1 , SUB_WHCODE2 가 있고
  SELECT SINGLE A~CURRSTOCK
   FROM ZTBMM0030 AS A
   WHERE A~MATCODE = @ZSBMM0010-MATCODE
    AND A~WHCODE = @ZSBMM0011-SUB_WHCODE1
   INTO @DATA(LS_STOCK).

  SELECT SINGLE A~CURRSTOCK
   FROM ZTBMM0030 AS A
   WHERE A~MATCODE = @ZSBMM0010-MATCODE
    AND A~WHCODE = @ZSBMM0011-SUB_WHCODE2
   INTO @DATA(LS_STOCK2).

  SELECT SINGLE A~CURRSTOCK
   FROM ZTBMM0030 AS A
   WHERE A~MATCODE = @ZSBMM0010-MATCODE
    AND A~WHCODE = @ZSBMM0011-MAIN_WHCODE
   INTO @DATA(LS_STOCK3).

 \* 판매오더 진행상태가 0 이고 ( DB View ) 1창고 데이터 들고오기 자재코드와 맞는거
 \* 전부 SUM
  SELECT SUM( A~AMOUNTPRD ) AS AMOUNT
   FROM ZVBMM0011 AS A
   WHERE A~WHCODE = @ZSBMM0011-SUB_WHCODE1
    AND A~MATCODE = @ZSBMM0010-MATCODE
   INTO @DATA(LT_SD0030).


  SELECT SINGLE SUM( A~AMOUNTPRD ) AS AMOUNT
   FROM ZVBMM0011 AS A
   WHERE A~WHCODE = @ZSBMM0011-SUB_WHCODE2
    AND A~MATCODE = @ZSBMM0010-MATCODE
   INTO @DATA(LT2_SD0030).

  SELECT SINGLE SUM( A~AMOUNTPRD ) AS AMOUNT
   FROM ZVBMM0011 AS A
   WHERE A~WHCODE = @ZSBMM0011-MAIN_WHCODE
    AND A~MATCODE = @ZSBMM0010-MATCODE
   INTO @DATA(LT3_SD0030).

 \* 값이 음수로 나올 경우 에러 떨어짐
  IF LS_STOCK < LT_SD0030 OR LS_STOCK2 < LT2_SD0030 OR LS_STOCK3 < LT3_SD0030.
   MESSAGE ID 'ZCOMMON_MSG' TYPE 'I' NUMBER '121'.  " 범위 초과
   RETURN.
  ENDIF.

  ZSBMM0011 = VALUE #( BASE ZSBMM0011 SUB_AMOUNT1 = LS_STOCK - LT_SD0030
                    SUB_AMOUNT2 = LS_STOCK2 - LT2_SD0030
                    MAIN_AMOUNT = LS_STOCK3 - LT3_SD0030 ).
 ENDFORM.
