import SwiftUI

struct HorizontalFilterBar: View {
    @Binding var selectedFilter: ToolFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ToolFilter.allCases) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        onTap: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
