*&---------------------------------------------------------------------*
 *& Include     ZBRMM0010S01
 *&---------------------------------------------------------------------*

 INITIALIZATION.

  SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-T01.

   PARAMETERS: PA_WH TYPE ZSBMM0010-DEL_WH OBLIGATORY.

  SELECTION-SCREEN END OF BLOCK BLK1.

  INITIALIZATION.

  START-OF-SELECTION.
  PERFORM GET_DATA_HEADER.

  CALL SCREEN 100.
