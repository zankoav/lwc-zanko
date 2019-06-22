j$ = jQuery.noConflict();
function increaseCards() {
    var counter = parseInt($j('.cards-count .number-wrapper input').val());
    if(counter < 50){
        $j('.cards-count .number-wrapper input').val(counter + 1);
    }
}
function reductionCards() {
    var counter = parseInt($j('.cards-count .number-wrapper input').val());
    if(counter > 1){
        $j('.cards-count .number-wrapper input').val(counter - 1);
    }
}