(function(e){function t(t){for(var r,o,c=t[0],u=t[1],l=t[2],s=0,d=[];s<c.length;s++)o=c[s],a[o]&&d.push(a[o][0]),a[o]=0;for(r in u)Object.prototype.hasOwnProperty.call(u,r)&&(e[r]=u[r]);f&&f(t);while(d.length)d.shift()();return i.push.apply(i,l||[]),n()}function n(){for(var e,t=0;t<i.length;t++){for(var n=i[t],r=!0,o=1;o<n.length;o++){var c=n[o];0!==a[c]&&(r=!1)}r&&(i.splice(t--,1),e=u(u.s=n[0]))}return e}var r={},o={app:0},a={app:0},i=[];function c(e){return u.p+"js/"+({"as-planned":"as-planned","fuel-up":"fuel-up",header:"header",modal:"modal","more-time":"more-time","strong-package":"strong-package",background:"background","content-box":"content-box","shell-logo":"shell-logo"}[e]||e)+"."+{"as-planned":"35bc5a61","fuel-up":"b958164a",header:"3bc68ba5",modal:"f18fd25d","more-time":"1690fca0","strong-package":"2a8daed7",background:"12a0b747","content-box":"a7b7970c","shell-logo":"ac5cbc92"}[e]+".js"}function u(t){if(r[t])return r[t].exports;var n=r[t]={i:t,l:!1,exports:{}};return e[t].call(n.exports,n,n.exports,u),n.l=!0,n.exports}u.e=function(e){var t=[],n={header:1,modal:1,background:1,"content-box":1};o[e]?t.push(o[e]):0!==o[e]&&n[e]&&t.push(o[e]=new Promise(function(t,n){for(var r="css/"+({"as-planned":"as-planned","fuel-up":"fuel-up",header:"header",modal:"modal","more-time":"more-time","strong-package":"strong-package",background:"background","content-box":"content-box","shell-logo":"shell-logo"}[e]||e)+"."+{"as-planned":"31d6cfe0","fuel-up":"31d6cfe0",header:"c7c2e071",modal:"3317a54a","more-time":"31d6cfe0","strong-package":"31d6cfe0",background:"beb4c15e","content-box":"e5608c7b","shell-logo":"31d6cfe0"}[e]+".css",o=u.p+r,a=document.getElementsByTagName("link"),i=0;i<a.length;i++){var c=a[i],l=c.getAttribute("data-href")||c.getAttribute("href");if("stylesheet"===c.rel&&(l===r||l===o))return t()}var s=document.getElementsByTagName("style");for(i=0;i<s.length;i++){c=s[i],l=c.getAttribute("data-href");if(l===r||l===o)return t()}var d=document.createElement("link");d.rel="stylesheet",d.type="text/css",d.onload=t,d.onerror=function(t){var r=t&&t.target&&t.target.src||o,a=new Error("Loading CSS chunk "+e+" failed.\n("+r+")");a.request=r,n(a)},d.href=o;var f=document.getElementsByTagName("head")[0];f.appendChild(d)}).then(function(){o[e]=0}));var r=a[e];if(0!==r)if(r)t.push(r[2]);else{var i=new Promise(function(t,n){r=a[e]=[t,n]});t.push(r[2]=i);var l,s=document.getElementsByTagName("head")[0],d=document.createElement("script");d.charset="utf-8",d.timeout=120,u.nc&&d.setAttribute("nonce",u.nc),d.src=c(e),l=function(t){d.onerror=d.onload=null,clearTimeout(f);var n=a[e];if(0!==n){if(n){var r=t&&("load"===t.type?"missing":t.type),o=t&&t.target&&t.target.src,i=new Error("Loading chunk "+e+" failed.\n("+r+": "+o+")");i.type=r,i.request=o,n[1](i)}a[e]=void 0}};var f=setTimeout(function(){l({type:"timeout",target:d})},12e4);d.onerror=d.onload=l,s.appendChild(d)}return Promise.all(t)},u.m=e,u.c=r,u.d=function(e,t,n){u.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},u.r=function(e){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},u.t=function(e,t){if(1&t&&(e=u(e)),8&t)return e;if(4&t&&"object"===typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(u.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)u.d(n,r,function(t){return e[t]}.bind(null,r));return n},u.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return u.d(t,"a",t),t},u.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},u.p="",u.oe=function(e){throw console.error(e),e};var l=window["webpackJsonp"]=window["webpackJsonp"]||[],s=l.push.bind(l);l.push=t,l=l.slice();for(var d=0;d<l.length;d++)t(l[d]);var f=s;i.push([0,"chunk-vendors"]),n()})({0:function(e,t,n){e.exports=n("56d7")},"22c9":function(e,t,n){"use strict";n.r(t),n.d(t,"default",function(){return l});var r,o,a=n("d4ec"),i=n("bee2"),c=n("63ae"),u=n("9473"),l=Object(u["e"])((o=function(){function e(){Object(a["a"])(this,e),this.moduleName="general",this.direction=2}return Object(i["a"])(e,[{key:"setDirection",value:function(e,t){e.direction=t}},{key:"getDirection",value:function(e){return e.direction}}]),e}(),Object(c["a"])(o.prototype,"setDirection",[u["d"]],Object.getOwnPropertyDescriptor(o.prototype,"setDirection"),o.prototype),Object(c["a"])(o.prototype,"getDirection",[u["c"]],Object.getOwnPropertyDescriptor(o.prototype,"getDirection"),o.prototype),r=o))||r},"3dcc":function(e,t,n){var r={"./components/Modal/vuex/ModalStore.js":"dff9","./vuex/GeneralStore.js":"22c9"};function o(e){var t=a(e);return n(t)}function a(e){var t=r[e];if(!(t+1)){var n=new Error("Cannot find module '"+e+"'");throw n.code="MODULE_NOT_FOUND",n}return t}o.keys=function(){return Object.keys(r)},o.resolve=a,e.exports=o,o.id="3dcc"},"56d7":function(e,t,n){"use strict";n.r(t);n("cadf"),n("551c"),n("097d");var r,o,a,i,c,u,l,s,d=n("2b0e"),f=function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("div",{attrs:{id:"app"}},[n("div",{on:{click:function(t){e.$store.dispatch("modal/show")}}},[n("page-header"),n("div",{directives:[{name:"hammer",rawName:"v-hammer:swipe.horizontal",value:e.onSwipe,expression:"onSwipe",arg:"swipe",modifiers:{horizontal:!0}}]},[n("transition",{attrs:{appear:""},on:{enter:e.enter,leave:e.leave}},[n("router-view",{class:e.$style.page})],1)],1)],1),n("modal",{attrs:{headline:"Kunde werden und Tankkarten beantragen"}})],1)},p=[],m=(n("7f7f"),n("6b7b")),h=n("d4ec"),b=n("bee2"),v=n("99de"),y=n("7e84"),g=n("262e"),O=n("257e"),w=n("63ae"),j=(n("f890"),n("60a3")),k=n("4bb5"),x=[{path:"/",redirect:{name:"fuel-up"}},{path:"/fuel-up",name:"fuel-up",component:function(){return n.e("fuel-up").then(n.bind(null,"7eff"))}},{path:"/strong-package",name:"strong-package",component:function(){return n.e("strong-package").then(n.bind(null,"c553"))}},{path:"/more-time",name:"more-time",component:function(){return n.e("more-time").then(n.bind(null,"6e77"))}},{path:"/as-planned",name:"as-planned",component:function(){return n.e("as-planned").then(n.bind(null,"b14f"))}}],D=n("9380"),T=n.n(D),I=n("51f5"),P=n.n(I),_=n("f0e7"),E=n("9ce6"),S=n("61da"),N=function(){return n.e("header").then(n.bind(null,"4676"))},L=function(){return n.e("modal").then(n.bind(null,"fd0d"))},A=(r=Object(j["a"])({components:{PageHeader:N,Modal:L}}),o=Object(k["a"])("general/getDirection"),a=Object(k["a"])("modal/getShow"),i=Object(j["d"])("modalOpen"),r((u=function(e){function t(){var e,n;Object(h["a"])(this,t);for(var r=arguments.length,o=new Array(r),a=0;a<r;a++)o[a]=arguments[a];return n=Object(v["a"])(this,(e=Object(y["a"])(t)).call.apply(e,[this].concat(o))),n.routes=[],n.currentIndex=null,n.switchInterval=null,n.slideInterval=3e4,n.enterTimeline=null,n.leaveTimeline=null,n.slideAnimationDuration=.6,n.activated=[E["a"]],Object(m["a"])(n,"swipeDirection",l,Object(O["a"])(Object(O["a"])(n))),Object(m["a"])(n,"modalOpen",s,Object(O["a"])(Object(O["a"])(n))),n}return Object(g["a"])(t,e),Object(b["a"])(t,[{key:"modalOpenChanged",value:function(e){e?this.destroyInterval():this.initInterval()}},{key:"created",value:function(){this.routes=T()(x,function(e){return e.name})}},{key:"mounted",value:function(){this.initInterval()}},{key:"initInterval",value:function(){var e=this;this.destroyInterval(),this.switchInterval=setInterval(function(){e.$store.commit("general/setDirection",2),null===e.currentIndex&&(e.currentIndex=P()(e.routes,function(t){return t.name===e.$route.name})),e.currentIndex>=e.routes.length-1?e.currentIndex=0:e.currentIndex++,S["a"].$emit("PAGE_CHANGING"),j["c"].nextTick(function(){setTimeout(function(){e.$router.push(e.routes[e.currentIndex].name)},600)})},this.slideInterval)}},{key:"destroyInterval",value:function(){clearInterval(this.switchInterval),this.switchInterval=null}},{key:"destroyed",value:function(){this.destroyInterval()}},{key:"onSwipe",value:function(e){var t=this;this.destroyInterval(),this.initInterval(),this.$store.commit("general/setDirection",e.direction),null===this.currentIndex&&(this.currentIndex=P()(this.routes,function(e){return e.name===t.$route.name})),2===e.direction?this.currentIndex>=this.routes.length-1?this.currentIndex=0:this.currentIndex++:this.currentIndex<=0?this.currentIndex=this.routes.length-1:this.currentIndex--,this.$router.push(this.routes[this.currentIndex].name)}},{key:"enter",value:function(e,t){var n=this;null!==this.enterTimeline&&(this.enterTimeline.kill(),this.enterTimeline=null),j["c"].nextTick(function(){n.enterTimeline=new _["a"],n.enterTimeline.fromTo(e,n.slideAnimationDuration,{position:"absolute",top:0,left:0,xPercent:2===n.swipeDirection?"100%":"-100%"},{xPercent:0}),n.enterTimeline.to(e,0,{clearProps:"all",onComplete:t})})}},{key:"leave",value:function(e,t){var n=this;null!==this.leaveTimeline&&(this.leaveTimeline.kill(),this.leaveTimeline=null),j["c"].nextTick(function(){n.leaveTimeline=new _["a"],n.leaveTimeline.fromTo(e,n.slideAnimationDuration,{position:"absolute",top:0,left:0,xPercent:0},{xPercent:2===n.swipeDirection?"-100%":"100%",onComplete:t}),n.leaveTimeline.to(e,0,{clearProps:"all",onComplete:t})})}}]),t}(j["c"]),l=Object(w["a"])(u.prototype,"swipeDirection",[o],{configurable:!0,enumerable:!0,writable:!0,initializer:null}),s=Object(w["a"])(u.prototype,"modalOpen",[a],{configurable:!0,enumerable:!0,writable:!0,initializer:null}),Object(w["a"])(u.prototype,"modalOpenChanged",[i],Object.getOwnPropertyDescriptor(u.prototype,"modalOpenChanged"),u.prototype),c=u))||c),M=A,C=n("8d8d"),$=(n("5c64"),n("2877"));function G(e){this["$style"]=C["default"].locals||C["default"]}var z=Object($["a"])(M,f,p,!1,G,null,null);z.options.__file="App.vue";var U=z.exports,V=n("8c4f");d["default"].use(V["a"]);var B=new V["a"]({routes:x}),H=(n("ac6a"),n("2f62")),q=n("6cd4"),J=n.n(q),R=n("9473");d["default"].use(H["a"]);var X=n("3dcc"),F={};J()(X.keys(),function(e){var t=Object(R["b"])(X(e).default);"undefined"!==typeof t&&"undefined"!==typeof t.moduleName&&(F[t.moduleName]=t)});var K=new H["a"].Store({modules:F});var Y=K,Z=n("6591"),Q=n("9483");Object(Q["a"])("".concat("","service-worker.js"),{ready:function(){console.log("App is being served from cache by a service worker.\nFor more details, visit https://goo.gl/AFskqB"),window.addEventListener("beforeinstallprompt",function(e){e.prompt()})},cached:function(){console.log("Content has been cached for offline use.")},updated:function(){console.log("New content is available; please refresh.")},offline:function(){console.log("No internet connection found. App is running in offline mode.")},error:function(e){console.error("Error during service worker registration:",e)}}),Z["VueHammer"].config.swipe={threshold:100},d["default"].use(Z["VueHammer"]),d["default"].config.productionTip=!1,new d["default"]({router:B,store:Y,render:function(e){return e(U)}}).$mount("#app")},"5c64":function(e,t,n){"use strict";var r=n("c2ae"),o=n.n(r);o.a},"61da":function(e,t,n){"use strict";var r=n("2b0e"),o=new r["default"];t["a"]=o},"8d8d":function(e,t,n){"use strict";var r=n("bc78"),o=n.n(r);t["default"]=o.a},9473:function(e,t,n){"use strict";n.d(t,"e",function(){return o}),n.d(t,"c",function(){return a}),n.d(t,"d",function(){return i}),n.d(t,"a",function(){return c}),n.d(t,"b",function(){return u});n("f751"),n("7f7f"),n("ac6a"),n("456d");var r={};function o(e){if("function"!==typeof e)return function(t){var n=r[f(t)];if("undefined"!==typeof e&&"undefined"!==typeof e.extend)for(var o=0;o<Object.keys(e.extend).length;o++){var a=e.extend[Object.keys(e.extend)[o]],i=r[a.name];Object.assign(n.state,i.state),Object.assign(n.getters,i.getters),Object.assign(n.actions,i.actions),Object.assign(n.mutations,i.mutations)}l(t),"undefined"!==typeof e&&(e.persistent?n["persistent"]=e.persistent:n["persistent"]=!1)};l(e)}function a(e,t,n){d(e),r[f(e)].getters[t]=e[t]}function i(e,t,n){d(e),r[f(e)].mutations[t]=e[t]}function c(e,t,n){d(e),r[f(e)].actions[t]=e[t]}function u(e){return r[f(e)]}function l(e){var t=new e,n=Object.getOwnPropertyNames(t);"undefined"===typeof t["moduleName"]&&console.error("You need to define the 'moduleName' class variable inside '".concat(t.constructor.name,"'! Otherwise it won't be added to the Vuex Store!")),r[f(t)]["moduleName"]=t["moduleName"],n.splice(n.indexOf("moduleName"),1),d(t);var o=function(){return s(t,n)};r[f(t)].state=o}function s(e,t){for(var n={},r=0;r<Object.keys(t).length;r++){var o=t[Object.keys(t)[r]];n[o]=e[o]}return n}function d(e){"undefined"===typeof r[f(e)]&&(r[f(e)]={namespaced:!0,state:function(){return{}},getters:{},actions:{},mutations:{}})}function f(e){var t=new e.constructor;return"function"===typeof t&&(t=new e),t["moduleName"]}},bc78:function(e,t,n){e.exports={"fade-enter-active":"_2IhUstcnRdvLMSEyGgtoK3",fadeEnterActive:"_2IhUstcnRdvLMSEyGgtoK3","fade-leave-active":"_BnKTtzLTcPPRX1TzwcUoI",fadeLeaveActive:"_BnKTtzLTcPPRX1TzwcUoI","fade-enter":"_2fbEbdYV04yJ0f-3LOsgmf",fadeEnter:"_2fbEbdYV04yJ0f-3LOsgmf","fade-leave-to":"_3RGlckfb07jvyibLf0Eoeq",fadeLeaveTo:"_3RGlckfb07jvyibLf0Eoeq","fade-enter-to":"_3Wcfi4Lu2ZL6JlQVGMo2Xb",fadeEnterTo:"_3Wcfi4Lu2ZL6JlQVGMo2Xb","fade-leave":"_2NEAyLD4DiZy1xw8U_AH9X",fadeLeave:"_2NEAyLD4DiZy1xw8U_AH9X",nav:"_mGQf98zhVYFcQWbmIdZDq",page:"_3ybD_IdMYz7xkucmonFpiH"}},c2ae:function(e,t,n){},dff9:function(e,t,n){"use strict";n.r(t),n.d(t,"default",function(){return l});var r,o,a=n("d4ec"),i=n("bee2"),c=n("63ae"),u=(n("cadf"),n("551c"),n("097d"),n("9473")),l=Object(u["e"])((o=function(){function e(){Object(a["a"])(this,e),this.moduleName="modal",this.show=!1,this.display=!1}return Object(i["a"])(e,[{key:"show",value:function(e){var t=e.commit;t("setDisplay",!0),setTimeout(function(){t("setShow",!0)},150)}},{key:"hide",value:function(e){var t=e.commit;t("setShow",!1),setTimeout(function(){t("setDisplay",!1)},150)}},{key:"setShow",value:function(e,t){e.show=t}},{key:"getShow",value:function(e){return e.show}},{key:"setDisplay",value:function(e,t){e.display=t}},{key:"getDisplay",value:function(e){return e.display}}]),e}(),Object(c["a"])(o.prototype,"show",[u["a"]],Object.getOwnPropertyDescriptor(o.prototype,"show"),o.prototype),Object(c["a"])(o.prototype,"hide",[u["a"]],Object.getOwnPropertyDescriptor(o.prototype,"hide"),o.prototype),Object(c["a"])(o.prototype,"setShow",[u["d"]],Object.getOwnPropertyDescriptor(o.prototype,"setShow"),o.prototype),Object(c["a"])(o.prototype,"getShow",[u["c"]],Object.getOwnPropertyDescriptor(o.prototype,"getShow"),o.prototype),Object(c["a"])(o.prototype,"setDisplay",[u["d"]],Object.getOwnPropertyDescriptor(o.prototype,"setDisplay"),o.prototype),Object(c["a"])(o.prototype,"getDisplay",[u["c"]],Object.getOwnPropertyDescriptor(o.prototype,"getDisplay"),o.prototype),r=o))||r}});
//# sourceMappingURL=app.f81bbdc7.js.map