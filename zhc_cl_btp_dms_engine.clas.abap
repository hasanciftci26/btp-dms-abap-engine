class ZHC_CL_BTP_DMS_ENGINE definition
  public
  final
  create public .

public section.

  methods GET_FOLDER_TREE
    importing
      !IV_REPOSITORY type STRING
    returning
      value(RV_JSON) type STRING .
  methods CREATE_REPOSITORY
    importing
      !IV_DISPLAY_NAME type STRING
      !IV_DESCRIPTION type STRING
      !IV_REPOSITORYTYPE type STRING
      !IV_IS_VERSION_ENABLED type STRING
      !IV_IS_VIRUS_SCANENABLED type STRING
      !IV_SKIP_VIRUS_SCAN type STRING
      !IV_IS_THUMBNAIL_ENABLED type STRING
      !IV_IS_ENCRYPTION_ENABLE type STRING
      !IV_HASH_ALGORITHMS type STRING
      !IV_IS_CONTENT_BRIDGE_ENABLED type STRING
      !IV_EXTERNAL_ID type STRING
    returning
      value(RV_JSON) type STRING .
  methods CREATE_FOLDER
    importing
      !IV_FOLDER_NAME type STRING
      !IV_REPOSITORY type STRING
      !IV_DIRECTORY type STRING
    returning
      value(RV_JSON) type STRING .
  methods CREATE_DOCUMENT
    importing
      !IV_REPOSITORY type STRING
      !IV_FOLDER type STRING
      !IV_FILENAME type STRING
      !IV_MIMETYPE type STRING
      !IV_MEDIA type XSTRING
    returning
      value(RV_JSON) type STRING .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZHC_CL_BTP_DMS_ENGINE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZHC_CL_BTP_DMS_ENGINE->CREATE_DOCUMENT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_REPOSITORY                  TYPE        STRING
