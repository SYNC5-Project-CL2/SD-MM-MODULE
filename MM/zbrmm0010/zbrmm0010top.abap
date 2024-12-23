*&---------------------------------------------------------------------*
 *& Include ZBRMM0010TOP               - Report ZBRMM0010
 *&---------------------------------------------------------------------*
 REPORT ZBRMM0010 MESSAGE-ID ZCOMMON_MSG.

 TABLES : ZSBMM0010, ZSBMM0011, ZTBMM0030. " 재고이동조건, 재고현황

 DATA : OK_CODE  TYPE SY-UCOMM,
    SCREEN_AMOUNT TYPE SY-UCOMM.

 DATA : GT_FX_MATTYPE TYPE STANDARD TABLE OF DD07V.  " 자재유형


 DATA   : BEGIN        OF GS_ALV_ZTBMM0030.
       INCLUDE       TYPE ZTBMM0030.
 DATA   : MATNAME       TYPE ZTBMM1011-MATNAME  " 자재명
      , MATTYPE_TXT     TYPE CHAR10        " 자재유형 이름
      , WHNAME       TYPE ZTBMM1030-WHNAME   " 창고명
      , IT_COL       TYPE LVC_T_SCOL      " 컬러
      , PRV_AMOUNT     TYPE ZTBMM0030-CURRSTOCK " 이전 수량
      , MOVE_AMOUNT     TYPE ZTBMM0030-CURRSTOCK " 이동 수량
      , END         OF GS_ALV_ZTBMM0030.


 \* --------------------------------------------------------------------*
 \* 재고 현황 테이블
 *---------------------------------------------------------------------*


 DATA: GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
    GO_ALV  TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT TYPE LVC_S_LAYO,
    GT_FCAT  TYPE LVC_T_FCAT.


 DATA : GT_ALV_ZTBMM0030 LIKE TABLE OF GS_ALV_ZTBMM0030.

 

 \* --------------------------------------------------------------------*
 \* 재고 이동 내역
 *---------------------------------------------------------------------*


 DATA: GO_CONT2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
    GO_ALV2  TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT2 TYPE LVC_S_LAYO,
    GT_FCAT2  TYPE LVC_T_FCAT.

 DATA : GT_ALV_ZTBMM0031 LIKE TABLE OF GS_ALV_ZTBMM0030.
