*&---------------------------------------------------------------------*
 *&   Module USER_COMMAND_0100 INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE USER_COMMAND_0100 INPUT.
  PERFORM CHECK_INPUT. " 편집모드 사용하기
  CASE OK_CODE.
   WHEN 'TAB_C' OR 'TAB_R'. "탭스크린버튼
    G_TABSTRIP-ACTIVETAB = OK_CODE.
    PERFORM RESET.
    CLEAR : GV_LIST, ZTBSD0010-CTRYCODE.
    LEAVE SCREEN.
   WHEN 'BACK'.
    LEAVE TO SCREEN 0.
   WHEN 'PLAN'.     " 계획 세우기 버튼
    PERFORM SOP_PLAN.
   WHEN 'CREATE'.
    PERFORM CREATE. " 판매계획 생성
   WHEN 'RESET'.
    CLEAR : GV_LIST, ZTBSD0010-CTRYCODE.
    PERFORM RESET.
   WHEN 'SOP_READ'. "판매운영계획 조회
    PERFORM SOP_READ.
  ENDCASE.
 ENDMODULE.
 *&---------------------------------------------------------------------*
 *&   Module EXIT INPUT
 *&---------------------------------------------------------------------*
 \*    text
 *----------------------------------------------------------------------*
 MODULE EXIT INPUT.
  CASE OK_CODE.
   WHEN 'EXIT'.
    LEAVE PROGRAM.
   WHEN 'CANCEL'.
    LEAVE TO SCREEN 0.
  ENDCASE.
 ENDMODULE.
