WindowDialog subclass: #WorldHandicapNewPlayerDialog
  instanceVariableNames: 
    ' saved unsaved newPlayer entryName entryGhin '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants ' !
WindowDialog subclass: #WorldHandicapRoundEditDialog
  instanceVariableNames: 
    ' round saved unsaved player '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants ' !
ViewManager subclass: #WorldHandicapSystemUI
  instanceVariableNames: 
    ' currentPlayer unsaved '
  classVariableNames: ''
  poolDictionaries: 
    ' ColorConstants OperatingSystemConstants '  !
Object subclass: #WorldHandicapDatabase
  instanceVariableNames: 
    ' rounds '
  classVariableNames: ''
  poolDictionaries: '' !
Object subclass: #WorldHandicapPlayer
  instanceVariableNames: 
    ' playerName ghinNumber database '
  classVariableNames: ''
  poolDictionaries: ''   !
Object subclass: #WorldHandicapRound
  instanceVariableNames: 
    ' database roundNumber date dayOfWeek daysPassed courseName tees rating slope parTees score roundType pcc usedIndicator player '
  classVariableNames: ''
  poolDictionaries: ''  !


!WorldHandicapDatabase class methods !
   
includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  11:37:30 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapDatabase methods !
 
assignDaysPassed
    | sortedRounds reversedRounds prevRound prevDate currDate daysDiff |
    #CodeTrackerBlock.  "Last Modified  17:24:20 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    sortedRounds := self sortRoundsByDate.
    reversedRounds := sortedRounds asArray reversed.
    reversedRounds withIndexDo: [:round :i |
        currDate := round dateString.
        i = 1
            ifTrue: [round daysPassed: 'first'] "Most recent round"
            ifFalse: [
                prevRound := reversedRounds at: i-1.
                prevDate := prevRound dateString.
                daysDiff := currDate elapsedDaysSince: prevDate.
                round daysPassed: daysDiff.
            ].
    ].! !



!WorldHandicapDatabase methods !
 
assignRoundNumber

    | sortedRounds num |
    #CodeTrackerBlock.  "Last Modified  14:01:46 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    sortedRounds := self sortRoundsByDate.
    num := 1.
    sortedRounds do: [:round |
        round roundNumber: num.
        num := num + 1.].! !



!WorldHandicapDatabase methods !
  
loadFromGhinFile: fileName 

    | fileStream round line player ghin |
    #CodeTrackerBlock.  "Last Modified  17:10:44 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    fileStream := File pathNameReadOnly: fileName.
    player := WorldHandicapPlayer new.
    ghin := WorldHandicapPlayer getGhinFromFileName: fileName.
    player ghinNumber: ghin.
    [fileStream atEnd]
        whileFalse:[
            line := fileStream nextLine.
            (line notEmpty and: [line includes: Character tab])
                ifTrue:[
                    round := WorldHandicapRound fromTabLine: line.
                    self rounds add: round.]
                ifFalse:[WorldHandicapPlayer fromLine: line into: player.].].
    fileStream close.
    ^player! !



!WorldHandicapDatabase methods !

mostRecentRoundForCourse: aCourse tee: aTee player: aPlayer 

    | filteredRounds |
    #CodeTrackerBlock.  "Last Modified  13:47:43 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    filteredRounds := self rounds select: [:r |
        r player = aPlayer and: [r courseName = aCourse and: [r tees = aTee]]].
    filteredRounds isEmpty
        ifTrue:[^nil]
        ifFalse:[
            ^(filteredRounds asSortedCollection: [:a :b | (Date fromString: a date) > (Date fromString: b date)]) first].! !



!WorldHandicapDatabase methods !
 
playedCoursesForPlayer: aPlayer 

	"unique courses a player has played."
    #CodeTrackerBlock.  "Last Modified  14:30:42 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(self rounds select: [:r | r player = aPlayer] collect: [:r | r courseName]) asSet asSortedCollection.! !



!WorldHandicapDatabase methods !
   
recentTwentyRounds

"Return the most recent 20 rounds (by date, descending)"
    | sortedRecent n |
    #CodeTrackerBlock.  "Last Modified  19:23:04 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    sortedRecent := self sortRoundsByDate.
    n := sortedRecent size min: 20.
    ^sortedRecent copyFrom: 1 to: n.! !



!WorldHandicapDatabase methods !
 
rounds
    #CodeTrackerBlock.  "Last Modified  11:41:46 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    rounds isNil
        ifTrue:[rounds := OrderedCollection new].
    ^rounds! !



!WorldHandicapDatabase methods !

rounds: aValue
    #CodeTrackerBlock.  "Last Modified  11:40:54 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    rounds := aValue! !



!WorldHandicapDatabase methods !

sortRoundsByDate

	"Return the rounds sorted descending by date (most recent first)."
    #CodeTrackerBlock.  "Last Modified  16:19:37 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self rounds asSortedCollection: [:a :b |
        | dateA dateB|dateA := Date fromString: a date.
        dateB := Date fromString: b date.
        dateA = dateB
            ifTrue:[a roundDifferential < b roundDifferential] "Lower differential first for same day"
            ifFalse:[dateA > dateB] "Most recent date first"
        ]! !



!WorldHandicapDatabase methods !

uniqueTeesForCourse: aCourse 

    | courseRounds teesDict |
    #CodeTrackerBlock.  "Last Modified  13:43:12 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    courseRounds := self rounds select: [:r | r courseName = aCourse].
    teesDict := Dictionary new.
    courseRounds do: [:r |
        | existing|existing := teesDict at: r tees ifAbsent: [nil].
        ((existing isNil) or: [(Date fromString: r date) > (Date fromString: existing date)])
            ifTrue:[teesDict at: r tees put: r].].
    ^teesDict values.! !



!WorldHandicapNewPlayerDialog class methods !
   
includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  15:02:31 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapNewPlayerDialog class methods !

wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk 3.1.0 Win32"
    #CodeTrackerBlock.  "Last Modified  16:45:11 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^3.11! !



!WorldHandicapNewPlayerDialog methods !
  
cancelButtonClicked

	"Callback for the #clicked event in cancelButton [Button].
		(Generated by WindowBuilder Pro)"
    #CodeTrackerBlock.  "Last Modified  15:29:42 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (unsaved = true)
        ifTrue:[
            (self warningMessage)
                ifTrue:[
                    saved := false.
                    self close].]
        ifFalse:[
            saved := false.
            self close.].! !



!WorldHandicapNewPlayerDialog methods !

createViews

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."
    | cancelButton ghinNumberEntry mainView playerNameEntry saveButton staticText1 staticText2 xDU yDU |
    #CodeTrackerBlock.  "Last Modified  16:45:11 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    #generated.
    xDU := (SysFont width + 1 roundTo: 2) / (SysFont width roundTo: 2).
    yDU := 1.
    mainView := self topPaneClass new.

		"Temporary Variables"
    cancelButton := Button new.
    ghinNumberEntry := EnhancedEntryField new.
    playerNameEntry := EnhancedEntryField new.
    saveButton := Button new.
    staticText1 := StaticText new.
    staticText2 := StaticText new.
    mainView
        owner: self;
        setName: 'mainView';
        alignRelativeToScreen;
        when: #maximized send: #winMaximized to: mainView;
        when: #minimized send: #winMinimized to: mainView;
        when: #restored send: #winRestored to: mainView;
        addModalBorderStyle;
        labelWithoutPrefix: 'New Player';
        noSmalltalkMenuBar;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 1 / 2 / ((SysFont width roundTo: 2) / 4);
                 leftInset: -118 * xDU;
                 topRatio: 1 / 2 / (SysFont height / 8);
                 topInset: -816 / 19 * yDU;
                 rightRatio: 1 / 2 / ((SysFont width roundTo: 2) / 4);
                 rightInset: -118 * xDU;
                 bottomRatio: 1 / 2 / (SysFont height / 8);
                 bottomInset: -816 / 19 * yDU).
    self addView: mainView.
    playerNameEntry "EnhancedEntryField"
        owner: self;
        setName: 'playerNameEntry';
        when: #textChanged: send: #fieldEdited to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 41 / 118;
                 leftInset: 0 * xDU;
                 topRatio: 0;
                 topInset: 224 / 19 * yDU;
                 rightRatio: 1 / 2;
                 rightInset: -56 * xDU;
                 bottomRatio: 1 / 2;
                 bottomInset: 376 / 19 * yDU);
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: playerNameEntry.
    ghinNumberEntry "EnhancedEntryField"
        owner: self;
        setName: 'ghinNumberEntry';
        when: #textChanged: send: #fieldEdited to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 82 * xDU;
                 topRatio: 0;
                 topInset: 768 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -174 * xDU;
                 bottomRatio: 0;
                 bottomInset: -984 / 19 * yDU);
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: ghinNumberEntry.
    staticText1
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 50 * xDU;
                 topRatio: 0;
                 topInset: 224 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -74 * xDU;
                 bottomRatio: 0;
                 bottomInset: -384 / 19 * yDU);
        contents: 'Name';
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: staticText1.
    staticText2
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 50 * xDU;
                 topRatio: 0;
                 topInset: 800 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -72 * xDU;
                 bottomRatio: 0;
                 bottomInset: -960 / 19 * yDU);
        contents: 'GHIN';
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: staticText2.
    saveButton "Button"
        owner: self;
        setName: 'saveButton';
        when: #clicked send: #saveButtonClicked to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 68 * xDU;
                 topRatio: 0;
                 topInset: 64 * yDU;
                 rightRatio: 0;
                 rightInset: -104 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1472 / 19 * yDU);
        contents: 'Save';
        startGroup;
        noTabStop;
        font: SysFont.
    mainView addSubpane: saveButton.
    cancelButton "Button"
        owner: self;
        setName: 'cancelButton';
        when: #clicked send: #cancelButtonClicked to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 152 * xDU;
                 topRatio: 0;
                 topInset: 64 * yDU;
                 rightRatio: 0;
                 rightInset: -188 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1472 / 19 * yDU);
        contents: 'Cancel';
        startGroup;
        noTabStop;
        font: SysFont;
        cancelPushButton.
    mainView addSubpane: cancelButton! !



