module CardList exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Card exposing (Card)
import Card.Data as Card
import File.Download
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Ports
import Route


type alias Model =
    { cards : List Card
    , navKey : Nav.Key
    }


type Msg
    = CreateCardStart
    | DeleteCard Card
    | GoToEditPage Card.Id
    | ExportCsvFile


init : Maybe Card -> List Card -> Nav.Key -> ( Model, Cmd Msg )
init card cards navKey =
    ( { cards = cards
      , navKey = navKey
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateCardStart ->
            ( model
            , Ports.sendDataOutside Ports.AskForRandomId
            )

        DeleteCard selected ->
            let
                updatedCards =
                    Card.delete selected model.cards
            in
            ( { model
                | cards = updatedCards
              }
            , Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
            )

        GoToEditPage cardId ->
            ( model
            , Route.pushUrl (Route.CardEdit cardId) model.navKey
            )

        ExportCsvFile ->
            ( model
            , File.Download.string "cards.csv"
                "text/csv"
                (model.cards |> Card.asCsvString)
            )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [ Attrs.class "header" ]
            [ Html.h1 [ Attrs.class "govuk-heading-l" ]
                [ Html.text "Card list" ]
            ]
        , if List.isEmpty model.cards then
            Html.div [ Attrs.class "no-list" ]
                [ Html.p [ Attrs.class "govuk-body item__title" ]
                    [ Html.text "No cards have been created."
                    ]
                ]

          else
            Html.div [ Attrs.class "list" ]
                (model.cards
                    |> List.map
                        (\card ->
                            cardItemView card
                        )
                )
        , Html.div [ Attrs.class "footer" ]
            [ Html.div
                [ Attrs.class "govuk-button-group"
                ]
                [ Html.button
                    [ Events.onClick CreateCardStart
                    , Attrs.class "govuk-button"
                    , Attrs.attribute "data-module" "govuk-button"
                    ]
                    [ Html.text "Create card"
                    ]
                , Html.button
                    [ Attrs.class "govuk-button  govuk-button--secondary"
                    , Events.onClick ExportCsvFile
                    ]
                    [ Html.text "Export .csv file" ]
                ]
            ]
        ]


cardItemView : Card -> Html Msg
cardItemView card =
    let
        cardRef =
            case card.progress of
                Card.InProgress original ->
                    original.reference

                _ ->
                    card.reference
    in
    Html.div [ Attrs.class "list__item" ]
        [ Html.p [ Attrs.class "govuk-body item__title" ] [ Html.text cardRef ]
        , Html.div
            [ Attrs.classList
                [ ( "govuk-warning-text warning__content", True )
                , ( "warning-hidden", not (Card.isInProgress card) )
                ]
            ]
            [ Html.span
                [ Attrs.class "govuk-warning-text__icon"
                , Attrs.attribute "aria-hidden" "true"
                ]
                [ Html.text "!" ]
            , Html.strong [ Attrs.class "govuk-warning-text__text" ]
                [ Html.span [ Attrs.class "govuk-warning-text__assistive" ]
                    [ Html.text "Warning" ]
                , Html.text
                    "Draft"
                ]
            ]
        , Html.div [ Attrs.class "govuk-button-group" ]
            [ Html.button
                [ Attrs.class "govuk-button govuk-button--secondary"
                , Events.onClick (GoToEditPage card.id)
                ]
                [ Html.text "Edit" ]
            , Html.button
                [ Attrs.class "govuk-button govuk-button--warning"
                , Events.onClick (DeleteCard card)
                ]
                [ Html.text "Delete" ]
            ]
        ]
