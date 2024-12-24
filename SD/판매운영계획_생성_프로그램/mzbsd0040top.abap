*&---------------------------------------------------------------------*
 *& Include MZBSD0040TOP               - Module Pool   SAPMZBSD0040
 *&---------------------------------------------------------------------*


 PROGRAM SAPMZBSD0040 MESSAGE-ID ZCOMMON_MSG.

 TABLES : ZTBSD0010, ZTBSD0011.

 DATA GV_LIST TYPE SY-UCOMM. " 연도별 리스트 박스 선언

 DATA :LV_ANSWER TYPE CHAR1, " 컨펌 팝업
    OK_CODE  TYPE SY-UCOMM.

 DATA: GT_ZTBSD1030 TYPE TABLE OF ZTBSD1030,  " 사원ID 넣기
    GS_ZTBSD1030 LIKE LINE OF GT_ZTBSD1030.

 CONSTANTS: AMOUNT_CS TYPE P LENGTH 3 DECIMALS 2 VALUE '1.01', " 현재판매수량 = 전년도 판매수량 * 1.01
      AMOUNT_PQ TYPE P LENGTH 3 DECIMALS 2 VALUE '1.05',  " 생산수량 = 현재 판매 수량 * 1.05
      MAX_CAN  TYPE N LENGTH 7 VALUE 5200000,   " 캔 판매계획 제한 수량 ( 4개 국가 총합 제한 )
      MAX_GLASS TYPE N LENGTH 7 VALUE 3120000,  " 유리병 판매계획 제한 수량
      MAX_PET  TYPE N LENGTH 7 VALUE 1040000.   " 페트병 판매계획 제한 수량


 *&---------------------------------------------------------------------*
 *& TAB을 위한 변수
 *&---------------------------------------------------------------------*


 CONTROLS: G_TABSTRIP TYPE TABSTRIP.
 DATA GV_TAB TYPE SY-DYNNR.


 \* --------------------------------------------------------------------*
 \* 첫번째 ALV. 판매운영계획 ITEM / AREA1
 *---------------------------------------------------------------------*

 


 DATA: GO_CONT  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
    GO_ALV  TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT TYPE LVC_S_LAYO,
    GT_FCAT  TYPE LVC_T_FCAT.

 DATA   : BEGIN        OF GS_ZTBSD0011. " Inbound Grid
      INCLUDE       TYPE ZTBSD0011.
 DATA   : MATNAME      TYPE ZTBMM1011-MATNAME  " 자재명
      , CTRYNAME      TYPE ZTBSD1040-CTRYNAME  " 국가명
      , STTAB       TYPE LVC_T_STYL
      , END        OF GS_ZTBSD0011.

 DATA : GS_MATDATA  TYPE ZSBSD10,  " 각종 JOIN문 사용해서 가져오기에 사용
    GT_MATDATA  LIKE TABLE OF GS_MATDATA,
    GT_ZTBSD0011 LIKE TABLE OF GS_ZTBSD0011, " 판매운영계획 item
    GS_AMOUNT  TYPE ZTBSD0011,
    GT_AMOUNT  TYPE TABLE OF ZTBSD0011.

 


 \* --------------------------------------------------------------------*
  * 두번째 ALV. 판매운영계획 HEADER / AREA2
 *---------------------------------------------------------------------*

 

 DATA: GO_CONT2  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
    GO_ALV2  TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT2 TYPE LVC_S_LAYO,
    GT_FCAT2  TYPE LVC_T_FCAT.

 DATA   : BEGIN        OF GS_ZTBSD0010. " Inbound Grid
      INCLUDE       TYPE ZTBSD0010.
 DATA   : SOP_STATUS_TXT   TYPE CHAR5   " 판매운영계획 상태
      , CTRYNAME      TYPE ZTBSD1040-CTRYNAME
      , EXCP        TYPE CHAR1    " 상신 신호등
      , STTAB        TYPE LVC_T_STYL   " 각 셀별 특징 넣기
      , CHECK        TYPE CHAR1    " Check Box
      , EMPNAME       TYPE ZTBSD1030-EMPNAME  " 담당자명
      , END         OF GS_ZTBSD0010.

* 판매운영계획 Header
 DATA : GT_ZTBSD0010 LIKE TABLE OF GS_ZTBSD0010.
