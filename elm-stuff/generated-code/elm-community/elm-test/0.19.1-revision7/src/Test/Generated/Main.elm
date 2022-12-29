module Test.Generated.Main exposing (main)

import Tests

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    Test.Runner.Node.run
        { runs = 100
        , report = ConsoleReport UseColor
        , seed = 323901880618903
        , processes = 8
        , globs =
            []
        , paths =
            [ "/home/jackmurphy/j/flashcard-adder/tests/Tests.elm"
            ]
        }
        [ ( "Tests"
          , [ Test.Runner.Node.check Tests.dummy1
            , Test.Runner.Node.check Tests.dummy2
            , Test.Runner.Node.check Tests.all
            ]
          )
        ]