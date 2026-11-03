import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtMultimedia

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#06080d"

    // Theme Configuration Values
    readonly property color accentColor: "#00f2fe"
    readonly property color secondaryColor: "#9d4edd"
    readonly property color cardBgColor: Qt.rgba(0.06, 0.08, 0.13, 0.82)
    readonly property color inputBgColor: Qt.rgba(1.0, 1.0, 1.0, 0.06)
    readonly property color textMainColor: "#ffffff"
    readonly property color textDimColor: "#94a3b8"
    readonly property color errorColor: "#ff4d6d"

    property int currentSessionIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property string activeUser: (typeof userModel !== "undefined" && userModel.lastUser.length > 0) ? userModel.lastUser : "shazin"
    property bool isLoggingIn: false
    property bool hasLoginError: false
    property bool isCapsLockOn: false

    // -------------------------------------------------------------
    // 1. VIDEO BACKGROUND (Pristine Original 4K Quality, Zero Blur, Zero Tint)
    // -------------------------------------------------------------
    MediaPlayer {
        id: bgPlayer
        source: Qt.resolvedUrl("assets/background.mp4")
        audioOutput: null // Silent playback
        loops: MediaPlayer.Infinite
        videoOutput: bgVideoOutput
        Component.onCompleted: {
            bgPlayer.play()
        }
    }

    VideoOutput {
        id: bgVideoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        visible: bgPlayer.playbackState !== MediaPlayer.StoppedState
    }

    // Fallback static wallpaper if video is absent or stopped
    Image {
        id: bgImage
        anchors.fill: parent
        source: "assets/background.jpg"
        fillMode: Image.PreserveAspectCrop
        visible: !bgVideoOutput.visible
        asynchronous: true
    }

    // -------------------------------------------------------------
    // 2. DYNAMIC AURORA GLOW (Fallback only when NO video is playing)
    // -------------------------------------------------------------
    Item {
        id: auroraContainer
        anchors.fill: parent
        visible: !bgVideoOutput.visible

        // Orb 1: Cyan orb floating top-left to center
        Rectangle {
            id: orb1
            width: 480
            height: 480
            radius: 240
            color: root.accentColor
            opacity: 0.22
            x: root.width * 0.25
            y: root.height * 0.2

            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: root.width * 0.35; duration: 9000; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.width * 0.25; duration: 9000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: root.height * 0.35; duration: 7500; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.height * 0.2; duration: 7500; easing.type: Easing.InOutSine }
            }
        }

        // Orb 2: Violet/Purple orb floating center-right
        Rectangle {
            id: orb2
            width: 520
            height: 520
            radius: 260
            color: root.secondaryColor
            opacity: 0.24
            x: root.width * 0.55
            y: root.height * 0.35

            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: root.width * 0.45; duration: 11000; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.width * 0.55; duration: 11000; easing.type: Easing.InOutSine }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: root.height * 0.25; duration: 8500; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.height * 0.35; duration: 8500; easing.type: Easing.InOutSine }
            }
        }

        // Orb 3: Deep Magenta accent orb floating at the bottom
        Rectangle {
            id: orb3
            width: 420
            height: 420
            radius: 210
            color: "#e100ff"
            opacity: 0.16
            x: root.width * 0.4
            y: root.height * 0.55

            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: root.width * 0.5; duration: 13000; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.width * 0.4; duration: 13000; easing.type: Easing.InOutSine }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 64
        }
    }

    // -------------------------------------------------------------
    // 3. TOP CLOCK & DATE
    // -------------------------------------------------------------
    Item {
        id: clockContainer
        width: parent.width
        height: 140
        anchors.top: parent.top
        anchors.topMargin: root.height > 900 ? 70 : 30

        Timer {
            id: clockTimer
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var d = new Date()
                timeText.text = Qt.formatTime(d, "hh:mm")
                dateText.text = Qt.formatDate(d, "dddd, MMMM d")
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Text {
                id: timeText
                text: "19:30"
                color: root.textMainColor
                font.pixelSize: root.height > 900 ? 58 : 46
                font.weight: Font.DemiBold
                font.letterSpacing: 2
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.7)
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: dateText
                text: "Tuesday, November 3"
                color: "#e2e8f0"
                font.pixelSize: 15
                font.weight: Font.Normal
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.7)
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // -------------------------------------------------------------
    // 4. MINIMALIST PASSWORD BAR (Positioned right above bottom dock by default, draggable anywhere)
    // -------------------------------------------------------------
    Item {
        id: cardWrapper
        width: 360
        height: 105
        x: Math.round((root.width - width) / 2)
        y: Math.round(root.height - 100 - height)

        property real shakeOffset: 0
        transform: Translate { x: cardWrapper.shakeOffset }

        // Fluid drag gesture
        DragHandler {
            id: dragHandler
            target: cardWrapper
            xAxis.minimum: 20
            xAxis.maximum: root.width - cardWrapper.width - 20
            yAxis.minimum: 20
            yAxis.maximum: root.height - cardWrapper.height - 20
            cursorShape: dragHandler.active ? Qt.ClosedHandCursor : Qt.ArrowCursor
        }

        // Horizontal shake animation on failed password
        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: cardWrapper; property: "shakeOffset"; from: 0; to: -16; duration: 55; easing.type: Easing.OutQuad }
            NumberAnimation { target: cardWrapper; property: "shakeOffset"; from: -16; to: 16; duration: 55; easing.type: Easing.InOutQuad }
            NumberAnimation { target: cardWrapper; property: "shakeOffset"; from: 16; to: -10; duration: 50; easing.type: Easing.InOutQuad }
            NumberAnimation { target: cardWrapper; property: "shakeOffset"; from: -10; to: 10; duration: 50; easing.type: Easing.InOutQuad }
            NumberAnimation { target: cardWrapper; property: "shakeOffset"; from: 10; to: 0; duration: 50; easing.type: Easing.OutQuad }
        }

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            spacing: 8

            // Simple username text on top of the password box
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4

                Text {
                    id: userNameText
                    text: root.activeUser
                    color: root.textMainColor
                    font.pixelSize: 18
                    font.bold: true
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.75)
                }

                Item { Layout.fillWidth: true }

                // Small Caps Lock indicator
                Rectangle {
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: 105
                    radius: 10
                    color: Qt.rgba(1.0, 0.7, 0.0, 0.25)
                    border.color: "#fbbf24"
                    border.width: 1
                    visible: root.isCapsLockOn

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Image {
                            source: "assets/icons/lock.svg"
                            sourceSize: Qt.size(10, 10)
                        }

                        Text {
                            text: "Caps Lock"
                            color: "#fbbf24"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            // Sleek Floating Password Rectangle
            Rectangle {
                id: inputFieldContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 16
                color: Qt.rgba(0.06, 0.08, 0.13, 0.75)
                border.color: root.hasLoginError ? root.errorColor : (passwordInput.activeFocus ? root.accentColor : Qt.rgba(1, 1, 1, 0.22))
                border.width: root.hasLoginError || passwordInput.activeFocus ? 1.5 : 1.0

                Behavior on border.color { ColorAnimation { duration: 200 } }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowBlur: 0.6
                    shadowVerticalOffset: 4
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 8
                    spacing: 8

                    Image {
                        source: "assets/icons/lock.svg"
                        sourceSize: Qt.size(17, 17)
                        opacity: passwordInput.activeFocus ? 0.9 : 0.5
                    }

                    TextField {
                        id: passwordInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        echoMode: showPasswordToggle.showPassword ? TextInput.Normal : TextInput.Password
                        placeholderText: "Password"
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                        color: root.textMainColor
                        font.pixelSize: 15
                        focus: true
                        verticalAlignment: TextInput.AlignVCenter
                        background: Item {}

                        onTextChanged: {
                            if (root.hasLoginError) root.hasLoginError = false
                        }

                        Keys.onPressed: (event) => {
                            root.isCapsLockOn = (event.modifiers & Qt.ShiftModifier) === 0 && event.text.length === 1 && event.text.toUpperCase() === event.text && event.text.toLowerCase() !== event.text
                        }

                        onAccepted: doLogin()
                    }

                    // Show / Hide Password Eye Button
                    Item {
                        id: showPasswordToggle
                        property bool showPassword: false
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32

                        Image {
                            anchors.centerIn: parent
                            source: showPasswordToggle.showPassword ? "assets/icons/eye-off.svg" : "assets/icons/eye.svg"
                            sourceSize: Qt.size(18, 18)
                            opacity: eyeMouseArea.containsMouse ? 0.95 : 0.5
                        }

                        MouseArea {
                            id: eyeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showPasswordToggle.showPassword = !showPasswordToggle.showPassword
                        }
                    }

                    // Submit Arrow Button
                    Rectangle {
                        id: submitBtn
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 12
                        color: submitMouseArea.containsMouse ? root.accentColor : Qt.rgba(0.0, 0.95, 1.0, 0.2)
                        border.color: root.accentColor
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Image {
                            anchors.centerIn: parent
                            source: "assets/icons/arrow-right.svg"
                            sourceSize: Qt.size(15, 15)
                        }

                        MouseArea {
                            id: submitMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: doLogin()
                        }
                    }
                }
            }

            // Error Message (Compact below password box)
            Text {
                id: errorLabel
                Layout.alignment: Qt.AlignHCenter
                text: "Incorrect password. Please try again."
                color: root.errorColor
                font.pixelSize: 12
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.8)
                opacity: root.hasLoginError ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    // -------------------------------------------------------------
    // 5. BOTTOM FLOATING BAR (Session Selector + Power Actions)
    // -------------------------------------------------------------
    Rectangle {
        id: bottomDock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.horizontalCenter: parent.horizontalCenter
        height: 52
        width: dockRow.width + 36
        radius: 26
        color: Qt.rgba(0.06, 0.08, 0.13, 0.85)
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.4)
            shadowBlur: 0.6
            shadowVerticalOffset: 6
        }

        RowLayout {
            id: dockRow
            anchors.centerIn: parent
            spacing: 14

            // Session Selector Button
            Rectangle {
                id: sessionPill
                Layout.preferredHeight: 36
                Layout.preferredWidth: sessionLabel.implicitWidth + 30
                radius: 18
                color: sessionMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.15)
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        id: sessionLabel
                        text: {
                            if (typeof sessionModel !== "undefined" && sessionModel.count > 0 && root.currentSessionIndex < sessionModel.count) {
                                var sName = sessionModel.data(sessionModel.index(root.currentSessionIndex, 0), Qt.DisplayRole)
                                return sName ? sName : "Plasma (Wayland)"
                            }
                            return "Plasma (Wayland)"
                        }
                        color: root.textMainColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                MouseArea {
                    id: sessionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (typeof sessionModel !== "undefined" && sessionModel.count > 1) {
                            root.currentSessionIndex = (root.currentSessionIndex + 1) % sessionModel.count
                        }
                    }
                }
            }

            // Divider line
            Rectangle {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            // Sleep Button
            Rectangle {
                id: sleepBtn
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: sleepMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "assets/icons/sleep.svg"
                    sourceSize: Qt.size(18, 18)
                }

                MouseArea {
                    id: sleepMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (typeof sddm !== "undefined") sddm.suspend()
                }

                ToolTip.visible: sleepMouse.containsMouse
                ToolTip.text: "Sleep / Suspend"
            }

            // Restart Button
            Rectangle {
                id: restartBtn
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: restartMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "assets/icons/restart.svg"
                    sourceSize: Qt.size(18, 18)
                }

                MouseArea {
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (typeof sddm !== "undefined") sddm.reboot()
                }

                ToolTip.visible: restartMouse.containsMouse
                ToolTip.text: "Restart"
            }

            // Power Off Button
            Rectangle {
                id: powerBtn
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: powerMouse.containsMouse ? Qt.rgba(1.0, 0.3, 0.3, 0.25) : "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "assets/icons/power.svg"
                    sourceSize: Qt.size(18, 18)
                }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (typeof sddm !== "undefined") sddm.powerOff()
                }

                ToolTip.visible: powerMouse.containsMouse
                ToolTip.text: "Shut Down"
            }
        }
    }

    // -------------------------------------------------------------
    // 6. LOGIN FUNCTION & SDDM SIGNAL HANDLERS
    // -------------------------------------------------------------
    function doLogin() {
        if (passwordInput.text.length === 0) {
            shakeAnim.start()
            return
        }
        root.isLoggingIn = true
        root.hasLoginError = false
        if (typeof sddm !== "undefined") {
            sddm.login(root.activeUser, passwordInput.text, root.currentSessionIndex)
        } else {
            console.log("Mock login triggered for:", root.activeUser, "with session:", root.currentSessionIndex)
        }
    }

    // SDDM Integration
    Connections {
        target: typeof sddm !== "undefined" ? sddm : null

        function onLoginFailed() {
            root.isLoggingIn = false
            root.hasLoginError = true
            shakeAnim.start()
            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.isLoggingIn = false
            root.opacity = 0.0
        }
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus()
    }

    // Esc key clears password input
    Shortcut {
        sequence: "Esc"
        onActivated: {
            if (passwordInput.text.length > 0) {
                passwordInput.text = ""
            }
        }
    }
}

