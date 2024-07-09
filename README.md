# AutoClicker

A webview autoclicker pod

### Install

pod 'AutoClick', :path => "AutoClick"

### How to use AutoTapWebView:

let autoTapWebView = AutoTapWebView(frame: view.bounds, url: url)

autoTapWebView.tapInterval = 1.0

autoTapWebView.tapPoints = [CGPoint(x: 100, y: 400), CGPoint(x: 180, y: 400)]

autoTapWebView.showHighlight = true

autoTapWebView.clickType = .multiclick

autoTapWebView.duration = 10.0

view.addSubview(autoTapWebView)

autoTapWebView.startAutoClick()

