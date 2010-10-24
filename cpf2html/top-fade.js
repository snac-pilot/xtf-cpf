 $(function () {        /* http://agyuku.net/2009/05/back-to-top-link-using-jquery/ */
     $(window).scroll(function () {  
         var f = $(this).scrollTop();
         if ( $(this).scrollTop() > 2500 ) {         
             $('.return-top').fadeIn();
         } else {
             $('.return-top').fadeOut();
         }
     });
     $('.return-top').click(function () {
         $('body,html').animate({
             scrollTop: 0
         },
         800);
         _gaq.push(['snak._trackEvent', 'OnPage', 'BackToTop', window.title ]);
         return false;
     });
     // other GA event tracker
     $("li.more").click(function () {
         _gaq.push(['snak._trackEvent', 'OnPage', 'More Browse ' + this.parentNode.getAttribute("class"), window.title ]);
     });
     $("div.more").click(function () {
         _gaq.push(['snak._trackEvent', 'OnPage', 'More Results', window.title ]);
     });
 });
