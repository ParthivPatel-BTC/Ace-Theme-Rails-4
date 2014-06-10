$(document).ready ->
  $.validator.addMethod "pin_validation", ((value, element) ->
    @optional(element) or /^(\s*\d{6}\s*)(,\s*\d{6}\s*)*,?\s*$/.test(value)
  ), "PIN should contain 6 digits."
  $.validator.addMethod "pin_comparison", ((value, element) ->
    @optional(element) or ($("#case_pin_number").val() is $("#case_pin_number_inital_pin_number_inital").val())
  ), "PIN doesn't match."

  # FILE NEW REPORT PAGE
  # Show/Hide select box related fields
  $('#clientCaseWebForm select').change ->
    if $(this).find('option:selected').text() is 'Other'
      showSiblingTextFields $(this)
    else
      hideSiblingTextFields $(this)

  # Show/Hide Radio Button related fields
  $('#clientCaseWebForm :input[name="case[case_question_answers_attributes][remain_anonymous][question_option_id]"]').change ->
    if $(this).next().text() is 'No'
      showSiblingTextFields $(this)
    else
      hideSiblingTextFields $(this)

  # EDIT CASE PAGE
  # When Auto Assign Investigator is selected 'yes' and casePriorityField or caseClassificationField changes
  # then send ajax request for auto assign case manager
  $('#caseUpdateForm :input[name="case[auto_assign_investigator]"], #caseUpdateForm #caseClassificationField, #caseUpdateForm #casePriorityField').change ->
    if $('#caseUpdateForm input:radio[name="case[auto_assign_investigator]"]:checked').val() is 'true'
      autoAssignCaseMgrByAjax()
    else
      $('#caseUpdateForm #autoAssignInvestigatorNotFound').html('')

  # When Auto Assign Investigator is selected 'NO' then empty the primary Investigator field
  $('#caseUpdateForm :input[name="case[auto_assign_investigator]"]').change ->
    if $(this).val() == 'false'
      $('#caseUpdateForm #casePrimaryInvestigator').val('')

  $('#caseUpdateForm #casePrimaryInvestigator').change ->
    $('#caseUpdateForm #autoAssignInvestigatorNotFound').html('')

  caseUpdateForm = $('#caseUpdateForm');
  if caseUpdateForm.length > 0
    validatecaseUpdatePageForm(caseUpdateForm)
  newCaseForm = $("#clientCaseWebForm")
  validateNewCaseForm newCaseForm

  $(".chosen-select").chosen()
  $("#chosen-multiple-style").on "click", (e) ->
    target = $(e.target).find("input[type=radio]")
    which = parseInt(target.val())
    if which is 2
      $("#form-field-select-4").addClass "tag-input-style"
    else
      $("#form-field-select-4").removeClass "tag-input-style"
    return

  nowDate = new Date()
  today = new Date(nowDate.getFullYear(), nowDate.getMonth(), nowDate.getDate(), 0, 0, 0, 0)
  $(".date-picker").datepicker(autoclose: true, format: 'dd/mm/yyyy', startDate: today ).next().on ace.click_event, ->
    $(this).prev().focus()
    return

  $("input[name=created_at]").daterangepicker({ format: 'DD/MM/YYYY' }).prev().on ace.click_event, ->
    $(this).next().focus()
    return

showSiblingTextFields = (changedElement) ->
  changedElement.parent().children('.hide').attr('class', 'show')

hideSiblingTextFields = (changedElement) ->
  targetDiv = changedElement.parent().children('.show').attr('class', 'hide')
  targetDiv.find('input').val('')

validatecaseUpdatePageForm = (form) ->
  jQuery.validator.addMethod "investigatorNotEqual", ((value, element) ->
    $('label.error').hide()
    @optional(element) or $('#casePrimaryInvestigator').val() != $('#caseSecondaryInvestigator').val()
  ), "* Please select two different Investigators"
  # jQuery.validator.addMethod "selectOneInvestigator", ((value, element) ->
  #   $('label.error').hide()
  #   if value is 'false'
  #     investigatorNotAssigned = ($(casePrimaryInvestigator).val() is '' && $(caseSecondaryInvestigator).val() is '')
  #     error = !investigatorNotAssigned
  #   else
  #     error = true
  #   @optional(element) or error
  # ), "* Please assign Investigators"
  form.validate
    rules:
      "case[case_investigators_attributes][][user_id]":
        investigatorNotEqual: true
      # "case[auto_assign_investigator]":
      #   selectOneInvestigator: true

    errorPlacement: (error, element) ->
      if element.attr("name") is 'case[auto_assign_investigator]'
        error.insertAfter "#autoAssignInvestigatorErrorMsg"
      else
        error.insertAfter element

autoAssignCaseMgrByAjax = ->
  casePriorityId = $('#casePriorityField').val()
  caseClassificationId = $('#caseClassificationField').val()
  caseIdPath = $('#caseUpdateForm').attr('action')
  $.ajax
    type: "POST"
    beforeSend: (xhr) ->
      xhr.setRequestHeader "X-CSRF-Token", $("meta[name=\"csrf-token\"]").attr("content")
    url: caseIdPath+'/auto_assign'
    data: {case_priority_id: casePriorityId, case_classification_id: caseClassificationId}

validateNewCaseForm = (form) ->
  form.validate errorPlacement: (error, element) ->
    if element.attr("type") is "radio"
      $(element).parent().append(error)
      # error.insertBefore element
    else
      error.insertAfter element
