import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
     \qmltype StatusTagSelector
     \inherits Item
     \inqmlmodule StatusQ.Components
     \since StatusQ.Components 0.1
     \brief Displays a tag selector component together with a list of where to select and add the tags from.
     Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

     The \c StatusTagSelector displays a list of asorted elements together with a text input where tags are added. As the user
     types some text, the list elements are filtered and if the user selects any of those a new tag is created.
     For example:

     \qml
     StatusTagSelector {
        width: 650
        height: 44
        anchors.centerIn: parent
        namesModel: ListModel {
            ListElement {
                publicId: "0x0"
                name: "Maria"
                icon: ""
                isIdenticon: false
                onlineStatus: 3
            }
            ListElement {
                publicId: "0x1"
                name: "James"
                icon: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                isIdenticon: false
                onlineStatus: 1
            }
            ListElement {
                publicId: "0x2"
                name: "Paul"
                icon: ""
                isIdenticon: false
                onlineStatus: 2
            }
        }
        toLabelText: qsTr("To: ")
        warningText: qsTr("USER LIMIT REACHED")
     }
     \endqml

     \image status_tag_selector.png

     For a list of components available see StatusQ.
  */

Item {
    id: root

    implicitWidth: 448
    implicitHeight: (104 + contactsLabel.height + contactsLabel.anchors.topMargin + (userListView.model.count * 64)) > root.maxHeight ? root.maxHeight :
                    (104 + contactsLabel.height + contactsLabel.anchors.topMargin + (userListView.model.count * 64))

    /*!
        \qmlproperty real StatusTagSelector::maxHeight
        This property holds the maximum height of the component.
    */
    property real maxHeight: (488 + contactsLabel.height + contactsLabel.anchors.topMargin) //default min
    /*!
        \qmlproperty alias StatusTagSelector::textEdit
        This property holds a reference to the TextEdit component.
    */
    property alias textEdit: edit
    /*!
        \qmlproperty alias StatusTagSelector::text
        This property holds a reference to the TextEdit's text property.
    */
    property alias text: edit.text
    /*!
        \qmlproperty string StatusTagSelector::warningText
        This property sets the warning text.
    */
    property string warningText: ""
    /*!
        \qmlproperty string StatusTagSelector::toLabelText
        This property sets the 'to' label text.
    */
    property string toLabelText: ""
    /*!
        \qmlproperty string StatusTagSelector::listLabel
        This property sets the elements list label text.
    */
    property string listLabel: ""
    /*!
        \qmlproperty int StatusTagSelector::nameCountLimit
        This property sets the tags count limit.
    */
    property int nameCountLimit: 5
    /*!
        \qmlproperty ListModel StatusTagSelector::sortedList
        This property holds the sorted list model.
    */
    property ListModel sortedList: ListModel { }
    /*!
        \qmlproperty ListModel StatusTagSelector::namesModel
        This property holds the asorted names model.
    */
    property ListModel namesModel: ListModel { }

    /*!
        \qmlmethod
        This function is used to find an entry in a model.
    */
    function find(model, criteria) {
        for (var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i);
        return null;
    }

    /*!
        \qmlmethod
        This function is used to insert a new tag.
    */
    function insertTag(name, id) {
        if (!find(namesModel, function(item) { return item.publicId === id }) && namesModel.count < root.nameCountLimit) {
            namesModel.insert(namesModel.count, {"name": name, "publicId": id});
            addMember(id);
            edit.clear();
        }
    }

    /*!
        \qmlmethod
        This function is used to sort the source model.
    */
    function sortModel(inputModel) {
        sortedList.clear();
        if (text !== "") {
            for (var i = 0; i < inputModel.count; i++ ) {
                var entry = inputModel.get(i);
                if (entry.name.toLowerCase().includes(text.toLowerCase())) {
                    sortedList.append({"publicId": entry.publicId, "name": entry.name,
                                       "icon": entry.icon, "isIdenticon": entry.isIdenticon,
                                       "onlineStatus": entry.onlineStatus});
                    userListView.model = sortedList;
                }
            }
        } else {
            userListView.model = inputModel;
        }
    }

    /*!
        \qmlsignal
        This signal is emitted when a new tag is created.
    */
    signal addMember(string memberId)

    /*!
        \qmlsignal
        This signal is emitted when a tag is removed.
    */
    signal removeMember(string memberId)

    Rectangle {
        id: tagSelectorRect
        width: parent.width
        height: 44
        radius: 8
        color: Theme.palette.baseColor2
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8
            StatusBaseText {
                Layout.preferredWidth: 22
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                color: Theme.palette.baseColor1
                text: root.toLabelText
            }

            ScrollView {
                Layout.preferredWidth: (namesList.contentWidth > (parent.width - 177)) ?
                                       (parent.width - 177) : namesList.contentWidth
                implicitHeight: 30
                Layout.alignment: Qt.AlignVCenter
                visible: (namesList.count > 0)
                contentWidth: namesList.contentWidth
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                clip: true
                ListView {
                    id: namesList
                    anchors.fill: parent
                    model: namesModel
                    orientation: ListView.Horizontal
                    spacing: 8
                    function scrollToEnd() {
                        if (contentWidth > width) {
                            contentX = contentWidth;
                        }
                    }
                    onWidthChanged: { scrollToEnd(); }
                    onCountChanged: { scrollToEnd(); }
                    delegate: Rectangle {
                        id: nameDelegate
                        width: (nameText.contentWidth + 34)
                        height: 30
                        color: mouseArea.containsMouse ? Theme.palette.miscColor1 : Theme.palette.primaryColor1
                        radius: 8
                        StatusBaseText {
                            id: nameText
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.palette.indirectColor1
                            text: name
                        }
                        StatusIcon {
                            anchors.left: nameText.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.palette.indirectColor1
                            icon: "close"
                        }
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                removeMember(publicId);
                                namesModel.remove(index, 1);
                            }
                        }
                    }
                }
            }

            TextInput {
                id: edit
                verticalAlignment: Text.AlignVCenter
                focus: true
                color: Theme.palette.directColor1
                clip: true
                font.pixelSize: 15
                wrapMode: TextEdit.NoWrap
                font.family: Theme.palette.baseFont.name
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Keys.onPressed: {
                    if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Escape)
                            && getText(cursorPosition, (cursorPosition-1)) === ""
                            && (namesList.count-1) >= 0) {
                        removeMember(namesModel.get(namesList.count-1).publicId);
                        namesModel.remove((namesList.count-1), 1);
                    }
                    if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && (sortedList.count > 0)) {
                        root.insertTag(sortedList.get(userListView.currentIndex).name, sortedList.get(userListView.currentIndex).publicId);
                    }
                }
                Keys.onUpPressed: { userListView.decrementCurrentIndex(); }
                Keys.onDownPressed: { userListView.incrementCurrentIndex(); }
            }

            StatusBaseText {
                id: warningTextLabel
                visible: (namesModel.count === root.nameCountLimit)
                Layout.preferredWidth: visible ? 120 : 0
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                font.pixelSize: 10
                color: Theme.palette.dangerColor1
                text: root.nameCountLimit + " " + root.warningText
            }
        }
    }

    StatusBaseText {
        id: contactsLabel
        font.pixelSize: 15
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: tagSelectorRect.bottom
        anchors.topMargin: visible ? 32 : 0
        height: visible ? contentHeight : 0
        visible: (root.sortedList.count === 0)
        color: Theme.palette.baseColor1
        text: root.listLabel
    }

    Control {
        id: suggestionsContainer
        width: 360
        anchors {
            top: (root.sortedList.count > 0) ? tagSelectorRect.bottom : contactsLabel.bottom
            topMargin: 8//Style.current.halfPadding
            bottom: parent.bottom
            bottomMargin: 16//Style.current.padding
        }
        clip: true
        visible: ((edit.text === "") || (root.sortedList.count > 0))
        x: ((root.namesModel.count > 0) && (root.sortedList.count > 0) && ((edit.x + 8) <= (root.width - suggestionsContainer.width)))
           ? (edit.x + 8) : 0
        background: Rectangle {
            id: bgRect
            anchors.fill: parent
            visible: (root.sortedList.count > 0)
            color: Theme.palette.statusPopupMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                width: bgRect.width
                height: bgRect.height
                x: bgRect.x
                source: bgRect
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                spread: 0.2
                color: Theme.palette.dropShadow
            }
        }
        contentItem: ListView {
            id: userListView
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            clip: true
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
            boundsBehavior: Flickable.StopAtBounds
            onCountChanged: {
                userListView.currentIndex = 0;
            }
            delegate: Item {
                id: wrapper
                anchors.right: parent.right
                anchors.left: parent.left
                height: 64
                Rectangle {
                    id: rectangle
                    anchors.fill: parent
                    anchors.rightMargin: 8
                    anchors.leftMargin: 8
                    radius: 8
                    visible: (root.sortedList.count > 0)
                    color: (userListView.currentIndex === index) ? Theme.palette.baseColor2 : "transparent"
                }

                StatusSmartIdenticon {
                    id: contactImage
                    anchors.left: parent.left
                    anchors.leftMargin: 16//Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    name: model.name
                    icon: StatusIconSettings {
                        width: 40
                        height: 40
                        letterSize: 15
                    }
                    image: StatusImageSettings {
                        width: 40
                        height: 40
                        source: model.icon
                        isIdenticon: model.isIdenticon
                    }
                }

                StatusBaseText {
                    id: contactInfo
                    text: model.name
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.left: contactImage.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    color: Theme.palette.directColor1
                    font.weight: Font.Medium
                    font.pixelSize: 15
                }

                MouseArea {
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        userListView.currentIndex = index;
                    }
                    onClicked: {
                        root.insertTag(model.name, model.publicId);
                    }
                }
            }
        }
    }
}