* | [--->] IV_FOLDER                      TYPE        STRING
* | [--->] IV_FILENAME                    TYPE        STRING
* | [--->] IV_MIMETYPE                    TYPE        STRING
* | [--->] IV_MEDIA                       TYPE        XSTRING
* | [<-()] RV_JSON                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_document.

    DATA: lo_http_client   TYPE REF TO if_http_client.

    cl_http_client=>create_by_destination(
      EXPORTING
        destination                = 'BTP_DMS_API'
      IMPORTING
        client                     = lo_http_client
      EXCEPTIONS
        argument_not_found         = 1
        destination_not_found      = 2
        destination_no_authority   = 3
        plugin_not_active          = 4
        internal_error             = 5
        oa2c_set_token_error       = 6
        oa2c_missing_authorization = 7
        oa2c_invalid_config        = 8
        oa2c_invalid_parameters    = 9
        oa2c_invalid_scope         = 10
        oa2c_invalid_grant         = 11
        OTHERS                     = 12
    ).

    cl_http_utility=>set_request_uri(
      request    = lo_http_client->request
      uri        = |/browser/{ iv_repository }/root{ iv_folder }|
    ).

    lo_http_client->request->set_header_field(
      name  = 'Content-Type'
      value = |multipart/form-DATA; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW|
    ).

    DATA(lo_part) = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="cmisaction"'
    ).

    lo_part->set_cdata(
      data = 'createDocument'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="propertyId[0]"'
    ).

    lo_part->set_cdata(
      data = 'cmis:name'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="propertyValue[0]"'
    ).

    lo_part->set_cdata(
      data = iv_filename
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="propertyId[1]"'
    ).

    lo_part->set_cdata(
      data = 'cmis:objectTypeId'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="propertyValue[1]"'
    ).

    lo_part->set_cdata(
      data = 'cmis:document'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="_charset"'
    ).

    lo_part->set_cdata(
      data = 'UTF-8'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="includeAllowableActions"'
    ).

    lo_part->set_cdata(
      data = 'false'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = 'form-data; name="succinct"'
    ).

    lo_part->set_cdata(
      data = 'false'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value = |form-data; name="media"; filename="{ iv_filename }"|
    ).

    lo_part->set_header_field(
    name  = 'Content-Type'
    value = iv_mimetype
  ).

    lo_part->set_data(
      data = iv_media
    ).

    lo_http_client->request->set_method( 'POST' ).
    lo_http_client->send(  ).
    lo_http_client->receive( ).
    rv_json = lo_http_client->response->get_cdata( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZHC_CL_BTP_DMS_ENGINE->CREATE_FOLDER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FOLDER_NAME                 TYPE        STRING
* | [--->] IV_REPOSITORY                  TYPE        STRING
* | [--->] IV_DIRECTORY                   TYPE        STRING
* | [<-()] RV_JSON                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_folder.

    DATA: lo_http_client TYPE REF TO if_http_client.

    cl_http_client=>create_by_destination(
      EXPORTING
        destination                = 'BTP_DMS_API'
      IMPORTING
        client                     = lo_http_client
      EXCEPTIONS
        argument_not_found         = 1
        destination_not_found      = 2
        destination_no_authority   = 3
        plugin_not_active          = 4
        internal_error             = 5
        oa2c_set_token_error       = 6
        oa2c_missing_authorization = 7
        oa2c_invalid_config        = 8
        oa2c_invalid_parameters    = 9
        oa2c_invalid_scope         = 10
        oa2c_invalid_grant         = 11
        OTHERS                     = 12
    ).

    cl_http_utility=>set_request_uri(
      request    = lo_http_client->request
      uri        = |/browser/{ iv_repository }/root{ iv_directory }|
    ).

    lo_http_client->request->set_header_field(
      name  = 'Content-Type'
      value = |multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW|
    ).

    DATA(lo_part) = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="cmisaction"'
    ).

    lo_part->set_cdata(
      data   = 'createFolder'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="propertyId[0]"'
    ).

    lo_part->set_cdata(
      data   = 'cmis:name'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="propertyValue[0]"'
    ).

    lo_part->set_cdata(
      data   = iv_folder_name
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="propertyId[1]"'
    ).

    lo_part->set_cdata(
      data   = 'cmis:objectTypeId'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="propertyValue[1]"'
    ).

    lo_part->set_cdata(
      data   = 'cmis:folder'
    ).

    lo_part = lo_http_client->request->add_multipart( ).

    lo_part->set_header_field(
      name  = 'Content-Disposition'
      value =  'form-data; name="succinct"'
    ).

    lo_part->set_cdata(
      data   = 'true'
    ).

    lo_http_client->request->set_method( 'POST' ).
    lo_http_client->send(  ).
    lo_http_client->receive( ).
    rv_json = lo_http_client->response->get_cdata( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZHC_CL_BTP_DMS_ENGINE->CREATE_REPOSITORY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_DISPLAY_NAME                TYPE        STRING
* | [--->] IV_DESCRIPTION                 TYPE        STRING
* | [--->] IV_REPOSITORYTYPE              TYPE        STRING
* | [--->] IV_IS_VERSION_ENABLED          TYPE        STRING
* | [--->] IV_IS_VIRUS_SCANENABLED        TYPE        STRING
* | [--->] IV_SKIP_VIRUS_SCAN             TYPE        STRING
* | [--->] IV_IS_THUMBNAIL_ENABLED        TYPE        STRING
* | [--->] IV_IS_ENCRYPTION_ENABLE        TYPE        STRING
* | [--->] IV_HASH_ALGORITHMS             TYPE        STRING
* | [--->] IV_IS_CONTENT_BRIDGE_ENABLED   TYPE        STRING
* | [--->] IV_EXTERNAL_ID                 TYPE        STRING
* | [<-()] RV_JSON                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_repository.

    TYPES: BEGIN OF lty_repository,
             display_name                   TYPE string,
             description                    TYPE string,
             repository_type                TYPE string,
             is_version_enabled             TYPE string,
             is_virus_scan_enabled          TYPE string,
             skip_virus_scan_for_large_file TYPE string,
             is_thumbnail_enabled           TYPE string,
             is_encryption_enabled          TYPE string,
             hash_algorithms                TYPE string,
             is_content_bridge_enabled      TYPE string,
             external_id                    TYPE string,
           END OF lty_repository.

    DATA: BEGIN OF ls_body_data,
            repository TYPE lty_repository,
          END OF ls_body_data,
          lo_http_client TYPE REF TO if_http_client,
          lv_json        TYPE string.

    ls_body_data-repository-display_name                   = iv_display_name.
    ls_body_data-repository-description                    = iv_description.
    ls_body_data-repository-repository_type                = iv_repositorytype.
    ls_body_data-repository-is_version_enabled             = iv_is_version_enabled.
    ls_body_data-repository-is_virus_scan_enabled          = iv_is_virus_scanenabled.
    ls_body_data-repository-skip_virus_scan_for_large_file = iv_skip_virus_scan.
    ls_body_data-repository-is_thumbnail_enabled           = iv_is_thumbnail_enabled.
    ls_body_data-repository-is_encryption_enabled          = iv_is_encryption_enable.
    ls_body_data-repository-hash_algorithms                = iv_hash_algorithms.
    ls_body_data-repository-is_content_bridge_enabled      = iv_is_content_bridge_enabled.
    ls_body_data-repository-external_id                    = iv_external_id.

    lv_json = /ui2/cl_json=>serialize(
      EXPORTING
        data             =  ls_body_data
        pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
    ).

    cl_http_client=>create_by_destination(
      EXPORTING
        destination                = 'BTP_DMS_API'
      IMPORTING
        client                     = lo_http_client
      EXCEPTIONS
        argument_not_found         = 1
        destination_not_found      = 2
        destination_no_authority   = 3
        plugin_not_active          = 4
        internal_error             = 5
        oa2c_set_token_error       = 6
        oa2c_missing_authorization = 7
        oa2c_invalid_config        = 8
        oa2c_invalid_parameters    = 9
        oa2c_invalid_scope         = 10
        oa2c_invalid_grant         = 11
        OTHERS                     = 12
    ).

    cl_http_utility=>set_request_uri(
      request    = lo_http_client->request
      uri        = |/rest/v2/repositories|
    ).

    lo_http_client->request->set_header_field(
    name = 'Content-Type'
    value = 'application/json'
    ).

    lo_http_client->request->set_cdata(
      EXPORTING
        data = lv_json
    ).

    lo_http_client->request->set_method( 'POST' ).
    lo_http_client->send(  ).
    lo_http_client->receive( ).
    rv_json = lo_http_client->response->get_cdata( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZHC_CL_BTP_DMS_ENGINE->GET_FOLDER_TREE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_REPOSITORY                  TYPE        STRING
* | [<-()] RV_JSON                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_folder_tree.

    DATA: lo_http_client   TYPE REF TO if_http_client.

    cl_http_client=>create_by_destination(
      EXPORTING
        destination                = 'BTP_DMS_API'
      IMPORTING
        client                     = lo_http_client
      EXCEPTIONS
        argument_not_found         = 1
        destination_not_found      = 2
        destination_no_authority   = 3
        plugin_not_active          = 4
        internal_error             = 5
        oa2c_set_token_error       = 6
        oa2c_missing_authorization = 7
        oa2c_invalid_config        = 8
        oa2c_invalid_parameters    = 9
        oa2c_invalid_scope         = 10
        oa2c_invalid_grant         = 11
        OTHERS                     = 12
    ).

    cl_http_utility=>set_request_uri(
      request    = lo_http_client->request
      uri        =  |browser/{ iv_repository }/root|
    ).

    lo_http_client->request->set_method( 'GET' ).
    lo_http_client->send(  ).
    lo_http_client->receive( ).
    rv_json = lo_http_client->response->get_cdata( ).

  ENDMETHOD.
ENDCLASS.
