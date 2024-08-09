#include <GUIConstantsEx.au3>
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

Global $aQuestions
Global $iCurrentQuestion = -1
Global $iScore = 0
Global $aCheckBoxes[6]

; CSV-Datei laden
LoadQuestionsFromCSV("questions.csv")

; Fragen randomisieren
_ArrayShuffle($aQuestions)

; GUI erstellen
GUICreate("Fragen GUI", 800, 400)
Global $lblQuestion = GUICtrlCreateLabel("", 10, 10, 780, 40)
For $i = 0 To 5
    $aCheckBoxes[$i] = GUICtrlCreateCheckbox("", 10, 60 + ($i * 30), 780, 20)
Next
Global $btnNext = GUICtrlCreateButton("Nächste Frage", 250, 300, 100, 30)
GUISetState(@SW_SHOW)

NextQuestion()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $btnNext
            CheckAnswer()
            NextQuestion()
    EndSwitch
WEnd

Func LoadQuestionsFromCSV($sFilePath)
    Local $aData, $i, $j
    If Not _FileReadToArray($sFilePath, $aData) Then
        MsgBox($MB_ICONERROR, "Fehler", "Konnte die Datei nicht lesen: " & $sFilePath)
        Exit
    EndIf

    Dim $aQuestions[UBound($aData) - 1][3]
    For $i = 1 To UBound($aData) - 1
        Local $aRow = StringSplit($aData[$i], '","', 3)
        If UBound($aRow) = 3 Then
            For $j = 0 To 2
                $aQuestions[$i - 1][$j] = StringTrimLeft(StringTrimRight($aRow[$j], 1), 1)
            Next
        Else
            MsgBox($MB_ICONERROR, "Fehler", "Ungültige Zeile in der CSV-Datei: " & $aData[$i] & @CRLF & "Erwartet: 3 Felder, gefunden: " & UBound($aRow))
            Exit
        EndIf
    Next
EndFunc

Func NextQuestion()
    $iCurrentQuestion += 1
    If $iCurrentQuestion >= UBound($aQuestions) Then
        MsgBox($MB_ICONINFORMATION, "Ergebnis", "Du hast " & $iScore & " von " & UBound($aQuestions) & " Fragen richtig beantwortet!")
        Exit
    EndIf

    GUICtrlSetData($lblQuestion, $aQuestions[$iCurrentQuestion][0])
    Local $answers = StringSplit($aQuestions[$iCurrentQuestion][1], ";", $STR_ENTIRESPLIT)
    For $i = 1 To UBound($answers) - 1
        GUICtrlSetData($aCheckBoxes[$i - 1], $i & ". " & $answers[$i])
        GUICtrlSetState($aCheckBoxes[$i - 1], $GUI_SHOW)
        GUICtrlSetState($aCheckBoxes[$i - 1], $GUI_UNCHECKED)
    Next

    ; Verstecke nicht benötigte Checkboxen
    For $i = UBound($answers) To 6
        GUICtrlSetState($aCheckBoxes[$i - 1], $GUI_HIDE)
    Next
EndFunc

Func CheckAnswer()
    Local $userAnswers = ""
    For $i = 0 To 5
        If BitAND(GUICtrlRead($aCheckBoxes[$i]), $GUI_CHECKED) Then
            $userAnswers &= $i + 1 & ","
        EndIf
    Next
    $userAnswers = StringTrimRight($userAnswers, 1)

    Local $correctAnswers = $aQuestions[$iCurrentQuestion][2]

    ; Sortiere die Antworten für den Vergleich
    Local $aUserAnswers = StringSplit($userAnswers, ",", $STR_ENTIRESPLIT)
    Local $aCorrectAnswers = StringSplit($correctAnswers, ",", $STR_ENTIRESPLIT)
    _ArraySort($aUserAnswers)
    _ArraySort($aCorrectAnswers)

    If _ArrayToString($aUserAnswers) == _ArrayToString($aCorrectAnswers) Then
        $iScore += 1
        MsgBox($MB_SYSTEMMODAL, "Ergebnis", "Richtig! ?")
    Else
        MsgBox($MB_SYSTEMMODAL, "Ergebnis", "Falsch! ? Die richtige(n) Antwort(en) ist/sind: " & $correctAnswers)
    EndIf
EndFunc