!WorldHandicapNewPlayerDialog methods !
 
entryGhin
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^entryGhin! !



!WorldHandicapNewPlayerDialog methods !

entryGhin: aValue
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    entryGhin := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
entryName
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^entryName! !



!WorldHandicapNewPlayerDialog methods !

entryName: aValue
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    entryName := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
fieldEdited

	"Callback for the #textChanged: event in playerNameEntry [EnhancedEntryField].
		(Generated by WindowBuilder Pro)"
    #CodeTrackerBlock.  "Last Modified  16:45:32 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved := true.! !



!WorldHandicapNewPlayerDialog methods !
  
initWindow
    #CodeTrackerBlock.  "Last Modified  16:11:10 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    super initWindow.! !



!WorldHandicapNewPlayerDialog methods !
  
isValidGhinFile: aString 

	 "form 9999-999"
    | i |
    #CodeTrackerBlock.  "Last Modified  16:56:10 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (aString size = 8)
        ifFalse:[^false].
    (aString at: 5) = $-
        ifFalse:[^false].

	 "Check positions 1 to 4 are digits"
    i := 1.
    [i <= 4]
        whileTrue:[
            ((aString at: i) isDigit)
                ifFalse:[^false].
            i := i + 1.].

	 "Check positions 6 to 8 are digits"
    i := 6.
    [i <= 8]
        whileTrue:[
            ((aString at: i) isDigit)
                ifFalse:[^false].
            i := i + 1.].
    ^true! !



!WorldHandicapNewPlayerDialog methods !
   
markModified
    #CodeTrackerBlock.  "Last Modified  15:29:11 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved := true.! !



!WorldHandicapNewPlayerDialog methods !
 
newPlayer
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^newPlayer! !



!WorldHandicapNewPlayerDialog methods !

newPlayer: aValue
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    newPlayer := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
openOn
    #CodeTrackerBlock.  "Last Modified  15:23:18 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    saved := false.
    newPlayer := nil.
    self open.! !



!WorldHandicapNewPlayerDialog methods !
 
saveButtonClicked

							"Callback for the #clicked event in saveButton [Button].
														(Generated by WindowBuilder Pro)"
    | name ghin fileName fileStream |
    #CodeTrackerBlock.  "Last Modified  16:49:12 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    name := (self paneNamed: 'playerNameEntry') contents asString.
    ghin := (self paneNamed: 'ghinNumberEntry') contents asString.
    (self isValidGhinFile: ghin)
        ifFalse:[
            MessageBox message: 'GHIN must be 7 digits in the format ####-###'.
            ^self].
    fileName := 'C:\Labware-8\Data\' , ghin , '.ghin'.
    (File exists: fileName)
        ifTrue:[
            MessageBox message: 'GHIN number already in use.'.
            ^self].
    fileStream := File newFile: fileName.
    fileStream
        nextPutAll: 'PlayerName=' , name;
        close.

		  "Create the player object and assign it to currentPlayer"
    newPlayer := WorldHandicapPlayer new.
    newPlayer playerName: name.
    newPlayer ghinNumber: ghin.
    newPlayer database: (WorldHandicapDatabase new). "empty database object"
    saved := true.
    self close.! !



!WorldHandicapNewPlayerDialog methods !
 
saved
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^saved! !



!WorldHandicapNewPlayerDialog methods !

saved: aValue
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    saved := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
unsaved
    #CodeTrackerBlock.  "Last Modified  15:28:12 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^unsaved! !



!WorldHandicapNewPlayerDialog methods !

unsaved: aValue
    #CodeTrackerBlock.  "Last Modified  15:28:12 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
views
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^views! !



!WorldHandicapNewPlayerDialog methods !

views: aValue
    #CodeTrackerBlock.  "Last Modified  15:09:54 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    views := aValue! !



!WorldHandicapNewPlayerDialog methods !
   
warningMessage
    #CodeTrackerBlock.  "Last Modified  15:30:34 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^MessageBox confirmWithCancel: 'You have unsaved changes. 
Are you sure you want to cancel?'! !



!WorldHandicapNewPlayerDialog methods !
  
wasSaved
    #CodeTrackerBlock.  "Last Modified  15:10:49 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^saved = true.! !



!WorldHandicapPlayer class methods !
  
fromLine: aString into: aPlayer 

    | pair key value |
    #CodeTrackerBlock.  "Last Modified  15:19:42 07/24/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    pair := aString asArrayOfSubstringsSeparatedBy: (Character value: 61). "equals sign ="
    pair size = 2
        ifTrue:[
            key := pair first.
            value := pair two.
            key = 'PlayerName'
                ifTrue:[aPlayer playerName: value].].
    ^aPlayer! !



!WorldHandicapPlayer class methods !
  
getGhinFromFileName: fileName
    #CodeTrackerBlock.  "Last Modified  11:17:38 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^((fileName asArrayOfSubstringsSeparatedBy: $\) last) copyUpTo: '.'! !



!WorldHandicapPlayer class methods !

includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  10:40:28 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapPlayer methods !
   
assignRankIndicatorsTo: rounds 

    | rank lastDiff rankCount |
    #CodeTrackerBlock.  "Last Modified  15:38:52 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    rank := 1.
    lastDiff := nil.
    rankCount := 0.
    rounds do: [:r |
        rankCount := rankCount + 1.
        (lastDiff notNil and: [r roundDifferential = lastDiff])
            ifFalse:[rank := rankCount].
        r usedIndicator: rank asString.
        lastDiff := r roundDifferential.].! !



!WorldHandicapPlayer methods !

averageDifferentialOf: rounds 

	"average differential of the cgiven collected rounds."
    #CodeTrackerBlock.  "Last Modified  17:10:01 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(rounds inject: 0 into: [:sum :each | sum + each roundDifferential]) / rounds size.! !



!WorldHandicapPlayer methods !

clearUsedIndicatorsOnRecentRounds
    #CodeTrackerBlock.  "Last Modified  15:38:33 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    self playerRecentTwentyRounds do: [:r | r usedIndicator: ''].! !



!WorldHandicapPlayer methods !

database
    #CodeTrackerBlock.  "Last Modified  14:29:02 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^database! !



!WorldHandicapPlayer methods !
   
database: aValue
    #CodeTrackerBlock.  "Last Modified  14:29:02 07/23/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    database := aValue! !



!WorldHandicapPlayer methods !
  
displayHandicapIndex: aValue
    #CodeTrackerBlock.  "Last Modified  13:44:36 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (aValue isNumber)
        ifFalse:[^aValue].
    aValue < 0
        ifTrue:[^'+' , (aValue abs asString)].
    ^aValue asString! !



!WorldHandicapPlayer methods !
   
ghinNumber
    #CodeTrackerBlock.  "Last Modified  10:41:50 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^ghinNumber! !



!WorldHandicapPlayer methods !
   
ghinNumber: aValue
    #CodeTrackerBlock.  "Last Modified  10:41:50 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ghinNumber := aValue! !



!WorldHandicapPlayer methods !
  
handicapIndexDeductionForRoundCount: roundCount 

		  "returns the amount deducted if there are 6, 4, or 3 rounds."
    #CodeTrackerBlock.  "Last Modified  20:01:38 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    roundCount = 6
        ifTrue:[^1.0].
    roundCount = 4
        ifTrue:[^1.0].
    roundCount = 3
        ifTrue:[^2.0].
    ^0.0! !



!WorldHandicapPlayer methods !
 
handicapIndexForCourse: aCourse tee: aTee 

		"Calculate index for this course/tee combo, following all rules."
    | courseRounds |
    #CodeTrackerBlock.  "Last Modified  17:09:00 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    courseRounds := self playerRecentTwentyRounds select: [:r |
        (r courseName = aCourse) and: (r tees = aTee)].
    ^self handicapIndexForRounds: courseRounds! !



!WorldHandicapPlayer methods !
   
handicapIndexForRounds: roundCollection 

"player's handicap index for the given rounds, or 'N.H' if < 3 rounds"
    | numRounds deduction usedRounds bestN sorted avgIndex |
    #CodeTrackerBlock.  "Last Modified  16:25:35 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    numRounds := roundCollection size.
    numRounds < 3
        ifTrue:[^'N.H.'].
    bestN := self numUsedBasedOn: numRounds.
    deduction := self handicapIndexDeductionForRoundCount: numRounds.
    sorted := self roundsSortedByLowestDifferential: roundCollection.
    usedRounds := self selectUsedRoundsFrom: sorted bestN: bestN.
    avgIndex := (self averageDifferentialOf: usedRounds) - deduction.
    ^avgIndex roundTo: 0.1! !



