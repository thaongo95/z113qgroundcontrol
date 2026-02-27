

/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Window 2.2
import QtQml.Models 2.1

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Airspace 1.0
import QGroundControl.Airmap 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

import SiYi.Object 1.0
import "qrc:/qml/QGroundControl/Controls"

// This is the ui overlay layer for the widgets/tools for Fly View
Item {
    id: _root

    property var parentToolInsets
    property var totalToolInsets: _totalToolInsets
    property var mapControl

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _planMasterController: globals.planMasterControllerFlyView
    property var _missionController: _planMasterController.missionController
    property var _geoFenceController: _planMasterController.geoFenceController
    property var _rallyPointController: _planMasterController.rallyPointController
    property var _guidedController: globals.guidedControllerFlyView
    property real _margins: ScreenTools.defaultFontPixelWidth / 2
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    property rect _centerViewport: Qt.rect(0, 0, width, height)
    property real _rightPanelWidth: ScreenTools.defaultFontPixelWidth * 20 //*30

    property var siyi: SiYi
    property SiYiCamera camera: siyi.camera
    property int iconLeftMargin: toolStrip.width + toolStrip.anchors.leftMargin
    MainToolBar{
        id: toolbar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: parent.height/12
        color:           Qt.rgba(qgcPal.window.r, qgcPal.window.g, qgcPal.window.b, 0.5)
    }

    QGCToolInsets {
        id: _totalToolInsets
        leftEdgeTopInset: toolStrip.leftInset
        leftEdgeCenterInset: toolStrip.leftInset
        leftEdgeBottomInset: parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset: parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset: parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset: parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset: parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset: parentToolInsets.topEdgeCenterInset
        topEdgeRightInset: parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset: parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset: mapScale.centerInset
        bottomEdgeRightInset: 0
    }

    FlyViewMissionCompleteDialog {
        missionController: _missionController
        geoFenceController: _geoFenceController
        rallyPointController: _rallyPointController
    }

    Row {
        id: multiVehiclePanelSelector
        anchors.margins: _toolsMargin
        anchors.top: parent.top
        anchors.right: parent.right
        width: _rightPanelWidth
        spacing: ScreenTools.defaultFontPixelWidth
        visible: QGroundControl.multiVehicleManager.vehicles.count > 1
                 && QGroundControl.corePlugin.options.flyView.showMultiVehicleList

        property bool showSingleVehiclePanel: !visible || singleVehicleRadio.checked

        QGCMapPalette {
            id: mapPal
            lightColors: true
        }

        QGCRadioButton {
            id: singleVehicleRadio
            text: qsTr("Single")
            checked: true
            textColor: mapPal.text
        }

        QGCRadioButton {
            text: qsTr("Multi-Vehicle")
            textColor: mapPal.text
        }
    }

    MultiVehicleList {
        anchors.margins: _toolsMargin
        anchors.top: multiVehiclePanelSelector.bottom
        anchors.right: parent.right
        width: _rightPanelWidth
        height: parent.height - y - _toolsMargin
        visible: !multiVehiclePanelSelector.showSingleVehiclePanel
    }

    // FlyViewInstrumentPanel {
    //     id: instrumentPanel
    //     // anchors.margins: _toolsMargin
    //     // //anchors.topMargin: anchors.margins + SiYi.iconsHeight
    //     // anchors.top: multiVehiclePanelSelector.visible ? multiVehiclePanelSelector.bottom : parent.top
    //     // anchors.right: parent.right
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: _rightPanelWidth/2
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     width: _rightPanelWidth/2
    //     spacing: _toolsMargin
    //     visible:  SiYi.hideWidgets ? false : QGroundControl.corePlugin.options.flyView.showInstrumentPanel
    //                         && multiVehiclePanelSelector.showSingleVehiclePanel
    //     availableHeight: _rightPanelWidth*2 //parent.height - y - _toolsMargin

    //     property real rightInset: visible ? parent.width - x : 0
    // }

    Rectangle {
        id:                 instrumentPanel
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width:              parent.width/8
        height:             width
        radius:             width/2
        color:              "transparent"//qgcPal.window
        border.width:       height/20
        border.color:       _activeVehicle ? "green" : Qt.lighter("red", 1.4)

        DeadMouseArea { anchors.fill: parent }

        QGCCompassWidget {
            id:                     compass
            anchors.centerIn:           parent
            size:                   parent.width-parent.border.width
            vehicle:                globals.activeVehicle
        }
    }
    Label{
        id: attitudeValue
        anchors.verticalCenter: instrumentPanel.verticalCenter
        anchors.right: instrumentPanel.left
        anchors.margins: 5
        text: _activeVehicle ? (_activeVehicle.altitudeRelative.valueString +" "+ _activeVehicle.altitudeRelative.units) : ("_ " )
        font.pixelSize: 32
        color: "white"
    }
    Label{
        id: horizonSpeedValue
        anchors.horizontalCenter:  attitudeValue.horizontalCenter
        anchors.top: attitudeValue.bottom
        anchors.margins: 5
        text: _activeVehicle ? (_activeVehicle.airSpeed.valueString +" "+ _activeVehicle.airSpeed.units) : ("_ " )
        font.pixelSize: 24
        color: "white"
    }

    Label{
        id: distanceValue
        anchors.verticalCenter: instrumentPanel.verticalCenter
        anchors.left: instrumentPanel.right
        anchors.margins: 5
        text: _activeVehicle ? (_activeVehicle.distanceToHome.valueString +" "+ _activeVehicle.distanceToHome.units) : ("_ ")
        font.pixelSize: 32
        color: "white"
    }
    Label{
        id: verticalSpeedValue
        anchors.horizontalCenter:  distanceValue.horizontalCenter
        anchors.top: distanceValue.bottom
        anchors.margins: 5
        text: _activeVehicle ? (_activeVehicle.groundSpeed.valueString +" "+ _activeVehicle.groundSpeed.units) : ("_ " )
        font.pixelSize: 24
        color: "white"
    }
    Label{
        id: distanceToStation
        anchors.horizontalCenter:  distanceValue.horizontalCenter
        anchors.bottom: distanceValue.top
        anchors.margins: 5
        text: _activeVehicle ? (_activeVehicle.distanceToGCS.valueString +" "+ _activeVehicle.distanceToGCS.units) : ("_ " )
        font.pixelSize: 24
        color: "white"
    }
    // Row{
    //     id: rightRow
    //     anchors.bottom: _root.bottom
    //     anchors.left: instrumentPanel.right
    //     anchors.right: _root.right
    //     anchors.leftMargin: _root.width/30
    //     anchors.rightMargin: _root.width/10
    //     spacing:  width/15
    //     Repeater{
    //         model: _activeVehicle ? [{fact: _activeVehicle.heading, sourceUrl: "qrc:/resources/Z113/black_letter-y.png"},
    //             {fact: _activeVehicle.pitch, sourceUrl: "qrc:/resources/Z113/black_letter-p.png"},
    //             {fact: _activeVehicle.roll,sourceUrl: "qrc:/resources/Z113/black_letter-r.png"},
    //             {fact: _activeVehicle.groundSpeed, sourceUrl: "qrc:/resources/Z113/black_speed.png"},
    //             {fact: _activeVehicle.hobbs, sourceUrl: "qrc:/resources/Z113/black_clock.png"}] :
    //             [{fact: "", sourceUrl: "qrc:/resources/Z113/black_letter-y.png"},
    //             {fact: "", sourceUrl: "qrc:/resources/Z113/black_letter-p.png"},
    //             {fact: "",sourceUrl: "qrc:/resources/Z113/black_letter-r.png"},
    //             {fact: "", sourceUrl: "qrc:/resources/Z113/black_speed.png"},
    //             {fact: "", sourceUrl: "qrc:/resources/Z113/black_clock.png"}]
    //         delegate: Rectangle{
    //             width: (rightRow.width-rightRow.width/15*4)/5
    //             height: width*1.2
    //             color: "transparent"
    //             Rectangle{
    //                 anchors.top: parent.top
    //                 anchors.right: parent.right
    //                 anchors.left:parent.left
    //                 height: parent.height/3
    //                 color: "transparent"
    //                 Text {
    //                     anchors.centerIn: parent
    //                     font.pixelSize: 32
    //                     color: "white" //qgcPal.text
    //                     text: _activeVehicle ? (modelData.fact.valueString +" "+ modelData.fact.units) : ("_ " +modelData.fact.units)
    //                 }
    //             }
    //             Rectangle{
    //                 anchors.right: parent.right
    //                 anchors.left:parent.left
    //                 anchors.bottom: parent.bottom
    //                 height: parent.height*2/3
    //                 color: "transparent"
    //                 Image{
    //                     anchors.centerIn: parent
    //                     width: parent.width/2
    //                     height: width
    //                     source: modelData.sourceUrl
    //                 }
    //             }
    //         }
    //     }
    // }
    // Row{
    //     id: leftRow
    //     anchors.bottom: _root.bottom
    //     anchors.left: _root.left
    //     anchors.right: instrumentPanel.left
    //     anchors.leftMargin: _root.width/10
    //     anchors.rightMargin: _root.width/30
    //     spacing:  width/15
    //     Repeater{
    //         model: _activeVehicle ? [{fact: _activeVehicle.gps.count, sourceUrl: "qrc:/resources/Z113/black_satellite.png"},
    //             {fact: _activeVehicle.altitudeRelative,sourceUrl: "qrc:/resources/Z113/black_aerial.png"},
    //             {fact: _activeVehicle.distanceToHome, sourceUrl: "qrc:/resources/Z113/black_home.png"},
    //             {fact: _activeVehicle.distanceToGCS,sourceUrl: "qrc:/resources/Z113/black_placeholder.png"},
    //             {fact: _activeVehicle.flightMode,sourceUrl: "/qmlimages/FlightModesComponentIcon.png"}] :
    //             [{fact: "", sourceUrl: "qrc:/resources/Z113/black_satellite.png"},
    //             {fact: "",sourceUrl: "qrc:/resources/Z113/black_aerial.png"},
    //             {fact: "", sourceUrl: "qrc:/resources/Z113/black_home.png"},
    //             {fact: "",sourceUrl: "qrc:/resources/Z113/black_placeholder.png"},
    //             {fact: "",sourceUrl: "qrc:/resources/Z113/black_temperature.png"}]
    //         delegate: Rectangle{
    //             width: (leftRow.width-leftRow.width/15*4)/5
    //             height: width*1.2
    //             color: "transparent"
    //             Rectangle{
    //                 anchors.top: parent.top
    //                 anchors.right: parent.right
    //                 anchors.left:parent.left
    //                 height: parent.height/3
    //                 color: "transparent"
    //                 Text {
    //                     anchors.centerIn: parent
    //                     font.pixelSize: 32
    //                     color: "white" //qgcPal.text
    //                     text: (index===4) ? modelData.fact : (_activeVehicle ? modelData.fact.valueString +" "+ modelData.fact.units : modelData.fact)
    //                 }
    //             }
    //             Rectangle{
    //                 anchors.right: parent.right
    //                 anchors.left:parent.left
    //                 anchors.bottom: parent.bottom
    //                 height: parent.height*2/3
    //                 color: "transparent"
    //                 Image{
    //                     anchors.centerIn: parent
    //                     width: parent.width/2
    //                     height: width
    //                     source: modelData.sourceUrl
    //                 }
    //             }
    //         }
    //     }
    // }
    // PhotoVideoControl {
    //     id: photoVideoControl
    //     anchors.margins: _toolsMargin
    //     anchors.right: parent.right
    //     width: _rightPanelWidth
    //     state: _verticalCenter ? "verticalCenter" : "topAnchor"
    //     visible: false  //!SiYi.hideWidgets
    //     states: [
    //         State {
    //             name: "verticalCenter"
    //             AnchorChanges {
    //                 target: photoVideoControl
    //                 anchors.top: undefined
    //                 anchors.verticalCenter: _root.verticalCenter
    //             }
    //         },
    //         State {
    //             name: "topAnchor"
    //             AnchorChanges {
    //                 target: photoVideoControl
    //                 anchors.verticalCenter: undefined
    //                 anchors.top: instrumentPanel.bottom
    //             }
    //         }
    //     ]

    //     property bool _verticalCenter: !QGroundControl.settingsManager.flyViewSettings.alternateInstrumentPanel.rawValue
    // }

    Rectangle {
        id: zoomMultipleRectangle
        width: zoomMultipleLabel.width + zoomMultipleLabel.width * 0.4
        height: zoomMultipleLabel.height + zoomMultipleLabel.height * 0.4
        color: "white"
        anchors.top: toolbar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        radius: 5
        QGCLabel {
            id: zoomMultipleLabel
            text: (zoomMultipleLabel.zoomMultiple / 10).toFixed(1)
            anchors.centerIn: parent
            color: "black"
            font.pixelSize: 28

            Timer {
                id: visibleTimer
                interval: 5000
                running: false
                repeat: false
                onTriggered: zoomMultipleRectangle.visible = false
            }

            property real zoomMultiple: siYiCamera.zoomMultiple
            onZoomMultipleChanged: {
                resultRectangle.visible = false
                is_recording.visible = false
                zoomMultipleRectangle.visible = true
                visibleTimer.restart()
            }
        }
    }

    Rectangle {
        id: resultRectangle    
        width: resultLabel.width + resultLabel.width * 0.4
        height: resultLabel.height + resultLabel.height * 0.4
        anchors.top: toolbar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        visible: false
        radius: 5
        QGCLabel {
            id: resultLabel
            anchors.centerIn: parent
            color: "black"
            font.pixelSize: 28

            Timer {
                id: resultTimer
                interval: 5000
                running: false
                repeat: false
                onTriggered: resultRectangle.visible = false
            }

            Connections {
                target: siYiCamera
                onOperationResultChanged: {
                    if (result === 0) {
                        resultLabel.text = qsTr("Chụp ảnh thành công!")
                    } else if (result === 1) {
                        resultLabel.text = qsTr("Take Photo Failed")
                    } else if (result === 4) {
                        resultLabel.text = qsTr("Video Record Failed")
                    } else if (result === -1) {
                        resultLabel.text = qsTr("Not supportted") //4K视频不支持变倍
                    } else if (result === SiYiCamera.TipOptionLaserNotInRange) {
                        resultLabel.text = qsTr("Not in the range of laser")
                    } else if (result === SiYiCamera.TipOptionSettingOK) {
                        resultLabel.text = qsTr("Setting OK")
                    } else if (result === SiYiCamera.TipOptionSettingFailed) {
                        resultLabel.text = qsTr("Setting Failed")
                    } else if (result === SiYiCamera.TipOptionIsNotAiTrackingMode) {
                        resultLabel.text = qsTr("Not in AI tracking mode") // 不支持AI跟踪模式
                    } else if (result === SiYiCamera.TipOptionStreamNotSupportedAiTracking) {
                        resultLabel.text = qsTr("AI tracking not supportted") //AI跟踪不支持
                    }

                    resultTimer.restart()
                    zoomMultipleRectangle.visible = false
                    is_recording.visible = false
                    resultRectangle.visible = true
                }
            }
        }
    }
    // cho them hien thi quay video
    Rectangle {
        id: is_recording
        width: recordingLabel.width + recordingLabel.width * 0.4
        height: recordingLabel.height + recordingLabel.height * 0.4
        anchors.top: toolbar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        visible: false
        radius: 5
        property int secondCount: 0
        QGCLabel {
            id: recordingLabel
            anchors.centerIn: parent
            color: "red"
            font.pixelSize: 28
            text: getTime(is_recording.secondCount)

            function getTime(time){
                var hours = Math.floor(time/3600)
                var minutes = Math.floor(time%3600/60)
                var seconds = Math.floor(time%60)
                function get_string(n){
                    return n>=10 ? n.toString() : '0' + n
                }
                return "Ghi hình " + get_string(hours) + ":" + get_string(minutes) + ":" + get_string(seconds)
            }

            Timer {
                id: recordingTimer
                interval: 1000 // 1 second
                repeat: true
                running: false
                onTriggered: is_recording.secondCount += 1
            }


            Connections {
                target: siYiCamera

                onIsRecordingChanged:{
                    if (siYiCamera.isRecording){
                        recordingTimer.restart()
                        zoomMultipleRectangle.visible = false
                        is_recording.visible = true
                        resultRectangle.visible = false
                    }
                    else {
                        recordingTimer.stop()
                        is_recording.secondCount = 0
                        is_recording.visible = false

                    }
                }
            }
        }
    }
    // Rectangle{
    //     id: droneIcon
    //     anchors.bottom: _root.bottom
    //     anchors.margins: height/6
    //     anchors.horizontalCenter: _root.horizontalCenter
    //     height: _root.height/5
    //     width: height
    //     color: "transparent"
    //     radius: height/2
    //     border.width: height/10
    //     border.color: _activeVehicle ? "green" : Qt.lighter("red", 1.2)

    //     Image{
    //         anchors.centerIn: parent
    //         height: parent.height/2
    //         width: height
    //         source: "qrc:/resources/Z113/drone.png"
    //     }
    // }
    // Rectangle{
    //     id: flightModeMenu
    //     height: _root.height/12
    //     width: height*3
    //     anchors.bottom: _root.bottom
    //     anchors.margins: height/6
    //     anchors.left: droneIcon.right
    //     color: "blue"//"transparent"
    //     FlightModeMenu {
    //         anchors.centerIn:       parent
    //         font.pointSize:         ScreenTools.largeFontPointSize //_vehicleInAir ?  ScreenTools.largeFontPointSize : ScreenTools.defaultFontPointSize
    //         visible:                _activeVehicle
    //     }
    // }


    TelemetryValuesBar {
        id: telemetryPanel
        // x: recalcXPosition()
        anchors.margins: _toolsMargin
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false //!SiYi.hideWidgets

        // States for custom layout support
        // states: [
        //     State {
        //         name: "bottom"
        //         when: telemetryPanel.bottomMode

        //         AnchorChanges {
        //             target: telemetryPanel
        //             anchors.top: undefined
        //             anchors.bottom: parent.bottom
        //             anchors.right: undefined
        //             anchors.verticalCenter: undefined
        //         }

        //         PropertyChanges {
        //             target: telemetryPanel
        //             x: recalcXPosition()
        //         }
        //     }
            // ,

            // State {
            //     name: "right-video"
            //     when: !telemetryPanel.bottomMode && photoVideoControl.visible

            //     AnchorChanges {
            //         target: telemetryPanel
            //         anchors.top: photoVideoControl.bottom
            //         anchors.bottom: undefined
            //         anchors.right: parent.right
            //         anchors.verticalCenter: undefined
            //     }
            // },

            // State {
            //     name: "right-novideo"
            //     when: !telemetryPanel.bottomMode && !photoVideoControl.visible

            //     AnchorChanges {
            //         target: telemetryPanel
            //         anchors.top: undefined
            //         anchors.bottom: undefined
            //         anchors.right: parent.right
            //         anchors.verticalCenter: parent.verticalCenter
            //     }
            // }
        // ]

        // function recalcXPosition() {
        //     // First try centered
        //     var halfRootWidth = _root.width / 2
        //     var halfPanelWidth = telemetryPanel.width / 2
        //     var leftX = (halfRootWidth - halfPanelWidth) - _toolsMargin
        //     var rightX = (halfRootWidth + halfPanelWidth) + _toolsMargin
        //     if (leftX >= parentToolInsets.leftEdgeBottomInset
        //             || rightX <= parentToolInsets.rightEdgeBottomInset) {
        //         // It will fit in the horizontalCenter
        //         return halfRootWidth - halfPanelWidth
        //     } else {
        //         // Anchor to left edge
        //         return parentToolInsets.leftEdgeBottomInset + _toolsMargin
        //     }
        // }
    }

    //-- Virtual Joystick
    // Loader {
    //     id: virtualJoystickMultiTouch
    //     z: QGroundControl.zOrderTopMost + 1
    //     width: parent.width - (_pipOverlay.width / 2)
    //     height: Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
    //     visible: _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen
    //              && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: parentToolInsets.leftEdgeBottomInset + ScreenTools.defaultFontPixelHeight * 2
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     source: "qrc:/qml/VirtualJoystick.qml"
    //     active: _virtualJoystickEnabled
    //             && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

    //     property bool autoCenterThrottle: QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue

    //     property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
    // }

    FlyViewToolStrip {
        id: toolStrip
        anchors.leftMargin: _toolsMargin + parentToolInsets.leftEdgeCenterInset
        anchors.topMargin: _toolsMargin + parentToolInsets.topEdgeLeftInset
        anchors.left: parent.left
        anchors.top: parent.top
        z: QGroundControl.zOrderWidgets
        maxHeight: parent.height - y - parentToolInsets.bottomEdgeLeftInset - _toolsMargin
        visible:  false // !QGroundControl.videoManager.fullScreen

        onDisplayPreFlightChecklist: mainWindow.showPopupDialogFromComponent(
                                         preFlightChecklistPopup)

        property real leftInset: x + width
    }

    FlyViewAirspaceIndicator {
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.defaultFontPixelHeight * 0.25
        anchors.horizontalCenter: parent.horizontalCenter
        z: QGroundControl.zOrderWidgets
        show: mapControl.pipState.state !== mapControl.pipState.pipState
    }

    VehicleWarnings {
        anchors.centerIn: parent
        z: QGroundControl.zOrderTopMost
    }

    MapScale {
        id: mapScale
        anchors.margins: _toolsMargin
        anchors.left: toolStrip.right
        anchors.top: parent.top
        mapControl: _mapControl
        buttonsOnLeft: false
        visible:   ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale
                 && mapControl.pipState.state === mapControl.pipState.fullState

        property real centerInset: visible ? parent.height - y : 0
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {}
    }
}
