*&---------------------------------------------------------------------*
 *& Include     ZBBSD0010F01
 *&---------------------------------------------------------------------*
 *&---------------------------------------------------------------------*
 *& Form GET_FILENM
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- PA_FILE
 *&---------------------------------------------------------------------*
 FORM GET_FILENM CHANGING P_PA_FILE. " 파일 탐색창 띄우기
  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
    FIELD_NAME = 'PA_FILE' "선택된 파일명이 저장될 필드 이름 지정
   IMPORTING
    FILE_NAME = P_PA_FILE. " 선택된 파일명을 P_PA_FILE에 저장
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form UPLOAD_EXCEL
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM UPLOAD_EXCEL ." 엑셀 업로드 하기
  " LV_FILENAME 에 저장된 파일 경로로 접근해서 해당 파일이 엑셀파일이면
  " 엑셀 파일 내에서 1번째 칸부터 9번째 칸까지 하나의 데이터로 취급한다.
  " 이때 시작하는 라인은 2번째 줄부터 데이터가 계속해서 이어지는 조건에
  " 최종적으로 5000번째 줄까지 내용을 읽어온다.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
   EXPORTING
    FILENAME        = PA_FILE
    I_BEGIN_COL       = 1
    I_BEGIN_ROW       = 2
    I_END_COL        = 17
    I_END_ROW        = 100
   TABLES
    INTERN         = GT_EXCEL
   EXCEPTIONS
    INCONSISTENT_PARAMETERS = 1
    UPLOAD_OLE       = 2
    OTHERS         = 3.

  CASE SY-SUBRC.
   WHEN 0. " 엑셀 파일의 내용을 주어진 조건에 맞춰서 올바르게 가져왔다.
   WHEN 1. MESSAGE '엑셀 파일 경로 또는 데이터 범위가 잘못되었습니다.' TYPE 'E'.
   WHEN 2. MESSAGE '지정한 경로의 파일이 엑셀파일이 아닙니다.' TYPE 'E'.
   WHEN 3. MESSAGE '알 수 없는 오류가 발생했습니다.' TYPE 'E'.
  ENDCASE.

 \* 엑셀 데이터를 하나씩 가지고와 GT_DATA에 넣는다
  FIELD-SYMBOLS: <FS_ITAB> TYPE ANY.
  LOOP AT GT_EXCEL INTO GS_EXCEL.
   ASSIGN COMPONENT GS_EXCEL-COL OF STRUCTURE GS_DATA TO <FS_ITAB>.
   <FS_ITAB> = GS_EXCEL-VALUE.
   AT END OF ROW.
    APPEND GS_DATA TO GT_DATA.
    CLEAR: GS_DATA.
   ENDAT.
  ENDLOOP.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Module CLEAR_OKCOD OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE CLEAR_OKCOD OUTPUT.
  CLEAR: OK_CODE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Module INIT_ALV OUTPUT
 *&---------------------------------------------------------------------*
 *&
 *&---------------------------------------------------------------------*
 MODULE INIT_ALV OUTPUT.  " 엑셀에 있는 데이터를 ALV 형태로 보여줘라 (도킹 사용)

  IF GO_DOCK IS NOT INITIAL.
   RETURN.
  ENDIF.

  CREATE OBJECT GO_DOCK
   EXPORTING
    EXTENSION = 1000.

  CREATE OBJECT GO_ALV
   EXPORTING
    I_PARENT = GO_DOCK.

  PERFORM SET_ALV .

 ENDMODULE.
 *&---------------------------------------------------------------------*
 *& Form DOWNLOAD_EXCEL_FILE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> SY_REPID
 *&---------------------------------------------------------------------*
 FORM EXCEL_TEMPLATE USING P_SY_REPID. " 현재 프로그램 이름

 \* 저장위치 선택
  PERFORM SET_SAVE_PATH.

 \* 저장할 테이블 필드명 가져오기
  PERFORM TABLE_FIELD.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_SAVE_PATH
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- LV_SAVEPATH
 *&---------------------------------------------------------------------*
 FORM SET_SAVE_PATH.  " 유저가 파일을 저장할 위치와 파일명을 선택하는 부분

  DATA: LV_FILENAME   TYPE STRING,     " 기본 파일명을 저장할 변수
     LV_PATH     TYPE STRING,     " 파일이 저장될 경로를 저장할 변수
     LV_SAVE_FILENAME TYPE STRING,     " 사용자 지정 저장 파일명을 저장할 변수
     LV_SAVEPATH   TYPE STRING.     " 파일의 전체 경로를 저장할 변수

  " 현재 날짜와 시간을 포함한 기본 파일명을 생성
  " 구문을 사용해 현재 날짜(SY-DATUM)와 시간(SY-UZEIT)를 포함한 파일명 생성
  LV_FILENAME = |납품처MASTER__{ SY-DATUM }{ SY-UZEIT }.xlsx|.

  " CL_GUI_FRONTEND_SERVICES 클래스의 FILE_SAVE_DIALOG 메서드를 호출하여 파일 저장 다이얼로그 표시
  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
   EXPORTING
    DEFAULT_FILE_NAME     = LV_FILENAME      " 기본 파일명 설정
    FILE_FILTER        = '엑셀 파일(*.xlsx)|*.xlsx' " 파일 확장자 필터 설정
    INITIAL_DIRECTORY     = 'C:\'        " 초기 디렉토리 설정
   CHANGING
    FILENAME         = LV_SAVE_FILENAME    " 사용자가 지정한 파일명 반환
    PATH           = LV_PATH        " 사용자가 선택한 경로 반환
    FULLPATH         = LV_SAVEPATH      " 전체 경로와 파일명 반환
   EXCEPTIONS
    CNTL_ERROR        = 1           " GUI 컨트롤 에러 발생 시
    ERROR_NO_GUI       = 2           " GUI가 없는 경우
    NOT_SUPPORTED_BY_GUI   = 3           " GUI에서 지원하지 않는 경우
    INVALID_DEFAULT_FILE_NAME = 4           " 기본 파일명이 잘못된 경우
    OTHERS          = 5           " 기타 예외 처리
  ).

  " 파일 다이얼로그가 정상적으로 실행되지 않은 경우 예외 메시지를 출력
  IF SY-SUBRC <> 0.
   MESSAGE '엑셀 파일 경로가 잘못되었습니다.' TYPE 'E'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form fill_cell
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> GO_EXCEL
 *&   --> P_1
 *&   --> LV_INDEX
 *&   --> LS_TAB_FIELDTEXT
 *&---------------------------------------------------------------------*
 FORM FILL_CELL USING PV_APPLICATION " 엑셀에 셀을 채우는 부분
             PV_ROW
             PV_COL
             PV_VALUE.

  DATA: LV_ECELL TYPE OLE2_OBJECT. " 엑셀의 셀을 나타냄

  " Cells 메서드를 사용해 Excel의 특정 셀을 지정합니다.
  " PV_ROW와 PV_COL을 인자로 전달하여 행과 열 위치를 지정하고, 그 셀을 LV_ECELL에 할당합니다.
  CALL METHOD OF PV_APPLICATION 'Cells' = LV_ECELL
   EXPORTING
    \#1 = PV_ROW
    \#2 = PV_COL.
  " LV_ECELL의 'Value' 속성에 PV_VALUE를 설정하여 셀에 값 입력
  SET PROPERTY OF LV_ECELL 'Value' = PV_VALUE.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form TABLE_FIELD
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM TABLE_FIELD .  " 테이블 필드명 가져오기 ( 양식 다운로드 )

 \* Excel을 열고, 새로운 워크북과 시트를 생성한 후, ABAP 테이블 LT_TAB의 데이터를 순차적으로 Excel 셀에 입력합니다.

  DATA: LT_TAB TYPE TABLE OF DFIES,  " dfies 구조체로 이루어진 테이블 lt_tab 선언
     LS_TAB LIKE LINE OF LT_TAB.  " lt_tab의 한 줄 구조체 ls_tab 선언

  DATA: LV_VISIBLE TYPE I,       " Excel 가시성을 저장할 정수형 변수 lv_visible 선언
     LV_INDEX  TYPE SY-TABIX.    " 현재 행의 인덱스를 저장할 변수 lv_index 선언

  " 딕셔너리에 저장된 테이블의 속성을 가져오는 함수 호출
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
   EXPORTING
    TABNAME    = 'ZSBSD60'  " 테이블의 이름을 전달
   TABLES
    DFIES_TAB   = LT_TAB      " 결과를 lt_tab에 저장
   EXCEPTIONS
    NOT_FOUND   = 1         " 테이블이 존재하지 않는 경우 예외 처리
    INTERNAL_ERROR = 2         " 내부 오류 발생 시 예외 처리
    OTHERS     = 3.        " 그 외의 예외 처리

  IF SY-SUBRC <> 0.           " 함수 호출이 성공했는지 체크
   MESSAGE '데이터에 문제가 생겼습니다.' TYPE 'E'.
  ENDIF.

 \* 1. Excel 애플리케이션 객체 생성
  CREATE OBJECT GO_EXCEL 'EXCEL.APPLICATION'.  "Excel 응용 프로그램 제어 부분

 \* 2. 새 워크북 생성 및 시트 표시 설정
  " get list of workbooks, initially empty
  CALL METHOD OF GO_EXCEL 'Workbooks' = GO_WBOOK.

  SET PROPERTY OF GO_EXCEL 'Visible' = 1. "엑셀을 띄울것인지 설정 (조회모드) : 1 or 0

  CALL METHOD OF GO_WBOOK 'Add'. " 워크북을 추가

 \* 3. 시트 활성화 및 이름 설정
  " 시트 설정
  CALL METHOD OF GO_EXCEL 'Worksheets' = GO_SHEET
   EXPORTING
    \#1 = 1.  "활성화할 시트

  CALL METHOD OF GO_SHEET 'Activate'.  " 시트 활성화
  SET PROPERTY OF GO_SHEET 'Name' = '납품처 리스트'.  "Sheet name

  LOOP AT LT_TAB INTO LS_TAB.
   LV_INDEX = SY-TABIX.
   PERFORM FILL_CELL USING GO_EXCEL 1 LV_INDEX LS_TAB-FIELDTEXT.  " 엑셀 셀 채우기
  ENDLOOP.

  FREE: GO_EXCEL, GO_WBOOK, GO_SHEET.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ZBSD_CON_POPUP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> P_
 *&   <-- LV_ANSWER
 *&---------------------------------------------------------------------*
 FORM ZBSD_CON_POPUP USING P_VALUE CHANGING LV_ANSWER.
  DATA DOMAIN TYPE CHAR10 VALUE '납품처MASTER'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
   EXPORTING
    TITLEBAR       = | { DOMAIN } 데이터 { P_VALUE } |
    TEXT_QUESTION     = | { DOMAIN }을(를) { P_VALUE } 하시겠습니까? |
    TEXT_BUTTON_1     = 'YES'
    ICON_BUTTON_1     = 'ICON_OKAY'
    TEXT_BUTTON_2     = 'NO'
    ICON_BUTTON_2     = 'ICON_CANCEL'
    DEFAULT_BUTTON    = '1'
    DISPLAY_CANCEL_BUTTON = ''
   IMPORTING
    ANSWER        = LV_ANSWER
   EXCEPTIONS
    TEXT_NOT_FOUND    = 1
    OTHERS        = 2.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_ALV
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_ALV .

  PERFORM ZBSD_SET_LAYOUT.
  SET HANDLER LCL_EVENT_HANDLER=>ON_DATA_CHANGED_FINISHED FOR GO_ALV.
  PERFORM SET_DISPLAY.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ZBSD_SET_LAYOUT
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- GS_LAYOUT
 *&---------------------------------------------------------------------*
 FORM ZBSD_SET_LAYOUT.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-GRID_TITLE = 'BP 리스트'.
  GS_LAYOUT-EDIT = 'X'. " 입력필드로 만들기
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SAVE_DATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SAVE_DATA. " 데이터 저장하기
  LOOP AT GT_DATA INTO GS_DATA.

   DATA LV_NUM TYPE CHAR10.
   PERFORM GET_NUMBER_RANGE CHANGING LV_NUM. " NUMBER RANGE GET
   GS_ZTBSD1060-SUPCODE = |C{ LV_NUM }|. "PK 납품처 코드

   PERFORM GET_TIMESTAMP.
   GS_ZTBSD1060-BPCODE = GS_DATA-BPCODE. "BP코드
   GS_ZTBSD1060-SUPADNR = GS_DATA-SUPADNR. "주소
   GS_ZTBSD1060-SUPTEL = GS_DATA-SUPTEL. " 연락처
   GS_ZTBSD1060-WHCODE = GS_DATA-WHCODE. "창고 코드 필수

   GS_ZTBSD1061-SUPCODE = |C{ LV_NUM }|. "PK 납품처 코드
   GS_ZTBSD1061-SUPNAME = GS_DATA-SUPNAME.
   GS_ZTBSD1061-SPRAS = SY-LANGU.

   INSERT INTO ZTBSD1060 VALUES GS_ZTBSD1060.
   INSERT INTO ZTBSD1061 VALUES GS_ZTBSD1061.
  ENDLOOP.

 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ZBSD_SET_DATA
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- GS_DATA
 *&---------------------------------------------------------------------*
 FORM ZBSD_SET_DATA. " TODO. 시간 있을 때
 \* 1. GS_ZTBSD1060 와 GS_ZTBSD1061 에 데이터 하나씩 비교하며 바구니에 담기
 \* Number Range를 사용하기에 pk가 null일 경우는 없다.
 \* 데이터 타입이 잘못되는 경우는?
  GS_ZTBSD1060-SUPADNR = GS_DATA-SUPADNR.
  GS_ZTBSD1060-SUPTEL = GS_DATA-SUPTEL.

  GS_ZTBSD1061-SUPNAME = GS_DATA-SUPNAME.
  GS_ZTBSD1060-BPCODE = GS_DATA-BPCODE.
  GS_ZTBSD1060-WHCODE = GS_DATA-WHCODE.

  APPEND GS_DATA TO GT_DATA.
  CLEAR: GS_DATA.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_NUMBER_RANGE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   <-- LV_NUM
 *&---------------------------------------------------------------------*
 FORM GET_NUMBER_RANGE CHANGING P_LV_NUM.
  CALL FUNCTION 'NUMBER_GET_NEXT'
   EXPORTING
    NR_RANGE_NR       = '01'
    OBJECT         = 'ZBBSD1060'
   IMPORTING
    NUMBER         = P_LV_NUM
   EXCEPTIONS
    INTERVAL_NOT_FOUND   = 1
    NUMBER_RANGE_NOT_INTERN = 2
    OBJECT_NOT_FOUND    = 3
    QUANTITY_IS_0      = 4
    QUANTITY_IS_NOT_1    = 5
    INTERVAL_OVERFLOW    = 6
    BUFFER_OVERFLOW     = 7
    OTHERS         = 8.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form GET_TIMESTAMP
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM GET_TIMESTAMP .
  SELECT * FROM ZTBSD1030 INTO TABLE GT_ZTBSD1030.
  READ TABLE GT_ZTBSD1030 INTO GS_ZTBSD1030 WITH KEY LOGID = SY-UNAME.
  GS_ZTBSD1060-STAMP_DATE_F = SY-DATUM.
  GS_ZTBSD1060-STAMP_TIME_F = SY-UZEIT.
  GS_ZTBSD1060-STAMP_USER_F = GS_ZTBSD1030-EMPID.
  GS_ZTBSD1061-STAMP_DATE_F = SY-DATUM.
  GS_ZTBSD1061-STAMP_TIME_F = SY-UZEIT.
  GS_ZTBSD1061-STAMP_USER_F = GS_ZTBSD1030-EMPID.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form SET_DISPLAY
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *& --> p1    text
 *& <-- p2    text
 *&---------------------------------------------------------------------*
 FORM SET_DISPLAY .
  CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
   EXPORTING
    I_BYPASSING_BUFFER      = 'X'       " Switch Off Buffer
    I_STRUCTURE_NAME       = 'ZSBSD60'       " Internal Output Table Structure Name
    IS_LAYOUT           = GS_LAYOUT     " Layout
   CHANGING
    IT_OUTTAB           = GT_DATA     " Output Table
 \*   IT_FIELDCATALOG        =         " Field Catalog
   EXCEPTIONS
    INVALID_PARAMETER_COMBINATION = 1        " Wrong Parameter
    PROGRAM_ERROR         = 2        " Program Errors
    TOO_MANY_LINES        = 3        " Too many Rows in Ready for Input Grid
    OTHERS            = 4.
  IF SY-SUBRC <> 0.
   MESSAGE '잠시후 다시 시도해주세요.' TYPE 'E'.
  ENDIF.
 ENDFORM.
 *&---------------------------------------------------------------------*
 *& Form ALV_UPDATE
 *&---------------------------------------------------------------------*
 *& text
 *&---------------------------------------------------------------------*
 *&   --> ER_DATA_CHANGED
 *&   --> SENDER
 *&---------------------------------------------------------------------*
 FORM ALV_UPDATE USING PV_MODIFIED
            PT_GOOD_CELLS TYPE LVC_T_MODI.
  BREAK-POINT.
 ENDFORM.
