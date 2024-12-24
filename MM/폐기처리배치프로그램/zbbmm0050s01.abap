*&---------------------------------------------------------------------*
 *& Include     ZBBMM0050S01
 *&---------------------------------------------------------------------*

 INITIALIZATION.

 SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-T01.
  PARAMETERS: PA_NEXT TYPE DATS.
 SELECTION-SCREEN END OF BLOCK BLK1.

 AT SELECTION-SCREEN OUTPUT.
  PERFORM SCREEN_OUTPUT. " 날짜 HIGH 필드 아웃풋 처리.

 AT SELECTION-SCREEN.

 START-OF-SELECTION.
  PERFORM DEP_SYSTEM.

 " 배치 프로그램 이름 : ZB_AUTO_DIS.
