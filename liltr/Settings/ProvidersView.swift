import SwiftUI

struct ProviderKeyField: View {
    let label: String
    let icon: String

    @Binding var ak: String
    @Binding var sk: String
    
    private var disableAK: Bool

    init(label: String, icon: String, ak: Binding<String>? = nil, sk: Binding<String>) {
        self.label = label
        self.icon = icon
        self._sk = sk
        
        if let ak = ak {
            self._ak = ak
            disableAK = false
        } else {
            self._ak = Binding.constant("")
            disableAK = true
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AlignedText(text: "Access Key (AK)", width: 120)
                TextField("Access Key ID", text: $ak)
                    .frame(width: 200)
                    .disabled(disableAK)
            }
            
            HStack {
                AlignedText(text: "Secret Key (SK)", width: 120)
                SecureField("Secret Key", text: $sk)
                    .frame(width: 200)

            }
            Spacer()
        }.tabItem {
            Label(label, systemImage: icon)
        }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
}

struct ProvidersView: View {
    @Default(\.primaryProvider) var primaryProvider
    @Default(\.secondaryProvider) var secondaryProvider

    @Default(\.NiuTransSK) var niuTransSK

    @Default(\.BaiduAK) var baiduAK
    @Default(\.BaiduSK) var baiduSK

    @Default(\.VolcengineAK) var volcengineAK
    @Default(\.VolcengineSK) var volcengineSK

    @Default(\.AliAK) var aliAK
    @Default(\.AliSK) var aliSK

    @Default(\.BigHugeThesaurusSK) var bigHugeThesaurusSK
    
    @Default(\.dictionary) var dictionary

    private let _gapSize: CGFloat = 8

    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                HStack {
                    AlignedText(text: "Primary Provider")
                    ProviderPicker(prividerName: $primaryProvider)
                }
                HStack {
                    AlignedText(text: "Secondary Provider")
                    ProviderPicker(prividerName: $secondaryProvider)
                }
                HStack {
                    AlignedText(text: "Dictionary")
                    Picker(selection: $dictionary) {
                        ForEach(AppleDictionaryProvider.shared.getDictionaries(), id: \.self) { dictName in
                            Text("\(dictName)").tag(dictName)
                        }
                    } label: {}
                        .frame(width: 200)
                }

            }.padding(EdgeInsets(top: _gapSize * 2, leading: _gapSize * 2, bottom: 0, trailing: _gapSize * 2))

            Divider()
                .padding(EdgeInsets(top: _gapSize, leading: 0, bottom: _gapSize, trailing: 0))

            TabView(content: {
                ProviderKeyField(label: "NiuTrans", icon: "1.square", sk: $niuTransSK)

                ProviderKeyField(label: "Volcengine", icon: "2.square", ak: $volcengineAK, sk: $volcengineSK)

                ProviderKeyField(label: "Ali", icon: "3.square", ak: $aliAK, sk: $aliSK)

                ProviderKeyField(label: "Baidu", icon: "4.square", ak: $baiduAK, sk: $baiduSK)
                
                ProviderKeyField(label: "BigHugeThesaurus", icon: "5.square", sk: $bigHugeThesaurusSK)
            }).padding(EdgeInsets(top: 0, leading: _gapSize * 2, bottom: 0, trailing: _gapSize * 2))
        }
        .frame(width: 500, height: 220)
    }
}

#Preview("Provider", traits: .fixedLayout(width: 500, height: 500)) {
    ProvidersView()
        .padding()
}