!WorldHandicapPlayer methods !

maxAfterNext
    #CodeTrackerBlock.  "Last Modified  15:36:23 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self maxAfterSimulatedRounds: 1! !



!WorldHandicapPlayer methods !
  
maxAfterSimulatedRounds: count 

	"Return the maximum possible handicap index after 'count' simulated future bad rounds."
    | recentRounds simulatedRounds futureDate allRounds |
    #CodeTrackerBlock.  "Last Modified  18:14:24 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    recentRounds := self playerRecentTwentyRounds copy.
    simulatedRounds := OrderedCollection new.
    1 to: count do: [:i |
        futureDate := (Date today addDays: i).
        simulatedRounds add: (self simulateWorstCaseRoundWithDate: futureDate).].

	"Remove the oldest N rounds to maintain 20"
    (recentRounds size + simulatedRounds size > 20)
        ifTrue:[recentRounds := recentRounds copyFrom: 1 to: (20 - simulatedRounds size)].
    allRounds := simulatedRounds , recentRounds. "ombines the two collections into one"
    ^self handicapIndexForRounds: allRounds.! !



!WorldHandicapPlayer methods !

maxAfterThree
    #CodeTrackerBlock.  "Last Modified  16:35:28 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self maxAfterSimulatedRounds: 3! !



!WorldHandicapPlayer methods !
 
maxAfterTwo
    #CodeTrackerBlock.  "Last Modified  15:36:47 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self maxAfterSimulatedRounds: 2! !



!WorldHandicapPlayer methods !
   
numUsedBasedOn: count 

	"Return number of rounds to use based on count"
    #CodeTrackerBlock.  "Last Modified  16:54:02 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    count >= 20
        ifTrue:[^8].
    count = 19
        ifTrue:[^7].
    (count = 17 or: [count = 18])
        ifTrue:[^6].
    (count = 15 or: [count = 16])
        ifTrue:[^5].
    ((count >= 12) and: [count <= 14])
        ifTrue:[^4].
    ((count >= 9) and: [count <= 11])
        ifTrue:[^3].
    ((count = 7) or: [count = 8])
        ifTrue:[^2].
    count = 6
        ifTrue:[^2].
    count = 5
        ifTrue:[^1].
    count = 4
        ifTrue:[^1].
    count = 3
        ifTrue:[^1].
    ^0.! !



!WorldHandicapPlayer methods !
  
playedCourses
    #CodeTrackerBlock.  "Last Modified  14:36:32 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^database playedCoursesForPlayer: self! !



!WorldHandicapPlayer methods !
   
playedTeesForCourse: aCourse
    #CodeTrackerBlock.  "Last Modified  14:36:56 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^database playedTeesForCourse: aCourse player: self! !



!WorldHandicapPlayer methods !
   
playerName
    #CodeTrackerBlock.  "Last Modified  10:49:04 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^playerName! !



!WorldHandicapPlayer methods !
  
playerName: aValue
    #CodeTrackerBlock.  "Last Modified  10:49:26 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    playerName := aValue! !



!WorldHandicapPlayer methods !
 
playerRecentTwentyRounds
    #CodeTrackerBlock.  "Last Modified  14:17:36 07/23/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self database recentTwentyRounds! !



!WorldHandicapPlayer methods !
 
roundsSortedByLowestDifferential: roundCollection 

	"rounds sorted in ascending order of round differential (lowest first)."
    #CodeTrackerBlock.  "Last Modified  16:21:04 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^roundCollection asSortedCollection: [:a :b |
        a roundDifferential < b roundDifferential].! !



!WorldHandicapPlayer methods !
 
selectUsedRoundsFrom: sortedRounds bestN: n 

	"Returns the best n rounds from sortedRounds, including all rounds tied at the nth differential.
If multiple rounds share the cutoff value, all are included."
    | effectiveN cutoffValue |
    #CodeTrackerBlock.  "Last Modified  16:53:24 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    effectiveN := n min: sortedRounds size.
    cutoffValue := (sortedRounds at: effectiveN) roundDifferential.
    ^sortedRounds select: [:r | r roundDifferential <= cutoffValue].! !



!WorldHandicapPlayer methods !

simulateWorstCaseRoundWithDate: aDate 

	"Create a simulated round with a very high differential and a future date to calculate
	handicapindex max after next, maxt after two, and max after three"
    | round |
    #CodeTrackerBlock.  "Last Modified  16:40:24 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round := WorldHandicapRound new.
    round player: self.
    round date: aDate printString.
    round courseName: 'SimulatedCourse'.
    round tees: 'SimulatedTee'.
    round rating: 70.0.
    round slope: 120.
    round parTees: 72.
    round pcc: 0.
    round score: 130.
    round roundType: 'S'.
    ^round.! !



!WorldHandicapPlayer methods !
   
sortedRecentRoundsByDifferential
    #CodeTrackerBlock.  "Last Modified  16:39:02 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self playerRecentTwentyRounds asSortedCollection: [:a :b |
        a roundDifferential < b roundDifferential].! !



!WorldHandicapPlayer methods !
  
usedRoundsRanking

"player's recent twenty rounds should be marked as 'used'"

"selects the best N rounds by differential"

"clears existing 'used', assigns to selected rounds, and returns the used rounds collection."
    | bestN cutoffValue usedRounds sortedRounds |
    #CodeTrackerBlock.  "Last Modified  16:12:32 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self playerRecentTwentyRounds isEmpty or: [(self numUsedBasedOn: self playerRecentTwentyRounds size) = 0])
        ifTrue:[
            self clearUsedIndicatorsOnRecentRounds.
            ^nil].
    bestN := self numUsedBasedOn: self playerRecentTwentyRounds size.
    sortedRounds := self sortedRecentRoundsByDifferential.
    bestN := bestN min: sortedRounds size.
    cutoffValue := (sortedRounds at: bestN) roundDifferential.
    usedRounds := sortedRounds select: [:r | r roundDifferential <= cutoffValue].
    self clearUsedIndicatorsOnRecentRounds.
    self assignRankIndicatorsTo: usedRounds.
    ^usedRounds! !



!WorldHandicapRound class methods !
   
fromTabLine: aString 

    | fields round key value pair dateField |
    #CodeTrackerBlock.  "Last Modified  16:54:06 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    fields := aString asArrayOfSubstringsDelimitedBy: Character tab.
    round := self new.
    dateField := nil.
    fields do: [:field |
        pair := field asArrayOfSubstringsSeparatedBy: (Character value: 61). "equals sign"
        pair size = 2
            ifTrue:[
                key := pair first.
                value := pair two.
                key = 'Date'
                    ifTrue:[round date: value].
                key = 'Course'
                    ifTrue:[round courseName: value].
                key = 'Tees'
                    ifTrue:[round tees: value].
                key = 'Par'
                    ifTrue:[round parTees: value asInteger].
                key = 'Rating'
                    ifTrue:[round rating: value asFloat].
                key = 'Slope'
                    ifTrue:[round slope: value asInteger].
                key = 'PCC'
                    ifTrue:[round pcc: value asInteger].
                key = 'Score'
                    ifTrue:[round score: value asInteger].
                key = 'Type'
                    ifTrue:[round roundType: value].].].
    ^round! !



!WorldHandicapRound class methods !
 
includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  17:09:40 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapRound methods !

abbrevDayNameForDate: aDate 

    | dayName |
    #CodeTrackerBlock.  "Last Modified  17:14:48 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    dayName := aDate dayName.
    ^dayName size > 2
        ifTrue:[dayName copyFrom: 1 to: 3]
        ifFalse:[dayName]! !



!WorldHandicapRound methods !
 
assignDayOfWeek

    | aDate |
    #CodeTrackerBlock.  "Last Modified  14:58:36 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    aDate := self dateString.
    aDate isNil
        ifTrue:[
            self dayName: 'Err'.
            ^self].
    self dayOfWeek: aDate dayName asString.! !



!WorldHandicapRound methods !
   
courseName
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^courseName! !



!WorldHandicapRound methods !

courseName: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    courseName := aValue! !



!WorldHandicapRound methods !
   
database
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^database! !



!WorldHandicapRound methods !

database: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    database := aValue! !



!WorldHandicapRound methods !
   
date
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^date! !



!WorldHandicapRound methods !

date: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    date := aValue! !



!WorldHandicapRound methods !
   
dateString

    | dateParts month day year |
    #CodeTrackerBlock.  "Last Modified  19:31:28 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    dateParts := self date asArrayOfSubstringsSeparatedBy: $/.
    (dateParts size = 3)
        ifFalse:[^'Err'].
    month := (dateParts at: 1) asInteger.
    day := (dateParts at: 2) asInteger.
    year := (dateParts at: 3) asInteger.
    ^Date newDay: day monthIndex: month year: year.! !



!WorldHandicapRound methods !
   
dayOfWeek
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^dayOfWeek! !



!WorldHandicapRound methods !
  
