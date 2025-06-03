﻿#ifndef SIYICAMERA_H
#define SIYICAMERA_H

#include <QHostAddress>
#include <QObject>
#include <QTimer>

#include "SiYiTcpClient.h"

class SiYiCamera : public SiYiTcpClient
{
    Q_OBJECT
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
    Q_PROPERTY(int zoomMultiple READ zoomMultiple NOTIFY zoomMultipleChanged)
    Q_PROPERTY(bool enableZoom READ enableZoom NOTIFY enableZoomChanged)
    Q_PROPERTY(bool enableFocus READ enableFocus NOTIFY enableFocusChanged)
    Q_PROPERTY(bool enablePhoto READ enablePhoto NOTIFY enablePhotoChanged)
    Q_PROPERTY(bool enableVideo READ enableVideo NOTIFY enableVideoChanged)
    Q_PROPERTY(bool enableControl READ enableControl NOTIFY enableControlChanged)
    Q_PROPERTY(bool is4k READ is4k NOTIFY is4kChanged)
    Q_PROPERTY(bool enableLaser READ enableLaser NOTIFY enableLaserChanged FINAL)
    Q_PROPERTY(bool laserStateOn READ laserStateOn NOTIFY laserStateOnChanged FINAL)
    Q_PROPERTY(int laserDistance READ laserDistance NOTIFY laserDistanceChanged FINAL)
    Q_PROPERTY(int laserCoordsX READ laserCoordsX NOTIFY laserCoordsXChanged FINAL)
    Q_PROPERTY(int laserCoordsY READ laserCoordsY NOTIFY laserCoordsYChanged FINAL)
    Q_PROPERTY(QString cookedLaserDistance READ cookedLaserDistance NOTIFY cookedLaserDistanceChanged FINAL)

    Q_PROPERTY(quint16 resolutionW READ resolutionW NOTIFY resolutionWChanged FINAL)
    Q_PROPERTY(quint16 resolutionH READ resolutionH NOTIFY resolutionHChanged FINAL)

    Q_PROPERTY(bool enableAi READ enableAi NOTIFY enableAiChanged FINAL)
    Q_PROPERTY(bool aiModeOn READ aiModeOn NOTIFY aiModeOnChanged FINAL)
    Q_PROPERTY(bool isTracking READ isTracking NOTIFY isTrackingChanged FINAL)

    Q_PROPERTY(bool using1080p READ using1080p WRITE setUsing1080p NOTIFY using1080pChanged FINAL)
    Q_PROPERTY(QString cookedLongitude READ cookedLongitude NOTIFY cookedLongitudeChanged FINAL)
    Q_PROPERTY(QString cookedLatitude READ cookedLatitude NOTIFY cookedLatitudeChanged FINAL)

    Q_PROPERTY(bool laserStateHasResponse READ laserStateHasResponse NOTIFY
                   laserStateHasResponseChanged FINAL)
    Q_PROPERTY(
        int mainStreamSplitMode READ mainStreamSplitMode NOTIFY mainStreamSplitModeChanged FINAL)
    Q_PROPERTY(int subStreamSplitMode READ subStreamSplitMode NOTIFY subStreamSplitModeChanged FINAL)
public:
    struct ProtocolMessageHeaderContext {
        quint32 stx;
        quint8 control;
        quint32 dataLength;
        quint16 sequence;
        quint8 cmdId;
        quint32 crc;
    };
    struct ProtocolMessageContext {
        ProtocolMessageHeaderContext header;
        QByteArray data;
        quint32 crc;
    };
    enum CameraCommand {
        CameraCommandTakePhoto
    };
    Q_ENUM(CameraCommand);
    enum CameraVideoCommand {
        CloseRecording,
        OpenRecording
    };
    Q_ENUM(CameraVideoCommand);
    enum AiMode {
        AiModeOff,
        AiModeOn
    };
    Q_ENUM(AiMode);
    enum LaserState {
        LaserStateOff,
        LaserStateOn,
    };
    Q_ENUM(LaserState);

