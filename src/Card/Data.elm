module Card.Data exposing
    ( ProgressTuple
    , asCsvString
    , decode
    , encode
    , toCsvData
    )

import Card exposing (Card, Progress(..))
import Csv.Encode exposing (Csv)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


decode : Decoder Card
decode =
    Decode.map5 Card
        (Decode.field "id"
            (Decode.string
                |> Decode.andThen (Decode.succeed << Card.idFromString)
            )
        )
        (Decode.field "back" Decode.string)
        (Decode.field "front" Decode.string)
        (Decode.field "progress" decodeProgressTuple)
        (Decode.field "reference" Decode.string)


decodeChildren : Decoder Card
decodeChildren =
    Decode.lazy (\_ -> decode)


encode : Card -> Encode.Value
encode card =
    Encode.object
        [ ( "id"
          , Encode.string <| Card.idToString card.id
          )
        , ( "back", Encode.string card.back )
        , ( "front", Encode.string card.front )
        , ( "progress", encodeProgress (progressToJson card.progress) )
        , ( "reference", Encode.string card.reference )
        ]


type alias ProgressTuple =
    ( String, Maybe Card )


progressToJson : Card.Progress -> ProgressTuple
progressToJson progress =
    case progress of
        NotStarted ->
            ( "NotStarted", Nothing )

        InProgress originalState ->
            ( "InProgress", Just originalState )

        Finished ->
            ( "Finished", Nothing )


encodeProgress : ProgressTuple -> Encode.Value
encodeProgress progressTuple =
    encodeTuple
        Encode.string
        (encodeNullable (Card.notStarted >> encode))
        progressTuple


encodeTuple :
    (a -> Encode.Value)
    -> (b -> Encode.Value)
    -> ( a, b )
    -> Encode.Value
encodeTuple enc1 enc2 ( val1, val2 ) =
    Encode.list identity [ enc1 val1, enc2 val2 ]


encodeNullable : (value -> Encode.Value) -> Maybe value -> Encode.Value
encodeNullable valueEncoder maybeValue =
    case maybeValue of
        Just value ->
            valueEncoder value

        Nothing ->
            Encode.null


progressFromJson : ProgressTuple -> Progress
progressFromJson str =
    case str of
        ( "NotStarted", _ ) ->
            NotStarted

        ( "InProgress", Just originalState ) ->
            InProgress originalState

        ( "Finished", _ ) ->
            Finished

        _ ->
            NotStarted


decodeProgressTuple : Decoder Progress
decodeProgressTuple =
    Decode.map2 Tuple.pair
        (Decode.index 0 Decode.string)
        (Decode.index 1 (Decode.maybe decodeChildren))
        |> Decode.andThen (Decode.succeed << progressFromJson)



-- Convert to/from CSV format


toCsvData : List Card -> Csv
toCsvData cards =
    Csv
        [ "front", "back", "title" ]
        (List.map toRow cards)


toRow : Card -> List String
toRow card =
    [ card.front
    , card.back
    , card.reference
    ]


asCsvString : List Card -> String
asCsvString cards =
    cards
        |> toCsvData
        |> Csv.Encode.toString
