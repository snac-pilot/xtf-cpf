/* ========================================================================
 * Bootstrap: alert.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#alerts
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
+function(e){"use strict";var t='[data-dismiss="alert"]',n=function(n){e(n).on("click",t,this.close)};n.prototype.close=function(t){function n(){i.trigger("closed.bs.alert").remove()}var o=e(this),r=o.attr("data-target");r||(r=o.attr("href"),r=r&&r.replace(/.*(?=#[^\s]*$)/,""));var i=e(r);t&&t.preventDefault(),i.length||(i=o.hasClass("alert")?o:o.parent()),i.trigger(t=e.Event("close.bs.alert")),t.isDefaultPrevented()||(i.removeClass("in"),e.support.transition&&i.hasClass("fade")?i.one(e.support.transition.end,n).emulateTransitionEnd(150):n())};var o=e.fn.alert;e.fn.alert=function(t){return this.each(function(){var o=e(this),r=o.data("bs.alert");r||o.data("bs.alert",r=new n(this)),"string"==typeof t&&r[t].call(o)})},e.fn.alert.Constructor=n,e.fn.alert.noConflict=function(){return e.fn.alert=o,this},e(document).on("click.bs.alert.data-api",t,n.prototype.close)}(window.jQuery);