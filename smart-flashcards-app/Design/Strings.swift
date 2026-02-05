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

    // MARK: - Card
    enum Card {
        static let createCard = "Karte erstellen"
        static let editCard = "Karte bearbeiten"
        static let startLearning = "Jetzt lernen"
        static let autoCreate = "Automatisch erstellen"
        static let deleteTitle = "Karte löschen"
        static let deleteMessage = "Möchtest du diese Karte wirklich löschen?"
        static let deleteConfirm = "Löschen"
        static let emptyState = "Noch keine Karten vorhanden"
        static let deleteError = "Karte konnte nicht gelöscht werden"
        static let loadError = "Karten konnten nicht geladen werden"
        static let saveError = "Karte konnte nicht gespeichert werden"
        static let duePrefix = "Fällig:"
        static let dueToday = "Heute"
        static let question = "Vorderseite"
        static let answer = "Rückseite"
        static let questionPlaceholder = "Frage eingeben..."
        static let answerPlaceholder = "Antwort eingeben..."
        static let emptyQuestion = "Gebe eine Frage ein"
        static let emptyAnswer = "Gebe eine Antwort ein"
    }

    // MARK: - AI Card Creation
    enum AICardCreation {
        static let title = "Karteikarten erstellen lassen"
        static let fileSection = "PDF-Datei"
        static let selectFile = "Datei auswählen..."
        static let fileHint = "PDF-Datei (max. 10 MB)"
        static let instructionsSection = "Sonstige Anweisungen"
        static let instructionsPlaceholder = "Optionale Anweisungen für die KI..."
        static let generate = "Generieren"
        static let noFileSelected = "Bitte wähle eine PDF-Datei aus"
        static let fileTooLarge = "Die Datei ist zu groß (max. 10 MB)"
        static let fileReadError = "Die Datei konnte nicht gelesen werden"
        static let uploadError = "Beim Hochladen ist ein Fehler aufgetreten"

        // Progress messages
        static let progressImporting = "Deine Datei wird überprüft..."
        static let progressChecking = "Deine Datei wird gelesen..."
        static let progressUploading = "Deine Datei wird hochgeladen..."
        static let progressProviding = "Deine Datei wird dem Sprachmodell bereitgestellt..."
        static let progressGenerating = "Karteikarten werden generiert..."
        static let progressStillGenerating = "Einen Moment noch, die Karteikarten werden noch generiert..."
        static let progressUpdating = "Dein Stapel wird aktualisiert..."
        static let progressAlmostDone = "Einen Moment noch, gleich sind wir soweit..."
    }

    // MARK: - Learning
    enum Learning {
        static let question = "Frage"
        static let answer = "Antwort"
        static let hint = "Hinweis"
        static let tapToReveal = "Tippen zum Aufdecken"
        static let completionTitle = "Geschafft!"
        static let completionMessage = "Du hast alle fälligen Karten gelernt."
        static let cardsReviewed = "%d Karten wiederholt"
        static let cardsReviewedSingular = "1 Karte wiederholt"
        static let learnAhead = "Vorauslernen"
        static let finish = "Beenden"
        static let loadError = "Karte konnte nicht geladen werden"
        static let ratingError = "Bewertung konnte nicht gespeichert werden"
        static let retry = "Erneut versuchen"
        static let close = "Schließen"
    }
}
