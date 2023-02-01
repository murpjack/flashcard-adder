module Types exposing (Model, Msg(..), Page(..))

import Card exposing (Card)
import Ports


type alias Model =
    { cards : List Card
    , selected : Maybe Card

    --, navKey : Nav.Key
    , page : Page
    }


type Page
    = CardListPage
    | CardEditPage


type Msg
    = OnIncomingData (Result String Ports.DataForElm)
      -- List msgs
    | CreateCardStart
    | DeleteCard Card
    | GoToEditPage Card.Id
    | ExportCsvFile
      -- Edit msgs
    | AddCardToList
    | DiscardSelected
    | EditCardPart Card Card.Part String
    | SaveDraft
