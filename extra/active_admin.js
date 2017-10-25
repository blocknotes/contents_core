//= require active_admin/base

window.onload = function() {
  var items = document.querySelectorAll( '[data-hash-key]' );
  for( var i = 0; i < items.length; i++ ) {
    var key = items[i].getAttribute( 'data-hash-key' );
    var name = items[i].getAttribute( 'name' );
    items[i].setAttribute( 'name', name.slice( 0, -1 ) + '_' + key + ']' )
  }
};
