import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.views 1.0
import shared.controls 1.0

import "../stores"

Item {
    id: root

    property var token

    QtObject {
        id: d
        property var marketValueStore : RootStore.marketValueStore
    }

    Connections {
        target: walletSectionAllTokens
        onTokenHistoricalDataReady: {
            let response = JSON.parse(tokenDetails)
            if (response === null) {
                console.debug("error parsing message for tokenHistoricalDataReady: error: ", response.error)
                return
            }
            if(response.historicalData === null || response.historicalData <= 0)
                return

            d.marketValueStore.setTimeAndValueData(response.historicalData, response.range)
        }
    }

    AssetsDetailsHeader {
        id: tokenDetailsHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        width: parent.width
        asset.name: token && token.symbol ? Style.png("tokens/%1".arg(token.symbol)) : ""
        asset.isImage: true
        primaryText: token ? token.name : ""
        secondaryText: token ? `${token.enabledNetworkBalance} ${token.symbol}` : ""
        tertiaryText: token ? "%1 %2".arg(Utils.toLocaleString(token.enabledNetworkCurrencyBalance.toFixed(2), RootStore.locale, {"currency": true})).arg(RootStore.currencyStore.currentCurrency.toUpperCase()) : ""
        balances: token && token.balances ? token.balances :  null
        getNetworkColor: function(chainId){
            return RootStore.getNetworkColor(chainId)
        }
        getNetworkIcon: function(chainId){
            return RootStore.getNetworkIcon(chainId)
        }
    }

    Loader {
        id: graphDetailLoader
        width: parent.width
        height: 290
        anchors.top: tokenDetailsHeader.bottom
        anchors.topMargin: 24
        active: root.visible
        sourceComponent: StatusChartPanel {
            id: graphDetail
            graphsModel: d.marketValueStore.graphTabsModel
            defaultTimeRangeIndexShown: TokenMarketValuesStore.TimeRange.All
            timeRangeModel: d.marketValueStore.timeRangeTabsModel
            onHeaderTabClicked: chart.animateToNewData()
            chart.chartType: 'line'
            chart.chartData: {
                return {
                    labels: d.marketValueStore.timeRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange],
                    datasets: [{
                            xAxisId: 'x-axis-1',
                            yAxisId: 'y-axis-1',
                            backgroundColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 0.2)' : 'rgba(67, 96, 223, 0.2)',
                            borderColor: (Theme.palette.name === "dark") ? 'rgba(136, 176, 255, 1)' : 'rgba(67, 96, 223, 1)',
                            borderWidth: 3,
                            pointRadius: 0,
                            data: d.marketValueStore.dataRange[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange],
                            parsing: false,
                        }]
                }
            }

            chart.chartOptions: {
                return {
                    maintainAspectRatio: false,
                    responsive: true,
                    legend: {
                        display: false
                    },
                    //TODO enable zoom
                    //zoom: {
                    //  enabled: true,
                    //  drag: true,
                    //  speed: 0.1,
                    //  threshold: 2
                    //},
                    //pan:{enabled:true,mode:'x'},
                    tooltips: {
                        intersect: false,
                        displayColors: false,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                let label = data.datasets[tooltipItem.datasetIndex].label || '';
                                if (label) {
                                    label += ': ';
                                }
                                label += tooltipItem.yLabel.toFixed(2);
                                return label.slice(0,label.indexOf(":")+1) + " %1".arg(RootStore.currencyStore.currentCurrencySymbol) + label.slice(label.indexOf(":") + 2, label.length);
                            }
                        }
                    },
                    scales: {
                        xAxes: [{
                                id: 'x-axis-1',
                                position: 'bottom',
                                gridLines: {
                                    drawOnChartArea: false,
                                    drawBorder: false,
                                    drawTicks: false,
                                },
                                ticks: {
                                    fontSize: 10,
                                    fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                                    padding: 16,
                                    maxRotation: 0,
                                    minRotation: 0,
                                    maxTicksLimit:  d.marketValueStore.maxTicks[graphDetail.timeRangeTabBarIndex][graphDetail.selectedTimeRange],
                                },
                            }],
                        yAxes: [{
                                position: 'left',
                                id: 'y-axis-1',
                                gridLines: {
                                    borderDash: [8, 4],
                                    drawBorder: false,
                                    drawTicks: false,
                                    color: (Theme.palette.name === "dark") ? '#909090' : '#939BA1'
                                },
                                beforeDataLimits: (axis) => {
                                    axis.paddingTop = 25;
                                    axis.paddingBottom = 0;
                                },
                                ticks: {
                                    fontSize: 10,
                                    fontColor: (Theme.palette.name === "dark") ? '#909090' : '#939BA1',
                                    padding: 8,
                                    callback: function(value, index, ticks) {
                                        return LocaleUtils.numberToLocaleString(value)
                                    },
                                }
                            }]
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.top: graphDetailLoader.bottom
        anchors.topMargin: 24
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        width: parent.width

        spacing: Style.current.padding

        RowLayout {
            Layout.fillWidth: true
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Market Cap")
                secondaryText: token && token.marketCap !== "" ? token.marketCap : "---"
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day Low")
                secondaryText: token && token.lowDay !== "" ? token.lowDay : "---"
            }
            InformationTile {
                maxWidth: parent.width
                primaryText: qsTr("Day High")
                secondaryText: token && token.highDay ? token.highDay : "---"
            }
            Item {
                Layout.fillWidth: true
            }
            InformationTile {
                readonly property string changePctHour: token ? token.changePctHour : ""
                maxWidth: parent.width
                primaryText: qsTr("Hour")
                secondaryText: changePctHour ? "%1%".arg(changePctHour) : "---"
                secondaryLabel.color: Math.sign(Number(changePctHour)) === 0 ? Theme.palette.directColor1 :
                                                                               Math.sign(Number(changePctHour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                         Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePctDay: token ? token.changePctDay : ""
                maxWidth: parent.width
                primaryText: qsTr("Day")
                secondaryText: changePctDay ? "%1%".arg(changePctDay) : "---"
                secondaryLabel.color: Math.sign(Number(changePctDay)) === 0 ? Theme.palette.directColor1 :
                                                                              Math.sign(Number(changePctDay)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                       Theme.palette.successColor1
            }
            InformationTile {
                readonly property string changePct24hour: token ? token.changePct24hour : ""
                maxWidth: parent.width
                primaryText: qsTr("24 Hours")
                secondaryText: changePct24hour ? "%1%".arg(changePct24hour) : "---"
                secondaryLabel.color: Math.sign(Number(changePct24hour)) === 0 ? Theme.palette.directColor1 :
                                                                                 Math.sign(Number(changePct24hour)) === -1 ? Theme.palette.dangerColor1 :
                                                                                                                             Theme.palette.successColor1
            }
        }

        StatusTabBar {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Overview")
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            StatusScrollView {
                id: scrollView
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                topPadding: 8
                bottomPadding: 8
                Flow {
                    id: detailsFlow

                    readonly property bool isOverflowing:  detailsFlow.width - tagsLayout.width - tokenDescriptionText.width < 24

                    spacing: 24

                    width: scrollView.availableWidth
                    StatusBaseText {
                        id: tokenDescriptionText
                        width: Math.max(536 , scrollView.availableWidth - tagsLayout.width - 24)

                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        text: token ? token.description : ""
                        color: Theme.palette.directColor1
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        textFormat: Qt.RichText
                    }
                    ColumnLayout {
                        id: tagsLayout
                        spacing: 10
                        InformationTag {
                            id: website
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight
                            iconAsset.icon: "browser"
                            tagPrimaryLabel.text: qsTr("Website")
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.assetWebsiteUrl !== ""
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Global.openLink(token.assetWebsiteUrl)
                            }
                        }
                        InformationTag {
                            id: smartContractAddress
                            Layout.alignment: detailsFlow.isOverflowing ? Qt.AlignLeft : Qt.AlignRight

                            image.source: token  && token.builtOn !== "" ? Style.svg("tiny/" + RootStore.getNetworkIconUrl(token.builtOn)) : ""
                            tagPrimaryLabel.text: token && token.builtOn !== "" ? RootStore.getNetworkName(token.builtOn) : "---"
                            tagSecondaryLabel.text: token && token.smartContractAddress !== "" ? token.smartContractAddress : "---"
                            controlBackground.color: Theme.palette.baseColor2
                            controlBackground.border.color: "transparent"
                            visible: token && token.builtOn !== "" && token.smartContractAddress !== ""
                        }
                    }
                }
            }
        }
    }
}
