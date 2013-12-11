/* ========================================================================
 * Bootstrap: collapse.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#collapse
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
+function(t){"use strict";var e=function(n,o){this.$element=t(n),this.options=t.extend({},e.DEFAULTS,o),this.transitioning=null,this.options.parent&&(this.$parent=t(this.options.parent)),this.options.toggle&&this.toggle()};e.DEFAULTS={toggle:!0},e.prototype.dimension=function(){var t=this.$element.hasClass("width");return t?"width":"height"},e.prototype.show=function(){if(!this.transitioning&&!this.$element.hasClass("in")){var e=t.Event("show.bs.collapse");if(this.$element.trigger(e),!e.isDefaultPrevented()){var n=this.$parent&&this.$parent.find("> .panel > .in");if(n&&n.length){var o=n.data("bs.collapse");if(o&&o.transitioning)return;n.collapse("hide"),o||n.data("bs.collapse",null)}var a=this.dimension();this.$element.removeClass("collapse").addClass("collapsing")[a](0),this.transitioning=1;var i=function(){this.$element.removeClass("collapsing").addClass("in")[a]("auto"),this.transitioning=0,this.$element.trigger("shown.bs.collapse")};if(!t.support.transition)return i.call(this);var s=t.camelCase(["scroll",a].join("-"));this.$element.one(t.support.transition.end,t.proxy(i,this)).emulateTransitionEnd(350)[a](this.$element[0][s])}}},e.prototype.hide=function(){if(!this.transitioning&&this.$element.hasClass("in")){var e=t.Event("hide.bs.collapse");if(this.$element.trigger(e),!e.isDefaultPrevented()){var n=this.dimension();this.$element[n](this.$element[n]())[0].offsetHeight,this.$element.addClass("collapsing").removeClass("collapse").removeClass("in"),this.transitioning=1;var o=function(){this.transitioning=0,this.$element.trigger("hidden.bs.collapse").removeClass("collapsing").addClass("collapse")};return t.support.transition?(this.$element[n](0).one(t.support.transition.end,t.proxy(o,this)).emulateTransitionEnd(350),void 0):o.call(this)}}},e.prototype.toggle=function(){this[this.$element.hasClass("in")?"hide":"show"]()};var n=t.fn.collapse;t.fn.collapse=function(n){return this.each(function(){var o=t(this),a=o.data("bs.collapse"),i=t.extend({},e.DEFAULTS,o.data(),"object"==typeof n&&n);a||o.data("bs.collapse",a=new e(this,i)),"string"==typeof n&&a[n]()})},t.fn.collapse.Constructor=e,t.fn.collapse.noConflict=function(){return t.fn.collapse=n,this},t(document).on("click.bs.collapse.data-api","[data-toggle=collapse]",function(e){var n,o=t(this),a=o.attr("data-target")||e.preventDefault()||(n=o.attr("href"))&&n.replace(/.*(?=#[^\s]+$)/,""),i=t(a),s=i.data("bs.collapse"),r=s?"toggle":o.data(),l=o.attr("data-parent"),d=l&&t(l);s&&s.transitioning||(d&&d.find('[data-toggle=collapse][data-parent="'+l+'"]').not(o).addClass("collapsed"),o[i.hasClass("in")?"addClass":"removeClass"]("collapsed")),i.collapse(r)})}(window.jQuery);