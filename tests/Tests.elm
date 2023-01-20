module Tests exposing (..)

import Card exposing (Card)
import Expect
import Test exposing (..)


card1 : Card
card1 =
    Card.create "card1"
        |> (Card.changePart Card.Back "Back"
                >> Card.changePart Card.Front "Front"
                >> Card.changePart Card.Reference "card1"
           )


card2 : Card
card2 =
    Card.create "card2"
        |> (Card.changePart Card.Back "Back"
                >> Card.changePart Card.Front "Front"
                >> Card.changePart Card.Reference "card2"
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
                                    >> Card.changePart Card.Reference "Title"
                               )

                    initialCards =
                        [ card1, card2 ]
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards + 1) (List.length updatedList)
                    ]
                    (Card.toList initialCards newCard)
        , test "A card should should be editable given some details and a card id." <|
            \_ ->
                let
                    editedCard =
                        Card.inProgress card1 <|
                            Card.edit
                                { card1
                                    | back = "My back gives me trouble."
                                    , front = "My ____ gives me trouble."
                                }

                    initialCards =
                        [ card1, card2 ]

                    editedFromList =
                        Card.byId card1.id
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards) (List.length updatedList)
                    , \updatedList -> Expect.equal (editedFromList updatedList) (Just editedCard)
                    ]
                    (Card.toList initialCards editedCard)
        , test "A card should be deleted from cards list." <|
            \_ ->
                let
                    toDelete =
                        card1

                    initialCards =
                        [ card1, card2 ]
                in
                Expect.all
                    [ \updatedList -> Expect.equal (List.length initialCards - 1) (List.length updatedList)
                    ]
                    (Card.delete toDelete initialCards)
        ]
