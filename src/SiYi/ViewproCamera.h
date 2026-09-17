#ifndef VIEWPROCAMERA_H
#define VIEWPROCAMERA_H

#include <QObject>
#include <string>
#include <vector>

class ViewproCamera : public QObject
{
    Q_OBJECT

public:
    static ViewproCamera* instance();
    Q_INVOKABLE void setAddress(const QString& ip, int port);
    Q_INVOKABLE bool connectCamera();
    Q_INVOKABLE void closeCamera();
    Q_INVOKABLE void turnleft();
    Q_INVOKABLE void turnright();
    Q_INVOKABLE void turnup();
    Q_INVOKABLE void turndown();
    Q_INVOKABLE void zoom();

    Q_INVOKABLE void stop();
    Q_INVOKABLE void down90();
    Q_INVOKABLE void home();
    Q_INVOKABLE void starttrack();
    Q_INVOKABLE void stoptrack();

    Q_INVOKABLE void setSpeed(int speed);
    Q_INVOKABLE int getSpeed() {return speed_;}
    Q_INVOKABLE void setMultiple(int multiple);
    Q_INVOKABLE int getMultiple() {return multiple_;}
signals:
private:
    explicit ViewproCamera(QObject *parent = nullptr);
    ~ViewproCamera();
    std::vector<uint8_t> hexToBytes(const std::string& hex);
    void sendPacket(const std::vector<uint8_t>& data);
    void sendHexPacket(const std::string& hex);


private:
    std::string ip_{"192.168.144.26"};
    int port_{2000};
    int sock_{-1};
    int speed_{10};
    int multiple_{1};
    std::vector<std::string> upstr =
        {
            "eb901455aadc11300d000005dc000005c80000000000380f",
            "eb901455aadc11300d000005dc000005b400000000004407",
            "eb901455aadc11300d000005dc000005a0000000000050ff",
            "eb901455aadc11300d000005dc0000058c00000000007c17",
            "eb901455aadc11300d000005dc000005780000000000880f",
            "eb901455aadc11300d000005dc0000056400000000009407",
            "eb901455aadc11300d000005dc000005500000000000a0ff",
            "eb901455aadc11300d000005dc0000053c0000000000cc17",
            "eb901455aadc11300d000005dc000005280000000000d80f",
            "eb901455aadc11300d000005dc000005140000000000e407",
            "eb901455aadc11300d000005dc000005000000000000f0ff",
            "eb901455aadc11300d000005dc000004ec00000000001d17",
            "eb901455aadc11300d000005dc000004d80000000000290f",
            "eb901455aadc11300d000005dc000004c400000000003507",
            "eb901455aadc11300d000005dc000004b0000000000041ff",
            "eb901455aadc11300d000005dc0000049c00000000006d17",
            "eb901455aadc11300d000005dc000004880000000000790f",
            "eb901455aadc11300d000005dc0000047400000000008507",
            "eb901455aadc11300d000005dc00000460000000000091ff",
            "eb901455aadc11300d000005dc0000044c0000000000bd17"
        };
    std::vector<std::string> downstr =
        {
            "eb901455aadc11300d000005dc000005f0000000000000ff",
            "eb901455aadc11300d000005dc000006040000000000f70b",
            "eb901455aadc11300d000005dc000006180000000000eb13",
            "eb901455aadc11300d000005dc0000062c0000000000df1b",
            "eb901455aadc11300d000005dc000006400000000000b303",
            "eb901455aadc11300d000005dc000006540000000000a70b",
            "eb901455aadc11300d000005dc0000066800000000009b13",
            "eb901455aadc11300d000005dc0000067c00000000008f1b",
            "eb901455aadc11300d000005dc0000069000000000006303",
            "eb901455aadc11300d000005dc000006a40000000000570b",
            "eb901455aadc11300d000005dc000006b800000000004b13",
            "eb901455aadc11300d000005dc000006cc00000000003f1b",
            "eb901455aadc11300d000005dc000006e000000000001303",
            "eb901455aadc11300d000005dc000006f40000000000070b",
            "eb901455aadc11300d000005dc000007080000000000fa13",
            "eb901455aadc11300d000005dc0000071c0000000000ee1b",
            "eb901455aadc11300d000005dc000007300000000000c203",
            "eb901455aadc11300d000005dc000007440000000000b60b",
            "eb901455aadc11300d000005dc000007580000000000aa13",
            "eb901455aadc11300d000005dc0000076c00000000009e1b"
        };
    std::vector<std::string> leftstr =
        {
            "eb901455aadc11300d000005c8000005dc0000000000380f",
            "eb901455aadc11300d000005b4000005dc00000000004407",
            "eb901455aadc11300d000005a0000005dc000000000050ff",
            "eb901455aadc11300d0000058c000005dc00000000007c17",
            "eb901455aadc11300d00000578000005dc0000000000880f",
            "eb901455aadc11300d00000564000005dc00000000009407",
            "eb901455aadc11300d00000550000005dc0000000000a0ff",
            "eb901455aadc11300d0000053c000005dc0000000000cc17",
            "eb901455aadc11300d00000528000005dc0000000000d80f",
            "eb901455aadc11300d00000514000005dc0000000000e407",
            "eb901455aadc11300d00000500000005dc0000000000f0ff",
            "eb901455aadc11300d000004ec000005dc00000000001d17",
            "eb901455aadc11300d000004d8000005dc0000000000290f",
            "eb901455aadc11300d000004c4000005dc00000000003507",
            "eb901455aadc11300d000004b0000005dc000000000041ff",
            "eb901455aadc11300d0000049c000005dc00000000006d17",
            "eb901455aadc11300d00000488000005dc0000000000790f",
            "eb901455aadc11300d00000474000005dc00000000008507",
            "eb901455aadc11300d00000460000005dc000000000091ff",
            "eb901455aadc11300d0000044c000005dc0000000000bd17"
        };
    std::vector<std::string> rightstr =  {
        "eb901455aadc11300d000005f0000005dc000000000000ff",
        "eb901455aadc11300d00000604000005dc0000000000f70b",
        "eb901455aadc11300d00000618000005dc0000000000eb13",
        "eb901455aadc11300d0000062c000005dc0000000000df1b",
        "eb901455aadc11300d00000640000005dc0000000000b303",
        "eb901455aadc11300d00000654000005dc0000000000a70b",
        "eb901455aadc11300d00000668000005dc00000000009b13",
        "eb901455aadc11300d0000067c000005dc00000000008f1b",
        "eb901455aadc11300d00000690000005dc00000000006303",
        "eb901455aadc11300d000006a4000005dc0000000000570b",
        "eb901455aadc11300d000006b8000005dc00000000004b13",
        "eb901455aadc11300d000006cc000005dc00000000003f1b",
        "eb901455aadc11300d000006e0000005dc00000000001303",
        "eb901455aadc11300d000006f4000005dc0000000000070b",
        "eb901455aadc11300d00000708000005dc0000000000fa13",
        "eb901455aadc11300d0000071c000005dc0000000000ee1b",
        "eb901455aadc11300d00000730000005dc0000000000c203",
        "eb901455aadc11300d00000744000005dc0000000000b60b",
        "eb901455aadc11300d00000758000005dc0000000000aa13",
        "eb901455aadc11300d0000076c000005dc00000000009e1b"
    };
    std::vector<std::string> zoomstr =
        {
            "eb901055aadc0d31000053000a000000000065db",
            "eb901055aadc0d31000053001400000000007bfb",
            "eb901055aadc0d31000053001e000000000071fb",
            "eb901055aadc0d310000530028000000000047db",
            "eb901055aadc0d31000053003200000000005dfb",
            "eb901055aadc0d31000053003c000000000053fb",
            "eb901055aadc0d310000530046000000000029db",
            "eb901055aadc0d31000053005000000000003ffb",
            "eb901055aadc0d31000053005a000000000035fb",
            "eb901055aadc0d31000053006400000000000bdb",
            "eb901055aadc0d31000053006e000000000001db",
            "eb901055aadc0d310000530078000000000017fb",
            "eb901055aadc0d3100005300820000000000eddb",
            "eb901055aadc0d31000053008c0000000000e3db",
            "eb901055aadc0d3100005300960000000000f9fb",
            "eb901055aadc0d3100005300a00000000000cfdb",
            "eb901055aadc0d3100005300aa0000000000c5db",
            "eb901055aadc0d3100005300b40000000000dbfb",
            "eb901055aadc0d3100005300be0000000000d1fb",
            "eb901055aadc0d3100005300c80000000000a7db",
            "eb901055aadc0d3100005300d20000000000bdfb",
            "eb901055aadc0d3100005300dc0000000000b3fb",
            "eb901055aadc0d3100005300e6000000000089db",
            "eb901055aadc0d3100005300f000000000009ffb",
            "eb901055aadc0d3100005300fa000000000095fb",
            "eb901055aadc0d31000053010400000000006adb",
            "eb901055aadc0d31000053010e000000000060db",
            "eb901055aadc0d310000530118000000000076fb",
            "eb901055aadc0d31000053012200000000004cdb",
            "eb901055aadc0d31000053012c000000000042db",
            "eb901055aadc0d310000530136000000000058fb",
            "eb901055aadc0d31000053014000000000002edb",
            "eb901055aadc0d31000053014a000000000024db",
            "eb901055aadc0d31000053015400000000003afb",
            "eb901055aadc0d31000053015e000000000030fb",
            "eb901055aadc0d310000530168000000000006db"
        };
    std::string stopstr = "eb901455aadc11300100000000000000000000000000203d";
    std::string homestr = "eb901455aadc113004000000000000000000000000002545";
    std::string starttrackstr = "eb901455aadc113006000000000000000000000003002449";
    std::string stoptrackstr = "eb900955aadc061e0001001919";
    std::string down90str = "eb901455aadc11300b00003ffc000000000000000000e94b";

    std::vector<std::vector<uint8_t>> leftPackets;
    std::vector<std::vector<uint8_t>> rightPackets;
    std::vector<std::vector<uint8_t>> upPackets;
    std::vector<std::vector<uint8_t>> downPackets;
    std::vector<std::vector<uint8_t>> zoomPackets;

    std::vector<uint8_t> stopPacket;
    std::vector<uint8_t> homePacket;
    std::vector<uint8_t> starttrackPacket;
    std::vector<uint8_t> stoptrackPacket;
    std::vector<uint8_t> down90Packet;
};

#endif // VIEWPROCAMERA_H
