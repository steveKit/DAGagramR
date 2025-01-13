Shiny.addCustomMessageHandler('copyToClipboard', function(text) {
  navigator.clipboard.writeText(text).then(function() {
    console.log('Text copied successfully');
  }).catch(function(err) {
    console.error('Failed to copy text:', err);
  });
});
