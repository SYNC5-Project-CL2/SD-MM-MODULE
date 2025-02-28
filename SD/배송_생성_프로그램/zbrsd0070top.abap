*&---------------------------------------------------------------------*
 *& Include ZBRSD0070TOP               - Report ZBRSD0070
 *&---------------------------------------------------------------------*


 REPORT ZBRSD0070 MESSAGE-ID ZCOMMON_MSG.

 TABLES : ZTBSD0040, ZTBSD0060, ZTBSD1060.

 DATA : OK_CODE TYPE SY-UCOMM.

 DATA : GT_FX_SOPSTATUS TYPE STANDARD TABLE OF DD07V,  " 판매오더 Fixed Value
    GT_ZTBSD1030 TYPE TABLE OF ZTBSD1030,  " 사원ID 넣기
    GS_ZTBSD1030 LIKE LINE OF GT_ZTBSD1030,
    GT_ZTBSD1060 LIKE TABLE OF ZTBSD1060.

 DATA LV_ANSWER TYPE CHAR1. " 컨펌 팝업

 \* --------------------------------------------------------------------*
 \* CONTAINER
 *---------------------------------------------------------------------*


 DATA: GO_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER,
    GO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER.


 \* --------------------------------------------------------------------*
 \* 첫번째 DOCKING 송장 리스트
 *---------------------------------------------------------------------*

 

 DATA : GO_CON_TOP  TYPE REF TO CL_GUI_CONTAINER,
    AVL_GRID_TOP TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT  TYPE LVC_S_LAYO,
    GT_FCAT   TYPE LVC_T_FCAT,
    GT_ROW    TYPE LVC_T_ROW,
    GS_ROW    TYPE LVC_S_ROW.


 DATA   : BEGIN        OF GS_ALV_ZTBSD0040.
       INCLUDE       TYPE ZTBSD0040.
 DATA   : EMPNAME       TYPE ZTBSD1030-EMPNAME  " 담당자명
      , BPCODE       TYPE ZTBSD1051-BPCODE   " BP코드
      , BPNAME       TYPE ZTBSD1051-BPNAME   " BP명
      , SUPCODE       TYPE ZTBSD1060-SUPCODE  " 납품처코드
      , SUPNAME       TYPE ZTBSD1061-SUPNAME  " 납품처코드
      , CURRENCY      TYPE ZTBSD0060-CURRENCY  " 화폐단위
      , EXCP        TYPE CHAR1        " 출고여부 0미완료/1완료
      , SOP_STATUS     TYPE ZTBSD0030-STATUS   " 판매오더 진행상태
      , SOP_STATUS_TXT   TYPE CHAR10        " 판매오더 진행상태명
      , CHECK        TYPE CHAR1        " Check Box
      , STTAB        TYPE LVC_T_STYL      " 각 셀별 특징 넣기
      , END         OF GS_ALV_ZTBSD0040.

 DATA : GT_ALV_ZTBSD0040 LIKE TABLE OF GS_ALV_ZTBSD0040.

 

 \* --------------------------------------------------------------------*
 \* 두번째 DOCKING 배송 리스트
 *---------------------------------------------------------------------*


 DATA : GO_CON_BOTTOM  TYPE REF TO CL_GUI_CONTAINER,
    AVL_GRID_BOTTOM TYPE REF TO CL_GUI_ALV_GRID,
    GS_LAYOUT2   TYPE LVC_S_LAYO,
    GT_FCAT2    TYPE LVC_T_FCAT,
    GT_ROW2     TYPE LVC_T_ROW,
    GS_ROW2     TYPE LVC_S_ROW.


 DATA   : BEGIN        OF GS_ALV_ZTBSD0060.
       INCLUDE       TYPE ZTBSD0060.
 DATA   : TRANSPORT_TXT    TYPE CHAR6        " 배송방법 명 1TRUCK/2SHIP
      , EMPNAME       TYPE ZTBSD1030-EMPNAME  " 담당자명
      , BPCODE       TYPE ZTBSD1051-BPCODE   " BP코드
      , BPNAME       TYPE ZTBSD1051-BPNAME   " BP명
      , SUPCODE       TYPE ZTBSD1060-SUPCODE  " 납품처코드
      , SUPNAME       TYPE ZTBSD1061-SUPNAME  " 납품처코드
      , EXCP        TYPE CHAR1        " A 대금청구생선전 / B 생성완료
      , SOP_STATUS     TYPE ZTBSD0030-STATUS   " 판매오더 진행상태
      , SOP_STATUS_TXT   TYPE CHAR10        " 판매오더 진행상태명
      , END         OF GS_ALV_ZTBSD0060.

 DATA : GT_ALV_ZTBSD0060 LIKE TABLE OF GS_ALV_ZTBSD0060.
