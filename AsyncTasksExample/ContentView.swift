import os
import SwiftUI

class ExampleModel: ObservableObject {
    @Published var result: [String: Int]?
    let terms = "Corona,Klima,Wahl".components(separatedBy: ",")

    func countTermsFor(url: URL) async throws -> [String: Int] {
        let data = try await URLSession.shared.data(from: url).0
        return self.countTerms(string: data.html2String, terms: self.terms)
    }

    func refresh() async throws {
        print("Getting term count for Spiegel")
        let termCountSpiegel = try await countTermsFor(url: URL(string: "https://www.spiegel.de/")!)
        print("term count for spiegel.de: ", termCountSpiegel)

        await self.updateResults(termCountSpiegel)
    }

    func countTerms(string: String, terms: [String]) -> [String: Int] {
        var result = [String: Int]()
        let string = string.lowercased()
        for term in terms {
            result[term] = string.countOccurences(of: term.lowercased())
        }
        return result
    }

    @MainActor func updateResults(_ result: [String: Int]) {
        self.result = result
    }
}

struct ContentView: View {
    @StateObject var model = ExampleModel()
    @State var inProgress = false

    var body: some View {
        List {
            if let result = model.result {
                ForEach(Array(result).sorted(by: { $0.value > $1.value }), id: \.key) { term, count in
                    VStack(alignment: .leading) {
                        Text(term)
                            .font(.title)
                            .bold()
                        Text("\(count)×")
                            .font(.footnote)
                    }
                }
            }
        }
        .refreshable {
            await self.refresh()
        }
        .task {
            await self.refresh()
        }
    }

    func refresh() async {
        do {
            try await self.model.refresh()
        } catch {
            os_log("Error during refresh: %@", type: .error, error.localizedDescription)
        }
    }
}
