*&---------------------------------------------------------------------*
 *& Include     ZBRSD0070S01
 *&---------------------------------------------------------------------*

 INITIALIZATION.

  SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-T01.

   PARAMETERS: PA_DONUM TYPE ZTBSD0040-DONUM.
   SELECT-OPTIONS : PA_DATE FOR ZTBSD0040-DODAT.

  SELECTION-SCREEN END OF BLOCK BLK1.

 \* 날짜 DEFAULT 값 넣어주기 ( 한달 )
  PA_DATE = VALUE #( SIGN = 'I'
            OPTION = 'BT'
            HIGH = SY-DATUM
            LOW = '202301' && '01' ).
  APPEND PA_DATE.

  SELECTION-SCREEN FUNCTION KEY 1.

 START-OF-SELECTION.

  PERFORM GET_DATA_SHP. " 송장 리스트

  CALL SCREEN 100.