    enum CameraType {
        CameraTypeR1 = 0x6c,
        CameraTypeZR10 = 0x6e,
        CameraTypeR1M = 0x71,
        CameraTypeA8 = 0x72,
        CameraTypeA2 = 0x74,
        CameraTypeZR30 = 0x77,
        CameraTypeZT30 = 0x7B,
        CameraTypeZT6 = 0x82,
    };
    Q_ENUM(CameraType);
    enum CameraTipOption {
        TipOptionTakePhotoSuccessfully = 0, // 拍照成功
        TipOptionTakePhotoFailed = 1, // 拍照失败
        TipOptionRecordVideoFailed = 4, // 录像失败
        TipOptionNotSupported4K = -1, // 4K视频不支持变倍
        //0：拍照成功
        //1：拍照失败，请检查是否未插入TF卡
        //2：HDR模式开启
        //3：HDR模式关闭
        //4：录像失败，请检查是否未插入TF卡
        //5：未插入TF卡
        //6：激光测距不在范围内
        TipOptionLaserNotInRange = 6, // 激光测距不在范围内
        TipOptionSettingOK = 101, // 设置成功
        TipOptionSettingFailed, // 设置失败
        TipOptionIsNotAiTrackingMode, // 当前模式不是Ai追踪模式
        TipOptionStreamNotSupportedAiTracking, // 当前码流不支持AI追踪功能
    };
    Q_ENUM(CameraTipOption);

signals:
    void operationResultChanged(int result);
    void aiInfoChanged(int x, int y, int w, int h);

public:
    explicit SiYiCamera(QObject *parent = nullptr);
    ~SiYiCamera();

    Q_INVOKABLE void analyzeIp(QString videoUrl) override;

    Q_INVOKABLE bool turn(int yaw, int pitch);
    Q_INVOKABLE bool resetPostion();
    Q_INVOKABLE bool autoFocus(int x, int y, int w, int h);
    // 1: 放大，0：停止，-1：缩小
    Q_INVOKABLE bool zoom(int option);
    // 1: 远景，0：停止，-1：近景
    Q_INVOKABLE bool focus(int option);
    Q_INVOKABLE bool sendCommand(int cmd);
    Q_INVOKABLE bool sendRecodingCommand(int cmd);
    void setLogState(int state);
    bool getRecordingState();
    void getResolution();   // 获取录像流分辨率
    void getResolutionMain();// 获取主码流分辨率
    Q_INVOKABLE void emitOperationResultChanged(int result);
    Q_INVOKABLE void getLaserCoords();  // 获取激光测距指示坐标
    Q_INVOKABLE void getLaserDistance();  // 获取激光测距距离
    Q_INVOKABLE void getLaserState();     // 获取激光测距开关状态
    Q_INVOKABLE void setLaserState(int state); // 激光测距开关，0: 关闭，1: 打开
    Q_INVOKABLE void setAiModel(int mode); // 设置AI模式
    Q_INVOKABLE void getAiModel(); // 获取AI模式
    Q_INVOKABLE void setTrackingTarget(bool tracking, int x, int y); // 设置/取消设置跟踪目标
    Q_INVOKABLE void getTrackingState();
    Q_INVOKABLE void getSplitMode(); // 获取分屏模式

protected:
    QByteArray heartbeatMessage() override;
    void analyzeMessage() override;

private:
    qint8 recording_state_{0};
    qint8 camera_type_{-1};
    quint16 resolutionWidth_{0};
    quint16 resolutionHeight_{0};
    quint16 m_resolutionWidthMain{0};
    quint16 m_resolutionHeightMain{0};
    bool m_isCancelingTracking{false};
    QTimer *m_laserTimer{nullptr};
    int m_streamType;

private:
    QByteArray packMessage(quint8 control, quint8 cmd,
                           const QByteArray &payload);
    quint32 headerCheckSum32(ProtocolMessageHeaderContext *ctx);
    quint32 packetCheckSum32(ProtocolMessageContext *ctx);
    bool unpackMessage(ProtocolMessageContext *ctx,
                       const QByteArray &msg);
    void getCamerVersion();

private:
    void messageHandle0x80(const QByteArray &msg);
    void messageHandle0x81(const QByteArray &msg);
    void messageHandle0x83(const QByteArray &msg);
    void messageHandle0x89(const QByteArray &msg);
    void messageHandle0x92(const QByteArray &msg);
    void messageHandle0x94(const QByteArray &msg);
    void messageHandle0x98(const QByteArray &msg);
    void messageHandle0x9e(const QByteArray &msg);
    void messageHandle0xa1(const QByteArray &msg);
    void messageHandle0xa2(const QByteArray &msg);
    void messageHandle0xa3(const QByteArray &msg);
    void messageHandle0xa6(const QByteArray &msg);
    void messageHandle0xaa(const QByteArray &msg);
    void messageHandle0xab(const QByteArray &msg);
    void messageHandle0xac(const QByteArray &msg);
    void messageHandle0xb0(const QByteArray &msg);
    void messageHandle0xba(const QByteArray &msg);
    void messageHandle0xbb(const QByteArray &msg);

private:
    bool isRecording_{false};
    bool isRecording(){return isRecording_;}
    //Q_SIGNAL void isRecordingChanged();

