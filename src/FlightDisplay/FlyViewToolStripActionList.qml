/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models 2.12

import QGroundControl           1.0
import QGroundControl.Controls  1.0

ToolStripActionList {
    id: _root

    signal displayPreFlightChecklist

    model: [
        ToolStripAction {
            text:           qsTr("Plan")
            iconSource:     "/qmlimages/Plan.svg"
            onTriggered:    mainWindow.showPlanView()
        },
        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        ToolStripAction {
            // Switches the displayed video between the Camera 1 and Camera 2 RTSP urls
            property var    _videoSettings: QGroundControl.settingsManager.videoSettings
            property int    _activeCamera:  _videoSettings.activeCamera.rawValue
            property bool   _isRTSP:        _videoSettings.videoSource.rawValue === _videoSettings.rtspVideoSource
            property bool   _hasTwoUrls:    _videoSettings.rtspUrl.rawValue !== "" && _videoSettings.rtspUrl2.rawValue !== ""

            text:           qsTr("Cam %1").arg(_activeCamera + 1)
            iconSource:     "/qmlimages/camera_switch.svg"
            visible:        _isRTSP && _hasTwoUrls && !QGroundControl.videoManager.autoStreamConfigured
            onTriggered:    _videoSettings.activeCamera.rawValue = (_activeCamera === 0 ? 1 : 0)
        },
        GuidedActionTakeoff { },
        GuidedActionLand { },
        GuidedActionRTL { },
        GuidedActionPause { },
        GuidedActionActionList { }
    ]
}
