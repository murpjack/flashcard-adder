module Card exposing
    ( Card
    , Id
    , Part(..)
    , allFinished
    , asCsvString
    , backFieldName
    , byId
    , changePart
    , create
    , decode
    , delete
    , edit
    , encode
    , frontFieldName
    , inProgress
    , partToFieldName
    , titleFieldName
    , toCsvData
    , toList
    )

import Csv.Encode exposing (Csv)
import Html
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import List.Extra as List
import Url


type Id
    = Id String


type Part
    = Back
    | Front
    | Title


type Progress
    = NotStarted
    | InProgress
    | Finished


type alias Card =
    { id : Id
    , back : String
    , front : String
    , progress : Progress
    , title : String
    }



-- Modify


create : String -> Card
create newId =
    Card (idFromString newId) "" "" NotStarted "My new card"


idFromString : String -> Id
idFromString str =
    Id str


idToString : Id -> String
idToString (Id id) =
    id


edit : Card -> Card
edit { id, back, front, progress, title } =
    Card id back front progress title



-- TODO: This should only ever remove one card


delete : Card -> List Card -> List Card
delete card cards =
    List.remove card cards


inProgress : Card -> Card
inProgress card =
    { card
        | progress = InProgress
    }



-- Find


allFinished : List Card -> List Card
allFinished =
    List.foldr
        (\card acc ->
            case card.progress of
                Finished ->
                    card :: acc

                _ ->
                    acc
        )
        []



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


partToFieldName : Part -> String
partToFieldName cardPart =
    case cardPart of
        Title ->
            "title"

        Back ->
            "back"

        Front ->
            "front"


titleFieldName : String
titleFieldName =
    partToFieldName Title


backFieldName : String
backFieldName =
    partToFieldName Back


frontFieldName : String
frontFieldName =
    partToFieldName Front


changePart : Part -> String -> Card -> Card
changePart part value card =
    case part of
        Title ->
            { card | title = value }

        Back ->
            { card | back = value }

        Front ->
            { card | front = value }



-- Data


decode : Decoder Card
decode =
    Decode.map5 Card
        (Decode.field "id"
            (Decode.string
                |> Decode.andThen (Decode.succeed << idFromString)
            )
        )
        (Decode.field "back" Decode.string)
        (Decode.field "front" Decode.string)
        (Decode.field "progress" Decode.string
            |> Decode.andThen (Decode.succeed << progressFromStr)
        )
        (Decode.field "title" Decode.string)


encode : Card -> Encode.Value
encode card =
    Encode.object
        [ ( "id"
          , Encode.string <| idToString card.id
          )
        , ( "back", Encode.string card.back )
        , ( "front", Encode.string card.front )
        , ( "progress", Encode.string (progressToStr card.progress) )
        , ( "title", Encode.string card.title )
        ]


progressFromStr : String -> Progress
progressFromStr str =
    case str of
        "NotStarted" ->
            NotStarted

        "InProgress" ->
            InProgress

        "Finished" ->
            Finished

        _ ->
            NotStarted


progressToStr : Progress -> String
progressToStr progress =
    case progress of
        NotStarted ->
            "NotStarted"

        InProgress ->
            "InProgress"

        Finished ->
            "Finished"



-- Convert to/from CSV format


toCsvData : List Card -> Csv
toCsvData cards =
    Csv
        [ "back", "front", "title" ]
        (List.map toRow cards)


toRow : Card -> List String
toRow card =
    [ card.back
    , card.front
    , card.title
    ]


asCsvString : List Card -> String
asCsvString cards =
    cards
        |> toCsvData
        |> Csv.Encode.toString
