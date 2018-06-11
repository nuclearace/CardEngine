import React, { Component } from 'react';

export class BuildersGame extends Component {
    constructor(props) {
        super(props);

        this.ws = new WebSocket('ws://localhost:8080/join');

        this.ws.addEventListener('open', () => {
            this.ws.send(JSON.stringify({'game': 'TheBuilders'}));
        });

        this.ws.addEventListener('message', event => {
            this.parseMessage(JSON.parse(event.data));
        });

        this.state = {gameState: new BuildersState()};
    }

    discardCard(cardNum) {
        this.setState(prevState => {
            const newState = new BuildersState(prevState.gameState);

            newState.cardsToDiscard.push(cardNum);

            return {gameState: newState};
        });
    }

    discardCards() {
        this.ws.send(JSON.stringify({
            'discard': this.state.gameState.cardsToDiscard
        }));
    }

    draw(type) {
        this.ws.send(JSON.stringify({
            'draw': type
        }));
    }

    parseMessage(messageObject) {
        switch (messageObject['type']) {
        case 'playError':
        case 'turnStart':
        case 'turnEnd':
            this.setState({gameState: new BuildersState()});
            break;
        case 'turn':
            this.parseTurn(messageObject['interaction']);
            break;
        default:
            console.log(`didn't handle ${JSON.stringify(messageObject)}`);
            break;
        }
    }

    parseTurn(turnObject) {
        switch (turnObject['phase']) {
        case 'play':
            this.setState(() => {
                const state = new BuildersState();

                state.turn = 'play';
                state.hand = turnObject['hand'];

                return {gameState: state};
            });
            break;
        case 'discard':
            this.setState(() => {
                const state = new BuildersState();

                state.turn = 'discard';
                state.hand = turnObject['hand'];

                return {gameState: state};
            });
            break;
        case 'draw':
            this.setState(() => {
                const state = new BuildersState();

                state.turn = 'draw';

                return {gameState: state};
            });
            break;
        default:
            console.error(`unhandled turn ${JSON.stringify(turnObject)}`);
        }
    }

    playCard(cardNum) {
        this.setState(prevState => {
            const newState = new BuildersState(prevState.gameState);

            newState.cardsToPlay.push(cardNum);

            return {gameState: newState};
        });
    }

    playCards() {
        this.ws.send(JSON.stringify({
            'play': this.state.gameState.cardsToPlay
        }));
    }

    render() {
        return <BuildersGameView game={this.state.gameState} callbacks={new BuilderCallbacks(this)}/>
    }
}

class BuildersGameView extends Component {
    render() {
        const turn = this.props.game.turn;
        const hand = this.props.game.hand;
        const callbacks = this.props.callbacks;

        switch (turn) {
            case 'play':
                return (
                    <div>
                        Would you like to play something?
                        <PlayerHand hand={hand}
                                    onPlay={callbacks.playCard}
                                    hide={this.props.game.cardsToPlay}/>
                        <button onClick={callbacks.playCards}>Play selected cards</button>
                    </div>
                );
            case 'discard':
                return (
                    <div>
                        Would you like to discard something?
                        <PlayerHand hand={hand}
                                    onPlay={callbacks.discardCard}
                                    hide={this.props.game.cardsToDiscard}/>
                        <button onClick={callbacks.discardCards}>Discard selected cards</button>
                    </div>
                );
            case 'draw':
                return (
                    <div>
                        What would you like to draw?
                        <ul>
                            {['worker', 'material', 'accident'].map(type => {
                                return (
                                    <li key={type}>
                                        <button onClick={() => callbacks.draw(type)}>Draw</button>
                                        {type.charAt(0).toUpperCase() + type.slice(1)}
                                    </li>
                                );
                            })}
                        </ul>
                    </div>
                );
            default:
                return <h2>Waiting!</h2>;
        }
    }
}

class PlayerHand extends Component {
    render() {
        return (
            <ul>
                {this.props.hand.map((card, i) => {
                    return <PlayerCard key={i}
                                       card={card}
                                       onPlay={() => this.props.onPlay(i)}
                                       hide={this.props.hide.indexOf(i) !== -1} />;
                })}
            </ul>
        )
    }
}

class PlayerCard extends Component {
    render() {
        const card = this.props.card;
        const type = this.props.card.playType;

        return (
            <li>
                <span>
                    <button onClick={this.props.onPlay} disabled={this.props.hide}>Select</button>
                    Type {PlayerCard.getInner(type, card)}
                </span>
            </li>
        )
    }

    static getInner(type, card) {
        switch (type) {
        case 'worker':
            return `Worker => Skill: ${card['skill']}, Skill level: ${card['skillLevel']}`;
        case 'material':
            return `Material => Block type ${card['blockType']}`;
        case 'accident':
            const accident = card['type'];

            if ('strike' in accident) {
                return `Accident => Effects: ${card['type']['strike']}`;
            }
        }
    }
}

class BuildersState {
    constructor(prev) {
        if (prev !== undefined) {
            // TODO Maybe use a lib like immutable?
            this.turn = prev.turn;
            this.hand = prev.hand.slice();
            this.cardsToPlay = prev.cardsToPlay.slice();
            this.cardsToDiscard = prev.cardsToDiscard.slice();
        } else {
            this.turn = null;
            this.hand = [];
            this.cardsToPlay = [];
            this.cardsToDiscard = [];
        }
    }
}

class BuilderCallbacks {
    constructor(game) {
        this.playCard = game.playCard.bind(game);
        this.playCards = game.playCards.bind(game);
        this.discardCard = game.discardCard.bind(game);
        this.discardCards = game.discardCards.bind(game);
        this.draw = game.draw.bind(game);
    }
}
