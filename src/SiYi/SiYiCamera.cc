﻿#include <QSettings>
#include <QStandardPaths>
#include <QTimerEvent>
#include <QtEndian>

#include "SiYiCamera.h"

SiYiCamera::SiYiCamera(QObject *parent)
    : SiYiTcpClient("192.168.144.25:8554/main.264", 37256)   //37256
{
    m_laserTimer = new QTimer(this);
    m_laserTimer->setInterval(1000);
    connect(m_laserTimer, &QTimer::timeout, this, [=]() {
        getLaserCoords();
        getLaserDistance();
    });

    connect(this, &SiYiCamera::connected,
            this, [=](){
        getCamerVersion();
        getResolution();
        getResolutionMain();
        getRecordingState();
        getSplitMode();
        m_laserTimer->start();
#if 0
        setLogState(1);
#endif
    });
    connect(this, &SiYiCamera::disconnected, this, [=]() { m_laserTimer->stop(); });

    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                           + "/config.ini",
                       QSettings::IniFormat);
    QString tmp = settings.value("siyiCameraIp").toString();
    if (!tmp.isEmpty()) {
        ip_ = tmp;
    }
}

SiYiCamera::~SiYiCamera()
{

}

void SiYiCamera::analyzeIp(QString videoUrl)
{
    SiYiTcpClient::analyzeIp(videoUrl);
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                           + "/config.ini",
                       QSettings::IniFormat);
    settings.setValue("siyiCameraIp", ip_);
}

