#ifndef BUTTONCHANGESTATE_H
#define BUTTONCHANGESTATE_H

#include <QObject>
#include "QGCApplication.h"
#include "Vehicle.h"
#include "MultiVehicleManager.h"
#include "QGCMAVLink.h"

class ButtonMonitor : public QObject {
    Q_OBJECT
    Q_PROPERTY(int state READ state NOTIFY stateChanged)

public:
    explicit ButtonMonitor(QObject* parent = nullptr);
    ~ButtonMonitor() override = default;

    int state() const { return _state; }

    // call from QML to start monitoring the active vehicle
    Q_INVOKABLE void attachToActiveVehicle();

signals:
    void stateChanged(int state);

private slots:
    void _activeVehicleChanged(Vehicle* vehicle);
    void _handleMessage(const mavlink_message_t& message);

private:
    Vehicle* _vehicle = nullptr;
    int _state = 0;
};

#endif // BUTTONCHANGESTATE_H
