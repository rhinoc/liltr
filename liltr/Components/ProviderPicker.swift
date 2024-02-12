import Foundation
import SwiftUI

struct ProviderPicker: View {
    @Binding var prividerName: String

    var body: some View {
        Picker(selection: $prividerName) {
            ForEach(PROVIDER_ARRAY, id: \.name) { provider in
                Text("\(provider.name)").tag(provider.name)
            }
        } label: {}
            .frame(width: 200)
    }
}
