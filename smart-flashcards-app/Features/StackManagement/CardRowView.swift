import SwiftUI

struct CardRowView: View {
    let card: Card

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.question)
                    .font(.headline)
                    .foregroundStyle(Theme.gray900)
                    .lineLimit(1)

                Text(card.answer)
                    .font(.subheadline)
                    .foregroundStyle(Theme.gray600)
                    .lineLimit(1)

                if let maturity = card.maturity {
                    dueDateView(maturity: maturity)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.gray300)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func dueDateView(maturity: CardMaturity) -> some View {
        if let date = parseDate(maturity.maturity) {
            HStack(spacing: 4) {
                Text(Strings.Card.duePrefix)
                    .font(.caption)
                    .foregroundStyle(Theme.gray600)

                Text(formattedDate(date))
                    .font(.caption)
                    .foregroundStyle(dueDateColor(for: date))
            }
        }
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return Strings.Card.dueToday
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }

    private func dueDateColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return Theme.orange500
        } else if date < now {
            return Theme.red500
        } else {
            return Theme.gray600
        }
    }
}

#Preview {
    List {
        CardRowView(card: Card(
            id: 1,
            uniqueId: "card-1",
            question: "What is photosynthesis?",
            answer: "The process by which plants convert light energy into chemical energy",
            hint: nil,
            maturity: CardMaturity(id: 1, maturity: "2026-02-15T10:00:00Z", level: 1)
        ))
    }
}
