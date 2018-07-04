export class BuildersState {
    constructor(prev) {
        if (prev !== undefined) {
            // TODO Maybe use a lib like immutable?
            this.turn = prev.turn;
            this.hand = prev.hand.slice();
            this.cardsToPlay = prev.cardsToPlay.slice();
            this.cardsToDiscard = prev.cardsToDiscard.slice();
            this.cardsInPlay = prev.cardsInPlay; // cardsInPlay is a immutable property, only the server can change it
            this.floorsBuilt = prev.floorsBuilt; // floorsBuilt is a immutable property, only the server can change it
            this.winner = prev.winner;
        } else {
            this.turn = null;
            this.hand = [];
            this.cardsToPlay = [];
            this.cardsToDiscard = [];
            this.cardsInPlay = {};
            this.floorsBuilt = {};
            this.winner = null;
        }
    }
}

export class BuildersCallbacks {
    constructor(game) {
        this.playCard = game.playCard.bind(game);
        this.playCards = game.playCards.bind(game);
        this.discardCard = game.discardCard.bind(game);
        this.discardCards = game.discardCards.bind(game);
        this.draw = game.draw.bind(game);
    }
}
