*&---------------------------------------------------------------------*
 *& Include     ZBRSD0060I01
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
   WHEN 'CANCEL'.
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
   WHEN 'BACK'.
    LEAVE TO SCREEN 0.
   WHEN 'CREATE'.
    PERFORM CHECK_CREATE.
   WHEN 'DELETE'.
    PERFORM CHECK_ROW USING '삭제'.
   WHEN 'RESET'.
    PERFORM ALV_REFRESH.
    PERFORM GET_DATA USING 'INIT'.
   WHEN 'UPDATE'.
    PERFORM CHECK_ROW USING '수정'.
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module USER_COMMAND_0110 INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE USER_COMMAND_0110 INPUT.
  CASE OK_CODE.
   WHEN 'OKAY'.
    PERFORM CREATE.
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module USER_COMMAND_0120 INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE USER_COMMAND_0120 INPUT.
  CASE OK_CODE.
   WHEN 'OKAY'.
    PERFORM UPDATE USING '수정'.
    LEAVE TO SCREEN 0.
  ENDCASE.
 ENDMODULE.
