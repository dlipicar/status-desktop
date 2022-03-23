import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: root

    property string displayName
    property string pubkey
    property string icon
    property bool isIdenticon: false

    property bool displayNameVisible: true
    property bool pubkeyVisible: true

    property alias imageWidth: userImage.imageWidth
    property alias imageHeight: userImage.imageHeight
    property size emojiSize: Qt.size(14, 14)
    property bool supersampling: true

    property alias imageOverlay: imageOverlay.sourceComponent

    signal clicked()

    height: visible ? contentContainer.height : 0
    implicitHeight: contentContainer.implicitHeight

    ColumnLayout {
        id: contentContainer

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Style.current.smallPadding
            rightMargin: Style.current.smallPadding
        }

        UserImage {
            id: userImage

            Layout.alignment: Qt.AlignHCenter

            name: root.displayName
            pubkey: root.pubkey
            icon: root.icon
            isIdenticon: root.isIdenticon
            showRing: true
            interactive: false

            Loader {
                id: imageOverlay
                anchors.fill: parent
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.displayNameVisible

            text: root.displayName

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 3
            wrapMode: Text.Wrap
            font {
                weight: Font.Medium
                pixelSize: Style.current.primaryTextFontSize
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.pubkeyVisible

            text: pubkey.substring(0, 10) + "..." + pubkey.substring(
                      pubkey.length - 4)

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.asideTextFontSize
            color: Style.current.secondaryText
        }

        Text {
            id: emojihash

            readonly property size finalSize: supersampling ? Qt.size(emojiSize.width * 2, emojiSize.height * 2) : emojiSize
            property string size: `${finalSize.width}x${finalSize.height}`

            Layout.fillWidth: true
            renderType: Text.NativeRendering
            scale: supersampling ? 0.5 : 1

            text: {
                const emojiHash = Utils.getEmojiHashAsJson(root.pubkey)
                var emojiHashFirstLine = ""
                var emojiHashSecondLine = ""
                for (var i = 0; i < 7; i++) {
                    emojiHashFirstLine += emojiHash[i]
                }
                for (var i = 7; i < emojiHash.length; i++) {
                    emojiHashSecondLine += emojiHash[i]
                }

                return StatusQUtils.Emoji.parse(emojiHashFirstLine, size) + "<br>" +
                       StatusQUtils.Emoji.parse(emojiHashSecondLine, size)
            }

            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 1 // make sure there is no padding for emojis due to 'style: "vertical-align: top"'
        }
    }
}
