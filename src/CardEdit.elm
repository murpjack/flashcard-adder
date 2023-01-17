module CardEdit exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Card exposing (Card, Part(..))
import Html exposing (Html)
import Html.Attributes as Attrs exposing (selected)
import Html.Events as Events
import Ports
import Route


type alias Model =
    { selected : Card
    , cards : List Card
    , navKey : Nav.Key
    }


type Msg
    = AddCardToList
    | DiscardSelected
    | EditCardPart Card Card.Part String
    | SaveDraft


init : Card -> List Card -> Nav.Key -> ( Model, Cmd Msg )
init card cards navKey =
    let
        existingCard =
            case card.progress of
                Card.InProgress _ ->
                    Card.inProgress card card

                _ ->
                    Card.inProgress card card
    in
    ( { selected = existingCard
      , cards = cards
      , navKey = navKey
      }
    , Ports.sendDataOutside (Ports.SetSelectedInStorage existingCard)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddCardToList ->
            let
                updatedCards =
                    Card.finished model.selected
                        |> Card.toList model.cards
            in
            ( { model
                | cards = updatedCards
              }
            , Cmd.batch
                [ Route.pushUrl Route.CardList model.navKey
                ]
            )

        SaveDraft ->
            ( { model
                | cards =
                    Card.toList model.cards model.selected
              }
            , Route.pushUrl Route.CardList model.navKey
            )

        DiscardSelected ->
            let
                revertSelected =
                    case model.selected.progress of
                        Card.InProgress original ->
                            Card.notStarted original

                        _ ->
                            -- This state should be impossible to reach
                            model.selected

                updatedCards card =
                    case card.progress of
                        Card.InProgress original ->
                            if noChanges card original then
                                Card.delete card model.cards

                            else
                                Card.toList model.cards revertSelected

                        _ ->
                            -- This should be an impossible state
                            model.cards
            in
            ( { model
                | selected = revertSelected
                , cards = updatedCards model.selected
              }
            , Cmd.batch
                [ Ports.sendDataOutside (Ports.SetCardsInStorage (updatedCards model.selected))
                , Ports.sendDataOutside Ports.ClearSelectedInStorage
                , Route.pushUrl Route.CardList model.navKey
                ]
            )

        EditCardPart selected part value ->
            let
                changed =
                    selected
                        |> Card.changePart part value

                newList =
                    Card.toList model.cards changed
            in
            ( { model
                | selected = changed
                , cards = newList
              }
            , Cmd.batch
                [ Ports.sendDataOutside
                    (Ports.SetSelectedInStorage changed)
                , Ports.sendDataOutside
                    (Ports.SetCardsInStorage newList)
                ]
            )


noChanges : Card -> Card -> Bool
noChanges card original =
    card /= original


view : Model -> Html Msg
view model =
    editCard model.selected


editCard : Card -> Html Msg
editCard card =
    Html.div
        []
        [ Html.h1 [ Attrs.class "govuk-heading-l" ] [ Html.text "Edit card" ]
        , Html.div [ Attrs.class "form" ]
            [ Html.div [ Attrs.class "govuk-form-group" ]
                [ Html.label
                    [ Attrs.class "govuk-label"
                    , Attrs.for Card.referenceFieldName
                    ]
                    [ Html.text "Ref:" ]
                , Html.input
                    [ Attrs.type_ "text"
                    , Attrs.class "govuk-input"
                    , Attrs.id Card.referenceFieldName
                    , Attrs.name Card.referenceFieldName
                    , Attrs.value card.reference
                    , Events.onInput (EditCardPart card Card.Reference)
                    ]
                    []
                ]
            , Html.div [ Attrs.class "govuk-form-group" ]
                [ Html.label
                    [ Attrs.class "govuk-label"
                    , Attrs.for Card.backFieldName
                    ]
                    [ Html.text "Back:" ]
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
                    [ Html.text "Front:" ]
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
                , Html.button
                    [ Attrs.class "govuk-link"
                    , Events.onClick DiscardSelected
                    ]
                    [ Html.text "Discard changes" ]
                ]
            ]
        ]
