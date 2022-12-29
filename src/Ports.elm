port module Ports exposing
    ( DataForElm(..)
    , DataForJs(..)
    , getDataFromOutside
    , sendDataOutside
    )

import Card exposing (Card)
import Json.Decode as Decode
import Json.Encode as Encode


type DataForJs
    = SetCardsInStorage (List Card)
    | SetSelectedInStorage Card
    | ClearSelectedInStorage
    | AskForRandomId


type DataForElm
    = GetCardsFromStorage (List Card)
    | GetRandomId String
    | GetSelectedFromStorage Card


type alias GenericPortData =
    { tag : String
    , data : Encode.Value
    }


getDataFromOutside : (Result String DataForElm -> msg) -> Sub msg
getDataFromOutside tagger =
    incomingData <|
        \outsideInfo ->
            case outsideInfo.tag of
                "GetRandomId" ->
                    outsideInfo.data
                        |> Decode.decodeValue Decode.string
                        |> Result.map GetRandomId
                        |> Result.mapError Decode.errorToString
                        |> tagger

                "GetCardsFromStorage" ->
                    outsideInfo.data
                        |> Decode.decodeValue (Decode.list Card.decode)
                        |> Result.map GetCardsFromStorage
                        |> Result.mapError Decode.errorToString
                        |> tagger

                "GetSelectedFromStorage" ->
                    outsideInfo.data
                        |> Decode.decodeValue Card.decode
                        |> Result.map GetSelectedFromStorage
                        |> Result.mapError Decode.errorToString
                        |> tagger

                _ ->
                    tagger (Err ("Unexpected data from js: {tag: \"" ++ outsideInfo.tag ++ "\", data: " ++ Encode.encode 0 outsideInfo.data ++ " }"))


sendDataOutside : DataForJs -> Cmd msg
sendDataOutside data =
    case data of
        AskForRandomId ->
            outgoingData
                { tag = "AskForRandomId"
                , data = Encode.null
                }

        SetCardsInStorage list ->
            outgoingData
                { tag = "SetCardsInStorage"
                , data = list |> Encode.list Card.encode
                }

        SetSelectedInStorage card ->
            outgoingData
                { tag = "SetSelectedInStorage"
                , data = Card.encode card
                }

        ClearSelectedInStorage ->
            outgoingData
                { tag = "ClearSelectedInStorage"
                , data = Encode.null
                }


port outgoingData : GenericPortData -> Cmd msg


port incomingData : (GenericPortData -> msg) -> Sub msg
