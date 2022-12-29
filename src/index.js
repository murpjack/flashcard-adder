import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';


const CARDS = "cards";
const SELECTED = "selected";

const flags = {
    [CARDS]: getCardsFromStorage(),
    [SELECTED]: getSelectedFromStorage()
}

var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags,
});

app.ports.outgoingData.subscribe(({ tag, data }) => {
    switch (tag) {
        case "AskForRandomId":
            app.ports.incomingData.send({
                tag: "GetRandomId",
                data: Date.now() + Math.floor(Math.random() * 10) + "",
            });
            break;
        case "GetCardsFromStorage":
            app.ports.incomingData.send({
                tag: "GetCardsFromStorage",
                data: getCardsFromStorage() 
            });
            break;
 
        case "SetCardsInStorage":
            setCardsInStorage(data);           
            break;
        
        case "SetSelectedInStorage":
            setSelectedInStorage(data);           
            break;
        
        case "ClearSelectedInStorage":
            clearSelectedInStorage(data);           
            break;

    }
});

function setCardsInStorage (cards) {
    localStorage.setItem(CARDS, JSON.stringify(cards));
}

function getCardsFromStorage () {
    const cards = localStorage.getItem(CARDS);
    return JSON.parse(cards);
}

function setSelectedInStorage (card) {
    localStorage.setItem(SELECTED, JSON.stringify(card));
}

function getSelectedFromStorage () {
    const selected = localStorage.getItem(SELECTED);
    return JSON.parse(selected);
}

function clearSelectedInStorage () {
    localStorage.removeItem(SELECTED);
}
// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
