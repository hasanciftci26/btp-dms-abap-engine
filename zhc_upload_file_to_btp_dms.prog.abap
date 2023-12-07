*&---------------------------------------------------------------------*
*& Report ZHC_UPLOAD_FILE_TO_BTP_DMS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhc_upload_file_to_btp_dms.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_file TYPE localfile OBLIGATORY.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: lv_rc     TYPE i,
        lt_files  TYPE filetable,
        lv_action TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      multiselection          = abap_false
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
      user_action             = lv_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5
  ).

  IF lv_action = cl_gui_frontend_services=>action_ok.
    IF lines( lt_files ) > 0.
      p_file = lt_files[ 1 ]-filename.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  DATA: lt_filetable     TYPE filetable,
        lv_length        TYPE i,
        lv_xstring_file  TYPE xstring,
        lo_dms_engine    TYPE REF TO zhc_cl_btp_dms_engine,
        lv_response_json TYPE string,
        lv_file_name     TYPE string,
        lv_mime_type     TYPE skwf_mime,
        BEGIN OF ls_response,
          BEGIN OF properties,
            BEGIN OF object_id,
              id          TYPE string,
              localname   TYPE string,
              displayname TYPE string,
              queryname   TYPE string,
              cardinality TYPE string,
              value       TYPE string,
            END OF object_id,
          END OF properties,
        END OF ls_response,
        lt_name_mappings TYPE HASHED TABLE OF /ui2/cl_json=>name_mapping WITH UNIQUE KEY abap,
        ls_name_mappings LIKE LINE OF lt_name_mappings.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = CONV string( p_file )
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_length
    CHANGING
      data_tab                = lt_filetable
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  "Convert binary ITAB to xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_length
    IMPORTING
      buffer       = lv_xstring_file
    TABLES
      binary_tab   = lt_filetable
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  CREATE OBJECT lo_dms_engine.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = p_file
    IMPORTING
      stripped_name = lv_file_name
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.

  CALL FUNCTION 'SKWF_MIMETYPE_OF_FILE_GET'
    EXPORTING
      filename = CONV skwf_filnm( lv_file_name )
    IMPORTING
      mimetype = lv_mime_type.

  lv_response_json = lo_dms_engine->create_document(
    iv_repository = 'SAMPLE_REPO3'
    iv_folder     = '/SAMPLE_FOLDER1/SAMPLE_CHILD_FOLDER'
    iv_filename   = lv_file_name
    iv_mimetype   = CONV string( lv_mime_type )
    iv_media      = lv_xstring_file
  ).

  ls_name_mappings-abap = 'properties'.
  ls_name_mappings-json = 'properties'.
  INSERT ls_name_mappings INTO TABLE lt_name_mappings.

  ls_name_mappings-abap = 'object_id'.
  ls_name_mappings-json = 'cmis:objectId'.
  INSERT ls_name_mappings INTO TABLE lt_name_mappings.

  ls_name_mappings-abap = 'value'.
  ls_name_mappings-json = 'value'.
  INSERT ls_name_mappings INTO TABLE lt_name_mappings.

  " Convert JSON to get object ID
  /ui2/cl_json=>deserialize(
    EXPORTING
      json          = lv_response_json
      name_mappings = lt_name_mappings
    CHANGING
      data          = ls_response
  ).

  WRITE |CMIS Object ID = { ls_response-properties-object_id-value }|.
