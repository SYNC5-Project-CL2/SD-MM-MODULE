*&---------------------------------------------------------------------*
 *& Include     MZBSD0040O01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Module CLEAR_OK_CODE OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE CLEAR_OK_CODE OUTPUT.
  CLEAR: OK_CODE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module STATUS_0100 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module FILL_DYNNR_0100 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE FILL_DYNNR_0100 OUTPUT.
  CASE G_TABSTRIP-ACTIVETAB.
   WHEN 'TAB_C'. " 판매운영계획 생성
    GV_TAB = '0110'.
   WHEN 'TAB_R'. "판매운영계획 조회
    GV_TAB = '0120'.
   WHEN OTHERS.
    GV_TAB = '0110'.
    G_TABSTRIP-ACTIVETAB = 'TAB_C'.
  ENDCASE.
 ENDMODULE.

 *&---------------------------------------------------------------------*
 *& Form CREATE_OBJECT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CREATE_OBJECT_0100 .
  CREATE OBJECT GO_CONT
   EXPORTING
    CONTAINER_NAME = 'AREA1'.

  CREATE OBJECT GO_ALV
   EXPORTING
    I_PARENT = GO_CONT.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_DISPLAY_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_DISPLAY_0100 .
* ZTBMM1010 에서 MATTYPE이 C (완제품)인 것만 가져와서 담는다.

  CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
*    Local Structure는 올 수 없다.
    I_STRUCTURE_NAME = 'ZTBSD0011'      " Internal Output Table Structure Name
    IS_LAYOUT    = GS_LAYOUT
   CHANGING
    IT_OUTTAB    = GT_ZTBSD0011
    IT_FIELDCATALOG = GT_FCAT.       " FIELD CATALOG
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form CREATE_OBJECT2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM CREATE_OBJECT2_0100 .
  CREATE OBJECT GO_CONT2
   EXPORTING
    CONTAINER_NAME = 'AREA2'.

  CREATE OBJECT GO_ALV2
   EXPORTING
    I_PARENT = GO_CONT2.
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
    I_STRUCTURE_NAME = 'ZTBSD0010'      " Internal Output Table Structure Name
    IS_LAYOUT    = GS_LAYOUT2
   CHANGING
    IT_OUTTAB    = GT_ZTBSD0010
    IT_FIELDCATALOG = GT_FCAT2.       " FIELD CATALOG
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV_EVENT2_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_EVENT2_0100 .
  SET HANDLER : LCL_EVENT=>ON_DOUBLE_CLICK FOR GO_ALV2,
         LCL_EVENT=>ON_BUTTON_CLICK FOR GO_ALV2,
         LCL_EVENT=>ON_TOOLBAR FOR GO_ALV2,
         LCL_EVENT=>ON_USER_COMMAND FOR GO_ALV2.
 ENDFORM.

 *&---------------------------------------------------------------------*
 *& Module INIT_ALV2 OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE INIT_ALV2 OUTPUT.  " 판매운영계획 Header
  IF GO_CONT2 IS INITIAL.
   PERFORM CREATE_OBJECT2_0100.
   PERFORM SET_ALV_FIELDCAT2_0100.
   PERFORM SET_LAYOUT2_0100.
   PERFORM SET_ALV_EVENT2_0100.  " ALV 이벤트 등록
   PERFORM SET_REGISTER_EVENT2_0100.
   PERFORM SET_ALV_DISPLAY2_0100.
  ENDIF.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module INIT_ALV OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE INIT_ALV OUTPUT.   " 판매운영계획 Item
  PERFORM SET_LIST_BOX. " list 박스 생성하기

  IF GO_CONT IS INITIAL.
   PERFORM CREATE_OBJECT_0100.
   PERFORM SET_LAYOUT_0100.
   PERFORM SET_ALV_FIELDCAT_0100.
   PERFORM SET_ALV_EVENT_0100.
   PERFORM SET_REGISTER_EVENT_0100.
   PERFORM SET_ALV_DISPLAY_0100.
  ENDIF.
 ENDMODULE.
 *---------------------------------------------*
 *& Form SET_ALV_EVENT_0100
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV_EVENT_0100 .
  SET HANDLER : LCL_EVENT=>ON_DATA_CHANGED_FINISHED FOR GO_ALV.
 ENDFORM.
