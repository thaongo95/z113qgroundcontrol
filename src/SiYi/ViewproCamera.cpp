#include "ViewproCamera.h"
#include <iostream>
#include <cstring>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>


ViewproCamera::ViewproCamera(QObject *parent)
    : QObject{parent}
{
    for (const auto& s : upstr)
        upPackets.push_back(hexToBytes(s));

    for (const auto& s : downstr)
        downPackets.push_back(hexToBytes(s));

    for (const auto& s : leftstr)
        leftPackets.push_back(hexToBytes(s));

    for (const auto& s : rightstr)
        rightPackets.push_back(hexToBytes(s));

    for (const auto& s : zoomstr)
        zoomPackets.push_back(hexToBytes(s));
    stopPacket = hexToBytes(stopstr);
    homePacket = hexToBytes(homestr);
    starttrackPacket = hexToBytes(starttrackstr);
    stoptrackPacket = hexToBytes(stoptrackstr);
    down90Packet = hexToBytes(down90str);
}
ViewproCamera::~ViewproCamera()
{
    closeCamera();
}
ViewproCamera* ViewproCamera::instance()
{
    static ViewproCamera camera;
    return &camera;
}

void ViewproCamera::setAddress(const QString& ip, int port)
{
    ip_ = ip.toStdString();
    port_ = port;
}
bool ViewproCamera::connectCamera()
{
    sock_ = socket(AF_INET, SOCK_STREAM, 0);

    if (sock_ < 0)
    {
        std::cout << "Socket create failed\n";
        return false;
    }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port_);

    inet_pton(AF_INET, ip_.c_str(), &addr.sin_addr);

    if (::connect(sock_, (sockaddr*)&addr, sizeof(addr)) < 0)
    {
        std::cout << "Connect failed\n";
        return false;
    }

    std::cout << "Connected to SIYI camera\n";


    return true;
}

std::vector<uint8_t> ViewproCamera::hexToBytes(const std::string& hex){
    std::vector<uint8_t> bytes;

    for (size_t i = 0; i < hex.length(); i += 2)
    {
        bytes.push_back(
            static_cast<uint8_t>(
                std::stoul(hex.substr(i, 2), nullptr, 16)
                )
            );
    }

    return bytes;
}
void ViewproCamera::sendPacket(const std::vector<uint8_t>& data){
    if (sock_ < 0) return;

    ::send(sock_, data.data(), data.size(), 0);
}
void ViewproCamera::sendHexPacket(const std::string& hex)
{
    if (sock_ < 0) return;

    std::vector<uint8_t> data;
    data.reserve(hex.size() / 2);

    for (size_t i = 0; i < hex.size(); i += 2)
    {
        data.push_back(
            static_cast<uint8_t>(
                std::stoul(hex.substr(i, 2), nullptr, 16)
                )
            );
    }

    ::send(sock_, data.data(), data.size(), 0);
}
void ViewproCamera::turnleft(){
    if (speed_<1) sendPacket(leftPackets[0]);
    else if (speed_>20) sendPacket(leftPackets[19]);
    else sendPacket(leftPackets[speed_-1]);

}
void ViewproCamera::turnright(){
    if (speed_<1) sendPacket(rightPackets[0]);
    else if (speed_>20) sendPacket(rightPackets[19]);
    else sendPacket(rightPackets[speed_-1]);

}
void ViewproCamera::turnup(){
    if (speed_<1) sendPacket(upPackets[0]);
    else if (speed_>20) sendPacket(upPackets[19]);
    else sendPacket(upPackets[speed_-1]);

}
void ViewproCamera::turndown(){
    if (speed_<1) sendPacket(downPackets[0]);
    else if (speed_>20) sendPacket(downPackets[19]);
    else sendPacket(downPackets[speed_-1]);

}
void ViewproCamera::zoom(){
    if (multiple_<1) sendPacket(zoomPackets[0]);
    else if (multiple_>36) sendPacket(zoomPackets[35]);
    else sendPacket(zoomPackets[multiple_-1]);

}


void ViewproCamera::stop(){
    sendPacket(stopPacket);

}

void ViewproCamera::down90(){
    sendPacket(down90Packet);

}
void ViewproCamera::home(){
    sendPacket(homePacket);

}

void ViewproCamera::starttrack(){
    sendPacket(starttrackPacket);

}
void ViewproCamera::stoptrack(){
    sendPacket(stoptrackPacket);

}

void ViewproCamera::setSpeed(int speed)
{
    speed_ = speed;
}

void ViewproCamera::setMultiple(int multiple)
{
    multiple_ = multiple;
}


void ViewproCamera::closeCamera()
{


    if (sock_ > 0)
        close(sock_);

    std::cout << "Disconnected\n";
}
