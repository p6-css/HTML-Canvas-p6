use v6;
use Test;
plan 9;

use PDF::Content::PDF;
use PDF::Content::Image::PNG;
use HTML::Canvas;
use HTML::Canvas::To::PDF;

my PDF::Content::PDF $pdf .= new;
my $page-no;
my @html-body;
my @sheets;

my $y = 0;
my \h = 20;
my \pad = 10;
my \textHeight = 20;
my $measured-text;

sub test-page(&markup) {
    my HTML::Canvas $canvas .= new;
    my $gfx = $pdf.add-page.gfx;
    $gfx.comment-ops = True;
    my $feed = HTML::Canvas::To::PDF.new: :$gfx, :$canvas;
    my Bool $clean = True;
    $page-no++;
    try {
        $canvas.context(
            -> \ctx {
                $y = 0;
                ctx.font = "20pt times";
                &markup(ctx);
            });

        CATCH {
            default {
                warn "stopped on page $page-no: {.message}";
                $clean = False;
                # flush
                $canvas.beginPath if $canvas.subpath;
                $canvas.restore while $canvas.gsave;
                $canvas._finish;
            }
        }
    }

    ok $clean, "completion of page $page-no";
    my $width = $feed.width;
    my $height = $feed.height;
    @html-body.push: "<hr/>" ~ $canvas.to-html( :$width, :$height );
    @sheets.push: $canvas;
}

