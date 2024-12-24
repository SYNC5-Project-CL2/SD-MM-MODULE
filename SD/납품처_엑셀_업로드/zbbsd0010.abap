*&---------------------------------------------------------------------*
 *& Report ZBBSD0010
 *&---------------------------------------------------------------------*
 *&
 *&  [SD]
 *&
 *&  개발자         : CL2 KDT-B-13 윤소영
 *&  프로그램 개요      : 납품처 MASTER 엑셀 업로드 관리 프로그램
 *&  개발 시작일      : 2024.10.29
 *&  개발 완료일      : 2024.10.30
 *&  개발 상태       : 개발완료
 *&  단위테스트 여부
 *&
 *&
 *&---------------------------------------------------------------------*

 INCLUDE ZBBSD0010TOP              .  " Global Data
 INCLUDE ZBBSD0010C01              .  " Global Data
 INCLUDE ZBBSD0010SEL              .  " Global Data
 INCLUDE ZBBSD0010O01              . " PBO-Modules
 INCLUDE ZBBSD0010I01              . " PAI-Modules
 INCLUDE ZBBSD0010F01              . " FORM-Routines


 INITIALIZATION.
  " Selection Screen 에서 앱툴바에 버튼을 추가할 때 아이콘을 다루고 싶을 때 사용
  DATA LS_DYNTXT TYPE SMP_DYNTXT.
  LS_DYNTXT-ICON_ID = ICON_XLS. " Icon 은 se38에서 showicon 프로그램을 실행해서 찾을 수 있다.
  LS_DYNTXT-ICON_TEXT = '양식 다운로드'.
  SSCRFIELDS-FUNCTXT_01 = LS_DYNTXT.

 AT SELECTION-SCREEN.
  " Selection Screen의 앱툴바에 추가된 버튼은
  " FC01 부터 FC05 까지 사전에 정의가 되어 있다.
  CASE SSCRFIELDS-UCOMM.
   WHEN 'FC01'.
    PERFORM ZBSD_CON_POPUP USING '다운로드' CHANGING LV_ANSWER.
    CHECK LV_ANSWER = '1'.

    PERFORM EXCEL_TEMPLATE USING SY-REPID.
  ENDCASE.

 AT SELECTION-SCREEN OUTPUT.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_FILE.
  PERFORM GET_FILENM CHANGING PA_FILE.

 START-OF-SELECTION.
  IF PA_FILE = 'C:\'.   " 경로 지정 없이 넘긴다면
   MESSAGE I022 DISPLAY LIKE 'E'.
   RETURN.
  ENDIF.
  PERFORM UPLOAD_EXCEL.     " 엑셀파일을 읽어온다.
  CALL SCREEN 100.
