import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: window
    width: 360
    height: 640
    visible: true
    title: "NPO Kolibri"
    color: "#212b36"

    property string displayValue: "0"
    property bool waitingForCode: false
    property bool isSecretMode: false // Состояние экрана

    // --- ЛОГИКА ---
    function handleInput(val) {
        if (val === "C") {
            displayValue = "0"
            waitingForCode = false
        } else if (val === "=") {
            try {
                let expression = displayValue.replace(/×/g, '*').replace(/÷/g, '/').replace(/,/g, '.')
                displayValue = String(eval(expression)).substring(0, 25)
            } catch (e) { displayValue = "Error" }
        } else {
            if (displayValue === "0" && val !== ",") displayValue = val
            else if (displayValue.length < 25) displayValue += val

            if (waitingForCode && displayValue.endsWith("123")) {
                waitingForCode = false
                isSecretMode = true // ПЕРЕКЛЮЧАЕМ ЭКРАН
            }
        }
    }

    // --- ОСНОВНОЙ ИНТЕРФЕЙС КАЛЬКУЛЯТОРА ---
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        visible: !window.isSecretMode // Виден, когда НЕ секрет

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.3
            color: "#54b1a3"
            Text {
                anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 20
                text: window.displayValue; color: "white"; font.pixelSize: 50
                fontSizeMode: Text.Fit; minimumPixelSize: 15
            }
        }

        GridLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; columns: 4; rowSpacing: 10; columnSpacing: 10; Layout.margins: 20
            Repeater {
                model: ["()", "+/-", "%", "÷", "7", "8", "9", "×", "4", "5", "6", "-", "1", "2", "3", "+", "C", "0", ",", "="]

                // Используем Rectangle вместо Button для полного контроля событий
                Rectangle {
                    id: btnRect
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: height / 2
                    color: (modelData === "=") ? "#fec331" : (["÷", "×", "-", "+"].indexOf(modelData) > -1) ? "#53677b" : "#333f4d"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: "white"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        // Настройка долгого нажатия
                        pressAndHoldInterval: 4000

                        onPressAndHold: {
                            if (modelData === "=") {
                                window.waitingForCode = true
                                secretTimer.start()
                                console.log("Удержание 4 сек сработало! Жду 123...")
                            }
                        }

                        onClicked: {
                            handleInput(modelData)
                            console.log("Нажато:", modelData)
                        }
                    }
                }
            }

        }
    }

    // --- ЭКРАН СЕКРЕТНОГО МЕНЮ ---
    Rectangle {
        id: secretScreen
        anchors.fill: parent
        color: "#212b36"
        visible: window.isSecretMode // Виден только в режиме секрета

        Column {
            anchors.centerIn: parent
            spacing: 30
            Text { text: "Секретное меню"; color: "white"; font.pixelSize: 32; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }

            // Кнопка Назад
            Rectangle {
                width: 200; height: 60; color: "#fec331"; radius: 30
                anchors.horizontalCenter: parent.horizontalCenter
                Text { anchors.centerIn: parent; text: "НАЗАД"; color: "black"; font.bold: true; font.pixelSize: 18 }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        window.isSecretMode = false // ВОЗВРАЩАЕМСЯ
                        window.displayValue = "0"
                    }
                }
            }
        }
    }

    Timer { id: secretTimer; interval: 5000; onTriggered: window.waitingForCode = false }
}

