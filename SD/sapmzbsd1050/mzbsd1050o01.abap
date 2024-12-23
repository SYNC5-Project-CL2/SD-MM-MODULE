*&---------------------------------------------------------------------*
 *& Include     MZBSD1050O01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Module STATUS_0100 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
  PERFORM RADIO_RESET.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module CLEAR_OK_CODE OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR: OK_CODE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module INIT_ALV OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE INIT_ALV OUTPUT.

  IF GO_CONT IS INITIAL.
   CREATE OBJECT GO_CONT
    EXPORTING
     CONTAINER_NAME = 'AREA'.

   CREATE OBJECT GO_ALV
    EXPORTING
     I_PARENT = GO_CONT.

   PERFORM SET_LAYOUT.
   PERFORM SET_FIELDCAT.

   CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*    Local Structure는 올 수 없다.
     I_STRUCTURE_NAME = 'ZSBSD50'      " Internal Output Table Structure Name
     IS_LAYOUT    = GS_LAYOUT
    CHANGING
     IT_OUTTAB    = GT_BPDATA
     IT_FIELDCATALOG = GT_FCAT.
  ENDIF.

  PERFORM ALV_REFRESH.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module STATUS_0110 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE STATUS_0110 OUTPUT.
  SET PF-STATUS 'S110'.
  SET TITLEBAR 'T110'.
 ENDMODULE.

 *&---------------------------------------------------------------------*
 *& Module STATUS_0120 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE STATUS_0120 OUTPUT.
  SET PF-STATUS 'S120'.
  SET TITLEBAR 'T120'.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module INIT_LISTBOX OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE INIT_LISTBOX OUTPUT.
  PERFORM SET_LISTBOX.
 ENDMODULE.
