class zcl_nad_core_gos_viewer definition
  public
  final
  create public .

public section.

  interfaces /neptune/if_nad_server .

  types:begin of ty_attachment,
          instid       type string,
          typeid       type string,
          instid_b     type sofolenti1-doc_id,
          description  type string,
          file_ext     type string,
          file_size    type string,
          file_name    type string,
          mime_type    type string,
          creat_name   type string,
          creat_fnam   type string,
          creat_date   type string,
          creat_time   type string,
          content      type string,
          delete       type boolean,
    end of ty_attachment.

  data wa_attachment type ty_attachment.
protected section.
private section.

  methods GET_ATTACHMENT_DATA
    importing
      !AJAX_VALUE type STRING .
ENDCLASS.



CLASS ZCL_NAD_CORE_GOS_VIEWER IMPLEMENTATION.


method /neptune/if_nad_server~handle_on_ajax.


  case ajax_id.

    when 'GET_DATA'.
      call method get_attachment_data( ajax_value ).

  endcase.

endmethod.


method get_attachment_data.

data: lv_doc_id         type sofolenti1-doc_id,
      lv_content        type xstring,
      lv_file_name(255) type c,
      lv_file_type(9)   type c,
      lv_length         type i,
      lv_temp           type string,
      lv_lines          type i,
      it_hex            type standard table of solix,
      it_header         type standard table of solisti1,
      wa_header         type solisti1,
      wa_hex            like line of it_hex,
      wa_doc            type sofolenti1.


  lv_doc_id = ajax_value.
  call function 'SO_DOCUMENT_READ_API1'
    exporting
      document_id                      = lv_doc_id
    importing
      document_data                    = wa_doc
    tables
      object_header                    = it_header
      contents_hex                     = it_hex
    exceptions
      document_id_not_exist            = 1
      operation_no_authorization       = 2
      x_error                          = 3
      others                           = 4.


* Build String
  lv_length = wa_doc-doc_size.

* Xstring
  call function 'SCMS_BINARY_TO_XSTRING'
    exporting
      input_length       = lv_length
    importing
      buffer             = lv_content
    tables
      binary_tab         = it_hex
    exceptions
      failed             = 1
      others             = 2.

* Base64 encoded
  call function 'SCMS_BASE64_ENCODE_STR'
    exporting
      input         = lv_content
    importing
      output        = wa_attachment-content.

* Filename
  read table it_header into wa_header index 1.

  split wa_header at '=' into lv_temp
                              lv_file_name.

* Get Extension
  call function 'TRINT_FILE_GET_EXTENSION'
    exporting
      filename        = lv_file_name
    importing
      extension       = lv_file_type.

* Attachment Data
  move-corresponding wa_doc to wa_attachment.
  wa_attachment-file_name = lv_file_name.
  condense wa_attachment-file_name no-gaps.


* Set Document Response
  case lv_file_type.

    when 'PNG'.
      wa_attachment-mime_type = 'image/png'.

    when 'JPG'.
      wa_attachment-mime_type = 'image/jpg'.

    when 'JPEG'.
      wa_attachment-mime_type = 'image/jpeg'.

    when 'GIF'.
      wa_attachment-mime_type = 'image/gif'.

    when 'PDF'.
      wa_attachment-mime_type = 'application/pdf'.

    when 'DOCX'.
      wa_attachment-mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document;charset=utf-8'.

    when 'DOC'.
      wa_attachment-mime_type = 'application/msword'.

    when 'XLS'.
      wa_attachment-mime_type = 'application/vnd.ms-excel'.

    when 'XLSX'.
      wa_attachment-mime_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=utf-8'.

    when 'PPT'.
      wa_attachment-mime_type = 'application/vnd.ms-powerpoint'.

    when 'PPTX'.
      wa_attachment-mime_type = 'application/vnd.openxmlformats-officedocument.presentationml.presentation;charset=utf-8'.

    when others.
      wa_attachment-mime_type = 'text/html'.

  endcase.


endmethod.
ENDCLASS.