dayOfWeek: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    dayOfWeek := aValue! !



!WorldHandicapRound methods !
 
daysPassed
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^daysPassed! !



!WorldHandicapRound methods !

daysPassed: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    daysPassed := aValue! !



!WorldHandicapRound methods !
   
displayColor
    #CodeTrackerBlock.  "Last Modified  17:16:41 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    self isUsed
        ifTrue:[^Color blue].
    self isRecent
        ifTrue:[^Color black].
    ^Color darkGray.! !



!WorldHandicapRound methods !

index
    #CodeTrackerBlock.  "Last Modified  18:27:10 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self player handicapIndexForCourse: self courseName tee: self tees! !



!WorldHandicapRound methods !
   
isOutsideRecent
    #CodeTrackerBlock.  "Last Modified  17:17:55 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self isRecent not! !



!WorldHandicapRound methods !
  
isRecent
    #CodeTrackerBlock.  "Last Modified  17:18:31 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(self database recentTwentyRounds includes: self)! !



!WorldHandicapRound methods !
 
isUsed
    #CodeTrackerBlock.  "Last Modified  17:18:53 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^self usedIndicator notEmpty! !



!WorldHandicapRound methods !
 
parTees
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^parTees! !



!WorldHandicapRound methods !
  
parTees: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    parTees := aValue! !



!WorldHandicapRound methods !
 
pcc
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^pcc! !



!WorldHandicapRound methods !
  
pcc: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    pcc := aValue! !



!WorldHandicapRound methods !
 
player
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^player! !



!WorldHandicapRound methods !

player: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    player := aValue! !



!WorldHandicapRound methods !
   
rating
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^rating! !



!WorldHandicapRound methods !

rating: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    rating := aValue! !



!WorldHandicapRound methods !
   
roundDifferential

	  "Calculate and return the differential for this round"

	  "Returns nil if any field is missing, not a number, or if slope is 0. Only returns a value if all are valid"
    | s r sl |
    #CodeTrackerBlock.  "Last Modified  18:11:19 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    s := self score.
    r := self rating.
    sl := self slope.
    ((s isNumber and: [r isNumber and: [sl isNumber and: [sl ~= 0]]]))
        ifTrue:[^(((s - r) * 113) / sl) roundTo: 0.1]
        ifFalse:[^nil].! !



!WorldHandicapRound methods !

roundNumber
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^roundNumber! !



!WorldHandicapRound methods !
  
roundNumber: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    roundNumber := aValue! !



!WorldHandicapRound methods !
 
roundType
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^roundType! !



!WorldHandicapRound methods !
  
roundType: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    roundType := aValue! !



!WorldHandicapRound methods !
 
score
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^score! !



!WorldHandicapRound methods !
  
score: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    score := aValue! !



!WorldHandicapRound methods !
 
slope
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^slope! !



!WorldHandicapRound methods !
  
slope: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    slope := aValue! !



!WorldHandicapRound methods !
 
strokes

    | hi result |
    #CodeTrackerBlock.  "Last Modified  18:25:58 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    hi := self player handicapIndexForCourse: self courseName tee: self tees.
    (hi isNumber)
        ifTrue:[
            result := ((hi * (self slope / 113.0)) + self rating - self parTees).
            ^result roundTo: 1]
        ifFalse:[^hi "Return 'N.H.' or however you want to handle it"
    ].! !



!WorldHandicapRound methods !
  
tees
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^tees! !



!WorldHandicapRound methods !

tees: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    tees := aValue! !



!WorldHandicapRound methods !
   
usedIndicator
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^usedIndicator! !



!WorldHandicapRound methods !
  
usedIndicator: aValue
    #CodeTrackerBlock.  "Last Modified  17:13:19 07/26/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    usedIndicator := aValue! !



!WorldHandicapRoundEditDialog class methods !
 
includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  09:17:53 07/24/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapRoundEditDialog class methods !

wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk 3.1.0 Win32"
    #CodeTrackerBlock.  "Last Modified  15:30:50 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^3.11! !



!WorldHandicapRoundEditDialog methods !
  
cancelButtonClicked

	"Callback for the #clicked event in cancelButton [Button].
		(Generated by WindowBuilder Pro)"
    #CodeTrackerBlock.  "Last Modified  19:44:20 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (unsaved := true)
        ifTrue:[
            (self warningMessage)
                ifTrue:[
                    saved := false.
                    self close.]
                ifFalse:[^self].]
        ifFalse:[
            saved := false.
            self close.].! !



!WorldHandicapRoundEditDialog methods !
 
clearTeeDetailsFields
    #CodeTrackerBlock.  "Last Modified  13:49:05 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self paneNamed: 'parField') value: ''.
    (self paneNamed: 'ratingField') value: ''.
    (self paneNamed: 'slopeField') value: ''.! !



!WorldHandicapRoundEditDialog methods !
  
clearTeesCombo
    #CodeTrackerBlock.  "Last Modified  13:44:51 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self paneNamed: 'teesCombo') contents: ''.
    (self paneNamed: 'teesCombo') value: nil.! !



!WorldHandicapRoundEditDialog methods !
 
courseComboChanged

"Callback for the #changed: event in courseCombo [WideEnhancedComboBox].

								(Generated by WindowBuilder Pro)"

"Callback for #textCahnged: event."
    | selectedCourse |
    #CodeTrackerBlock.  "Last Modified  15:34:23 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    selectedCourse := (self paneNamed: 'courseCombo') value.
    self populateTeesComboForCourse: selectedCourse.
    (self paneNamed: 'parField') value: ''.
    (self paneNamed: 'ratingField') value: ''.
    (self paneNamed: 'slopeField') value: ''.
    unsaved := true.! !



!WorldHandicapRoundEditDialog methods !

