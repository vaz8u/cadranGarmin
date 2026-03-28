import Toybox.Graphics;
import Toybox.WatchUi;

class TestTransform {
    function test() as Void {
        var t = new Graphics.AffineTransform();
        t.translate(10.0, 10.0);
        t.rotate(1.5);
    }
}
