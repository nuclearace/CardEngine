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

        this.state = {};
        this.state.turn = null;
        this.state.messages = [];
        this.state.hand = [];
        this.state.cardsToPlay = [];

        // Bind this
        this.playCards = this.playCards.bind(this);
        this.playCard = this.playCard.bind(this);
    }

    parseMessage(messageObject) {
        switch (messageObject['type']) {
        case 'turnStart':
            console.log('start turn');
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
            this.setState({turn: 'play', hand: turnObject['hand']});
            break;
        default:
            console.error(`unhandled turn ${JSON.stringify(turnObject)}`);
        }
    }

    playCard(cardNum) {
        this.setState(prevState => {
            const newPlay = prevState.cardsToPlay.slice();

            newPlay.push(cardNum);

            return {
                turn: 'play',
                hand: prevState.hand,
                cardsToPlay: newPlay
            }
        })
    }

    playCards() {
        this.ws.send(JSON.stringify({
            "play": this.state.cardsToPlay
        }))
    }

    render() {
        switch (this.state.turn) {
        case 'play':
            return (
                <div>
                    <PlayerHand hand={this.state.hand}
                                onPlay={this.playCard}
                                hide={this.state.cardsToPlay}/>
                    <button onClick={this.playCards}>Play selected cards</button>
                </div>
            );
        default:
            return <h2>'Waiting!'</h2>;
        }
    }
}

class PlayerHand extends Component {
    render() {
        this.onPlay = this.props.onPlay;

        return (
            <ul>
                {this.props.hand.map((card, i) => {
                    return <PlayerCard key={i}
                                       card={card}
                                       onPlay={() => this.playCard(i)}
                                       hide={this.props.hide.indexOf(i) !== -1} />;
                })}
            </ul>
        )
    }

    playCard(cardNum) {
        this.onPlay(cardNum);
    }
}

class PlayerCard extends Component {
    render() {
        const type = this.props.card.playType;

        return (
            <li>
                <span>
                    <button onClick={this.props.onPlay} disabled={this.props.hide}>Play</button>
                    Type {type}
                </span>
            </li>
        )
    }
}
