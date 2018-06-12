import React, { Component } from 'react';
import { BuildersCallbacks, BuildersState } from './helpers';

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

        this.state = {gameState: new BuildersState(), id: ''};
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
        case 'gameState':
            this.setState((prevState) => {
               const newState = new BuildersState(prevState.gameState);

               newState.cardsInPlay = messageObject['interaction']['gameState']['cardsInPlay'];

               return {gameState: newState};
            });
            break;
        case 'gameStart':
            this.setState((prevState) => {
                return {gameState: prevState.gameState, id: messageObject['interaction']['gameState']['id']};
            })
            break;
        case 'gameOver':
            this.setState((prevState) => {
                const state = new BuildersState(prevState.gameState);

                state.winner = messageObject['interaction']['winners'][0];

                return {gameState: state};
            });
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
            this.setState((prevState) => {
                const state = new BuildersState(prevState.gameState);

                state.turn = 'play';
                state.hand = turnObject['hand'];

                return {gameState: state};
            });
            break;
        case 'discard':
            this.setState((prevState) => {
                const state = new BuildersState(prevState.gameState);

                state.turn = 'discard';
                state.hand = turnObject['hand'];

                return {gameState: state};
            });
            break;
        case 'draw':
            this.setState((prevState) => {
                const state = new BuildersState(prevState.gameState);

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
        return <BuildersGameView game={this.state.gameState}
                                 callbacks={new BuildersCallbacks(this)}
                                 id={this.state.id} />
    }
}

class BuildersGameView extends Component {
    render() {
        if (this.props.game.winner) {
            return <h2>{this.props.game.winner} has won!</h2>;
        }

        const turn = this.props.game.turn;
        const hand = this.props.game.hand;
        const callbacks = this.props.callbacks;

        switch (turn) {
        case 'play':
            return (
                <div>
                    <InPlay cardsInPlay={this.props.game.cardsInPlay[this.props.id]} />

                    Would you like to play something?
                    <PlayerHand hand={hand}
                                onPlay={callbacks.playCard}
                                hide={this.props.game.cardsToPlay} />
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
                {this.props.hand.map(card => {
                    const id = card['id'];

                    return <PlayerCard key={id}
                                       card={card}
                                       onPlay={() => this.props.onPlay(id)}
                                       hide={this.props.hide.indexOf(id) !== -1} />;
                })}
            </ul>
        )
    }
}

// TODO Merge this and PlayerHand?
class InPlay extends Component {
    render() {
        if (this.props.cardsInPlay === undefined || this.props.cardsInPlay.length === 0) {
            return '';
        }

        return (
            <div>
                Your cards in play:
                <ul>
                    {this.props.cardsInPlay.map((card, i) => {
                        return <PlayerCard key={i} card={card} />;
                    })}
                </ul>
            </div>
        );
    }
}

class PlayerCard extends Component {
    render() {
        const card = this.props.card;
        const type = this.props.card.playType;

        if (this.props.onPlay === undefined) {
            return (
                <li>
                    <span>
                        {PlayerCard.getInner(type, card)}
                    </span>
                </li>
            )
        } else {
            return (
                <li>
                    <span>
                        <button onClick={this.props.onPlay} disabled={this.props.hide}>
                            Select
                        </button>
                        {PlayerCard.getInner(type, card)}
                    </span>
                </li>
            );
        }
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
