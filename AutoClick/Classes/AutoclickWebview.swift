import UIKit
import WebKit

public enum ClickType: String {
    case click
    case multiclick
    case doubleclick
}

public class AutoTapWebView: WKWebView {
    public var tapInterval: TimeInterval = 1.0 {
        didSet {
            stopAutoClick()
        }
    }

    public var tapPoints: [CGPoint] = [] {
        didSet {
            stopAutoClick()
        }
    }

    // show highlight for debugging if need
    public var showHighlight: Bool = false {
        didSet {
            stopAutoClick()
        }
    }

    public var clickType: ClickType = .click {
        didSet {
            stopAutoClick()
        }
    }

    public var duration: Double = 60.0 {
        didSet {
            stopAutoClick()
        }
    }

    private var autoTapTimer: Timer?
    private var currentTime = 0.0

    public init(frame: CGRect, url: URL) {
        let webConfiguration = WKWebViewConfiguration()
        super.init(frame: frame, configuration: webConfiguration)
        self.load(URLRequest(url: url))
        self.loadJavaScript()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startAutoClick() {
        autoTapTimer = Timer.scheduledTimer(timeInterval: tapInterval, target: self, selector: #selector(autoClick), userInfo: nil, repeats: true)
    }

    public func stopAutoClick() {
        autoTapTimer?.invalidate()
        autoTapTimer = nil
        currentTime = 0.0
    }

    @objc private func autoClick() {
        currentTime += tapInterval
        guard currentTime <= duration else {
            stopAutoClick()
            return
        }

        var pointsString = ""
        if clickType != .multiclick {
            if let point = tapPoints.first {
                pointsString = "{x: \(point.x), y: \(point.y)}"
            }
        } else {
            pointsString = tapPoints.map { "{x: \($0.x), y: \($0.y)}" }.joined(separator: ", ")
        }

        let script = "autoClick([\n\(pointsString)\n], '\(clickType.rawValue)', \(showHighlight));"

        self.evaluateJavaScript(script, completionHandler: { (result, error) in
            if let error = error {
                print("Error executing JavaScript: \(error.localizedDescription)")
            }
        })
    }

    private func loadJavaScript() {
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(userScript)
    }
}

fileprivate let scriptContent = """
    function autoClick(points, eventType, showHighlight) {
    points.forEach(point => {
        var event;
        if (eventType === "click" || eventType === "multiclick" ) {
            event = new MouseEvent('click', {
                view: window,
                bubbles: true,
                cancelable: true,
                clientX: point.x,
                clientY: point.y
            });
        } else if (eventType === "doubleclick") {
            event = new MouseEvent('dblclick', {
                view: window,
                bubbles: true,
                cancelable: true,
                clientX: point.x,
                clientY: point.y
            });
        }

        var elem = document.elementFromPoint(point.x, point.y);
        if (elem) {
            elem.dispatchEvent(event);
        } else {
            document.dispatchEvent(event);
        }

        if (showHighlight) {
            var highlight = document.createElement('div');
            highlight.style.position = 'absolute';
            highlight.style.width = '20px';
            highlight.style.height = '20px';
            highlight.style.backgroundColor = 'red';
            highlight.style.borderRadius = '50%';
            highlight.style.left = (point.x - 10) + 'px';
            highlight.style.top = (point.y - 10) + 'px';
            highlight.style.pointerEvents = 'none'; // ensure highlight does not block the click
            document.body.appendChild(highlight);

            setTimeout(function() {
                highlight.remove();
            }, 200); // thời gian highlight
        }
    });
}
"""

