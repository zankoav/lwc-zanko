"use strict";function phoneMask(e,t,n){var s=document.getElementsByClassName(e)[0];if(s){var u=new RegExp("^\\"+t+"\\d{0,"+n+"}$"),i=n+t.length,v=t;s.addEventListener("focus",function(){s.removeEventListener("mouseover",a,!1),s.removeEventListener("mouseout",o,!1),""===this.value&&(this.value=t)},!1),s.addEventListener("blur",function(){this.value===t&&(this.value="",s.addEventListener("mouseover",a,!1),s.addEventListener("mouseout",o,!1))},!1),s.addEventListener("mouseover",a,!1),s.addEventListener("mouseout",o,!1),s.addEventListener("input",function(){u.test(this.value)&&this.value.length<=i?v=this.value:this.value=v},!1)}function a(){""===this.value&&(this.value=t)}function o(){this!==document.activeElement&&this.value===t&&(this.value="")}}phoneMask('hu-js-phone', '+36', 10);phoneMask('de-js-phone', '+49', 14);phoneMask('nl-js-phone', '+31', 12);phoneMask('be-js-phone', '+32', 12);