bool SiYiCamera::turn(int yaw, int pitch)
{
    uint8_t cmdId = 0x9a;
    QByteArray body;
    body.append(char(yaw));
    body.append(char(pitch));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::resetPostion()
{
    uint8_t cmdId = 0x9b;
    QByteArray body;
    body.append(char(0x01));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::autoFocus(int x, int y, int w, int h)
{
    uint8_t cmdId = 0x97;
    QByteArray body;
    body.append(char(0x01));

    quint16 cookedX = x * m_resolutionWidthMain / w;
    quint16 cookedY = y * m_resolutionHeightMain / h;

    qInfo() << "autoFocus" << cookedX << cookedY << x << y << w << h << m_resolutionWidthMain
            << m_resolutionWidthMain;

    body.append(reinterpret_cast<char*>(&cookedX), 2);
    body.append(reinterpret_cast<char*>(&cookedY), 2);

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::zoom(int option)
{
    if (option != 1 && option != 0 && option != -1) {
        option = 0;
    }

    uint8_t cmdId = 0x98;
    QByteArray body;
    body.append(char(option));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::focus(int option)
{
    if (option != 1 && option != 0 && option != -1) {
        option = 0;
    }

    uint8_t cmdId = 0x99;
    QByteArray body;
    body.append(char(option));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::sendCommand(int cmd)
{
    uint8_t cmdId = 0x9f;
    QByteArray body;
    body.append(char(cmd));

    QByteArray msg = packMessage(0x00, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::sendRecodingCommand(int cmd)
{
    uint8_t cmdId = 0x81;
    QByteArray body;
    body.append(char(cmd));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

void SiYiCamera::setLogState(int state)
{
    uint8_t cmdId = 0xa1;
    QByteArray body;
    body.append(char(state));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

bool SiYiCamera::getRecordingState()
{
    uint8_t cmdId = 0x80;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

void SiYiCamera::getResolution()
{
    uint8_t cmdId = 0x83;
    QByteArray body;
    body.append(char(0x00));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::getResolutionMain()
{
    uint8_t cmdId = 0x83;
    QByteArray body;
    body.append(char(0x01));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::emitOperationResultChanged(int result)
{
    emit operationResultChanged(result);
}

void SiYiCamera::getLaserCoords()
{
    uint8_t cmdId = 0xA6;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::getLaserDistance()
{
    uint8_t cmdId = 0x89;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::getLaserState()
{
    uint8_t cmdId = 0xBA;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);

    qDebug() << "Tx get laser:" << msg.toHex(' ');

    sendMessage(msg);
}

void SiYiCamera::setLaserState(int state)
{
    uint8_t cmdId = 0xBB;
    QByteArray body;
    body.append(char(state));

    QByteArray msg = packMessage(0x01, cmdId, body);
    qDebug() << "Tx set laser:" << msg.toHex(' ');
    sendMessage(msg);

    if (state == LaserStateOn) {
        getSplitMode();
    }
}

/**
 * @brief SiYiCamera::setAiModel: 设置AI追踪模式
 * @param mode
 */
void SiYiCamera::setAiModel(int mode)
{
    uint8_t cmdId = 0xA3;
    QByteArray body;
    body.append(char(mode));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

/**
 * @brief SiYiCamera::getAiModel 获取AI追踪模式
 */
void SiYiCamera::getAiModel()
{
    uint8_t cmdId = 0xA2;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

/**
 * @brief SiYiCamera::setTrackingTarget 设置(取消设置)AI追踪目标
 * @param tracking
 * @param x
 * @param y
 */
void SiYiCamera::setTrackingTarget(bool tracking, int x, int y)
{
    uint8_t cmdId = 0xAA;
    uint8_t trackAction = tracking ? 1 : 0;
    uint16_t trackX = x;
    uint16_t trackY = y;

    QByteArray body;
    body.append(reinterpret_cast<char*>(&trackAction), 1);
    body.append(reinterpret_cast<char*>(&trackX), 2);
    body.append(reinterpret_cast<char*>(&trackY), 2);

    m_isCancelingTracking = !tracking;
    QByteArray msg = packMessage(0x01, cmdId, body);
    qInfo() << "camera.setTrackingTarget()" << trackX << trackY << msg.toHex(' ');
    sendMessage(msg);
}

/**
 * @brief SiYiCamera::getTrackingState 获取跟踪状态
 */
void SiYiCamera::getTrackingState()
{
    uint8_t cmdId = 0xAC;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::getSplitMode()
{
    uint8_t cmdId = 0x92;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    qInfo() << "Get split mode:" << msg.toHex(' ');
    sendMessage(msg);
}

QByteArray SiYiCamera::heartbeatMessage()
{
    return packMessage(0x01, 0x80, QByteArray());
}

void SiYiCamera::analyzeMessage()
{
    while (rxBytes_.length() >= 4) {
        if ((rxBytes_.at(0) == char(0x55)) && (rxBytes_.at(1) == char(0x66)) && (rxBytes_.at(3) == char(0xbb)) && (rxBytes_.at(3) == char(0xbb))) {
            int headerLength = 4+1+4+2+1+4;
            if (rxBytes_.length() >= headerLength) {
                ProtocolMessageHeaderContext header;
                quint32 *ptr32 = nullptr;
                quint16 *ptr16 = nullptr;
                quint8 *ptr8 = nullptr;
                int offset = 0;
                ptr32 = reinterpret_cast<quint32*>(rxBytes_.data());
                header.stx = *ptr32;
                offset += 4;

                ptr8 = reinterpret_cast<quint8*>(rxBytes_.data() + offset);
                header.control = *ptr8;
                offset += 1;

                ptr32 = reinterpret_cast<quint32*>(rxBytes_.data() + offset);
                header.dataLength = *ptr32;
                offset += 4;

                ptr16 = reinterpret_cast<quint16*>(rxBytes_.data() + offset);
                header.sequence = *ptr16;
                offset += 2;

                ptr8 = reinterpret_cast<quint8*>(rxBytes_.data() + offset);
                header.cmdId = *ptr8;
                offset += 1;

                ptr32 = reinterpret_cast<quint32*>(rxBytes_.data() + offset);
                header.crc = (*ptr32);
#if 0
                header.stx = qToBigEndian<quint32>(header.stx);
                header.control = qToBigEndian<quint8>(header.control);
                header.dataLength = qToBigEndian<quint16>(header.dataLength);
                header.sequence = qToBigEndian<quint16>(header.sequence);
                header.cmdId = qToBigEndian<quint8>(header.cmdId);
                header.crc = qToBigEndian<quint32>(header.crc);
#endif

                ProtocolMessageContext msg;
                msg.header = header;
                int msgLen = headerLength + header.dataLength + 4;
                if (rxBytes_.length() >= msgLen) {
                    msg.data = QByteArray(rxBytes_.data() + headerLength);
                    int offset = headerLength + header.dataLength;
                    msg.crc = *reinterpret_cast<quint16*>(rxBytes_.data() + offset);
                    msg.crc = qToBigEndian<quint32>(msg.crc);
                } else {
                    // 数据帧未完整
                    break;
                }

                QByteArray packet = QByteArray(rxBytes_.data(), msgLen);
                const QString info = QString("[%1:%2]:").arg(ip_, QString::number(port_));
                if (msg.header.cmdId == 0x80) {
                    messageHandle0x80(packet);
                } else if (msg.header.cmdId == 0x81) {
                    messageHandle0x81(packet);
                } else if (msg.header.cmdId == 0x83) {
                    messageHandle0x83(packet);
                } else if (msg.header.cmdId == 0x89) {
                    messageHandle0x89(packet);
                } else if (msg.header.cmdId == 0x90) {
                    // Nothin to do yet.
                } else if (msg.header.cmdId == 0x91) {
                    // Nothin to do yet.
                } else if (msg.header.cmdId == 0x92 || msg.header.cmdId == 0x93) {
                    messageHandle0x92(packet);
                } else if (msg.header.cmdId == 0x94) {
                    messageHandle0x94(packet);
                } else if (msg.header.cmdId == 0x98) {
                    messageHandle0x98(packet);
                } else if (msg.header.cmdId == 0x9e) {
                    messageHandle0x9e(packet);
                } else if (msg.header.cmdId == 0xa1) {
                    messageHandle0xa1(packet);
                } else if (msg.header.cmdId == 0xa2) {
                    messageHandle0xa2(packet);
                } else if (msg.header.cmdId == 0xa3) {
                    messageHandle0xa3(packet);
                } else if (msg.header.cmdId == 0xa6) {
                    messageHandle0xa6(packet);
                } else if (msg.header.cmdId == 0xaa) {
                    messageHandle0xaa(packet);
                } else if (msg.header.cmdId == 0xab) {
                    messageHandle0xab(packet);
                } else if (msg.header.cmdId == 0xac) {
                    messageHandle0xac(packet);
                } else if (msg.header.cmdId == 0xb0) {
                    messageHandle0xb0(packet);
                } else if (msg.header.cmdId == 0xba) {
                    messageHandle0xba(packet);
                } else if (msg.header.cmdId == 0xbb) {
                    messageHandle0xbb(packet);
                } else {
                    QString id = QString("0x%1").arg(QString::number(msg.header.cmdId, 16), 2, '0');
                    qWarning() << info << "Unknow handle message, cmd id:" << id;
                }

                rxBytes_.remove(0, msgLen);
            } else {
                break;
            }
        } else {
            rxBytes_.remove(0, 1);
        }
    }
}

QByteArray SiYiCamera::packMessage(quint8 control, quint8 cmd,
                                   const QByteArray &payload)
{
    ProtocolMessageContext ctx;
    ctx.header.stx = PROTOCOL_STX;
    ctx.header.control = control;
    ctx.header.dataLength = payload.length();
    ctx.header.sequence = sequence();
    ctx.header.cmdId = cmd;
    ctx.header.crc = headerCheckSum32(&ctx.header);
    ctx.data = payload;
    ctx.crc = packetCheckSum32(&ctx);

    QByteArray msg;
    quint32 beStx = qToBigEndian<quint32>(ctx.header.stx);

    msg.append(reinterpret_cast<char*>(&beStx), 4);                 // STX
    msg.append(reinterpret_cast<char*>(&ctx.header.control), 1);    // CTRL
    msg.append(reinterpret_cast<char*>(&ctx.header.dataLength), 4); // Data_len
    msg.append(reinterpret_cast<char*>(&ctx.header.sequence), 2);   // SEQ
    msg.append(reinterpret_cast<char*>(&ctx.header.cmdId), 1);      // CMD_ID
    msg.append(reinterpret_cast<char*>(&ctx.header.crc), 4);        // CRC32(header)
    msg.append(ctx.data);                                           // DATA
    msg.append(reinterpret_cast<char*>(&ctx.crc), 4);               // CRC32(packet)

    return msg;
}

quint32 SiYiCamera::headerCheckSum32(ProtocolMessageHeaderContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->dataLength), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->cmdId), 1);

        return checkSum32(bytes);
    }

    return 0;
}

quint32 SiYiCamera::packetCheckSum32(ProtocolMessageContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->header.stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->header.control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.dataLength), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->header.sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->header.cmdId), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.crc), 4);

        bytes.append(ctx->data);

        return checkSum32(bytes);
    }

    return 0;
}

bool SiYiCamera::unpackMessage(ProtocolMessageContext *ctx,
                               const QByteArray &msg)
{
    if (ctx) {
        int offset = 0;
        if (msg.length() >= 16) {
            // STX
            const quint32 *ptr32 =
                    reinterpret_cast<const quint32 *>(msg.data());
            quint32 i32 = *ptr32;
            i32 = qToBigEndian<quint32>(i32);
            ctx->header.stx = i32;
            offset += 4;
            // CTRL
            const quint8 *ptr8 =
                    reinterpret_cast<const quint8*>(msg.data() + offset);
            quint8 i8 = *ptr8;
            ctx->header.control = i8;
            offset += 1;
            // Data_len
            ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
            i32 = *ptr32;
            ctx->header.dataLength = i32;
            offset += 4;
            // SEQ
            const quint16 *ptr16 =
                    reinterpret_cast<const quint16*>(msg.data() + offset);
            quint16 i16 = *ptr16;
            ctx->header.sequence = i16;
            offset += 2;
            // CMD_ID
            ptr8 = reinterpret_cast<const quint8*>(msg.data() + offset);
            i8 = *ptr8;
            ctx->header.cmdId = i8;
            offset += 1;
            // CRC32(header)
            ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
            i32 = *ptr32;
            ctx->header.crc = i32;
            offset += 4;

            if (msg.length() >= int(16 + ctx->header.dataLength + 2)) {
                QByteArray data(msg.data() + offset, ctx->header.dataLength);
                ctx->data = data;
                offset += ctx->header.dataLength;

                ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
                i32 = *ptr32;
                ctx->crc = i32;

                if (ctx->header.stx == PROTOCOL_STX) {
                    QByteArray headerBytes(msg.data(), 16);
                    QByteArray packetBytes(msg.data(), 16
                                           + ctx->header.dataLength);
                    quint32 headerCrc = checkSum32(headerBytes);
                    quint32 packetCrc = checkSum32(packetBytes);
                    if (headerCrc == ctx->header.crc
                            && packetCrc == ctx->crc) {
                        return true;
                    }
                }
            }
        }
    }

    return false;
}

void SiYiCamera::getCamerVersion()
{
    uint8_t cmdId = 0x94;
    QByteArray body;

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
}

void SiYiCamera::messageHandle0x80(const QByteArray &msg)
{
    timeoutCountMutex.lock();
    timeoutCount = 0;
    timeoutCountMutex.unlock();

    struct ACK {
        quint8 state;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        isRecording_ = (ctx->state == 1);
        emit isRecordingChanged();
#if 0
        if (camera_type_ == CameraTypeA8 || camera_type_ == CameraTypeZR30) {
            if (recording_state_ != ctx->state) {
                recording_state_ = ctx->state;
                if (recording_state_ != 1) {
                     emit operationResultChanged(4);
                }
            }
        }
#endif
    }
}

void SiYiCamera::messageHandle0x81(const QByteArray &msg)
{
    struct ACK {
        quint8 isStarted;
        quint8 result;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

#if 0
        if (camera_type_ == CameraTypeA8 || camera_type_ == CameraTypeZR30) {
            // Nothing to do...
        } else {
            isRecording_ = ctx->isStarted;
            emit isRecordingChanged();

            if (ctx->result == 0) {
                emit operationResultChanged(4);
            }
        }
#else
        isRecording_ = ctx->isStarted;
        emit isRecordingChanged();

        if (ctx->result == 0) {
            emit operationResultChanged(4);
        }
#endif
    }
}

void SiYiCamera::messageHandle0x83(const QByteArray &msg)
{
    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + (1+1+2+2+2+1) + 4)) {
        const char *ptr = msg.constData();
        char *cookedPtr = const_cast<char *>(ptr + headerLength);
        char streamType = *cookedPtr;
        m_streamType = streamType;
        if (streamType == 1) { // 主码流
            quint16 *ptr16 = reinterpret_cast<quint16 *>(cookedPtr + 2);
            m_resolutionWidthMain = *ptr16;
            ptr16 = reinterpret_cast<quint16 *>(cookedPtr + 4);
            m_resolutionHeightMain = *ptr16;
            //qDebug() << "video resolution(main):" << resolutionWidth_ << "x" << resolutionHeight_;
        } else if (streamType == 0) { // 录像流
            quint16 *ptr16 = reinterpret_cast<quint16 *>(cookedPtr + 2);
            resolutionWidth_ = *ptr16;
            ptr16 = reinterpret_cast<quint16 *>(cookedPtr + 4);
            resolutionHeight_ = *ptr16;
            if (resolutionWidth_ == 4096) {
                is4k_ = true;
                emit is4kChanged();
            }

            m_resolutionH = resolutionWidth_;
            m_resolutionW = resolutionHeight_;
            emit resolutionHChanged();
            emit resolutionWChanged();
            qDebug() << "video resolution:" << resolutionWidth_ << "x" << resolutionHeight_;
        } else if (streamType == 2) { // 子码流
        } else {
            qWarning() << "Unknown stream(resolution) type:" << int(streamType) << msg.toHex(' ');
        }
    }
}

/**
 * @brief SiYiCamera::messageHandle0x89 处理0x89（获取激光测距距离信息应答）消息
 * @param msg 0x89消息
 */
void SiYiCamera::messageHandle0x89(const QByteArray &msg)
{
    struct ACK {
        quint32 distance;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);
        if (m_laserDistance != int(ctx->distance)) {
            m_laserDistance = ctx->distance;
            emit laserDistanceChanged();

            double tmp = m_laserDistance;
            tmp /= 10.0;
            m_cookedLaserDistance = QString::number(tmp, 'f', 1);
            emit cookedLaserDistanceChanged();
            qDebug() << "laser distance:" << m_laserDistance << "m";
        }
    }
}

void SiYiCamera::messageHandle0x92(const QByteArray &msg)
{
    struct ACK
    {
        quint8 mainStream;
        quint8 subStream;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK *>(ptr);

        m_mainStreamSplitMode = ctx->mainStream;
        m_subStreamSplitMode = ctx->subStream;

        qInfo() << "main stream split mode:" << m_mainStreamSplitMode
                << ";sub stream split mode:" << m_subStreamSplitMode;

        emit mainStreamSplitModeChanged();
        emit subStreamSplitModeChanged();
    }
}

void SiYiCamera::messageHandle0x94(const QByteArray &msg)
{
    struct ACK {
        quint32 version;
    };
    struct ACKNew
    {
        quint32 version;
        quint32 aiVersion;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    bool bytes4 = msg.length() == int(headerLength + sizeof(ACK) + 4);
    bool bytes8 = msg.length() == int(headerLength + sizeof(ACKNew) + 4);
    if (bytes4 || bytes8) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK *>(ptr);

        /*
        0x6C：R1卡录摄像头
        0x6E：ZR10 10倍变焦云台相机
        0x72：A8 mini云台相机
        0x74：A2 mini云台相机
        0x77：ZR30云台相机
        */
        int type = ctx->version >> 24;
        camera_type_ = type;
        qInfo() << "The camera type is: " << QString("0x%1").arg(QString::number(type, 16), 2, '0');
        if (type == CameraTypeZR10 || type == CameraTypeZR30 || type == CameraTypeZT30) { // ZR10,ZR30
            enableFocus_ = true;
            enableZoom_ = true;
            enablePhoto_ = true;
            enableVideo_ = true;
            enableControl_ = true;
            m_enableAi = true;
            if (type == CameraTypeZT30) {
                m_enableLaser = true;
                getLaserState();

                getResolutionMain();
                getLaserCoords();
            } else {
                m_enableLaser = false;
            }
        } else if (type == CameraTypeR1 || type == CameraTypeR1M) { // R1
            enableFocus_ = false;
            enableZoom_ = false;
            enablePhoto_ = false;
            enableVideo_ = true;
            enableControl_ = false;
            m_enableLaser = false;
        } else if (type == CameraTypeA8) { // A8
            enableFocus_ = false;
            enableZoom_ = true;
            enablePhoto_ = true;
            enableVideo_ = true;
            enableControl_ = true;
            m_enableLaser = false;
            m_enableAi = true;
        } else if (type == CameraTypeA2) { // A2
            enableFocus_ = false;
            enableZoom_ = false;
            enablePhoto_ = false;
            enableVideo_ = false;
            enableControl_ = true;
            m_enableLaser = false;
        } else if (type == CameraTypeZT6) {
            enableFocus_ = false;
            enableZoom_ = true;
            enablePhoto_ = true;
            enableVideo_ = true;
            enableControl_ = true;
            m_enableLaser = false;
            m_enableAi = true;
        } else {
            enableFocus_ = false;
            enableZoom_ = false;
            enablePhoto_ = false;
            enableVideo_ = false;
            enableControl_ = false;
            m_enableLaser = false;
            qWarning() << "Unknow camera type: " << type << ", disable all functions.";
        }
#if 0
        if (bytes4) {
            m_enableAi = false;
        } else if (bytes8) {
            m_enableAi = true;
        }
#endif

        emit enableFocusChanged();
        emit enableZoomChanged();
        emit enablePhotoChanged();
        emit enableVideoChanged();
        emit enableControlChanged();
        emit enableLaserChanged();
        emit enableAiChanged();

        if (m_enableAi) {
            getAiModel();
            getTrackingState();
        }
    } else {
        qWarning() << "The length of x0x94 message is not correct.";
    }
}

void SiYiCamera::messageHandle0x98(const QByteArray &msg)
{
    struct ACK {
        qint16 zoomMultiple;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        zoomMultiple_ = ctx->zoomMultiple;
        emit zoomMultipleChanged();
    }
}

void SiYiCamera::messageHandle0x9e(const QByteArray &msg)
{
    struct ACK {
        qint8 result;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        emit operationResultChanged(ctx->result);
    }
}

void SiYiCamera::messageHandle0xa1(const QByteArray &msg)
{
    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() > int(headerLength + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        qDebug() << "0xa1:" << ptr;
    }
}

/**
 * @brief SiYiCamera::messageHandle0xa2 获取AI追踪模式应答
 * @param msg
 */
void SiYiCamera::messageHandle0xa2(const QByteArray &msg)
{
    struct ACK {
        qint8 mode;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        bool on = (ctx->mode == AiModeOn);
        if (on != m_aiModeOn) {
            m_aiModeOn = on;
            emit aiModeOnChanged();
        }
    }
}

/**
 * @brief SiYiCamera::messageHandle0xa3 设置AI追踪模式应答
 * @param msg
 */
void SiYiCamera::messageHandle0xa3(const QByteArray &msg)
{
    struct ACK {
        qint8 mode;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        bool on = (ctx->mode == AiModeOn);
        if (on != m_aiModeOn) {
            m_aiModeOn = on;
            emit aiModeOnChanged();
        }

        if (!on) {
            m_isTracking = false;
            emit isTrackingChanged();
        }
    }
}

void SiYiCamera::messageHandle0xa6(const QByteArray &msg)
{
    struct ACK {
        qint16 x;
        qint16 y;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        if (m_laserCoordsX != ctx->x) {
            m_laserCoordsX = ctx->x;
            emit laserCoordsXChanged();
        }

        if (m_laserCoordsY != ctx->y) {
            m_laserCoordsY = ctx->y;
            emit laserCoordsYChanged();
        }

        //qDebug() << "laser coords: " << m_laserCoordsX << m_laserCoordsY;
    }
}

/**
 * @brief SiYiCamera::messageHandle0xaa 设置(取消设置)AI追踪目标应答
 * @param msg
 */
void SiYiCamera::messageHandle0xaa(const QByteArray &msg)
{
    struct ACK {
        qint8 result;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);
        if (ctx->result == 0) {
            //emit operationResultChanged(TipOptionSettingFailed);
            //m_isTracking = false;
            //emit isTrackingChanged();
            getTrackingState();
        } else if (ctx->result == 1) {
            //emit operationResultChanged(TipOptionSettingOK);
            if (m_isCancelingTracking) {
                m_isTracking = false;
            } else {
                m_isTracking = true;
            }
            emit isTrackingChanged();
            getTrackingState();
        } else if (ctx->result == 2) {
            emit operationResultChanged(TipOptionIsNotAiTrackingMode);
            getTrackingState();
            //m_isTracking = false;
            //emit isTrackingChanged();
        } else if (ctx->result == 3) {
            emit operationResultChanged(TipOptionStreamNotSupportedAiTracking);
            getTrackingState();
            //m_isTracking = false;
            //emit isTrackingChanged();
        }

        if (m_isCancelingTracking) {
            m_isCancelingTracking = false;
        }
        qInfo() << __FUNCTION__ << __LINE__ << m_isTracking << msg.toHex(' ');
    }
}

/**
 * @brief SiYiCamera::messageHandle0xab AI追踪目标信息推送
 * @param msg
 */
void SiYiCamera::messageHandle0xab(const QByteArray &msg)
{
    struct ACK {
        qint16 x;
        qint16 y;
        qint16 w;
        qint16 h;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);

        emit aiInfoChanged(ctx->x, ctx->y, ctx->w, ctx->h);
    }
}

/**
 * @brief SiYiCamera::messageHandle0xac 获取AI跟踪状态应答
 * @param msg
 */
void SiYiCamera::messageHandle0xac(const QByteArray &msg)
{
    struct ACK
    {
        qint8 state;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK *>(ptr);

        m_isTracking = !(ctx->state == 1);
        emit isTrackingChanged();
    }

    qDebug() << __FUNCTION__ << "m_isTracking:" << m_isTracking << msg.toHex(' ');
}

void SiYiCamera::messageHandle0xb0(const QByteArray &msg)
{
    struct ACK
    {
        quint32 longtitude;
        quint32 latitude;
    };

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK *>(ptr);

        qreal tmpLongtitude = qreal(ctx->longtitude) / 10000000.0;
        qreal tmpLatitude = qreal(ctx->latitude) / 10000000.0;

        m_cookedLongitude = QString::number(tmpLongtitude, 'f', 8);
        m_cookedLatitude = QString::number(tmpLatitude, 'f', 8);
        emit cookedLongitudeChanged();
        emit cookedLatitudeChanged();
    }
}

void SiYiCamera::messageHandle0xba(const QByteArray &msg)
{
    messageHandle0xbb(msg);
}

/**
 * @brief SiYiCamera::messageHandle0xbb 激光测距关闭/开启应答
 * @param msg
 */
void SiYiCamera::messageHandle0xbb(const QByteArray &msg)
{
    struct ACK {
        qint8 result;
    };

    qDebug() << "set laser response" << msg.toHex(' ');

    int headerLength = 4 + 1 + 4 + 2 + 1 + 4;
    if (msg.length() == int(headerLength + sizeof(ACK) + 4)) {
        const char *ptr = msg.constData();
        ptr += headerLength;
        auto ctx = reinterpret_cast<const ACK*>(ptr);
        bool on = (ctx->result == LaserStateOn);
        if (on != m_laserStateOn) {
            m_laserStateOn = on;
            emit laserStateOnChanged();
        }

        m_laserStateHasResponse = true;
        emit laserStateHasResponseChanged();
    }
}

bool SiYiCamera::using1080p()
{
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                           + "/config.ini",
                       QSettings::IniFormat);
    QVariant tmp = settings.value("using1080p");
    if (tmp.isNull()) {
        return true;
    }

    return tmp.toBool();
}

void SiYiCamera::setUsing1080p(bool using1080p)
{
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                           + "/config.ini",
                       QSettings::IniFormat);
    settings.setValue("using1080p", using1080p);
    emit using1080pChanged();
}
