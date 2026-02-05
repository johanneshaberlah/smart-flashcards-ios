import Foundation

enum Strings {
    // MARK: - Onboarding
    enum Onboarding {
        static let welcome = "Willkommen"
        static let login = "Anmelden"
        static let register = "Registrieren"

        // Form fields
        static let name = "Name"
        static let email = "E-Mail"
        static let password = "Passwort"

        // Validation errors
        static let emptyEmail = "Gebe deine E-Mail ein"
        static let emptyPassword = "Gebe dein Passwort ein"
        static let emptyName = "Gebe deinen Namen ein"
    }

    // MARK: - API Errors
    enum APIError {
        static let loginFailed = "Login fehlgeschlagen. Überprüfe deine Eingaben."
        static let userAlreadyExists = "Registrierung fehlgeschlagen. Es existiert bereits ein Account mit dieser Mail."
        static let networkError = "Netzwerkfehler. Bitte versuche es erneut."
        static let unknownError = "Ein unbekannter Fehler ist aufgetreten."
    }

    // MARK: - Dashboard
    enum Dashboard {
        static let title = "Meine Stapel"
        static let logout = "Abmelden"
        static let welcomeUser = "Hallo, %@!"
    }

    // MARK: - Stack
    enum Stack {
        static let title = "Deine Stapel"
        static let create = "Erstellen"
        static let cardCount = "%d Karten"
        static let cardCountSingular = "1 Karte"
        static let emptyState = "Erstelle deinen ersten Stapel"
        static let loading = "Stapel werden geladen..."
        static let deleteTitle = "Stapel löschen"
        static let deleteMessage = "Möchtest du den Stapel \"%@\" wirklich löschen?"
        static let deleteConfirm = "Löschen"
        static let cancel = "Abbrechen"
        static let name = "Name"
        static let namePlaceholder = "Stapelname"
        static let color = "Farbe"
        static let save = "Speichern"
        static let emptyName = "Gebe einen Namen ein"
        static let createError = "Stapel konnte nicht erstellt werden"
        static let deleteError = "Stapel konnte nicht gelöscht werden"
        static let loadError = "Stapel konnten nicht geladen werden"
    }
}
