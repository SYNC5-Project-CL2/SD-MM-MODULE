*&---------------------------------------------------------------------*
 *& Include ZBRSD0060TOP               - Report ZBRSD0060
 *&---------------------------------------------------------------------*
 REPORT ZBRSD0060 MESSAGE-ID ZCOMMON_MSG.

 TABLES: ZSSD0080, ZTBSD0080.

 DATA : OK_CODE TYPE SY-UCOMM,
    PRICE  TYPE SY-UCOMM.

 DATA LV_ANSWER TYPE CHAR1. " 컨펌 팝업

 DATA: GT_ZTBSD1030 TYPE TABLE OF ZTBSD1030,  " 사원ID 넣기
    GS_ZTBSD1030 LIKE LINE OF GT_ZTBSD1030.

 \* --------------------------------------------------------------------*
 \* 첫번째 ALV. 완제품 판매가 조회 화면
 *--------------------------------------------------------------------*

 DATA: GO_DOCK  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
    GO_ALV  TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT TYPE LVC_S_LAYO,
    GT_FCAT  TYPE LVC_T_FCAT,
    GT_ROW  TYPE LVC_T_ROID,
    GS_ROW  TYPE LVC_S_ROID.

 DATA   : BEGIN        OF GS_ALV_ZTBSD0080. " Inbound Grid
       INCLUDE       TYPE ZTBSD0080.
 DATA   : MATNAME      TYPE ZTBMM1011-MATNAME  " 자재명
      , CTRYNAME      TYPE ZTBSD1040-CTRYNAME  " 국가명
      , EMPNAME_F      TYPE ZTBSD1030-EMPNAME  " 담당자명
      , EMPNAME_L      TYPE ZTBSD1030-EMPNAME  " 담당자명
      , END        OF GS_ALV_ZTBSD0080.

 DATA : GT_ALV_ZTBSD0080 LIKE TABLE OF GS_ALV_ZTBSD0080. " 완제품 판매가 테이블
