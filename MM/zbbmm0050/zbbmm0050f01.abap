*&---------------------------------------------------------------------*
 *& Include     ZBBMM0050F01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Form SCREEN_OUTPUT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SCREEN_OUTPUT .
  LOOP AT SCREEN.
   IF SCREEN-NAME EQ 'PA_NEXT'.
    SCREEN-INPUT = '0'.
   ENDIF.
   MODIFY SCREEN.
  ENDLOOP.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form DEP_SYSTEM
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM DEP_SYSTEM.
* 검수내역에서 유통기한 확인 후 자재코드 확인, 자재현황 테이블
* 재고 수량 차감
  DATA : LS_ZTBPP0040 TYPE ZTBPP0040,
     LT_ZTBPP0040 LIKE TABLE OF LS_ZTBPP0040.

  DATA : LS_ZTBMM0030 TYPE ZTBMM0030,
     LT_ZTBMM0030 LIKE TABLE OF LS_ZTBMM0030.

  SELECT * FROM ZTBMM0030
   INTO CORRESPONDING FIELDS OF TABLE LT_ZTBMM0030.

  SELECT * FROM ZTBPP0040
   INTO CORRESPONDING FIELDS OF TABLE LT_ZTBPP0040
   WHERE EXDATE = SY-DATUM.

  LOOP AT LT_ZTBPP0040 INTO LS_ZTBPP0040.
*  유통기한이 오늘까지라면 삭제
   UPDATE ZTBPP0040
    SET DELFLG = 'X'
   WHERE WHCODE = LS_ZTBPP0040-WHCODE
    AND PORDNUM = LS_ZTBPP0040-PORDNUM
    AND MATCODE = LS_ZTBPP0040-MATCODE.

*  자재현황 테이블 확인 후 완제품 수량만큼만 재고현황 현재수량 차감
   LOOP AT LT_ZTBMM0030 INTO LS_ZTBMM0030.
    UPDATE ZTBMM0030
     SET CURRSTOCK = CURRSTOCK - LS_ZTBPP0040-PRDQUAN
    WHERE WHCODE = LS_ZTBPP0040-WHCODE
     AND MATCODE = LS_ZTBPP0040-MATCODE.
   ENDLOOP.
  ENDLOOP.
 ENDFORM.
