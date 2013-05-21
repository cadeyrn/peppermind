$('#mozilla-persona').click (event) ->
  event.preventDefault()
  navigator.id.watch
    loggedInUser: null
    onlogin: (assertion) ->
      $loadingOverlay = $('#loading-overlay')
      $loadingSpinner = $('#loading-spinner').show();
      $loadingOverlay.addClass('loading-overlay')
      $loadingSpinner.show();
      $.ajax
        type: 'POST'
        url: '/auth/persona/callback'
        data:
          assertion: assertion
        success: (res, status, xhr) ->
          $loadingOverlay.removeClass('loading-overlay')
          $loadingSpinner.hide();
          window.location.reload()
        error: (xhr, status, error) ->
          console.error(error)
    onlogout: ->
  navigator.id.request siteName: 'Peppermind'
