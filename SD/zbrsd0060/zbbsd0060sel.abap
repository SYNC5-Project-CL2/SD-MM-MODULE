*&---------------------------------------------------------------------*
 *& Include     ZBBSD0060SEL
 *&---------------------------------------------------------------------*


 INITIALIZATION.

  SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-T01.

   PARAMETERS: PA_MAT TYPE ZTBSD0080-MATCODE,
         PA_CTRY TYPE ZTBSD0080-CTRYCODE AS LISTBOX VISIBLE LENGTH 20.

  SELECTION-SCREEN END OF BLOCK BLK1.

*  selection screen
  SELECTION-SCREEN BEGIN OF BLOCK EXE WITH FRAME TITLE TEXT-EXE.
   PARAMETERS:
    ALL   RADIOBUTTON GROUP RAG1,
    VALID  RADIOBUTTON GROUP RAG1 DEFAULT 'X',
    DELETED RADIOBUTTON GROUP RAG1.
  SELECTION-SCREEN END OF BLOCK EXE.

  SELECTION-SCREEN FUNCTION KEY 1.

 START-OF-SELECTION.
  PERFORM GET_DATA USING 'INIT'.

  CALL SCREEN 100.