test-page(-> \ctx {
    # tests adapted from jsPDF/examples/context2d/test_context2d.html
      sub draw-line {
          ctx.beginPath();
          ctx.moveTo(20,$y);
          ctx.lineTo(150, $y);
          ctx.stroke();
      }

      # Text and Fonts
      ctx.save();
      ctx.fillText("Testing fillText, strokeText, and setFont", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.font = "10pt times";
      ctx.fillText("Hello PDF", 20, $y + textHeight);
      $y += textHeight + pad;
      $measured-text = ctx.measureText("Hello PDF").width;

      ctx.font = "10pt courier";
      ctx.fillText("Hello PDF", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.font = "small courier bold";
      ctx.fillText("Hello Bold PDF", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.font = "10pt courier italic";
      ctx.fillText("Hello Italic PDF", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.font = "50pt courier bold";
      ctx.fillText("Hello PDF", 20, $y + 50);
      $y += 50 + pad;

      ctx.font = "50pt courier bold";
      ctx.strokeText("Hello PDF", 20, $y + 50);
      $y += 50 + pad;

      ctx.font = "20pt courier bold";
      ctx.strokeText("Hello PDF", 20, $y + 20);
      $y += 20 + pad;

      ctx.font = "20pt courier bold";
      ctx.fillText("Hello PDF", 20, $y + 20);
      $y += 20 + pad;

      ctx.restore();

      # CSS Color Names
      ctx.save();
      ctx.fillText("Testing CSS color names", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.fillStyle = 'red';
      ctx.fillText("Red", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.fillStyle = 'green';
      ctx.fillText("Green", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.strokeStyle = 'blue';
      ctx.strokeText("Blue", 20, $y + textHeight);
      $y += textHeight + pad;
      ctx.restore();

      #
      # Text baseline
      #
      ctx.save();
      ctx.fillText("Testing textBaseline", 20, $y + textHeight);
      $y += textHeight + pad + 30;

      ctx.strokeStyle = '#ddd';
      ctx.font = "20pt times";

      draw-line();

      ctx.textBaseline = 'alphabetic';
      ctx.fillText("Alphabetic Q", 20, $y);
      $y += 40 + pad;

      draw-line();

      ctx.textBaseline = 'ideographic';
      ctx.fillText("Ideographic Q", 20, $y);
      $y += 40 + pad;

      draw-line();

      ctx.textBaseline = 'top';
      ctx.fillText("Top Q", 20, $y);
      $y += 40 + pad;

      draw-line();

      ctx.textBaseline = 'bottom';
      ctx.fillText("Bottom Q", 20, $y);
      $y += 40 + pad;

      draw-line();

      ctx.textBaseline = 'middle';
      ctx.fillText("Middle Q", 20, $y);
      $y += 40 + pad;

      draw-line();

      ctx.textBaseline = 'hanging';
      ctx.fillText("Hanging Q", 20, $y);
      $y += 40 + pad;

      ctx.restore();
});

ok(56 < $measured-text < 58, 'MeasureText')
    or diag "text measurement $measured-text outside of range: 56...58";

test-page( -> \ctx {
      #
      # rectangles
      #
      ctx.save();
      ctx.fillText("Testing fillRect, clearRect and strokeRect", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.fillRect(20, $y, 40, h);
      $y += h + pad;

      ctx.fillStyle = '#ccc';
      ctx.fillRect(20, $y, 40, h);
      ctx.clearRect(25, $y+5, 10, 10);
      $y += h + pad;

      ctx.strokeRect(20, $y, 40, h);
      $y += h + pad;
      ctx.restore();

      #
      # lines
      #
      # line caps

      ctx.save();
      ctx.fillText("Testing lineCap", 20, $y + textHeight);
      $y += textHeight + pad;
      ctx.lineWidth = 5;

      for <butt round square> -> \lc {
          ctx.beginPath();
          ctx.lineCap = lc;
          ctx.moveTo(20, $y);
          ctx.lineTo(200, $y);
          ctx.stroke();
          $y += pad;
      }

      ctx.restore();

      # line joins
      ctx.save();
      ctx.fillText("Testing lineJoin", 20, $y + textHeight);
      $y += textHeight + pad;
      ctx.lineWidth = 10;
      for <miter bevel round> -> \lj {
          ctx.beginPath();
          ctx.lineJoin = lj;
          ctx.moveTo(20, $y);
          ctx.lineTo(200, $y);
          ctx.lineTo(250, $y + 50);
          ctx.stroke();
          $y += pad + 10;
      }
      $y += pad + 10;
      $y += 50;
      ctx.restore();

      ctx.fillText("Testing moveTo, lineTo, stroke, and fill", 20, $y + textHeight);
      $y += textHeight + pad;

      for <stroke fill> -> \c {
          # diamond
          ctx.beginPath();
          ctx.moveTo(30, $y);
          ctx.lineTo(50, $y + 20);
          ctx.lineTo(30, $y + 40);
          ctx.lineTo(10, $y + 20);
          ctx.lineTo(30, $y);
          ctx."{c}"();
          $y += 50;
      }
});


sub deg2rad (Numeric $deg) {
    return $deg * pi / 180;
}

test-page( -> \ctx {
      #
      # arcs
      #
      ctx.fillText("Testing arc, stroke, and fill", 20, $y + textHeight);
      $y += textHeight + pad + 20;

      ctx.beginPath();
      ctx.arc(50, $y, 20, deg2rad(-10), deg2rad(170), False);
      ctx.stroke();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, deg2rad(-10), deg2rad(170), True);
      ctx.stroke();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, 0, pi, False);
      ctx.stroke();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, 0, pi, True);
      ctx.stroke();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, 0, 2*pi, False);
      ctx.stroke();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, 0, 2*pi, False);
      ctx.fill();
      $y +=  pad + 40;

      ctx.beginPath();
      ctx.arc(50, $y, 20, 0, pi, False);
      ctx.fill();
      $y +=  pad + 40;
});

test-page( -> \ctx {
      # fill and stroke styles
      ctx.fillText("Testing fillStyle and strokeStyle", 20, $y + textHeight);
      $y += textHeight + pad;

      # test fill style
      ctx.fillStyle = '#f00';
      ctx.fillRect(20, $y, 20, h);
      $y += h + pad;

      ctx.fillStyle = '#0f0';
      ctx.fillRect(20, $y, 20, h);
      $y += h + pad;

      ctx.fillStyle = '#00f';
      ctx.fillRect(20, $y, 20, h);
      $y += h + pad;

       # test stroke style
      ctx.strokeStyle = '#ff0000';
      ctx.strokeRect(20, $y, 20, h);
      $y += h + pad;

      ctx.strokeStyle = 'green';
      ctx.strokeRect(20, $y, 20, h);
      $y += h + pad;

      ctx.strokeStyle = 'blue';
      ctx.strokeRect(20, $y, 20, h);
      $y += h + pad;

      ctx.strokeStyle = 'black';
      ctx.fillStyle = 'black';

      # test save and restore (should be red and large)
      ctx.save(); {
          ctx.fillStyle = 'red';
          ctx.strokeStyle = 'red';
          ctx.save(); {
              ctx.fillStyle = 'blue';
              ctx.strokeStyle = 'blue';
              ctx.font = "10pt courier";
          }; ctx.restore();

          ctx.fillText("Testing save and restore (Should be red and large)", 20, $y + textHeight);
          $y += textHeight + pad;

          ctx.fillRect(20, $y, 20, h);
          $y += textHeight + pad;
          ctx.strokeRect(20, $y, 20, h);
          $y += textHeight + pad;
          ctx.fillText('Hello PDF', 20, $y + textHeight);
          $y += textHeight + pad;

      }; ctx.restore();

});

test-page( -> \ctx {
      $y = pad;
      ctx.fillText("Testing bezierCurveTo", 20, $y + textHeight);
      $y += textHeight + pad;

      ctx.save();
  	ctx.lineWidth = 6;
  	ctx.strokeStyle = "#333";
  	ctx.beginPath();
  	ctx.moveTo(100, $y);
  	ctx.bezierCurveTo(150, $y+100, 350, $y+100, 400, $y);
  	ctx.stroke();
  	ctx.restore();

      $y += 100 + pad;
      ctx.save();
      ctx.lineWidth = 6;
      ctx.strokeStyle = "#333";
      ctx.beginPath();
      ctx.moveTo(100, $y);
      ctx.bezierCurveTo(150, $y+100, 350, $y+100, 400, $y);
      ctx.fill();
      ctx.restore();

      $y += 100 + pad;
      ctx.fillText("Testing quadraticCurveTo", 20, $y + textHeight);
      $y += textHeight + pad;
      ctx.save();
      ctx.lineWidth = 6;
      ctx.strokeStyle = "#333";
      ctx.beginPath();
      ctx.moveTo(100, $y);
      ctx.quadraticCurveTo(250, $y+100, 400, $y);
      ctx.stroke();
      ctx.restore();

      $y += 100 + pad;
      ctx.save();
      ctx.lineWidth = 6;
      ctx.strokeStyle = "#333";
      ctx.beginPath();
      ctx.moveTo(100, $y);
      ctx.quadraticCurveTo(250, $y+100, 400, $y);
      ctx.fill();
      ctx.restore();
});

test-page( -> \ctx {
      ctx.fillText("Testing drawImage", 20, $y + textHeight);
      $y += textHeight + pad + 10;

      my \image = PDF::Content::Image::PNG.open("t/images/camelia-logo.png");
      @html-body.push: HTML::Canvas.to-html: image, :style("visibility:hidden");
      ctx.drawImage(image,  20,  $y+0,  50, 50);
      my $x = 50;
      my $shift = 0;
      for 1 .. 3 {
          ctx.drawImage(image, $shift, $shift, 240, 220,  $x,  $y, 50, 50);
          $x += 50;
          $shift += 20;
      }
      $shift = 0;
      for 1 .. 3 {
          ctx.drawImage(image, 0, 0, 200 + $shift, 220,  $x,  $y, 50, 50);
          $x += 60;
          $shift += 50;
      }
      ctx.drawImage(image, $x,  $y, 20, 50);
      $y += 80 + pad;
      ctx.drawImage(image,  20, $y, 200, 200);
      ctx.drawImage(image,  10, 10, 240, 220,
                           220, $y, 200, 200);
      $y += 200 + pad;
      ctx.drawImage(image, 20, $y);
      $y += 200 + pad;
});

test-page( -> \ctx {
      ctx.fillText("Testing drawImage (canvas)", 20, $y + textHeight);
      $y += textHeight + pad + 10;

      my $canvas = @sheets[0];

      my $x = 50;
      my $shift = 0;
      for 1 .. 3 {
          ctx.drawImage($canvas, $shift, $shift, 240, 220,  $x,  $y, 50, 50);
          $x += 60;
          $shift += 20;
      }

      $shift = 0;
      for 1 .. 3 {
          ctx.drawImage($canvas, 0, 0, 200 + $shift, 220,  $x,  $y, 50, 50);
          $x += 60;
          $shift += 50;
      }

      ctx.drawImage($canvas, $x,  $y, 20, 50);

      $y += 100 + pad;

      ctx.drawImage($canvas, 20, $y, 100, 150);
      ctx.drawImage($canvas, 160, $y, 100, 150);
      ctx.drawImage($canvas,                    30, 30, 400, 500,
                                   300, $y, 100, 150);

});

lives-ok {$pdf.save-as("t/render-pdf-test-pages.pdf")}, "pdf.save-as";

my $html = "<html><body>" ~ @html-body.join ~ "</body></html>";

"t/render-pdf-test-pages.html".IO.spurt: $html;

done-testing;
