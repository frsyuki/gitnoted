var gitNotesUrl = new URL(document.currentScript.src)
gitNotesUrl.pathname = "/api/notes.html"

$(document).ready(function() {
  function injectExpandScript(e, parentLabels) {
    e.querySelectorAll('.gitnoted-label').forEach(function (e) {
      var url = new URL(gitNotesUrl)
      url.searchParams.set('labels', e.innerText)
      url.searchParams.set('exclude_labels', parentLabels)
      var nextParentLabels = `${parentLabels},${e.innerText}`
      e.classList.add('gitnoted-label-button')
      e.onclick = function() {
        console.log(`exclude_labels: ${nextParentLabels}`)
        fetch(url, {mode: 'cors'}).then(function (r) {
          return r.text()
        }).then(function (t) {
          var template = document.createElement('template')
          template.innerHTML = t
          var note = template.content.firstChild
          injectExpandScript(note, nextParentLabels)
          e.parentNode.parentNode.appendChild(note, e)
          e.classList.remove('gitnoted-label-button')
          e.onclick = null
        })
      }
    })
  }

  document.querySelectorAll('div.gitnoted').forEach(function (e) {
    var url = new URL(gitNotesUrl)
    if (e.dataset.labels) {
      url.searchParams.set('labels', e.dataset.labels)
    }
    fetch(url, {mode: 'cors'}).then(function (r) {
      return r.text()
    }).then(function (t) {
      var template = document.createElement('template')
      template.innerHTML = t
      var note = template.content.firstChild
      if (e.dataset.labels) {
        injectExpandScript(note, e.dataset.labels)
      }
      e.parentNode.replaceChild(note, e)
    })
  })
})
