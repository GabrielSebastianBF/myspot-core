//= require action_cable
//= require_self
//= require_tree .

function initActionCable() {
  window.ActionCable = require('actioncable');
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initActionCable);
} else {
  initActionCable();
}
