module Tests exposing (..)

import Card exposing (Card)
import Expect
import Test exposing (..)


dummy1 : Card
dummy1 =
    Card.create "card1"
        |> (Card.changePart Card.Back "Back"
                >> Card.changePart Card.Front "Front"
                >> Card.changePart Card.Title "Title"
           )


dummy2 : Card
dummy2 =
    Card.create "card2"
        |> (Card.changePart Card.Back "Back"
                >> Card.changePart Card.Front "Front"
                >> Card.changePart Card.Title "Title"
           )


all : Test
all =
    describe "A Test Suite"
        [ test "A new card should be created in list." <|
            \_ ->
                let
                    newCard =
                        Card.create "newCard1"
                            |> (Card.changePart Card.Back "My back gives me trouble."
                                    >> Card.changePart Card.Front "My ____ gives me trouble."
                                    >> Card.changePart Card.Title "Title"
                               )

                    -- TODO: Fix the fact that both cards in this list have non-unique ids
                    initialCards =
                        [ dummy1, dummy2 ]
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards + 1) (List.length updatedList)
                    ]
                    (Card.toList newCard initialCards)
        , test "A card should should be editable given some details and a card id." <|
            \_ ->
                let
                    editedCard =
                        Card.edit
                            { id = dummy1.id
                            , back = "My back gives me trouble."
                            , front = "My ____ gives me trouble."
                            , title = "My title"
                            }

                    -- TODO: Fix the fact that both cards in this list have non-unique ids
                    initialCards =
                        [ dummy1, dummy2 ]

                    editedFromList =
                        Card.byId dummy1.id
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards) (List.length updatedList)
                    , \updatedList -> Expect.equal (editedFromList updatedList) (Just editedCard)
                    ]
                    (Card.toList editedCard initialCards)
        , test "A card should be deleted from cards list." <|
            \_ ->
                let
                    toDelete =
                        dummy1

                    -- TODO: Fix the fact that both cards in this list have non-unique ids
                    initialCards =
                        [ dummy1, dummy2 ]
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards - 1) (List.length updatedList)
                    ]
                    (Card.delete toDelete initialCards)
        ]