createViews

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."
    | cancelButton courseCombo dateField differField editButton mainView parField pccField ratingField saveButton scoreField segoeUI10 segoeUI8 slopeField staticText1 staticText10 staticText2 staticText3 staticText4 staticText5 staticText6 staticText7 staticText8 staticText9 teesCombo typeDropdown xDU yDU |
    #CodeTrackerBlock.  "Last Modified  15:30:50 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    #generated.
    xDU := (SysFont width + 1 roundTo: 2) / (SysFont width roundTo: 2).
    yDU := 1.
    mainView := self topPaneClass new.

		"Temporary Variables"
    cancelButton := Button new.
    courseCombo := WideEnhancedComboBox new.
    dateField := EnhancedEntryField new.
    differField := EnhancedEntryField new.
    editButton := Button new.
    parField := EnhancedEntryField new.
    pccField := EnhancedEntryField new.
    ratingField := EnhancedEntryField new.
    saveButton := Button new.
    scoreField := EnhancedEntryField new.
    slopeField := EnhancedEntryField new.
    staticText1 := StaticText new.
    staticText10 := StaticText new.
    staticText2 := StaticText new.
    staticText3 := StaticText new.
    staticText4 := StaticText new.
    staticText5 := StaticText new.
    staticText6 := StaticText new.
    staticText7 := StaticText new.
    staticText8 := StaticText new.
    staticText9 := StaticText new.
    teesCombo := WideEnhancedComboBox new.
    typeDropdown := DropDownList new.

		"Font Definitions"
    segoeUI10 := Font new fromByteArray: #[
        243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 2 2 83 0 101 0 103 0 111 0 101 0 32 0 85 0 73 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ].
    segoeUI8 := Font new fromByteArray: #[
        245 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 2 2 83 0 101 0 103 0 111 0 101 0 32 0 85 0 73 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ].
    mainView
        owner: self;
        setName: 'mainView';
        alignRelativeToScreen;
        when: #maximized send: #winMaximized to: mainView;
        when: #minimized send: #winMinimized to: mainView;
        when: #restored send: #winRestored to: mainView;
        addModalBorderStyle;
        labelWithoutPrefix: 'Round Edit';
        noSmalltalkMenuBar;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 1 / 2 / ((SysFont width roundTo: 2) / 4);
                 leftInset: -119 * xDU;
                 topRatio: 1 / 2 / (SysFont height / 8);
                 topInset: -144 * yDU;
                 rightRatio: 1 / 2 / ((SysFont width roundTo: 2) / 4);
                 rightInset: -119 * xDU;
                 bottomRatio: 1 / 2 / (SysFont height / 8);
                 bottomInset: -144 * yDU).
    self addView: mainView.
    editButton "Button"
        owner: self;
        setName: 'editButton';
        when: #clicked send: #editButton to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 176 * xDU;
                 topRatio: 0;
                 topInset: 392 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -202 * xDU;
                 bottomRatio: 0;
                 bottomInset: -648 / 19 * yDU);
        contents: 'Edit';
        startGroup;
        noTabStop;
        font: segoeUI8.
    mainView addSubpane: editButton.
    courseCombo "WideEnhancedComboBox"
        owner: self;
        setName: 'courseCombo';
        when: #select send: #courseComboChanged to: self;
        when: #textChanged: send: #courseComboChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 864 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -136 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1088 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: courseCombo.
    typeDropdown "DropDownList"
        owner: self;
        setName: 'typeDropdown';
        when: #changed: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 3488 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -138 * xDU;
                 bottomRatio: 0;
                 bottomInset: -3744 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10;
        contents: #( 'H' 'A' 'C' ).
    mainView addSubpane: typeDropdown.
    staticText1
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 44 * xDU;
                 topRatio: 0;
                 topInset: 480 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -640 / 19 * yDU);
        contents: 'Date:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText1.
    staticText2
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 36 * xDU;
                 topRatio: 0;
                 topInset: 888 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1048 / 19 * yDU);
        contents: 'Course:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText2.
    staticText3
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 44 * xDU;
                 topRatio: 0;
                 topInset: 1336 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1496 / 19 * yDU);
        contents: 'Tees:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText3.
    staticText4
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 40 * xDU;
                 topRatio: 0;
                 topInset: 1752 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -68 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1912 / 19 * yDU);
        contents: 'Rating:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText4.
    staticText5
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 40 * xDU;
                 topRatio: 0;
                 topInset: 2200 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2360 / 19 * yDU);
        contents: 'Slope:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText5.
    staticText6
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 48 * xDU;
                 topRatio: 0;
                 topInset: 2648 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2808 / 19 * yDU);
        contents: 'Par:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText6.
    staticText7
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 40 * xDU;
                 topRatio: 0;
                 topInset: 3096 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -3256 / 19 * yDU);
        contents: 'Score:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText7.
    staticText8
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 44 * xDU;
                 topRatio: 0;
                 topInset: 3512 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -3672 / 19 * yDU);
        contents: 'Type:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText8.
    staticText9
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 46 * xDU;
                 topRatio: 0;
                 topInset: 3960 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -4120 / 19 * yDU);
        contents: 'PCC:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText9.
    staticText10
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 42 * xDU;
                 topRatio: 0;
                 topInset: 232 * yDU;
                 rightRatio: 0;
                 rightInset: -66 * xDU;
                 bottomRatio: 0;
                 bottomInset: -4568 / 19 * yDU);
        contents: 'Differ:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText10.
    dateField "EnhancedEntryField"
        owner: self;
        setName: 'dateField';
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 416 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -640 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: dateField.
    ratingField "EnhancedEntryField"
        owner: self;
        setName: 'ratingField';
        when: #textChanged: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 1728 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1952 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: ratingField.
    slopeField "EnhancedEntryField"
        owner: self;
        setName: 'slopeField';
        when: #textChanged: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 2176 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2400 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: slopeField.
    parField "EnhancedEntryField"
        owner: self;
        setName: 'parField';
        when: #textChanged: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 2624 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2848 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: parField.
    scoreField "EnhancedEntryField"
        owner: self;
        setName: 'scoreField';
        when: #textChanged: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 3072 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -3296 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: scoreField.
    pccField "EnhancedEntryField"
        owner: self;
        setName: 'pccField';
        when: #textChanged: send: #fieldChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 3936 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -4160 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: pccField.
    differField "EnhancedEntryField"
        owner: self;
        setName: 'differField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 4384 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -156 * xDU;
                 bottomRatio: 0;
                 bottomInset: -4608 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: differField.
    saveButton "Button"
        owner: self;
        setName: 'saveButton';
        when: #clicked send: #saveButtonClicked to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 62 * xDU;
                 topRatio: 0;
                 topInset: 4960 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -98 * xDU;
                 bottomRatio: 0;
                 bottomInset: -5216 / 19 * yDU);
        contents: 'Save';
        startGroup;
        noTabStop;
        font: segoeUI8.
    mainView addSubpane: saveButton.
    cancelButton "Button"
        owner: self;
        setName: 'cancelButton';
        when: #clicked send: #cancelButtonClicked to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 140 * xDU;
                 topRatio: 0;
                 topInset: 4960 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -176 * xDU;
                 bottomRatio: 0;
                 bottomInset: -5216 / 19 * yDU);
        cancelPushButton;
        contents: 'Cancel';
        startGroup;
        noTabStop;
        font: segoeUI8.
    mainView addSubpane: cancelButton.
    teesCombo "WideEnhancedComboBox"
        owner: self;
        setName: 'teesCombo';
        when: #select send: #teesComboChanged to: self;
        when: #textChanged: send: #teesComboChanged to: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 76 * xDU;
                 topRatio: 0;
                 topInset: 1296 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -136 * xDU;
                 bottomRatio: 0;
                 bottomInset: -80 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: teesCombo! !



!WorldHandicapRoundEditDialog methods !
 
editButton

    | selectedDate |
    #CodeTrackerBlock.  "Last Modified  09:25:19 07/24/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    selectedDate := CalendarDialog openOn: round date.
    selectedDate ifNotNil: [(self paneNamed: 'dateField') contents: selectedDate date.].! !



!WorldHandicapRoundEditDialog methods !
   
fieldChanged

								"Callback for the #changed: event in typeDropdown [DropDownList].
																(Generated by WindowBuilder Pro)"
    #CodeTrackerBlock.  "Last Modified  17:18:58 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round parTees: (self paneNamed: 'parField') contents asInteger.
    round rating: (self paneNamed: 'ratingField') contents asFloat.
    round slope: (self paneNamed: 'slopeField') contents asInteger.
    round score: (self paneNamed: 'scoreField') contents asInteger.
    (self paneNamed: 'differField') contents: (round roundDifferential ifNil: ['']).
    unsaved := true.! !



!WorldHandicapRoundEditDialog methods !
   
initWindow
    #CodeTrackerBlock.  "Last Modified  17:19:58 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    super initWindow.
    self populateCourseCombo.
    self populateTeesComboForCourse: round courseName.
    self populateFieldsFromRound.! !



!WorldHandicapRoundEditDialog methods !

isKnownCourse: aCourse
    #CodeTrackerBlock.  "Last Modified  13:44:29 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(self paneNamed: 'courseCombo') contents includes: aCourse! !



!WorldHandicapRoundEditDialog methods !

openOn: aRound player: aPlayer
    #CodeTrackerBlock.  "Last Modified  15:29:46 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round := aRound.
    player := aPlayer.
    self open.
    (round date isNil or: [round date = '']) "no date, a new round"
        ifTrue:[self populateFieldsForNewRound]
        ifFalse:[self populateFieldsFromRound].! !



!WorldHandicapRoundEditDialog methods !

player
    #CodeTrackerBlock.  "Last Modified  13:13:32 07/29/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^player! !



!WorldHandicapRoundEditDialog methods !
  
player: aValue
    #CodeTrackerBlock.  "Last Modified  13:13:32 07/29/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    player := aValue! !



!WorldHandicapRoundEditDialog methods !
 
populateCourseCombo

    | courses |
    #CodeTrackerBlock.  "Last Modified  20:23:43 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    courses := (round player database rounds collect: [:r | r courseName]) asSet asSortedCollection.
    (self paneNamed: 'courseCombo') contents: courses.
    (self paneNamed: 'courseCombo') selection: round courseName.! !



!WorldHandicapRoundEditDialog methods !
 
populateFieldsForNewRound

	 "date to today for a new round, then populate all UI fields."
    #CodeTrackerBlock.  "Last Modified  17:16:16 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round date: Date today asString.
    round assignDayOfWeek.
    self populateFieldsFromRound.
    self fieldChanged.! !



!WorldHandicapRoundEditDialog methods !
  
populateFieldsFromRound
    #CodeTrackerBlock.  "Last Modified  13:25:06 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self paneNamed: 'dateField') value: (round date ifNil: ['']).
    (self paneNamed: 'courseCombo') value: (round courseName ifNil: ['']).
    self populateTeesComboForCourse: (self paneNamed: 'courseCombo') value.
    (self paneNamed: 'teesCombo') value: (round tees ifNil: ['']).
    (self paneNamed: 'ratingField') value: (round rating ifNil: ['']).
    (self paneNamed: 'slopeField') value: (round slope ifNil: ['']).
    (self paneNamed: 'parField') value: (round parTees ifNil: ['']).
    (self paneNamed: 'scoreField') value: (round score ifNil: ['']).
    (self paneNamed: 'typeDropdown') value: (round roundType ifNil: ['']).
    (self paneNamed: 'pccField') value: (round pcc ifNil: ['']).
    (self paneNamed: 'differField') value: (round roundDifferential ifNil: ['']).! !



!WorldHandicapRoundEditDialog methods !

populateTeesComboForCourse: aCourse 

    | rounds sortedTees |
    #CodeTrackerBlock.  "Last Modified  15:28:08 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self isKnownCourse: aCourse)
        ifFalse:[
            self clearTeesCombo.
            self clearTeeDetailsFields.
            ^self].
    rounds := player database uniqueTeesForCourse: aCourse.
    sortedTees := self sortTeesByRating: rounds.
    (self paneNamed: 'teesCombo') contents: (sortedTees collect: [:r | r tees]).
    (self paneNamed: 'teesCombo') value: nil.! !



!WorldHandicapRoundEditDialog methods !

round
    #CodeTrackerBlock.  "Last Modified  09:22:33 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^round! !



!WorldHandicapRoundEditDialog methods !

round: aValue
    #CodeTrackerBlock.  "Last Modified  10:15:57 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round := aValue.
    self populateFieldsFromRound.! !



!WorldHandicapRoundEditDialog methods !
   
