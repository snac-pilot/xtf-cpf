/*!
 * hoverIntent r7 // 2013.03.11 // jQuery 1.9.1+
 * http://cherne.net/brian/resources/jquery.hoverIntent.html
 *
 * You may use hoverIntent under the terms of the MIT license. Basically that
 * means you are free to use hoverIntent as long as this header is left intact.
 * Copyright 2007, 2013 Brian Cherne
 */
!function(t){t.fn.hoverIntent=function(e,n,o){var a={interval:100,sensitivity:7,timeout:0};a="object"==typeof e?t.extend(a,e):t.isFunction(n)?t.extend(a,{over:e,out:n,selector:o}):t.extend(a,{over:e,out:e,selector:n});var r,i,s,l,d=function(t){r=t.pageX,i=t.pageY},c=function(e,n){return n.hoverIntent_t=clearTimeout(n.hoverIntent_t),Math.abs(s-r)+Math.abs(l-i)<a.sensitivity?(t(n).off("mousemove.hoverIntent",d),n.hoverIntent_s=1,a.over.apply(n,[e])):(s=r,l=i,n.hoverIntent_t=setTimeout(function(){c(e,n)},a.interval),void 0)},u=function(t,e){return e.hoverIntent_t=clearTimeout(e.hoverIntent_t),e.hoverIntent_s=0,a.out.apply(e,[t])},p=function(e){var n=jQuery.extend({},e),o=this;o.hoverIntent_t&&(o.hoverIntent_t=clearTimeout(o.hoverIntent_t)),"mouseenter"==e.type?(s=n.pageX,l=n.pageY,t(o).on("mousemove.hoverIntent",d),1!=o.hoverIntent_s&&(o.hoverIntent_t=setTimeout(function(){c(n,o)},a.interval))):(t(o).off("mousemove.hoverIntent",d),1==o.hoverIntent_s&&(o.hoverIntent_t=setTimeout(function(){u(n,o)},a.timeout)))};return this.on({"mouseenter.hoverIntent":p,"mouseleave.hoverIntent":p},a.selector)}}(jQuery);