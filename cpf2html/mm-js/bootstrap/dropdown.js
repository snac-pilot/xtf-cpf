/* ========================================================================
 * Bootstrap: dropdown.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#dropdowns
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
+function(o){"use strict";function t(){o(e).remove(),o(r).each(function(t){var e=n(o(this));e.hasClass("open")&&(e.trigger(t=o.Event("hide.bs.dropdown")),t.isDefaultPrevented()||e.removeClass("open").trigger("hidden.bs.dropdown"))})}function n(t){var n=t.attr("data-target");n||(n=t.attr("href"),n=n&&/#/.test(n)&&n.replace(/.*(?=#[^\s]*$)/,""));var e=n&&o(n);return e&&e.length?e:t.parent()}var e=".dropdown-backdrop",r="[data-toggle=dropdown]",a=function(t){o(t).on("click.bs.dropdown",this.toggle)};a.prototype.toggle=function(e){var r=o(this);if(!r.is(".disabled, :disabled")){var a=n(r),i=a.hasClass("open");if(t(),!i){if("ontouchstart"in document.documentElement&&!a.closest(".navbar-nav").length&&o('<div class="dropdown-backdrop"/>').insertAfter(o(this)).on("click",t),a.trigger(e=o.Event("show.bs.dropdown")),e.isDefaultPrevented())return;a.toggleClass("open").trigger("shown.bs.dropdown"),r.focus()}return!1}},a.prototype.keydown=function(t){if(/(38|40|27)/.test(t.keyCode)){var e=o(this);if(t.preventDefault(),t.stopPropagation(),!e.is(".disabled, :disabled")){var a=n(e),i=a.hasClass("open");if(!i||i&&27==t.keyCode)return 27==t.which&&a.find(r).focus(),e.click();var d=o("[role=menu] li:not(.divider):visible a",a);if(d.length){var l=d.index(d.filter(":focus"));38==t.keyCode&&l>0&&l--,40==t.keyCode&&l<d.length-1&&l++,~l||(l=0),d.eq(l).focus()}}}};var i=o.fn.dropdown;o.fn.dropdown=function(t){return this.each(function(){var n=o(this),e=n.data("dropdown");e||n.data("dropdown",e=new a(this)),"string"==typeof t&&e[t].call(n)})},o.fn.dropdown.Constructor=a,o.fn.dropdown.noConflict=function(){return o.fn.dropdown=i,this},o(document).on("click.bs.dropdown.data-api",t).on("click.bs.dropdown.data-api",".dropdown form",function(o){o.stopPropagation()}).on("click.bs.dropdown.data-api",r,a.prototype.toggle).on("keydown.bs.dropdown.data-api",r+", [role=menu]",a.prototype.keydown)}(window.jQuery);