import QtQuick 2.0
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1

MainView {
    id: "mainView"
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "example.pushclient.hello"

    automaticOrientation: true
    property string token: pushClient.token
    onTokenChanged: {console.log(token)}

    width: units.gu(100)
    height: units.gu(75)

    Page {
        id: page
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('pushclient')
        }

        Button {
            anchors.centerIn: parent
            text: i18n.tr('Hello World!')
            onClicked: {
                console.log("Sending push notification ...")

                var req = new XMLHttpRequest();
                req.open("post", "https://push.ubports.com/notify", true);
                req.setRequestHeader("Content-type", "application/json");
                req.onreadystatechange = function() {//Call a function when the state changes.
                    console.log(req.responseText);
                }
                var approxExpire = new Date ()
                approxExpire.setUTCMinutes(approxExpire.getUTCMinutes()+10)
                req.send(JSON.stringify({
                    "appid" : "example.pushclient.hello_hello",
                    "expire_on": approxExpire.toISOString(),
                    "token": token,
                    "clear_pending": true,
                    "replace_tag": "tagname",
                    "data": {
                        "message": "foobar",
                        "notification": {
                            "card": {
                                "summary": "Test Notification",
                                "body": "Hello Ubports World!",
                                "popup": true,
                                "persist": true
                            },
                            "tag": "foo",
                            "vibrate": {
                                "duration": 200,
                                "pattern": [200, 100],
                                "repeat": 2
                            },
                            "emblem-counter": {
                                "count": 12,
                                "visible": true
                            }
                        }
                    }
                }))
            }

        }

        Label {
            id: label
            anchors.bottom: parent
            text: i18n.tr(' ')
        }


    }

    PushClient {
        id: pushClient
        Component.onCompleted: {
            notificationsChanged.connect(messageList.handle_notifications)
            error.connect(messageList.handle_error)
            onTokenChanged: {
                console.log("foooooo")
                console.log(token)
            }
        }
        appId: "example.pushclient.hello_hello"

    }

}
