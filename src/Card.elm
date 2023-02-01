module Card exposing
    ( Card
    , Id
    , Part(..)
    , Progress(..)
    , backFieldName
    , byId
    , changePart
    , create
    , delete
    , edit
    , finished
    , frontFieldName
    , idFromString
    , idToString
    , inProgress
    , isEmpty
    , isInProgress
    , noChanges
    , notStarted
    , partToFieldName
    , referenceFieldName
    , toList
    )

import List.Extra as List


type Id
    = Id String



-- the card attached to InProgress is the initial value on start edit


type Progress
    = NotStarted
    | InProgress Card
    | Finished


type alias Card =
    { id : Id
    , back : String
    , front : String
    , progress : Progress
    , reference : String
    }



-- Modify


create : String -> Card
create newId =
    Card (idFromString newId) "" "" NotStarted newId


edit : Card -> Card
edit { id, back, front, progress, reference } =
    Card id back front progress reference


delete : Card -> List Card -> List Card
delete card cards =
    List.remove card cards


idFromString : String -> Id
idFromString str =
    Id str


idToString : Id -> String
idToString (Id id) =
    id


notStarted : Card -> Card
notStarted card =
    { card
        | progress = NotStarted
    }


inProgress : Card -> Card -> Card
inProgress original card =
    { card
        | progress = InProgress original
    }


finished : Card -> Card
finished card =
    { card
        | progress = Finished
    }



-- Find


isInProgress : Card -> Bool
isInProgress card =
    case card.progress of
        InProgress _ ->
            True

        _ ->
            False


noChanges : Card -> Card -> Bool
noChanges card original =
    card /= original


isEmpty : Card -> Bool
isEmpty card =
    card.front == "" && card.back == ""



-- Multi


toList : List Card -> Card -> List Card
toList cards card =
    case byId card.id cards of
        Just _ ->
            updateAtId card cards

        Nothing ->
            cards ++ [ card ]


byId : Id -> List Card -> Maybe Card
byId selectedId cards =
    cards
        |> List.find (\card -> card.id == selectedId)


updateAtId : Card -> List Card -> List Card
updateAtId updated =
    List.foldr
        (\card acc ->
            if card.id == updated.id then
                updated :: acc

            else
                card :: acc
        )
        []



-- Form


type Part
    = Back
    | Front
    | Reference


partToFieldName : Part -> String
partToFieldName cardPart =
    case cardPart of
        Reference ->
            "reference"

        Back ->
            "back"

        Front ->
            "front"


referenceFieldName : String
referenceFieldName =
    partToFieldName Reference


backFieldName : String
backFieldName =
    partToFieldName Back


frontFieldName : String
frontFieldName =
    partToFieldName Front


changePart : Part -> String -> Card -> Card
changePart part value card =
    case part of
        Reference ->
            { card | reference = value }

        Back ->
            { card | back = value }

        Front ->
            { card | front = value }
