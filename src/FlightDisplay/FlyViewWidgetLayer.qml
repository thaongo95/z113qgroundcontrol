

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
import QGroundControl.Controls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

import SiYi.Object 1.0
import Viewpro.Camera 1.0
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

    FlyViewInstrumentPanel {
        id: instrumentPanel
        // anchors.margins: _toolsMargin
        // //anchors.topMargin: anchors.margins + SiYi.iconsHeight
        // anchors.top: multiVehiclePanelSelector.visible ? multiVehiclePanelSelector.bottom : parent.top
        // anchors.right: parent.right
        anchors.bottom: telemetryPanel.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: telemetryPanel.horizontalCenter
        // anchors.right: parent.right
        // anchors.top: servo8Indicator.bottom
        // anchors.margins: 10
        width: _rightPanelWidth
        spacing: _toolsMargin
        visible: SiYi.hideWidgets ? false : QGroundControl.corePlugin.options.flyView.showInstrumentPanel
                                    && multiVehiclePanelSelector.showSingleVehiclePanel
        availableHeight: parent.height - y - _toolsMargin

        property real rightInset: visible ? parent.width - x : 0
    }

    PhotoVideoControl {
        id: photoVideoControl
        anchors.margins: _toolsMargin
        anchors.right: parent.right
        width: _rightPanelWidth
        state: _verticalCenter ? "verticalCenter" : "topAnchor"
        visible: false  //!SiYi.hideWidgets
        states: [
            State {
                name: "verticalCenter"
                AnchorChanges {
                    target: photoVideoControl
                    anchors.top: undefined
                    anchors.verticalCenter: _root.verticalCenter
                }
            },
            State {
                name: "topAnchor"
                AnchorChanges {
                    target: photoVideoControl
                    anchors.verticalCenter: undefined
                    anchors.top: instrumentPanel.bottom
                }
            }
        ]

        property bool _verticalCenter: !QGroundControl.settingsManager.flyViewSettings.alternateInstrumentPanel.rawValue
    }

    Rectangle {
        id: zoomMultipleRectangle
        width: zoomMultipleLabel.width + zoomMultipleLabel.width * 0.4
        height: zoomMultipleLabel.height + zoomMultipleLabel.height * 0.4
        color: "white"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
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
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
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
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
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
    TelemetryValuesBar {
        id: telemetryPanel
        // x: recalcXPosition()
        anchors.margins: _toolsMargin
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !SiYi.hideWidgets

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
    Loader {
        id: virtualJoystickMultiTouch
        z: QGroundControl.zOrderTopMost + 1
        width: parent.width - (_pipOverlay.width / 2)
        height: Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
        visible: _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen
                 && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parentToolInsets.leftEdgeBottomInset + ScreenTools.defaultFontPixelHeight * 2
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/qml/VirtualJoystick.qml"
        active: _virtualJoystickEnabled
                && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

        property bool autoCenterThrottle: QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue

        property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
    }

    FlyViewToolStrip {
        id: toolStrip
        anchors.leftMargin: _toolsMargin + parentToolInsets.leftEdgeCenterInset
        anchors.topMargin: _toolsMargin + parentToolInsets.topEdgeLeftInset
        anchors.left: parent.left
        anchors.top: parent.top
        width: ScreenTools.defaultFontPixelWidth * 8
        z: QGroundControl.zOrderWidgets
        maxHeight: parent.height - y - parentToolInsets.bottomEdgeLeftInset - _toolsMargin
        visible: !QGroundControl.videoManager.fullScreen

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
        visible: !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale
                 && mapControl.pipState.state === mapControl.pipState.fullState

        property real centerInset: visible ? parent.height - y : 0
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {}
    }

    // MAVLinkInspectorController {
    //      id: controller
    // }
    // property var curSystem: controller ? controller.activeSystem : null
    // //property var servoMsg: null
    // property var currentMsg:  curSystem && curSystem.messages.count ? curSystem.messages.get(curSystem.selected) : null
    // function findServoMsg() {
    //     if (!curSystem || !curSystem.messages)
    //         return

    //     for (var i = 0; i < curSystem.messages.count; ++i) {
    //         var msg = curSystem.messages.get(i)
    //         //console.log("           " + msg.name)
    //         if (msg.name === "SERVO_OUTPUT_RAW") {
    //             curSystem.selected = i

    //             return
    //         }
    //     }
    //     //servoMsg = null
    // }
    // function findServoValue(){
    //     if (!curSystem || !curSystem.messages)
    //         return
    //     var servoMsg = curSystem.messages.get(curSystem.selected)
    //     for (var j = 0; j< servoMsg.fields.count; ++j){
    //         var field = servoMsg.fields.get(j)
    //         if (field.name === "servo6_raw"){
    //             console.log(field.value)
    //             servo6Value.text = field.value
    //             var x6 = Number(field.value)
    //             if ((x6>=1850)&&(x6<=1950)) {servo6Indicator.color = "red"}
    //             else if ((x6<=1150)&&(x6>=950)) {servo6Indicator.color = "#ba55d3"}
    //             else {servo6Indicator.color = "green"}
    //         }
    //         if (field.name === "servo8_raw"){
    //             console.log(field.value)
    //             servo8Value.text = field.value
    //             var x8 = Number(field.value)
    //             if ((x8>=1850)&&(x8<=1950)) {servo8Indicator.color = "red"}
    //             else if ((x8<=1150)&&(x8>=950)) {servo8Indicator.color = "#ba55d3"}
    //             else {servo8Indicator.color = "green"}
    //         }
    //     }
    // }

    // function findButtonChange() {
    //     if (!curSystem || !curSystem.messages)
    //         return

    //     for (var i = 0; i < curSystem.messages.count; ++i) {
    //         var msg = curSystem.messages.get(i)
    //         //console.log("           " + msg.name)
    //         if (msg.name === "BUTTON_CHANGE") {
    //             curSystem.selected = i
    //             return
    //         }
    //     }
    // }
    // function findButtonState(){
    //     if (!curSystem || !curSystem.messages)
    //         return
    //     var buttonMsg = curSystem.messages.get(curSystem.selected)
    //     for (var j = 0; j< buttonMsg.fields.count; ++j){
    //         var field = buttonMsg.fields.get(j)
    //         if (field.name === "state"){
    //             if (field.value === "3"){
    //                 button1Value.text = "Close"
    //                 button2Value.text = "Close"
    //                 button1Indicator.color = "green"
    //                 button2Indicator.color = "green"
    //             }
    //             else if (field.value === "2"){
    //                 button1Value.text = "Open"
    //                 button2Value.text = "Close"
    //                 button1Indicator.color = "red"
    //                 button2Indicator.color = "green"
    //             }
    //             else if (field.value === "0" ){
    //                 button1Value.text = "Open"
    //                 button2Value.text = "Open"
    //                 button1Indicator.color = "red"
    //                 button2Indicator.color = "red"
    //             }
    //             else if (field.value === "1" ){
    //                 button1Value.text = "Close"
    //                 button2Value.text = "Open"
    //                 button1Indicator.color = "green"
    //                 button2Indicator.color = "red"
    //             }
    //         }
    //     }
    // }

    // Timer {
    //     id: updateTimer
    //     interval: 200
    //     running: true
    //     repeat: true
    //     onTriggered: {
    //         findServoMsg()
    //         findServoValue()
    //         findButtonChange()
    //         findButtonState()
    //     }
    // }
    // Rectangle{
    //     id: servo8Indicator
    //     anchors.top: parent.top
    //     anchors.right: parent.right
    //     anchors.topMargin: 10
    //     anchors.rightMargin: 20
    //     width: ScreenTools.defaultFontPixelWidth * 10
    //     height: ScreenTools.defaultFontPixelWidth * 10
    //     radius: 10
    //     color: "green"
    //     Text{
    //         anchors.top: parent.top
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.topMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "PULSE 2"
    //         font.bold: true
    //     }
    //     Text{
    //         id: servo8Value
    //         anchors.bottom: parent.bottom
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottomMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: ""
    //     }
    // }
    // Rectangle{
    //     id: servo6Indicator
    //     anchors.top: parent.top
    //     anchors.right: servo8Indicator.left
    //     anchors.margins: 10
    //     width: ScreenTools.defaultFontPixelWidth * 10
    //     height: ScreenTools.defaultFontPixelWidth * 10
    //     radius: 10
    //     color: "green"
    //     Text{
    //         anchors.top: parent.top
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.topMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "PULSE 1"
    //         font.bold: true
    //     }
    //     Text{
    //         id: servo6Value
    //         anchors.bottom: parent.bottom
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottomMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: ""
    //     }
    // }
    // Rectangle{
    //     id: button2Indicator
    //     anchors.top: parent.top
    //     anchors.right: servo6Indicator.left
    //     anchors.margins: 10
    //     width: ScreenTools.defaultFontPixelWidth * 10
    //     height: ScreenTools.defaultFontPixelWidth * 10
    //     radius: 10
    //     color: "green"
    //     Text{
    //         anchors.top: parent.top
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.topMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "SERVO 2"
    //         font.bold: true
    //     }
    //     Text{
    //         id: button2Value
    //         anchors.bottom: parent.bottom
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottomMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "Close"
    //     }
    // }
    // Rectangle{
    //     id: button1Indicator
    //     anchors.top: parent.top
    //     anchors.right: button2Indicator.left
    //     anchors.margins: 10
    //     width: ScreenTools.defaultFontPixelWidth * 10
    //     height: ScreenTools.defaultFontPixelWidth * 10
    //     radius: 10
    //     color: "green"
    //     Text{
    //         anchors.top: parent.top
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.topMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "SERVO 1"
    //         font.bold: true
    //     }
    //     Text{
    //         id: button1Value
    //         anchors.bottom: parent.bottom
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottomMargin: 15
    //         font.pixelSize: 24
    //         color: "black"
    //         text: "Close"
    //     }
    // }
    Item {
        id:                     servoPanel
        anchors.top:            parent.top
        anchors.right:          parent.right
        anchors.topMargin:      10
        anchors.rightMargin:    4
        width:                  tileRow.width
        height:                 tileRow.height

        // ---- state ---------------------------------------------------------------------------
        property bool   expanded:       true    ///< false = only the handle is shown
        property int    buttonState:    -1      ///< BUTTON_CHANGE.state (bit 0 = button 1 closed, bit 1 = button 2 closed), -1 = no data
        property real   pulse1:         NaN     ///< SERVO_OUTPUT_RAW.servo6_raw, NaN = no data
        property real   pulse2:         NaN     ///< SERVO_OUTPUT_RAW.servo8_raw, NaN = no data

        readonly property real  _tileSize:  ScreenTools.defaultFontPixelWidth * 10
        readonly property var   _titles:    [ "SERVO 1", "SERVO 2", "PULSE 1", "PULSE 2" ]
        readonly property color _noData:    "#9e9e9e"

        // ---- data source ---------------------------------------------------------------------
        MAVLinkInspectorController { id: controller }

        readonly property var curSystem: controller ? controller.activeSystem : null

        // Cached position/last count of each message in the inspector's list
        property var _servoRef:     ({ name: "SERVO_OUTPUT_RAW", idx: -1, count: -1 })
        property var _buttonRef:    ({ name: "BUTTON_CHANGE",    idx: -1, count: -1 })

        onCurSystemChanged: {
            _servoRef.idx = -1;     _servoRef.count = -1
            _buttonRef.idx = -1;    _buttonRef.count = -1
            pulse1 = NaN;  pulse2 = NaN;  buttonState = -1
        }

        // Returns the message if it has received new data since the last call, otherwise null.
        // The inspector only refreshes a message's field values while that message is selected,
        // so a message is selected only when there is something new to read.
        function _fetchIfNew(sys, ref) {
            var msgs = sys.messages
            var msg  = (ref.idx >= 0 && ref.idx < msgs.count) ? msgs.get(ref.idx) : null

            if (!msg || msg.name !== ref.name) {
                // The list is sorted by name, so indexes move when new message types appear
                msg = null
                ref.idx = -1
                for (var i = 0; i < msgs.count; ++i) {
                    var m = msgs.get(i)
                    if (m.name === ref.name) {
                        ref.idx = i
                        msg = m
                        break
                    }
                }
            }
            if (!msg || msg.count === ref.count) {
                return null
            }
            ref.count = msg.count
            sys.selected = ref.idx
            return msg
        }

        function _fieldNumber(msg, fieldName) {
            var fields = msg.fields
            for (var j = 0; j < fields.count; ++j) {
                var f = fields.get(j)
                if (f.name === fieldName) {
                    return Number(f.value)
                }
            }
            return NaN
        }

        function _refresh() {
            var sys = curSystem
            if (!sys || !sys.messages) {
                return
            }
            var previousSelection = sys.selected

            var servo = _fetchIfNew(sys, _servoRef)
            if (servo) {
                pulse1 = _fieldNumber(servo, "servo6_raw")
                pulse2 = _fieldNumber(servo, "servo8_raw")
            }

            var button = _fetchIfNew(sys, _buttonRef)
            if (button) {
                var s = _fieldNumber(button, "state")
                buttonState = isNaN(s) ? -1 : (s & 3)
            }

            // Give the MAVLink Inspector page its selection back
            if (sys.selected !== previousSelection) {
                sys.selected = previousSelection
            }
        }

        // Polls only while the tiles are visible; showing them again refreshes immediately
        Timer {
            interval:           200
            repeat:             true
            running:            servoPanel.expanded && !!servoPanel.curSystem
            triggeredOnStart:   true
            onTriggered:        servoPanel._refresh()
        }

        // ---- presentation --------------------------------------------------------------------
        function _pulse(i) { return i === 2 ? pulse1 : pulse2 }

        function tileText(i) {
            if (i < 2) {
                return buttonState < 0 ? "--" : ((buttonState & (1 << i)) ? "Close" : "Open")
            }
            var p = _pulse(i)
            return isNaN(p) ? "--" : String(p)
        }

        function tileColor(i) {
            if (i < 2) {
                return buttonState < 0 ? _noData : ((buttonState & (1 << i)) ? "green" : "red")
            }
            var p = _pulse(i)
            if (isNaN(p))               return _noData
            if (p >= 1850 && p <= 1950) return "red"
            if (p >= 950  && p <= 1150) return "#ba55d3"
            return "green"
        }

        Row {
            id:         tileRow
            spacing:    ScreenTools.defaultFontPixelWidth

            Repeater {
                model: 4

                Rectangle {
                    width:      servoPanel._tileSize
                    height:     width
                    radius:     ScreenTools.defaultFontPixelWidth
                    visible:    servoPanel.expanded
                    color:      servoPanel.tileColor(index)

                    Text {
                        anchors.top:                parent.top
                        anchors.topMargin:          ScreenTools.defaultFontPixelHeight * 0.6
                        anchors.horizontalCenter:   parent.horizontalCenter
                        width:                      parent.width - ScreenTools.defaultFontPixelWidth
                        horizontalAlignment:        Text.AlignHCenter
                        font.pixelSize:             ScreenTools.defaultFontPixelHeight * 1.3
                        font.bold:                  true
                        fontSizeMode:               Text.HorizontalFit
                        minimumPixelSize:           8
                        color:                      "black"
                        text:                       servoPanel._titles[index]
                    }

                    Text {
                        anchors.bottom:             parent.bottom
                        anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 0.6
                        anchors.horizontalCenter:   parent.horizontalCenter
                        width:                      parent.width - ScreenTools.defaultFontPixelWidth
                        horizontalAlignment:        Text.AlignHCenter
                        font.pixelSize:             ScreenTools.defaultFontPixelHeight * 1.3
                        fontSizeMode:               Text.HorizontalFit
                        minimumPixelSize:           8
                        color:                      "black"
                        text:                       servoPanel.tileText(index)
                    }
                }
            }

            // Hide / show handle, stays on the right edge in both states
            Rectangle {
                id:         toggleHandle
                width:      servoPanel._tileSize * 0.45
                height:     servoPanel._tileSize
                radius:     ScreenTools.defaultFontPixelWidth
                color:      "#99000000"

                Text {
                    anchors.centerIn:   parent
                    text:               servoPanel.expanded ? "\u203A" : "\u2039"
                    color:              "white"
                    font.pixelSize:     ScreenTools.defaultFontPixelHeight * 2
                    font.bold:          true
                }

                MouseArea {
                    anchors.fill:   parent
                    onClicked:      servoPanel.expanded = !servoPanel.expanded
                }
            }
        }
    }


    Rectangle{
        id: gimbalcontrol
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        width: 300 ; height: 800 ; radius: 10
        color: Qt.rgba(240, 128, 128, 0.2)
        property bool isConnected: false
        visible: false
        // property color btcolor: Qt.rgba(240, 128, 128, 0.7)
        Slider {
            id: speedSlider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            orientation: Qt.Horizontal
            from: 1 ; to: 20 ; value: ViewproCamera.getSpeed(); stepSize:1
            background: Rectangle {
                x: speedSlider.leftPadding
                y: speedSlider.height / 2 - height / 2
                width: speedSlider.availableWidth
                height: 10 ; radius: 4
                Rectangle {
                    width: speedSlider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Qt.rgba(240, 128, 128, 0.7)
                }
            }
            handle: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: width / 2
                color: Qt.rgba(240, 128, 128, 0.7)
                x: speedSlider.leftPadding +
                   speedSlider.visualPosition *
                   (speedSlider.availableWidth - width)
                y: speedSlider.height / 2 - height / 2
                Text {
                    anchors.centerIn: parent
                    text: Math.round(speedSlider.value)
                    font.pixelSize: 12
                }
            }
            onValueChanged: ViewproCamera.setSpeed(speedSlider.value)
        }
        Rectangle{
            anchors.bottom: connect.top
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.margins: 10
            anchors.bottomMargin: 30
            height: width
            radius: width/2
            color: Qt.rgba(240, 128, 128, 0.7)
            Rectangle{
                id: homeBt
                anchors.centerIn: parent
                width: 100
                height: width
                radius: width/2
                color: homeMA.pressed ? Qt.rgba(0, 100, 255, 0.7) :  Qt.rgba(240, 128, 128, 0.7)
                border.width: 10
                border.color: homeMA.pressed ? Qt.rgba(0, 100, 255, 0.7) : Qt.rgba(240, 128, 128, 0.2)
                Image{
                    anchors.centerIn: parent
                    width: parent.width/2
                    height: width
                    source: "qrc:/resources/SiYi/center.png"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea{
                    id: homeMA
                    anchors.fill: parent
                    onClicked: ViewproCamera.home()
                }
            }
            Image{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: homeBt.left
                anchors.margins: 15
                source: "qrc:/resources/SiYi/arrowheads.png"
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        ViewproCamera.turnleft()
                    }
                    onReleased: {
                        ViewproCamera.stop()
                    }
                }
            }
            Image{
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: homeBt.right
                anchors.margins: 15
                source: "qrc:/resources/SiYi/arrowheads-right.png"
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        ViewproCamera.turnright()
                    }
                    onReleased: {
                        ViewproCamera.stop()
                    }
                }
            }
            Image{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: homeBt.top
                anchors.margins: 15
                source: "qrc:/resources/SiYi/arrowheads-up.png"
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        ViewproCamera.turnup()
                    }
                    onReleased: {
                        ViewproCamera.stop()
                    }
                }
            }
            Image{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.top: homeBt.bottom
                anchors.margins: 15
                source: "qrc:/resources/SiYi/arrowheads-down.png"
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        ViewproCamera.turndown()
                    }
                    onReleased: {
                        ViewproCamera.stop()
                    }
                }
            }
        }
        Rectangle{
            id: connect
            anchors.centerIn: parent
            width: 250 ; height: 60 ; radius: 30
            color: connectMA.pressed ? Qt.rgba(0, 100, 255, 0.7) : (connectLabel.text === "Disconnect" ? Qt.rgba(0, 255, 0, 0.7) : Qt.rgba(240, 128, 128, 0.7))
            Text{
                id: connectLabel
                anchors.centerIn: parent
                text: "Connect"
                font.pixelSize: 24
                font.bold: true
            }
            MouseArea{
                id: connectMA
                anchors.fill: parent
                onClicked: {
                    if (connectLabel.text === "Connect"){
                        if (ViewproCamera.connectCamera()){
                            connectLabel.text = "Disconnect"
                            gimbalcontrol.isConnected = true
                        }
                    }
                    else {
                        ViewproCamera.closeCamera()
                        connectLabel.text = "Connect"
                        gimbalcontrol.isConnected = false
                    }
                }
            }
        }
        Rectangle{
            id: track
            anchors.top: connect.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 30
            width: 200 ; height: 50 ; radius: 25
            color: trackMA.pressed ? Qt.rgba(0, 100, 255, 0.7) : Qt.rgba(240, 128, 128, 0.7)
            Text{
                id: trackLabel
                anchors.centerIn: parent
                text: "Track"
                font.pixelSize: 24
                font.bold: true
            }
            MouseArea{
                id: trackMA
                anchors.fill: parent
                onClicked: {
                    if (trackLabel.text === "Track"){
                        ViewproCamera.starttrack()
                        trackLabel.text = "Stop"
                    }
                    else {
                        ViewproCamera.stoptrack()
                        trackLabel.text = "Track"
                    }
                }

            }
        }
        Rectangle{
            id: gimbaldown
            anchors.top: track.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            width: 200 ; height: 50 ; radius: 25
            color: down90MA.pressed ? Qt.rgba(0, 100, 255, 0.7) : Qt.rgba(240, 128, 128, 0.7)
            Text{
                anchors.centerIn: parent
                text: "Nadir"
                font.pixelSize: 24
                font.bold: true
            }
            MouseArea{
                id: down90MA
                anchors.fill: parent
                onClicked: ViewproCamera.down90()
            }
        }

        Slider {
            id: zoomSlider
            anchors.top: gimbaldown.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            anchors.topMargin: 30
            orientation: Qt.Horizontal
            from: 1 ; to: 36 ; value: ViewproCamera.getMultiple(); stepSize:1
            background: Rectangle {
                x: zoomSlider.leftPadding
                y: zoomSlider.height / 2 - height / 2
                width: zoomSlider.availableWidth
                height: 10 ; radius: 4
                Rectangle {
                    width: zoomSlider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                }
            }
            handle: Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: width / 2
                color: Qt.rgba(240, 128, 128, 0.7)
                x: zoomSlider.leftPadding +
                   zoomSlider.visualPosition *
                   (zoomSlider.availableWidth - width)
                y: zoomSlider.height / 2 - height / 2
                Text {
                    anchors.centerIn: parent
                    text: Math.round(zoomSlider.value)
                    font.pixelSize: 12
                }
            }
            onValueChanged: {
                ViewproCamera.setMultiple(zoomSlider.value)
                ViewproCamera.zoom()
            }
        }
        Rectangle{
            id: zoomBt
            anchors.top: zoomSlider.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            width: 250 ; height: 50 ; radius: 25
            color:  Qt.rgba(240, 128, 128, 0.2)
            Text{
                anchors.centerIn: parent
                text: "Zoom"
                font.pixelSize: 24
                font.bold: true
                font.italic: true
            }
            Rectangle{
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height ; radius: height/2
                color: decrease.pressed ? Qt.rgba(0, 100, 255, 0.7) : Qt.rgba(240, 128, 128, 0.7)
                Text{
                    anchors.centerIn: parent
                    text: "-"
                    font.pixelSize: 32
                    font.bold: true
                }
                MouseArea{
                    id: decrease
                    anchors.fill: parent
                    onClicked: zoomSlider.value = (zoomSlider !==0) ? zoomSlider.value-1 : zoomSlider.value
                }
            }
            Rectangle{
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height ; radius: height/2
                color: increase.pressed ? Qt.rgba(0, 100, 255, 0.7) : Qt.rgba(240, 128, 128, 0.7)
                Text{
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 32
                    font.bold: true
                }
                MouseArea{
                    id: increase
                    anchors.fill: parent
                    onClicked: zoomSlider.value = (zoomSlider !==36) ? zoomSlider.value+1 : zoomSlider.value
                }
            }
        }
        Image{
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 5
            width: 80; height: 80
            source: "qrc:/resources/SiYi/logo_lightcoral.png"
            fillMode: Image.PreserveAspectFit
        }
    }


}