    int zoomMultiple_{1};
    int zoomMultiple(){return zoomMultiple_;}
    Q_SIGNAL void zoomMultipleChanged();

    bool enableZoom_{false};
    bool enableZoom(){return enableZoom_;}
    Q_SIGNAL void enableZoomChanged();

    bool enableFocus_{false};
    bool enableFocus(){return enableFocus_;}
    Q_SIGNAL void enableFocusChanged();

    bool enablePhoto_{false};
    bool enablePhoto(){return enablePhoto_;}
    Q_SIGNAL void enablePhotoChanged();

    bool enableVideo_{false};
    bool enableVideo(){return enableVideo_;}
    //Q_SIGNAL void enableVideoChanged();

    bool enableControl_{false};
    bool enableControl(){return enableControl_;}
    Q_SIGNAL void enableControlChanged();

    bool is4k_{false};
    bool is4k(){return is4k_;}
    Q_SIGNAL void is4kChanged();

    bool m_enableLaser{false};
    bool enableLaser(){return m_enableLaser;}
    Q_SIGNAL void enableLaserChanged();

    int m_laserDistance{0};
    int laserDistance(){return m_laserDistance;}
    Q_SIGNAL void laserDistanceChanged();

    int m_laserCoordsX{0};
    int laserCoordsX(){return m_laserCoordsX;}
    Q_SIGNAL void laserCoordsXChanged();

    int m_laserCoordsY{0};
    int laserCoordsY(){return m_laserCoordsY;}
    Q_SIGNAL void laserCoordsYChanged();

    bool m_laserStateOn{false};
    bool laserStateOn(){return m_laserStateOn;}
    Q_SIGNAL void laserStateOnChanged();

    QString m_cookedLaserDistance{"-.-"};
    QString cookedLaserDistance(){return m_cookedLaserDistance;}
    Q_SIGNAL void cookedLaserDistanceChanged();

    quint16 m_resolutionW{1920};
    quint16 resolutionW() { return m_resolutionW; }
    Q_SIGNAL void resolutionWChanged();

    quint16 m_resolutionH{1080};
    quint16 resolutionH() { return m_resolutionH; }
    Q_SIGNAL void resolutionHChanged();

    bool m_aiModeOn{false};
    bool aiModeOn(){return m_aiModeOn;}
    Q_SIGNAL void aiModeOnChanged();

    bool m_enableAi{false};
    bool enableAi() { return m_enableAi; }
    Q_SIGNAL void enableAiChanged();

    bool m_isTracking{false};
    bool isTracking() { return m_isTracking; }
    Q_SIGNAL void isTrackingChanged();

    bool using1080p();
    void setUsing1080p(bool using1080p);
    Q_SIGNAL void using1080pChanged();

    QString m_cookedLongitude{"-.-"};
    QString cookedLongitude() { return m_cookedLongitude; }
    Q_SIGNAL void cookedLongitudeChanged();

    QString m_cookedLatitude{"-.-"};
    QString cookedLatitude() { return m_cookedLatitude; }
    Q_SIGNAL void cookedLatitudeChanged();

    bool m_laserStateHasResponse{false};
    bool laserStateHasResponse() { return m_laserStateHasResponse; }
    Q_SIGNAL void laserStateHasResponseChanged();

    int m_mainStreamSplitMode{-1};
    int mainStreamSplitMode() { return m_mainStreamSplitMode; }
    Q_SIGNAL void mainStreamSplitModeChanged();

    int m_subStreamSplitMode{-1};
    int subStreamSplitMode() { return m_subStreamSplitMode; }
    Q_SIGNAL void subStreamSplitModeChanged();

signals:
    void isRecordingChanged();
    void enableVideoChanged();
};

#endif // SIYICAMERA_H
