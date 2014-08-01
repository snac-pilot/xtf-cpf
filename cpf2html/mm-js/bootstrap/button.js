/* ========================================================================
 * Bootstrap: button.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#buttons
 * ========================================================================
 * Copyright 2013 Twitter, Inc.
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
+function(e){"use strict";var t=function(o,n){this.$element=e(o),this.options=e.extend({},t.DEFAULTS,n)};t.DEFAULTS={loadingText:"loading..."},t.prototype.setState=function(e){var t="disabled",o=this.$element,n=o.is("input")?"val":"html",i=o.data();e+="Text",i.resetText||o.data("resetText",o[n]()),o[n](i[e]||this.options[e]),setTimeout(function(){"loadingText"==e?o.addClass(t).attr(t,t):o.removeClass(t).removeAttr(t)},0)},t.prototype.toggle=function(){var e=this.$element.closest('[data-toggle="buttons"]');if(e.length){var t=this.$element.find("input").prop("checked",!this.$element.hasClass("active")).trigger("change");"radio"===t.prop("type")&&e.find(".active").removeClass("active")}this.$element.toggleClass("active")};var o=e.fn.button;e.fn.button=function(o){return this.each(function(){var n=e(this),i=n.data("bs.button"),l="object"==typeof o&&o;i||n.data("bs.button",i=new t(this,l)),"toggle"==o?i.toggle():o&&i.setState(o)})},e.fn.button.Constructor=t,e.fn.button.noConflict=function(){return e.fn.button=o,this},e(document).on("click.bs.button.data-api","[data-toggle^=button]",function(t){var o=e(t.target);o.hasClass("btn")||(o=o.closest(".btn")),o.button("toggle"),t.preventDefault()})}(window.jQuery);