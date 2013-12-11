/* ========================================================================
 * Bootstrap: affix.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#affix
 * ========================================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ======================================================================== */
+function(e){"use strict";var t=function(n,o){this.options=e.extend({},t.DEFAULTS,o),this.$window=e(window).on("scroll.bs.affix.data-api",e.proxy(this.checkPosition,this)).on("click.bs.affix.data-api",e.proxy(this.checkPositionWithEventLoop,this)),this.$element=e(n),this.affixed=this.unpin=null,this.checkPosition()};t.RESET="affix affix-top affix-bottom",t.DEFAULTS={offset:0},t.prototype.checkPositionWithEventLoop=function(){setTimeout(e.proxy(this.checkPosition,this),1)},t.prototype.checkPosition=function(){if(this.$element.is(":visible")){var n=e(document).height(),o=this.$window.scrollTop(),i=this.$element.offset(),r=this.options.offset,a=r.top,s=r.bottom;"object"!=typeof r&&(s=a=r),"function"==typeof a&&(a=r.top()),"function"==typeof s&&(s=r.bottom());var l=null!=this.unpin&&o+this.unpin<=i.top?!1:null!=s&&i.top+this.$element.height()>=n-s?"bottom":null!=a&&a>=o?"top":!1;this.affixed!==l&&(this.unpin&&this.$element.css("top",""),this.affixed=l,this.unpin="bottom"==l?i.top-o:null,this.$element.removeClass(t.RESET).addClass("affix"+(l?"-"+l:"")),"bottom"==l&&this.$element.offset({top:document.body.offsetHeight-s-this.$element.height()}))}};var n=e.fn.affix;e.fn.affix=function(n){return this.each(function(){var o=e(this),i=o.data("bs.affix"),r="object"==typeof n&&n;i||o.data("bs.affix",i=new t(this,r)),"string"==typeof n&&i[n]()})},e.fn.affix.Constructor=t,e.fn.affix.noConflict=function(){return e.fn.affix=n,this},e(window).on("load",function(){e('[data-spy="affix"]').each(function(){var t=e(this),n=t.data();n.offset=n.offset||{},n.offsetBottom&&(n.offset.bottom=n.offsetBottom),n.offsetTop&&(n.offset.top=n.offsetTop),t.affix(n)})})}(window.jQuery);