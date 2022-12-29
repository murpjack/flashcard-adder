module Main exposing (..)

import Browser
import Card exposing (Card)
import File.Download
import Flags exposing (Flags)
import Html exposing (Html, button)
import Html.Attributes as Attrs exposing (selected)
import Html.Events as Events
import Json.Decode as Decode
import Maybe.Extra as Maybe
import Ports



---- MODEL ----


type alias Model =
    { cards : List Card
    , selected : Maybe Card
    , cardsInProgress : List Card
    , mode : Mode
    }


type Mode
    = CardsList
    | CardEdit


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        f =
            Decode.decodeValue Flags.decode flags
                |> Result.withDefault Flags.default
    in
    ( { cards = f.cards
      , selected = f.selected
      , cardsInProgress =
            f.selected
                |> Maybe.map (\s -> [ s ])
                |> Maybe.withDefault []
      , mode = CardsList
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = OnIncomingData (Result String Ports.DataForElm)
    | GoToEditCard Card
    | SaveDraft
    | CreateCardStart
    | DeleteCard Card
    | DiscardSelected
    | EditCardPart Card Card.Part String
    | ExportCsvFile
    | AddCardToList
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddCardToList ->
            let
                updatedCards =
                    model.selected
                        |> Maybe.map (Card.toList model.cards)
                        |> Maybe.withDefault model.cards

                updatedCardsInProgress =
                    model.selected
                        |> Maybe.map
                            (\selected ->
                                Card.delete selected model.cardsInProgress
                            )
                        |> Maybe.withDefault model.cardsInProgress
            in
            ( { model
                | cards =
                    updatedCards
                , selected = Nothing
                , cardsInProgress = updatedCardsInProgress
                , mode = CardsList
              }
            , Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
            )

        SaveDraft ->
            ( { model
                | mode =
                    CardsList
                , cardsInProgress =
                    model.selected
                        |> Maybe.map (Card.toList model.cardsInProgress)
                        |> Maybe.withDefault model.cardsInProgress
                , cards =
                    model.selected
                        |> Maybe.map
                            (\selected ->
                                case Card.byId selected.id model.cards of
                                    Just _ ->
                                        model.cards

                                    Nothing ->
                                        Card.toList model.cards selected
                            )
                        |> Maybe.withDefault model.cards
                , selected = Nothing
              }
            , Cmd.none
            )

        GoToEditCard card ->
            ( { model
                | mode = CardEdit
                , cardsInProgress = Card.toList model.cardsInProgress card
                , selected = Just card
              }
            , Cmd.none
            )

        CreateCardStart ->
            ( model, Ports.sendDataOutside Ports.AskForRandomId )

        DeleteCard selected ->
            let
                updatedCards =
                    Card.delete selected model.cards

                updatedCardsInProgress =
                    Card.delete selected model.cardsInProgress
            in
            ( { model
                | cards = updatedCards
                , cardsInProgress = updatedCardsInProgress
              }
            , Ports.sendDataOutside (Ports.SetCardsInStorage updatedCards)
            )

        DiscardSelected ->
            let
                updatedCardsInProgress =
                    model.selected
                        |> Maybe.map
                            (\selected ->
                                Card.delete selected model.cardsInProgress
                            )
                        |> Maybe.withDefault model.cardsInProgress
            in
            ( { model
                | selected = Nothing
                , cardsInProgress = updatedCardsInProgress
                , mode = CardsList
              }
            , Ports.sendDataOutside Ports.ClearSelectedInStorage
            )

        EditCardPart selected part value ->
            let
                changed =
                    selected
                        |> Card.changePart part value
                        |> Card.inProgress
            in
            ( { model
                | selected = Just changed
                , cardsInProgress = Card.toList model.cardsInProgress changed
              }
            , Ports.sendDataOutside (Ports.SetSelectedInStorage changed)
            )

        ExportCsvFile ->
            -- TODO: add a meaningful name to downloaded file
            ( model
            , File.Download.string "cards.csv"
                "text/csv"
                (model.cards |> Card.asCsvString)
            )

        OnIncomingData (Ok (Ports.GetRandomId id)) ->
            ( { model
                | selected = Just (Card.create id)
                , cardsInProgress = Card.toList model.cardsInProgress (Card.create id)
                , mode = CardEdit
              }
            , Cmd.none
            )

        OnIncomingData _ ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div [ Attrs.id "app" ]
        (case model.mode of
            CardEdit ->
                model.selected
                    |> Maybe.andThen
                        (\selected ->
                            Card.byId selected.id model.cardsInProgress
                        )
                    |> Maybe.map cardEditView
                    |> Maybe.withDefault (cardsListView model)

            CardsList ->
                cardsListView model
        )


cardEditView : Card -> List (Html Msg)
cardEditView card =
    [ Html.h1 [ Attrs.class "govuk-heading-l" ] [ Html.text "Edit card" ]
    , Html.div [ Attrs.class "form" ]
        [ Html.div [ Attrs.class "govuk-form-group" ]
            [ Html.label
                [ Attrs.class "govuk-label"
                , Attrs.for Card.titleFieldName
                ]
                [ Html.text "Title" ]
            , Html.input
                [ Attrs.type_ "text"
                , Attrs.class "govuk-input"
                , Attrs.id Card.titleFieldName
                , Attrs.name Card.titleFieldName
                , Attrs.value card.title
                , Events.onInput (EditCardPart card Card.Title)
                ]
                []
            ]
        , Html.div [ Attrs.class "govuk-form-group" ]
            [ Html.label
                [ Attrs.class "govuk-label"
                , Attrs.for Card.backFieldName
                ]
                [ Html.text "Back" ]
            , Html.textarea
                [ Attrs.class "govuk-textarea"
                , Attrs.id Card.backFieldName
                , Attrs.name Card.backFieldName
                , Attrs.value card.back
                , Events.onInput (EditCardPart card Card.Back)
                ]
                []
            ]
        , Html.div [ Attrs.class "govuk-form-group" ]
            [ Html.label
                [ Attrs.class "govuk-label"
                , Attrs.for Card.frontFieldName
                ]
                [ Html.text "Front" ]
            , Html.textarea
                [ Attrs.class "govuk-textarea"
                , Attrs.id Card.frontFieldName
                , Attrs.name Card.frontFieldName
                , Attrs.value card.front
                , Events.onInput (EditCardPart card Card.Front)
                ]
                []
            ]
        , Html.div
            [ Attrs.class "govuk-button-group"
            ]
            [ Html.button
                [ Events.onClick AddCardToList
                , Attrs.class "govuk-button"
                , Attrs.attribute "data-module" "govuk-button"
                ]
                [ Html.text "Continue"
                ]
            , Html.button
                [ Attrs.class "govuk-button  govuk-button--secondary"
                , Events.onClick SaveDraft
                ]
                [ Html.text "Save as draft" ]
            , Html.a
                [ Attrs.class "govuk-link"
                , Attrs.href "#"
                , Events.onClick DiscardSelected
                ]
                [ Html.text "Discard changes" ]
            ]
        ]
    ]


cardsListView : Model -> List (Html Msg)
cardsListView model =
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
                        cardItemView card (Card.byId card.id model.cardsInProgress)
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


cardItemView : Card -> Maybe Card -> Html Msg
cardItemView card unsavedChanges =
    Html.div [ Attrs.class "list__item" ]
        [ Html.p [ Attrs.class "govuk-body item__title" ] [ Html.text card.title ]
        , Html.div
            [ Attrs.classList
                [ ( "govuk-warning-text warning__content", True )
                , ( "warning-hidden", Maybe.isNothing unsavedChanges )
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
                    "Card has unsaved changes"
                ]
            ]
        , Html.div [ Attrs.class "govuk-button-group" ]
            [ Html.button
                [ Attrs.class "govuk-button govuk-button--secondary"
                , Events.onClick
                    (GoToEditCard (Maybe.withDefault card unsavedChanges))
                ]
                [ Html.text "Edit" ]
            , Html.button
                [ Attrs.class "govuk-button govuk-button--warning"
                , Events.onClick (DeleteCard card)
                ]
                [ Html.text "Delete" ]
            ]
        ]



---- PROGRAM ----


main : Program Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.getDataFromOutside OnIncomingData ]
