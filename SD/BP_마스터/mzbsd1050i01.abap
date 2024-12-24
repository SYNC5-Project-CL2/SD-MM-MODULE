*&---------------------------------------------------------------------*
 *& Include     MZBSD1050I01
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
   WHEN 'SEARCH'.
    PERFORM GET_DATA USING 'INIT'.
   WHEN 'CREATE'.
    PERFORM CALL_CREATE_BP.
   WHEN 'UPDATE'.
    PERFORM UPDATE.
   WHEN 'DELETE'.
    PERFORM DELETE.
   WHEN 'RESET'.
    PERFORM RESET.
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
    PERFORM CREATE_BP.
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
    PERFORM UPDATE_BP.
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
