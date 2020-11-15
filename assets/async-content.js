load_resources = async function() {
  console.log('Arranco')
  resources = {
    'ping_8': '.ping-8-8-8-8',
    'ping_D': '.ping-digitalocean',
    'ping_I': '.ping-interno'
  }

  for (url of Object.keys(resources)) {
    $.ajax({
      url: url,
      success: function(result) {
        selector = resources[this.url.split('?')[0]]
        $(selector).html(result)
      }
    })
  }

  sync_resources = []

  function_for = function(url) {
    return function() {
      $.ajax({
        url: url,
        success: function(result) {
          selector = '.' + this.url.split('?')[0]
          $(selector).html(result)

          if (sync_resources.length) {
            sync_resources.pop()()
          }
        }
      })
    }.bind(this)
  }

  sync_resources.push(function_for('speedtest'))
  sync_resources.push(function_for('fast'))

  sync_resources.pop()()
}

setTimeout(load_resources, 1000)
