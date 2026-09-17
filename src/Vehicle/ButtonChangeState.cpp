#include "ButtonChangeState.h"
#include <QDebug>

ButtonMonitor::ButtonMonitor(QObject* parent)
    : QObject(parent)
{
    // watch for active vehicle changes
    auto mvm = qgcApp()->toolbox()->multiVehicleManager();
    connect(mvm, &MultiVehicleManager::activeVehicleChanged,
            this, &ButtonMonitor::_activeVehicleChanged);
}

void ButtonMonitor::attachToActiveVehicle()
{
    Vehicle* active = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle();
    _activeVehicleChanged(active);
}

void ButtonMonitor::_activeVehicleChanged(Vehicle* vehicle)
{
    if (_vehicle) {
        disconnect(_vehicle, &Vehicle::mavlinkMessageReceived,
                   this, &ButtonMonitor::_handleMessage);
        qDebug() << "ButtonMonitor: disconnected from previous vehicle";
    }

    _vehicle = vehicle;

    if (_vehicle) {
        connect(_vehicle, &Vehicle::mavlinkMessageReceived,
                this, &ButtonMonitor::_handleMessage);
        qDebug() << "ButtonMonitor: attached to vehicle id" << _vehicle->id();
    } else {
        qDebug() << "ButtonMonitor: no active vehicle";
    }
}

void ButtonMonitor::_handleMessage(const mavlink_message_t& message)
{
    // debug the incoming message id so we know messages are arriving
    qDebug() << "ButtonMonitor: msgid" << message.msgid;

    if (message.msgid == MAVLINK_MSG_ID_BUTTON_CHANGE) {
        mavlink_button_change_t btn;
        mavlink_msg_button_change_decode(&message, &btn);


        if (btn.state != _state) {
            _state = btn.state;
            emit stateChanged(_state);
        }
    }
}
