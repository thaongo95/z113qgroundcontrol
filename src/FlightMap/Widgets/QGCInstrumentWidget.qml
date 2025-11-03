/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.Palette       1.0


Rectangle {
    id:                 visualInstrument
    height:             width //_outerRadius * 2
    Layout.fillWidth:   true
    radius:             width/2 //_outerRadius
    color:              "transparent"//qgcPal.window

    DeadMouseArea { anchors.fill: parent }

    // QGCAttitudeWidget {
    //     id:                     attitude
    //     anchors.leftMargin:     _topBottomMargin
    //     anchors.left:           parent.left
    //     size:                   _innerRadius * 2
    //     vehicle:                globals.activeVehicle
    //     anchors.verticalCenter: parent.verticalCenter
    // }

    QGCCompassWidget {
        id:                     compass
        anchors.fill:     parent
        size:                   parent.width
        vehicle:                globals.activeVehicle
    }
}