saveButtonClicked

		 "Callback for the #clicked event in saveButton [Button].
					(Generated by WindowBuilder Pro)"
    #CodeTrackerBlock.  "Last Modified  19:50:01 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    round date: (self paneNamed: 'dateField') value asString.
    round courseName: (self paneNamed: 'courseCombo') value.
    round tees: (self paneNamed: 'teesCombo') value.
    round rating: (self paneNamed: 'ratingField') contents asFloat.
    round slope: (self paneNamed: 'slopeField') contents asInteger.
    round parTees: (self paneNamed: 'parField') contents asInteger.
    round score: (self paneNamed: 'scoreField') contents asInteger.
    round roundType: (self paneNamed: 'typeDropdown') value.
    round pcc: (self paneNamed: 'pccField') contents asInteger.
    saved := true.
    self close.! !



!WorldHandicapRoundEditDialog methods !

saved
    #CodeTrackerBlock.  "Last Modified  11:16:14 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^saved! !



!WorldHandicapRoundEditDialog methods !

saved: aValue
    #CodeTrackerBlock.  "Last Modified  11:16:14 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    saved := aValue! !



!WorldHandicapRoundEditDialog methods !
   
showTeeDetailsFrom: aRound
    #CodeTrackerBlock.  "Last Modified  18:21:48 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self paneNamed: 'parField') value: aRound parTees asString.
    (self paneNamed: 'ratingField') value: aRound rating asString.
    (self paneNamed: 'slopeField') value: aRound slope asString.
    self fieldChanged.! !



!WorldHandicapRoundEditDialog methods !
 
sortTeesByRating: rounds
    #CodeTrackerBlock.  "Last Modified  13:45:23 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^rounds asSortedCollection: [:a :b |
        (a rating isNil and: [b rating notNil])
            ifTrue:[false]
            ifFalse:[
                (a rating notNil and: [b rating isNil])
                    ifTrue:[true]
                    ifFalse:[a rating < b rating]]].! !



!WorldHandicapRoundEditDialog methods !
   
teesComboChanged

"Callback for the #changed: event in teesCombo [WideEnhancedComboBox]. (Generated by WindowBuilder Pro)"

"Callback for #textCahnged: event"
    | mostRecentRound selectedCourse selectedTee teeList |
    #CodeTrackerBlock.  "Last Modified  15:43:54 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    selectedCourse := (self paneNamed: 'courseCombo') value.
    selectedTee := (self paneNamed: 'teesCombo') value.
    teeList := (self paneNamed: 'teesCombo') contents.

	 "user typed a tee,	clear details."
    (selectedTee isNil | selectedTee isEmpty | (teeList includes: selectedTee) not)
        ifTrue:[^self clearTeeDetailsFields].
    mostRecentRound := player database mostRecentRoundForCourse: selectedCourse tee: selectedTee player: player.
    mostRecentRound isNil
        ifTrue:[self clearTeeDetailsFields]
        ifFalse:[self showTeeDetailsFrom: mostRecentRound].! !



!WorldHandicapRoundEditDialog methods !
   
unsaved
    #CodeTrackerBlock.  "Last Modified  11:18:45 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^unsaved! !



!WorldHandicapRoundEditDialog methods !

unsaved: aValue
    #CodeTrackerBlock.  "Last Modified  11:18:45 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved := aValue! !



!WorldHandicapRoundEditDialog methods !
   
views
    #CodeTrackerBlock.  "Last Modified  09:22:33 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^views! !



!WorldHandicapRoundEditDialog methods !

views: aValue
    #CodeTrackerBlock.  "Last Modified  09:22:33 07/24/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    views := aValue! !



!WorldHandicapRoundEditDialog methods !
   
warningMessage
    #CodeTrackerBlock.  "Last Modified  14:51:34 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^MessageBox confirmWithCancel: 'You have unsaved changes. Are you sure you want to cancel?'! !



!WorldHandicapRoundEditDialog methods !

wasSaved
    #CodeTrackerBlock.  "Last Modified  19:43:53 07/26/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^saved! !



!WorldHandicapSystemUI class methods !

includeClass

		"This method informs CodeTracker what tracks this class belongs to."
    #CodeTrackerBlock.  "Last Modified  10:29:44 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^true! !



!WorldHandicapSystemUI class methods !
   
wbBasicVersion

	"Private - Answer the WindowBuilder Pro version.
		Generated in: Visual Smalltalk 3.1.0 Win32"
    #CodeTrackerBlock.  "Last Modified  14:39:13 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^3.11! !



!WorldHandicapSystemUI methods !
 
aboutGhin

	"Callback for the menu item titled 'About GHIN'.
	 (Generated by WindowBuilder)"
    #CodeTrackerBlock.  "Last Modified  14:28:15 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    MessageBox message: 'World Handicap System
Version 1.0 © 2025, Kambria Rogalski'! !



!WorldHandicapSystemUI methods !

