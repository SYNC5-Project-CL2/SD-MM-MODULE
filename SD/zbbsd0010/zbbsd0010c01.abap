CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
   CLASS-METHODS: ON_DATA_CHANGED_FINISHED FOR EVENT DATA_CHANGED_FINISHED
    OF CL_GUI_ALV_GRID
    IMPORTING E_MODIFIED ET_GOOD_CELLS.
 ENDCLASS.

 CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD ON_DATA_CHANGED_FINISHED.
   PERFORM ALV_UPDATE USING E_MODIFIED ET_GOOD_CELLS.
  ENDMETHOD.
 ENDCLASS.