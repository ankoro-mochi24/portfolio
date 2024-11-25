// new/editで画像が選択されるたびに即座にブラウザに反映
document.addEventListener('DOMContentLoaded', function() {
  function previewDishImage(event) {
    var output = document.getElementById('dish_image_preview');
    output.innerHTML = '';
    var img = document.createElement('img');
    img.src = URL.createObjectURL(event.target.files[0]);
    img.style.maxWidth = '300px';
    img.style.maxHeight = '300px';
    output.appendChild(img);
  }

  function previewStepImage(event, input) {
    var previewContainer = input.closest('.nested-fields').querySelector('.step_image_preview');
    previewContainer.innerHTML = '';
    var img = document.createElement('img');
    img.src = URL.createObjectURL(event.target.files[0]);
    img.style.maxWidth = '300px';
    img.style.maxHeight = '300px';
    previewContainer.appendChild(img);
  }

  document.querySelectorAll('input[type="file"][id$="_dish_image"]').forEach(function(input) {
    input.addEventListener('change', previewDishImage);
  });

  document.querySelectorAll('input[type="file"][id$="_step_image"]').forEach(function(input) {
    input.addEventListener('change', function(event) {
      previewStepImage(event, this);
    });
  });
});
