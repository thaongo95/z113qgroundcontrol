/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Layouts  1.11

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Rectangle {
    color:          qgcPal.window
    anchors.fill:   parent

    readonly property real _margins: ScreenTools.defaultFontPixelHeight

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    QGCFlickable {
        anchors.margins:    _margins
        anchors.fill:       parent
        contentWidth:       grid.width
        contentHeight:      grid.height
        clip:               true

        GridLayout {
            id:         grid
            columns:    1

            QGCLabel { text: qsTr("TỔNG CỤC CÔNG NGHIỆP QUỐC PHÒNG")}
            QGCLabel { text: qsTr("CÔNG TY TNHH MỘT THÀNH VIÊN CƠ KHÍ HOÁ CHẤT 13")}
            QGCLabel { text: qsTr("Tổ 22 phường Đội Cấn, TP. Tuyên Quang, T. Tuyên Quang")}
            QGCLabel { text: qsTr("*Tel: +84 02073878.104 – 3878.103   * Fax: +84 02073878.102")}
            QGCLabel { text: qsTr("*Email: info@z113.vn        *Website: http://z113.vn")}
        }

        // GridLayout {
        //     id:         grid
        //     columns:    2

        //     QGCLabel { text: qsTr("QGroundControl User Guide") }
        //     QGCLabel {
        //         linkColor:          qgcPal.text
        //         text:               "<a href=\"https://docs.qgroundcontrol.com\">https://docs.qgroundcontrol.com</a>"
        //         onLinkActivated:    Qt.openUrlExternally(link)
        //     }

        //     QGCLabel { text: qsTr("PX4 Users Discussion Forum") }
        //     QGCLabel {
        //         linkColor:          qgcPal.text
        //         text:               "<a href=\"http://discuss.px4.io/c/qgroundcontrol\">http://discuss.px4.io/c/qgroundcontrol</a>"
        //         onLinkActivated:    Qt.openUrlExternally(link)
        //     }

        //     QGCLabel { text: qsTr("ArduPilot Users Discussion Forum") }
        //     QGCLabel {
        //         linkColor:          qgcPal.text
        //         text:               "<a href=\"https://discuss.ardupilot.org/c/ground-control-software/qgroundcontrol\">https://discuss.ardupilot.org/c/ground-control-software/qgroundcontrol</a>"
        //         onLinkActivated:    Qt.openUrlExternally(link)
        //     }
        // }
    }
}