createMenus: aPane 

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."
    #CodeTrackerBlock.  "Last Modified  14:39:13 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    #generated.
    aPane menuWindow
         yourself;
         addMenu: (
            Menu new
                 title: 'File';
                 owner: self;
                 appendItem: 'Open...' selector: #fileOpen;
                 appendItem: 'Save...' selector: #fileSave;
                 appendItem: 'Exit...' selector: #fileExit);
         addMenu: (
            Menu new
                 title: 'Player';
                 owner: self;
                 appendItem: 'New Player...' selector: #newPlayer);
         addMenu: (
            Menu new
                 title: 'Round';
                 owner: self;
                 appendItem: 'New Round...' selector: #newRoundMenubar);
         addMenu: (
            Menu new
                 title: 'About';
                 owner: self;
                 appendItem: 'About GHIN' selector: #aboutGhin)! !



!WorldHandicapSystemUI methods !
  
createViews

	"WARNING!! This method was automatically generated by 
	WindowBuilder. Code you add here which does not conform to 
	the WindowBuilder API will probably be lost the next time 
	you save your layout definition."
    | courseGrid ghinNumberField handicapIndexField mainGrid mainView maxNextField maxThreeField maxTwoField playerNameField segoeUI10 segoeUI8 staticText1 staticText2 staticText3 staticText4 staticText5 staticText6 xDU yDU |
    #CodeTrackerBlock.  "Last Modified  14:39:13 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    #generated.
    xDU := (SysFont width + 1 roundTo: 2) / 4.
    yDU := SysFont height / 8.
    mainView := self topPaneClass new.

		"Temporary Variables"
    courseGrid := CPColumnarListBox new.
    ghinNumberField := EnhancedEntryField new.
    handicapIndexField := EnhancedEntryField new.
    mainGrid := CPColumnarListBox new.
    maxNextField := EnhancedEntryField new.
    maxThreeField := EnhancedEntryField new.
    maxTwoField := EnhancedEntryField new.
    playerNameField := EnhancedEntryField new.
    staticText1 := StaticText new.
    staticText2 := StaticText new.
    staticText3 := StaticText new.
    staticText4 := StaticText new.
    staticText5 := StaticText new.
    staticText6 := StaticText new.

		"Font Definitions"
    segoeUI10 := Font new fromByteArray: #[
        243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 2 2 83 0 101 0 103 0 111 0 101 0 32 0 85 0 73 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ].
    segoeUI8 := Font new fromByteArray: #[
        245 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 2 2 83 0 101 0 103 0 111 0 101 0 32 0 85 0 73 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ].
    mainView
        owner: self;
        setName: 'mainView';
        when: #maximized send: #winMaximized to: mainView;
        when: #minimized send: #winMinimized to: mainView;
        when: #restored send: #winRestored to: mainView;
        labelWithoutPrefix: 'World Champion System';
        noSmalltalkMenuBar;
        backColor: Color buttonFace;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 1 / 2;
                 leftInset: -386 * xDU;
                 topRatio: 1 / 2;
                 topInset: -3232 / 19 * yDU;
                 rightRatio: 1 / 2;
                 rightInset: -386 * xDU;
                 bottomRatio: 1 / 2;
                 bottomInset: -3232 / 19 * yDU).
    self addView: mainView.
    courseGrid "CPColumnarListBox"
        owner: self;
        setName: 'courseGrid';
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 484 * xDU;
                 topRatio: 0;
                 topInset: 3552 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -736 * xDU;
                 bottomRatio: 0;
                 bottomInset: -5312 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI8;
        headerColor: (
            RGBColor red: 255 green: 255 blue: 128);
        fields: (
            OrderedCollection new
                 addLast: (
                    CPCLBField new
                         header: 'Course';
                         selector: #courseName);
                 addLast: (
                    CPCLBField new
                         header: 'Tees';
                         justification: #center;
                         selector: #tees);
                 addLast: (
                    CPCLBField new
                         header: 'Par';
                         justification: #center;
                         selector: #parTees);
                 addLast: (
                    CPCLBField new
                         header: 'Rating';
                         justification: #center;
                         selector: #rating);
                 addLast: (
                    CPCLBField new
                         header: 'Slope';
                         justification: #center;
                         selector: #slope);
                 addLast: (
                    CPCLBField new
                         header: 'Strokes';
                         justification: #center;
                         selector: #strokes);
                 addLast: (
                    CPCLBField new
                         header: 'Index';
                         justification: #center;
                         selector: #index);
                 yourself).
    mainView addSubpane: courseGrid.
    mainGrid "CPColumnarListBox"
        owner: self;
        setName: 'mainGrid';
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 26 * xDU;
                 topRatio: 0;
                 topInset: 352 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -456 * xDU;
                 bottomRatio: 0;
                 bottomInset: -5312 / 19 * yDU);
        startGroup;
        noTabStop;
        receiveAllWindowMessages;
        setPopupMenu: (
            Menu new
                 title: '';
                 owner: self;
                 appendItem: 'Edit Round' selector: #editRound;
                 appendItem: 'New Round' selector: #newRound;
                 appendItem: 'New Round on Selected Course' selector: #newRoundOnCourse;
                 appendItem: 'Delete Round' selector: #deleteRound);
        font: segoeUI8;
        headerColor: (
            RGBColor red: 128 green: 255 blue: 128);
        colorMethod: #displayColor;
        fields: (
            OrderedCollection new
                 addLast: (
                    CPCLBField new
                         header: '#';
                         justification: #center;
                         selector: #roundNumber);
                 addLast: (
                    CPCLBField new
                         header: 'Date';
                         justification: #center;
                         selector: #date);
                 addLast: (
                    CPCLBField new
                         header: 'Day';
                         selector: #dayOfWeek);
                 addLast: (
                    CPCLBField new
                         header: 'Days';
                         justification: #center;
                         selector: #daysPassed);
                 addLast: (
                    CPCLBField new
                         header: 'Course';
                         selector: #courseName);
                 addLast: (
                    CPCLBField new
                         header: 'Tees';
                         justification: #center;
                         selector: #tees);
                 addLast: (
                    CPCLBField new
                         header: 'Rating';
                         justification: #center;
                         selector: #rating);
                 addLast: (
                    CPCLBField new
                         header: 'Slope';
                         justification: #center;
                         selector: #slope);
                 addLast: (
                    CPCLBField new
                         header: 'Par';
                         justification: #center;
                         selector: #parTees);
                 addLast: (
                    CPCLBField new
                         header: 'Score';
                         justification: #center;
                         selector: #score);
                 addLast: (
                    CPCLBField new
                         header: 'Type';
                         selector: #roundType);
                 addLast: (
                    CPCLBField new
                         header: 'PCC';
                         justification: #center;
                         selector: #pcc);
                 addLast: (
                    CPCLBField new
                         header: 'Differential';
                         justification: #center;
                         selector: #roundDifferential);
                 addLast: (
                    CPCLBField new
                         header: 'Used';
                         justification: #center;
                         selector: #usedIndicator);
                 yourself).
    mainView addSubpane: mainGrid.
    playerNameField "EnhancedEntryField"
        owner: self;
        setName: 'playerNameField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 384 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -32 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: playerNameField.
    ghinNumberField "EnhancedEntryField"
        owner: self;
        setName: 'ghinNumberField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 872 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1088 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: ghinNumberField.
    handicapIndexField "EnhancedEntryField"
        owner: self;
        setName: 'handicapIndexField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 1352 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1576 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: handicapIndexField.
    maxNextField "EnhancedEntryField"
        owner: self;
        setName: 'maxNextField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 1864 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2080 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: maxNextField.
    maxTwoField "EnhancedEntryField"
        owner: self;
        setName: 'maxTwoField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 2344 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2560 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: maxTwoField.
    maxThreeField "EnhancedEntryField"
        owner: self;
        setName: 'maxThreeField';
        readOnly;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 568 * xDU;
                 topRatio: 0;
                 topInset: 2848 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -654 * xDU;
                 bottomRatio: 0;
                 bottomInset: -3064 / 19 * yDU);
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: maxThreeField.
    staticText1
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 536 * xDU;
                 topRatio: 0;
                 topInset: 416 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -562 * xDU;
                 bottomRatio: 0;
                 bottomInset: -576 / 19 * yDU);
        contents: 'Name:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText1.
    staticText2
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 538 * xDU;
                 topRatio: 0;
                 topInset: 896 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -562 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1056 / 19 * yDU);
        contents: 'GHIN:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText2.
    staticText3
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 536 * xDU;
                 topRatio: 0;
                 topInset: 1376 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -562 * xDU;
                 bottomRatio: 0;
                 bottomInset: -1536 / 19 * yDU);
        contents: 'Index:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText3.
    staticText4
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 508 * xDU;
                 topRatio: 0;
                 topInset: 1888 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -566 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2048 / 19 * yDU);
        contents: 'Max After Next:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText4.
    staticText5
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 510 * xDU;
                 topRatio: 0;
                 topInset: 2368 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -566 * xDU;
                 bottomRatio: 0;
                 bottomInset: -2528 / 19 * yDU);
        contents: 'Max After Two:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText5.
    staticText6
        owner: self;
        framingBlock: (
            LayoutFrame new
                 leftRatio: 0;
                 leftInset: 504 * xDU;
                 topRatio: 0;
                 topInset: 2880 / 19 * yDU;
                 rightRatio: 0;
                 rightInset: -566 * xDU;
                 bottomRatio: 0;
                 bottomInset: -160 * yDU);
        contents: 'Max After Three:';
        startGroup;
        noTabStop;
        font: segoeUI10.
    mainView addSubpane: staticText6.
    self createMenus: mainView! !



!WorldHandicapSystemUI methods !
  
currentPlayer
    #CodeTrackerBlock.  "Last Modified  10:42:47 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^currentPlayer! !



!WorldHandicapSystemUI methods !
   
currentPlayer: aValue
    #CodeTrackerBlock.  "Last Modified  10:42:47 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    currentPlayer := aValue! !



!WorldHandicapSystemUI methods !
  
deleteRound

		"Callback for the menu item titled 'Delete Round'.
		 (Generated by WindowBuilder)"
    | selectedRound userConfirmed |
    #CodeTrackerBlock.  "Last Modified  16:07:23 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self ensurePlayerSelected)
        ifFalse:[^self].
    (self ensureRoundSelected)
        ifFalse:[^self].
    selectedRound := (self paneNamed: 'mainGrid') selectedItem.
    userConfirmed := MessageBox confirmWithCancel: 'Do you really want to delete the round of ' , selectedRound score asString , ' on ' , selectedRound date asString , '?'.
    userConfirmed
        ifTrue:[
            self currentPlayer database rounds remove: selectedRound.
            self updateAfterRoundsChanged.
            unsaved := true].! !



!WorldHandicapSystemUI methods !
 
editRound

	 "Callback for the menu item titled 'Edit Round'.
	 (Generated by WindowBuilder)"
    | dialog |
    #CodeTrackerBlock.  "Last Modified  15:59:58 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self ensurePlayerSelected)
        ifFalse:[^self].
    (self ensureRoundSelected)
        ifFalse:[^self].
    dialog := WorldHandicapRoundEditDialog new.
    dialog openOn: self selectedRound player: self currentPlayer.
    (dialog wasSaved)
        ifTrue:[
            self updateAfterRoundsChanged.
            unsaved := true].! !



!WorldHandicapSystemUI methods !
 
ensureCourseSelected

	"true if a course is selected, otherwise shows an alert."
    #CodeTrackerBlock.  "Last Modified  15:54:02 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self selectedCourse isNil or: [self selectedCourse isEmpty])
        ifTrue:[
            MessageBox message: 'You must select a course first.'.
            ^false].
    ^true! !



!WorldHandicapSystemUI methods !
  
ensurePlayerSelected
    #CodeTrackerBlock.  "Last Modified  15:51:12 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self currentPlayer isNil)
        ifTrue:[
            MessageBox message: 'You must create or load a player (.ghin file) first.'.
            ^false].
    ^true! !



!WorldHandicapSystemUI methods !
  
ensureRoundSelected
    #CodeTrackerBlock.  "Last Modified  16:01:28 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self selectedRound isNil)
        ifTrue:[
            MessageBox message: 'You must select/create a round first.'.
            ^false].
    ^true! !



!WorldHandicapSystemUI methods !
  
exitProgram
    #CodeTrackerBlock.  "Last Modified  14:03:17 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    self close.! !



!WorldHandicapSystemUI methods !
  
fileExit

	"Callback for the menu item titled 'Exit...'.
	 (Generated by WindowBuilder)"
    | userChoice |
    #CodeTrackerBlock.  "Last Modified  14:12:42 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved
        ifTrue:[
            userChoice := MessageBox confirmWithCancel: 'You have unsaved changes. Save before exiting?'.
            userChoice = true
                ifTrue:[
                    self fileSave.
                    self exitProgram]. "Yes"
            userChoice = false
                ifTrue:[self exitProgram]. "No"
            userChoice = nil
                ifTrue:[^self]. "Cancel"
            ]
        ifFalse:[self exitProgram].! !



!WorldHandicapSystemUI methods !
 
fileOpen

    | fileName db player |
    #CodeTrackerBlock.  "Last Modified  16:06:32 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    fileName := FileDialog getFilePrompt: 'Select a GHIN file' default: '*.ghin'.
    (fileName isNil or: [fileName isEmpty])
        ifTrue:[^self].
    db := WorldHandicapDatabase new.
    player := db loadFromGhinFile: fileName.
    self currentPlayer: player.
    player database: db.
    self initializeRoundsFor: db player: player.
    self refreshAllAfterPlayerAndRoundsLoaded: db player: player.
    unsaved := false.! !



!WorldHandicapSystemUI methods !

fileSave

	"Callback for the menu item titled 'Save...'.
	 (Generated by WindowBuilder)"
    | fileName dataDirectory |
    #CodeTrackerBlock.  "Last Modified  20:08:57 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    dataDirectory := 'C:\LabWare-8\Data\'. "Use your actual directory path here, with trailing backslash"
    fileName := dataDirectory , (self currentPlayer ghinNumber , '.ghin').
    self saveToFile: fileName.
    MessageBox message: 'File saved successfully'.
    unsaved := false.! !



!WorldHandicapSystemUI methods !
 
initializeRoundsFor: db player: player
    #CodeTrackerBlock.  "Last Modified  16:04:50 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    db rounds do: [:round |
        round player: player.
        round database: db.
        round assignDayOfWeek].! !



!WorldHandicapSystemUI methods !
  
initWindow
    #CodeTrackerBlock.  "Last Modified  13:13:09 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    super initWindow.! !



!WorldHandicapSystemUI methods !
 
newPlayer

    | dialog player |
    #CodeTrackerBlock.  "Last Modified  14:02:43 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    dialog := WorldHandicapNewPlayerDialog new.
    dialog openOn.
    dialog wasSaved
        ifTrue:[
            player := dialog newPlayer.
            self currentPlayer: player.
            self populatePlayerFields.
            unsaved := true].! !



!WorldHandicapSystemUI methods !
   
newRound

	 "Callback for the menu item titled 'New Round'.
	  (Generated by WindowBuilder)"
    #CodeTrackerBlock.  "Last Modified  15:52:18 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self ensurePlayerSelected)
        ifFalse:[^self].
    self openNewRoundEditorWith: nil tee: nil score: nil.! !



!WorldHandicapSystemUI methods !
 
newRoundMenubar

		  "Callback for the menu item titled 'New Round'.
											(Generated by WindowBuilder)"
    #CodeTrackerBlock.  "Last Modified  15:52:30 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self ensurePlayerSelected)
        ifFalse:[^self].
    self openNewRoundEditorWith: nil tee: nil score: nil.! !



!WorldHandicapSystemUI methods !

newRoundOnCourse

	"Callback for the menu item titled 'New Round on Selected Course'.
	 (Generated by WindowBuilder)"
    #CodeTrackerBlock.  "Last Modified  15:54:34 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    (self ensurePlayerSelected)
        ifFalse:[^self].
    (self ensureCourseSelected)
        ifFalse:[^self].
    self openNewRoundEditorWith: self selectedCourse tee: self selectedTee score: nil.! !



!WorldHandicapSystemUI methods !

openNewRoundEditorWith: aCourse tee: aTee score: aScore 

								"handles creating a new round from the grid or the menu bar, and can open a new round on a selected course with course, tee, and score"
    | player db newRound dialog |
    #CodeTrackerBlock.  "Last Modified  15:48:38 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    player := self currentPlayer.
    db := player database.
    newRound := WorldHandicapRound new.
    newRound player: player.
    newRound database: db.
    newRound date: Date today asString.
    aCourse isNil
        ifFalse:[newRound courseName: aCourse].
    aTee isNil
        ifFalse:[newRound tees: aTee].
    newRound score: (aScore ifNil: ['']).
    dialog := WorldHandicapRoundEditDialog new.
    dialog openOn: newRound player: player.
    dialog populateFieldsForNewRound.
    (dialog wasSaved)
        ifTrue:[
            newRound assignDayOfWeek.
            db rounds add: newRound.
            self updateAfterRoundsChanged.
            unsaved := true].! !



!WorldHandicapSystemUI methods !

populateCourseGridFromMainGrid

    | mainGridRounds seenCombos courseRows |
    #CodeTrackerBlock.  "Last Modified  15:36:20 07/22/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    mainGridRounds := (self paneNamed: 'mainGrid') contents.
    seenCombos := Set new.
    courseRows := OrderedCollection new.
    mainGridRounds do: [:round |
        | comboKey|comboKey := round courseName , '|' , round tees.
        (seenCombos includes: comboKey)
            ifFalse:[
                seenCombos add: comboKey.
                round player: self currentPlayer.
                courseRows add: round.].].
    (self paneNamed: 'courseGrid') contents: courseRows.! !



!WorldHandicapSystemUI methods !
 
populatePlayerFields

    | player |
    #CodeTrackerBlock.  "Last Modified  13:45:37 07/28/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    player := currentPlayer.
    (self paneNamed: 'playerNameField') value: player playerName.
    (self paneNamed: 'ghinNumberField') value: player ghinNumber.
    (self paneNamed: 'handicapIndexField') value: (
        player displayHandicapIndex: (player handicapIndexForRounds: player playerRecentTwentyRounds)).
    (self paneNamed: 'maxNextField') value: (player displayHandicapIndex: player maxAfterNext).
    (self paneNamed: 'maxTwoField') value: (player displayHandicapIndex: player maxAfterTwo).
    (self paneNamed: 'maxThreeField') value: (player displayHandicapIndex: player maxAfterThree).! !



!WorldHandicapSystemUI methods !
   
populateRoundsGrid

    | allRounds |
    #CodeTrackerBlock.  "Last Modified  13:18:02 07/21/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    allRounds := WorldHandicapDatabase new rounds.
    (self paneNamed: 'mainGrid') contents: allRounds.! !



!WorldHandicapSystemUI methods !

refreshAllAfterPlayerAndRoundsLoaded: db player: player 

	"Updates round numbers, days passed, used round rankings, and refreshes both the main and course grids and player info fields after loading a player and their rounds from file."
    #CodeTrackerBlock.  "Last Modified  16:06:07 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    db assignRoundNumber.
    db assignDaysPassed.
    player usedRoundsRanking.
    (self paneNamed: 'mainGrid') contents: db sortRoundsByDate.
    self populateCourseGridFromMainGrid.
    self populatePlayerFields.! !



!WorldHandicapSystemUI methods !
 
saveToFile: fileName 

    | fileStream player |
    #CodeTrackerBlock.  "Last Modified  16:54:30 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    player := self currentPlayer.
    fileStream := File newFile: fileName.
    fileStream
        nextPutAll: 'PlayerName=' , player playerName;
        cr.
    player database rounds do: [:round |
        fileStream
            nextPutAll: 'Date=' , (round date asString) , (Character tab asString) , 'Course=' , (
                round courseName asString) , (Character tab asString) , 'Tees=' , (round tees asString) , (Character tab asString) , 'Par=' , (
                round parTees asString) , (Character tab asString) , 'Rating=' , (round rating asString) , (Character tab asString) , 'Slope=' , (
                round slope asString) , (Character tab asString) , 'PCC=' , (round pcc asString) , (Character tab asString) , 'Score=' , (
                round score asString) , (Character tab asString) , 'Type=' , (round roundType asString);
            cr.].
    fileStream close.! !



!WorldHandicapSystemUI methods !
  
selectedCourse

    | selected |
    #CodeTrackerBlock.  "Last Modified  15:57:27 07/29/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    selected := (self paneNamed: 'mainGrid') selectedItem.
    selected isNil
        ifTrue:[^nil].
    ^selected courseName! !



!WorldHandicapSystemUI methods !
  
selectedRound
    #CodeTrackerBlock.  "Last Modified  15:11:33 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(self paneNamed: 'mainGrid') selectedItem.! !



!WorldHandicapSystemUI methods !

selectedTee
    #CodeTrackerBlock.  "Last Modified  15:10:45 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^(self paneNamed: 'mainGrid') selectedItem tees! !



!WorldHandicapSystemUI methods !
  
unsaved
    #CodeTrackerBlock.  "Last Modified  13:58:01 07/27/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^unsaved! !



!WorldHandicapSystemUI methods !
   
unsaved: aValue
    #CodeTrackerBlock.  "Last Modified  13:58:01 07/27/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    unsaved := aValue! !



!WorldHandicapSystemUI methods !
  
updateAfterRoundsChanged

    | db |
    #CodeTrackerBlock.  "Last Modified  13:59:45 07/27/25"
    #LabWare. "Owner"
    #?. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #?. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    db := currentPlayer database.
    db assignRoundNumber.
    db assignDaysPassed.
    currentPlayer usedRoundsRanking.
    (self paneNamed: 'mainGrid') contents: db sortRoundsByDate.
    self populateCourseGridFromMainGrid.
    self populatePlayerFields.
    unsaved := true.! !



!WorldHandicapSystemUI methods !
 
views
    #CodeTrackerBlock.  "Last Modified  10:42:47 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    ^views! !



!WorldHandicapSystemUI methods !
   
views: aValue
    #CodeTrackerBlock.  "Last Modified  10:42:47 07/21/25"
    #LabWare. "Owner"
    #LIMS. "Type"
    #?. "Project"
    #WorldHandicap. "Module"
    #?. "Unit"
    #SS5. "RevisedBy"
    #NotReviewed. "ReviewedBy"
    #None. "LabTrackId"
    #CodeTrackerBlockEnd.  "Copyright © 2025 LabWare Inc."

    views := aValue! !
