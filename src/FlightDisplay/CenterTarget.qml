/****************************************************************************
 *
 * Center target reticle with an optional distance read-out below it.
 * One Image + one pill instead of many Rectangles.
 *
 ****************************************************************************/
import QtQuick          2.12
import QtQuick.Window   2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

Item {
    id: _root

    property real   size:           ScreenTools.defaultFontPixelHeight * 6  ///< reticle size in pixels
    property real   distance:       NaN     ///< distance in metres, NaN = no reading
    property string distanceText:   ""      ///< formatted read-out text (add the unit here if it is not included)
    property real   warnDistance:   0       ///< read-out turns amber below this distance (0 = disabled)
    property real   alertDistance:  0       ///< read-out turns red below this distance (0 = disabled)

    readonly property bool  _hasReading:    !isNaN(distance)
    readonly property color _valueColor:    !_hasReading                                        ? "white" :
                                            (alertDistance > 0 && distance < alertDistance)     ? "#ff5252" :
                                            (warnDistance  > 0 && distance < warnDistance)      ? "#ffb300" : "white"

    // The item is exactly the size of the reticle, so anchors.centerIn: parent centres the target itself
    width:  size
    height: size

    Image {
        id:             _reticle
        anchors.fill:   parent
        source:         "/qmlimages/center_target.svg"
        fillMode:       Image.PreserveAspectFit
        sourceSize:     Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
        smooth:         true
        mipmap:         true
        asynchronous:   true
    }

    // Distance read-out. Lives outside the item bounds, below the reticle. Fixed minimum width so it does not jitter.
    Rectangle {
        id:                         _readout
        anchors.top:                _reticle.bottom
        anchors.topMargin:          ScreenTools.defaultFontPixelHeight * 0.25
        anchors.horizontalCenter:   _reticle.horizontalCenter
        width:                      Math.max(_label.implicitWidth + ScreenTools.defaultFontPixelWidth * 2, ScreenTools.defaultFontPixelWidth * 8)
        height:                     _label.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.3
        radius:                     height / 2
        color:                      "#99000000"
        border.width:               1
        border.color:               "#6600ffff"
        opacity:                    _hasReading ? 1 : 0
        visible:                    opacity > 0

        Behavior on opacity { NumberAnimation { duration: 150 } }
        QGCLabel {
            id:                 _label
            anchors.centerIn:   parent
            text:               _root.distanceText
            color:              _root._valueColor
            font.family:        ScreenTools.demiboldFontFamily
        }
    }
}
