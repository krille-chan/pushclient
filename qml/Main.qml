import QtQuick 2.9
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'pushclient.christianpauly'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    Component.onCompleted: console.log("🤖 ============PUSHCLIENT STARTED============")

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('pushclient')
            trailingActionBar {
                actions: [
                Action {
                    iconName: "info"
                    onTriggered: Qt.openUrlExternally("https://github.com/ChristianPauly/pushclient")
                }
                ]
            }
        }

        TextField {
            id: tokenInput
            placeholderText: "Token"
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: units.gu(1)
            width: parent.width - units.gu(2)
        }
        TextField {
            id: messageInput
            placeholderText: i18n.tr("Your message")
            anchors.top: tokenInput.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: units.gu(1)
            width: parent.width - units.gu(2)
        }
        Button {
            id: sendButton
            text: i18n.tr("Send push notification")
            color: UbuntuColors.green
            anchors.top: messageInput.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: units.gu(1)
            width: parent.width - units.gu(2)
            enabled: pushClient.token && messageInput.displayText !== "" && tokenInput.displayText !== ""
            onClicked: {
                console.log("💬 Sending push notification ...")
                sendButton.color = UbuntuColors.green
                var req = new XMLHttpRequest();
                req.open("post", "https://push.ubports.com/notify", true);
                req.setRequestHeader("Content-type", "application/json");
                req.onreadystatechange = function() {
                    if ( req.readyState === XMLHttpRequest.DONE ) {
                        console.log("✍ Answer from push service:", req.responseText)
                        var ans = JSON.parse(req.responseText)
                        if ( ans.error ) {
                            sendButton.color = UbuntuColors.red
                            messageInput.text = ans.error
                            if ( ans.message ) {
                                messageInput.text += ": " + ans.message
                            }
                        }
                    }
                }
                var approxExpire = new Date ()
                approxExpire.setUTCMinutes(approxExpire.getUTCMinutes()+10)
                req.send(JSON.stringify({
                    "appid" : pushClient.appId,
                    "expire_on": approxExpire.toISOString(),
                    "token": tokenInput.displayText,
                    "data": {
                        "notification": {
                            "card": {
                                "icon": "notification",
                                "summary": "Push Notification",
                                "body": messageInput.displayText,
                                "popup": true,
                                "persist": true
                            },
                            "vibrate": true,
                            "sound": true
                        }
                    }
                }))
            }
        }


        Button {
            id: yourTokenDescription
            text: i18n.tr("Copy your token to clipboard")
            anchors.bottom: yourToken.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: units.gu(1)
            width: parent.width - units.gu(2)
            color: UbuntuColors.green
            enabled: pushClient.token
            onClicked: {
                mimeData.text = pushClient.token
                Clipboard.push( mimeData )
                yourTokenDescription.color =  UbuntuColors.slate
            }
        }


        Label {
            id: yourToken
            text: i18n.tr("No token generated yet")
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: units.gu(1)
            width: parent.width - units.gu(2)
            wrapMode: Text.WordWrap
        }
    }

    MimeData {
        id: mimeData
        text: ""
    }


    PushClient {
        id: pushClient
        appId: "pushclient.christianpauly_pushclient"

        onError: {
            console.warn("👎 Error:",reason)
            if ( reason === "bad auth" ) {
                yourToken.text = i18n.tr("Please log in to Ubuntu One!")
            }
        }

        onTokenChanged: {
            console.log ( "👍 Token changed to:", pushClient.token )
            if ( pushClient.token ) {
                yourToken.text = pushClient.token
            }
            else {
                yourToken.text = i18n.tr("An error has occurred!")
            }
        }
    }

}
