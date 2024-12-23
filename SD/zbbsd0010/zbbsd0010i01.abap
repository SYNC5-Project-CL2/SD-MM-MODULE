*&---------------------------------------------------------------------*
 *& Include     ZBBSD0010I01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *&   Module USER_COMMAND_0100 INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE USER_COMMAND_0100 INPUT.
  CASE OK_CODE.
   WHEN 'BACK'.
    LEAVE TO SCREEN 0.
   WHEN 'SAVE'.
    PERFORM ZBSD_CON_POPUP USING '저장' CHANGING LV_ANSWER.
    CHECK LV_ANSWER = '1'.
    PERFORM SAVE_DATA. " 데이터 저장하기
    LEAVE TO SCREEN 0. " 뒤로 가기
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module EXIT INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE EXIT INPUT.
  CASE OK_CODE.
   WHEN 'EXIT'.
    LEAVE PROGRAM.
   WHEN 'CANCEL'.
    LEAVE TO SCREEN 0.
  ENDCASE.
 ENDMODULE.
