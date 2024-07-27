document.addEventListener('DOMContentLoaded', function() {
  function previewFoodstuffImages(event) {
    var output = document.getElementById('foodstuff_image_preview');
    output.innerHTML = '';
    Array.from(event.target.files).forEach(function(file) {
      var img = document.createElement('img');
      img.src = URL.createObjectURL(file);
      img.style.maxWidth = '300px';
      img.style.maxHeight = '300px';
      output.appendChild(img);
    });
  }

  document.querySelectorAll('input[type="file"][id$="_image"]').forEach(function(input) {
    input.addEventListener('change', previewFoodstuffImages);
  });
});
